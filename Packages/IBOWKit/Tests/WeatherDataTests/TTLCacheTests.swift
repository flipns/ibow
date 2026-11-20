import Foundation
import Synchronization
import Testing
@testable import WeatherData

final class ManualClock: Sendable {
    private let current = Mutex(Date(timeIntervalSince1970: 1_000))
    var now: Date { current.withLock { $0 } }
    func advance(by seconds: TimeInterval) { current.withLock { $0 = $0.addingTimeInterval(seconds) } }
}

@Suite("TTLCache")
struct TTLCacheTests {
    @Test func returnsValueBeforeExpiry() async {
        let clock = ManualClock()
        let cache = TTLCache<String, Int>(ttl: 180, now: { clock.now })

        await cache.insert(1, for: "a")
        clock.advance(by: 179)

        #expect(await cache.value(for: "a") == 1)
    }

    @Test func dropsValueAtAndAfterExpiry() async {
        let clock = ManualClock()
        let cache = TTLCache<String, Int>(ttl: 180, now: { clock.now })

        await cache.insert(1, for: "a")
        clock.advance(by: 180)

        #expect(await cache.value(for: "a") == nil)
    }

    @Test func insertingAgainRefreshesTheEntry() async {
        let clock = ManualClock()
        let cache = TTLCache<String, Int>(ttl: 180, now: { clock.now })

        await cache.insert(1, for: "a")
        clock.advance(by: 200)
        await cache.insert(2, for: "a")
        clock.advance(by: 100)

        #expect(await cache.value(for: "a") == 2)
    }

    @Test func keysAreIndependent() async {
        let cache = TTLCache<String, Int>(ttl: 180)
        await cache.insert(1, for: "a")
        #expect(await cache.value(for: "b") == nil)
    }
}
