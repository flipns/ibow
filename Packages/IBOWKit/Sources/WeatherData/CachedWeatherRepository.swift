import Foundation
import WeatherDomain

public struct CachedWeatherRepository: WeatherRepository {
    public static let defaultTTL: TimeInterval = 3 * 60

    private let base: any WeatherRepository
    private let cache: TTLCache<String, [Metar]>

    public init(base: any WeatherRepository, cache: TTLCache<String, [Metar]>) {
        self.base = base
        self.cache = cache
    }

    public init(base: any WeatherRepository, ttl: TimeInterval = defaultTTL) {
        self.init(base: base, cache: TTLCache(ttl: ttl))
    }

    /// Forgets every cached response (used by the explicit "refresh" action).
    public func invalidate() async { await cache.removeAll() }

    public func metars(for codes: [ICAOCode]) async throws -> [Metar] {
        let key = codes.map(\.value).sorted().joined(separator: ",")
        if let hit = await cache.value(for: key) { return hit }

        let fresh = try await base.metars(for: codes)
        await cache.insert(fresh, for: key)
        return fresh
    }
}
