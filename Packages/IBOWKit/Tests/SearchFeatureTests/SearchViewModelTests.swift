import Foundation
import Testing
import WeatherDomain
@testable import SearchFeature

/// Search double whose calls only finish when the test says so.
private actor GatedSearch {
    private var waiters: [String: CheckedContinuation<[Metar], Error>] = [:]
    private(set) var started: [String] = []
    private(set) var cancelledAtCompletion: [String: Bool] = [:]

    func run(_ query: String) async throws -> [Metar] {
        started.append(query)
        let result = try await withCheckedThrowingContinuation { waiters[query] = $0 }
        cancelledAtCompletion[query] = Task.isCancelled
        return result
    }

    func finish(_ query: String, with metars: [Metar]) { waiters.removeValue(forKey: query)?.resume(returning: metars) }
    func fail(_ query: String, with error: Error) { waiters.removeValue(forKey: query)?.resume(throwing: error) }
}

private actor Recorder {
    private(set) var events: [String] = []
    func add(_ event: String) { events.append(event) }
}

private func metar(_ code: String) -> Metar {
    Metar(station: ICAOCode(code)!, name: nil, observedAt: .distantPast, rawText: code,
          temperatureC: nil, dewpointC: nil, wind: nil, visibility: nil, altimeterHPa: nil, clouds: [],
          weather: nil, flightCategory: .vfr, latitude: nil, longitude: nil, elevationMeters: nil)
}

/// Waits (bounded) until the condition holds; avoids fixed sleeps.
@MainActor
private func eventually(_ condition: () async -> Bool) async -> Bool {
    for _ in 0..<500 {
        if await condition() { return true }
        await Task.yield()
        try? await Task.sleep(for: .milliseconds(2))
    }
    return false
}

@MainActor
@Suite("SearchViewModel")
struct SearchViewModelTests {
    private func makeSUT(_ gate: GatedSearch) -> SearchViewModel {
        // No real debounce: tests control timing through the gate.
        SearchViewModel(debounce: .zero, sleep: { _ in }, search: { try await gate.run($0) })
    }

    @Test func emptyQueryIsIdleAndDoesNotSearch() async {
        let gate = GatedSearch()
        let sut = makeSUT(gate)

        sut.query = "LEMD"
        sut.query = "   "

        #expect(sut.state == .idle)
        try? await Task.sleep(for: .milliseconds(20))
        #expect(await gate.started.isEmpty)
    }

    @Test func showsResultsOfTheLatestQuery() async {
        let gate = GatedSearch()
        let sut = makeSUT(gate)

        sut.query = "LEMD"
        #expect(await eventually { await gate.started == ["LEMD"] })
        #expect(sut.state == .loading)

        await gate.finish("LEMD", with: [metar("LEMD")])
        #expect(await eventually { sut.state == .results([metar("LEMD")]) })
    }

    @Test func staleResponseNeverOverwritesNewerQuery() async {
        let gate = GatedSearch()
        let sut = makeSUT(gate)

        sut.query = "LEMD"
        #expect(await eventually { await gate.started.contains("LEMD") })
        sut.query = "LEBL"
        #expect(await eventually { await gate.started.contains("LEBL") })

        // New query finishes first, then the old one arrives late.
        await gate.finish("LEBL", with: [metar("LEBL")])
        #expect(await eventually { sut.state == .results([metar("LEBL")]) })
        await gate.finish("LEMD", with: [metar("LEMD")])
        try? await Task.sleep(for: .milliseconds(50))

        #expect(sut.state == .results([metar("LEBL")]))
    }

    @Test func newQueryCancelsTheInFlightTask() async {
        let gate = GatedSearch()
        let sut = makeSUT(gate)

        sut.query = "LEMD"
        #expect(await eventually { await gate.started.contains("LEMD") })
        sut.query = "LEBL"
        await gate.finish("LEMD", with: [])           // old request completes after being cancelled
        #expect(await eventually { await gate.cancelledAtCompletion["LEMD"] != nil })

        #expect(await gate.cancelledAtCompletion["LEMD"] == true)
        await gate.finish("LEBL", with: [])   // don't leak the second continuation
    }

    @Test func cancellationIsNotShownAsAnError() async {
        let gate = GatedSearch()
        let sut = makeSUT(gate)

        sut.query = "LEMD"
        #expect(await eventually { await gate.started.contains("LEMD") })
        await gate.fail("LEMD", with: CancellationError())
        try? await Task.sleep(for: .milliseconds(50))

        #expect(sut.state == .loading)   // untouched: no .failed
    }

