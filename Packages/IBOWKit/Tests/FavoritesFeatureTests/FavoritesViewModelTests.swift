import Foundation
import Testing
import WeatherDomain
@testable import FavoritesFeature

private actor FakeFavorites: FavoritesRepository {
    private var stored: [ICAOCode]
    var failWrites = false
    private var holdFirstWrite = false
    private var gate: CheckedContinuation<Void, Never>?
    private(set) var started = 0
    private var inFlight = 0
    private(set) var maxConcurrent = 0

    init(_ initial: [ICAOCode] = []) { stored = initial }

    func favorites() async throws -> [ICAOCode] { stored }

    func setFavorite(_ code: ICAOCode, isFavorite: Bool) async throws {
        started += 1
        inFlight += 1
        maxConcurrent = max(maxConcurrent, inFlight)
        defer { inFlight -= 1 }
        if holdFirstWrite {
            holdFirstWrite = false
            await withCheckedContinuation { gate = $0 }
        }
        if failWrites { throw WeatherError.decoding }
        stored.removeAll { $0 == code }
        if isFavorite { stored.insert(code, at: 0) }
    }

    /// The next write suspends until `releaseHeldWrite()`; actor reentrancy lets a second one overlap it.
    func setHoldFirstWrite() { holdFirstWrite = true }
    func releaseHeldWrite() { gate?.resume(); gate = nil }

    func setFailWrites(_ value: Bool) { failWrites = value }
}

private func metar(_ code: String) -> Metar {
    Metar(station: ICAOCode(code)!, name: nil, observedAt: .distantPast, rawText: code,
          temperatureC: nil, dewpointC: nil, wind: nil, visibility: nil, altimeterHPa: nil, clouds: [],
          weather: nil, flightCategory: .vfr, latitude: nil, longitude: nil, elevationMeters: nil)
}

/// Polls (bounded) until the condition holds; returns whether it did.
@MainActor
private func waitUntil(_ condition: () async -> Bool) async -> Bool {
    for _ in 0..<50 {
        if await condition() { return true }
        try? await Task.sleep(for: .milliseconds(2))
    }
    return false
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

    @Test func secondWriteWaitsForTheFirstOne() async throws {
        let repo = FakeFavorites()
        await repo.setHoldFirstWrite()
        let sut = makeSUT(repo)

        let first = Task { await sut.toggle(lemd) }
        #expect(await waitUntil { await repo.started == 1 })       // first write is now suspended in the store
        let second = Task { await sut.toggle(lemd) }
        let overtook = await waitUntil { await repo.started == 2 } // must NOT happen while the first is held
        #expect(!overtook)

        await repo.releaseHeldWrite()
        await first.value
        await second.value

        #expect(await repo.started == 2)
        #expect(await repo.maxConcurrent == 1)
        #expect(try await repo.favorites().isEmpty)
    }
}
