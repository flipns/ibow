import Foundation
import Observation
import WeatherDomain

@Observable
public final class FavoritesViewModel {
    public enum State: Equatable {
        case loading
        case loaded
        case failed(WeatherError)
    }

    public private(set) var codes: [ICAOCode] = []
    public private(set) var state: State = .loading
    private var metars: [ICAOCode: Metar] = [:]
    private var lastWrite: Task<Void, Never>?

    public typealias Fetch = @Sendable ([ICAOCode]) async throws -> [Metar]

    private let repository: any FavoritesRepository
    private let fetch: Fetch

    public init(repository: any FavoritesRepository, fetch: @escaping Fetch) {
        self.repository = repository
        self.fetch = fetch
    }

    public var favoriteMetars: [Metar] { codes.compactMap { metars[$0] } }

    public func metar(for code: ICAOCode?) -> Metar? { code.flatMap { metars[$0] } }

    public func isFavorite(_ code: ICAOCode) -> Bool { codes.contains(code) }

    public func load() async {
        await lastWrite?.value
        do {
            codes = try await repository.favorites()
        } catch is CancellationError {
            return
        } catch {
            state = .failed(.decoding)
            return
        }
        await refreshMetars()
    }

    public func refreshMetars() async {
        guard !codes.isEmpty else { state = .loaded; return }
        if favoriteMetars.isEmpty { state = .loading }
        do {
            let fresh = try await fetch(codes)
            for metar in fresh { metars[metar.station] = metar }
            state = .loaded
        } catch is CancellationError {
        } catch let error as WeatherError {
            state = .failed(error)
        } catch {
            state = .failed(.network)
        }
    }

    public func remember(_ metar: Metar) { metars[metar.station] = metar }

    public func toggle(_ code: ICAOCode) async {
        let wasFavorite = isFavorite(code)
        codes = wasFavorite ? codes.filter { $0 != code } : [code] + codes

        let previous = lastWrite
        let write = Task {
            await previous?.value
            do {
                try await repository.setFavorite(code, isFavorite: !wasFavorite)
            } catch {
                codes = wasFavorite ? [code] + codes.filter { $0 != code } : codes.filter { $0 != code }   // roll back
            }
        }
        lastWrite = write
        await write.value
    }
}
