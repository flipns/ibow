import Foundation
import Testing
import WeatherDomain
@testable import WeatherData

private actor CountingRepository: WeatherRepository {
    private(set) var calls = 0
    private var generation = 0
    var failure: WeatherError?

    func setFailure(_ error: WeatherError?) { failure = error }

    func metars(for codes: [ICAOCode]) async throws -> [Metar] {
        calls += 1
        generation += 1
        if let failure { throw failure }
        return codes.map { code in
            Metar(station: code, name: "gen\(generation)", observedAt: .distantPast, rawText: "",
                  temperatureC: nil, dewpointC: nil, wind: nil, visibility: nil, altimeterHPa: nil,
                  clouds: [], weather: nil, flightCategory: .vfr, latitude: nil, longitude: nil,
                  elevationMeters: nil)
        }
    }
}

@Suite("CachedWeatherRepository")
struct CachedWeatherRepositoryTests {
    private func makeSUT(clock: ManualClock) -> (CachedWeatherRepository, CountingRepository) {
        let base = CountingRepository()
        let cache = TTLCache<String, [Metar]>(ttl: 180, now: { clock.now })
        return (CachedWeatherRepository(base: base, cache: cache), base)
    }

    private let madrid = [ICAOCode("LEMD")!]

    @Test func validCachedResultSkipsTheNetwork() async throws {
        let clock = ManualClock()
        let (sut, base) = makeSUT(clock: clock)

        _ = try await sut.metars(for: madrid)
        clock.advance(by: 60)
        _ = try await sut.metars(for: madrid)

        #expect(await base.calls == 1)
    }

    @Test func expiredEntryIsRefetchedAndReplaced() async throws {
        let clock = ManualClock()
        let (sut, base) = makeSUT(clock: clock)

        let first = try await sut.metars(for: madrid)
        clock.advance(by: 181)
        let second = try await sut.metars(for: madrid)
        let third = try await sut.metars(for: madrid)   // served from the refreshed entry

        #expect(await base.calls == 2)
        #expect(first.first?.name == "gen1")
        #expect(second.first?.name == "gen2")
        #expect(third == second)
    }

    @Test func cacheKeyIgnoresOrderButNotContent() async throws {
        let clock = ManualClock()
        let (sut, base) = makeSUT(clock: clock)
        let a = [ICAOCode("LEMD")!, ICAOCode("LEBL")!]

        _ = try await sut.metars(for: a)
        _ = try await sut.metars(for: a.reversed())          // same query → hit
        _ = try await sut.metars(for: [ICAOCode("LEPA")!])   // different query → miss

        #expect(await base.calls == 2)
    }

    @Test func failuresAreNotCached() async throws {
        let clock = ManualClock()
        let (sut, base) = makeSUT(clock: clock)

        await base.setFailure(.network)
        await #expect(throws: WeatherError.network) { try await sut.metars(for: madrid) }

        await base.setFailure(nil)
        _ = try await sut.metars(for: madrid)

        #expect(await base.calls == 2)
    }
}
