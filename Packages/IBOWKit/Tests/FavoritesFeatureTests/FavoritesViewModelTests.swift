import Foundation
import Testing
import WeatherDomain
@testable import FavoritesFeature

private actor FakeFavorites: FavoritesRepository {
    private var stored: [ICAOCode]
    var failWrites = false

    init(_ initial: [ICAOCode] = []) { stored = initial }

    func favorites() async throws -> [ICAOCode] { stored }

    func setFavorite(_ code: ICAOCode, isFavorite: Bool) async throws {
        if failWrites { throw WeatherError.decoding }
        stored.removeAll { $0 == code }
        if isFavorite { stored.insert(code, at: 0) }
    }

    func setFailWrites(_ value: Bool) { failWrites = value }
}

private func metar(_ code: String) -> Metar {
    Metar(station: ICAOCode(code)!, name: nil, observedAt: .distantPast, rawText: code,
          temperatureC: nil, dewpointC: nil, wind: nil, visibility: nil, altimeterHPa: nil, clouds: [],
          weather: nil, flightCategory: .vfr, latitude: nil, longitude: nil, elevationMeters: nil)
}

@MainActor
@Suite("FavoritesViewModel")
struct FavoritesViewModelTests {
    private let lemd = ICAOCode("LEMD")!
    private let lebl = ICAOCode("LEBL")!

    private func makeSUT(_ repo: FakeFavorites, fetch: @escaping FavoritesViewModel.Fetch = { $0.map { metar($0.value) } })
        -> FavoritesViewModel {
        FavoritesViewModel(repository: repo, fetch: fetch)
    }

    @Test func loadShowsPersistedFavoritesInStoredOrder() async {
        let sut = makeSUT(FakeFavorites([lebl, lemd]))
        await sut.load()
        #expect(sut.favoriteMetars.map(\.station) == [lebl, lemd])
        #expect(sut.state == .loaded)
    }

    @Test func emptyFavoritesDoNotHitTheNetwork() async {
        let sut = makeSUT(FakeFavorites()) { _ in Issue.record("fetch must not run"); return [] }
        await sut.load()
        #expect(sut.codes.isEmpty)
        #expect(sut.state == .loaded)
    }

    @Test func toggleAddsAndPersists() async throws {
        let repo = FakeFavorites()
        let sut = makeSUT(repo)
        await sut.toggle(lemd)
        #expect(sut.isFavorite(lemd))
        #expect(try await repo.favorites() == [lemd])
    }

    @Test func toggleRemoves() async throws {
        let repo = FakeFavorites([lemd])
        let sut = makeSUT(repo)
        await sut.load()
        await sut.toggle(lemd)
        #expect(!sut.isFavorite(lemd))
        #expect(try await repo.favorites().isEmpty)
    }

    @Test func failedWriteRollsBack() async {
        let repo = FakeFavorites()
        await repo.setFailWrites(true)
        let sut = makeSUT(repo)
        await sut.toggle(lemd)
        #expect(!sut.isFavorite(lemd))
    }

    @Test func unfavoritedReportStaysResolvableForOpenDetail() async {
        let sut = makeSUT(FakeFavorites([lemd]))
        await sut.load()
        await sut.toggle(lemd)
        #expect(sut.favoriteMetars.isEmpty)
        #expect(sut.metar(for: lemd) != nil)
    }

    @Test func fetchFailureSurfacesError() async {
        let sut = makeSUT(FakeFavorites([lemd])) { _ in throw WeatherError.network }
        await sut.load()
        #expect(sut.state == .failed(.network))
    }

    @Test func rapidTogglesReachTheStoreInOrder() async throws {
        let repo = FakeFavorites()
        let sut = makeSUT(repo)
        // Fire without awaiting between taps, like a user double-tapping the star.
        async let first: Void = sut.toggle(lemd)
        async let second: Void = sut.toggle(lemd)
        _ = await (first, second)
        #expect(!sut.isFavorite(lemd))                 // on, then off
        #expect(try await repo.favorites().isEmpty)    // the store agrees with the UI
    }
}