    @Test func mapsErrorsToFailedState() async {
        let gate = GatedSearch()
        let sut = makeSUT(gate)

        sut.query = "LEMD"
        #expect(await eventually { await gate.started.contains("LEMD") })
        await gate.fail("LEMD", with: WeatherError.network)

        #expect(await eventually { sut.state == .failed(.network) })
    }

    @Test func emptyResultIsDistinctFromIdle() async {
        let gate = GatedSearch()
        let sut = makeSUT(gate)

        sut.query = "ZZZZ"
        #expect(await eventually { await gate.started.contains("ZZZZ") })
        await gate.finish("ZZZZ", with: [])

        #expect(await eventually { sut.state == .empty })
    }

    @Test func debounceDelaysTheRequest() async {
        // Sleep that never returns until cancelled: proves nothing is sent while "typing".
        let gate = GatedSearch()
        let sut = SearchViewModel(
            debounce: .seconds(60),
            sleep: { duration in try await Task.sleep(for: duration) },
            search: { try await gate.run($0) }
        )

        sut.query = "L"
        sut.query = "LE"
        sut.query = "LEMD"
        try? await Task.sleep(for: .milliseconds(50))

        #expect(await gate.started.isEmpty)
    }

    @Test func quickChipTogglesCodeInTheQuery() {
        let sut = SearchViewModel(debounce: .zero, sleep: { _ in }, search: { _ in [] })

        sut.toggle(code: "lemd")
        sut.toggle(code: "LEBL")
        #expect(sut.query == "LEMD, LEBL")
        #expect(sut.isSelected(code: "LEMD"))

        sut.toggle(code: "LEMD")
        #expect(sut.query == "LEBL")
        #expect(!sut.isSelected(code: "LEMD"))
    }

    @Test func partialCodeWhileTypingIsNotAnError() async {
        let gate = GatedSearch()
        let sut = makeSUT(gate)

        sut.query = "LEM"
        #expect(sut.state == .idle)
        sut.query = "LEMD, L"
        #expect(sut.state == .idle)

        await Task.yield()
        #expect(await gate.started.isEmpty)
    }

    @Test func completingTheCodeSearchesAfterAPartialOne() async {
        let gate = GatedSearch()
        let sut = makeSUT(gate)

        sut.query = "LEM"
        sut.query = "LEMD"

        #expect(await eventually { await gate.started == ["LEMD"] })
        await gate.finish("LEMD", with: [metar("LEMD")])
        #expect(await eventually { sut.state == .results([metar("LEMD")]) })
    }

    @Test func partialCodeLeavesALoadingStateBehind() async {
        let gate = GatedSearch()
        let sut = makeSUT(gate)

        sut.query = "LEMD"
        #expect(await eventually { await gate.started == ["LEMD"] })
        sut.query = "LEMD, L"          // the in-flight search is dropped; state must not stay `.loading`
        #expect(sut.state == .idle)
        await gate.finish("LEMD", with: [metar("LEMD")])
        await Task.yield()

        #expect(sut.state == .idle)
    }

    @Test func explicitSubmitReportsAnInvalidCode() async {
        let sut = SearchViewModel(debounce: .zero, sleep: { _ in }, search: { query in
            _ = try AirportQuery.parse(query)
            return []
        })

        sut.query = "LEM"
        sut.submit()

        #expect(await eventually { sut.state == .failed(.invalidCode("LEM")) })
    }

    @Test func refreshDropsTheCacheBeforeSearching() async {
        let recorder = Recorder()
        let sut = SearchViewModel(
            debounce: .seconds(60),    // the typing debounce never fires: only `refresh` searches
            sleep: { try await Task.sleep(for: $0) },
            invalidate: { await recorder.add("invalidate") },
            search: { _ in
                await recorder.add("search")
                return []
            }
        )

        sut.query = "LEMD"
        await sut.refresh()

        #expect(await recorder.events == ["invalidate", "search"])
        #expect(sut.state == .empty)
    }

    @Test func warnsWhenMoreCodesThanTheLimitAreTyped() {
        let sut = SearchViewModel(debounce: .seconds(60), sleep: { try await Task.sleep(for: $0) }, search: { _ in [] })
        let codes = (0..<AirportQuery.maxCodes + 1).map { "LE\(String(format: "%02d", $0))" }

        sut.query = codes.prefix(AirportQuery.maxCodes).joined(separator: ", ")
        #expect(!sut.exceedsCodeLimit)

        sut.query = codes.joined(separator: ", ")
        #expect(sut.exceedsCodeLimit)

        sut.query = (codes.prefix(AirportQuery.maxCodes) + codes.prefix(3)).joined(separator: ", ")   // repeats do not count
        #expect(!sut.exceedsCodeLimit)
    }
}
