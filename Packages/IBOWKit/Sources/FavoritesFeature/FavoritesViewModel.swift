import Foundation
import Observation
import WeatherDomain

/// Single source of truth for favorites: drives the star in the detail screen and the Favorites tab.
///
/// - Toggling is optimistic (the star flips immediately) and rolls back if persistence fails.
/// - `metars` keeps reports of airports un-favorited while the detail is still open,
///   so the screen doesn't vanish under the user; the list only shows current favorites.
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

    public typealias Fetch = @Sendable ([ICAOCode]) async throws -> [Metar]

    private let repository: any FavoritesRepository
    private let fetch: Fetch

    public init(repository: any FavoritesRepository, fetch: @escaping Fetch) {
        self.repository = repository
        self.fetch = fetch
    }

    /// Reports of the current favorites, in the order they were added (newest first).
    public var favoriteMetars: [Metar] { codes.compactMap { metars[$0] } }

    public func metar(for code: ICAOCode?) -> Metar? { code.flatMap { metars[$0] } }

    public func isFavorite(_ code: ICAOCode) -> Bool { codes.contains(code) }

    /// Loads persisted favorites, then their latest reports (served by the repository's TTL cache when fresh).
    public func load() async {
        do {
            codes = try await repository.favorites()
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
            // Leaving the tab cancels the task; keep whatever is shown.
        } catch let error as WeatherError {
            state = .failed(error)
        } catch {
            state = .failed(.network)
        }
    }

    /// Remembers a report seen elsewhere (search results) so a new favorite shows instantly.
    public func remember(_ metar: Metar) { metars[metar.station] = metar }

    public func toggle(_ code: ICAOCode) async {
        let wasFavorite = isFavorite(code)
        codes = wasFavorite ? codes.filter { $0 != code } : [code] + codes
        do {
            try await repository.setFavorite(code, isFavorite: !wasFavorite)
        } catch {
            codes = wasFavorite ? [code] + codes : codes.filter { $0 != code }   // roll back
        }
    }
}
