import DesignSystem
import FavoritesFeature
import SearchFeature
import SwiftUI
import WeatherData
import WeatherDomain

@main
struct IBOWApp: App {
    private let searchUseCase: SearchMetarsUseCase
    private let favorites: FavoritesViewModel
    private let cache: CachedWeatherRepository

    init() {
        FontRegistry.registerIfNeeded()

        let isUITesting = ProcessInfo.processInfo.arguments.contains("-ui-testing")
        let remote: any WeatherRepository = isUITesting ? FixtureWeatherRepository() : RemoteWeatherRepository()
        let cached = CachedWeatherRepository(base: remote)
        cache = cached
        searchUseCase = SearchMetarsUseCase(repository: cached)

        let store: any FavoritesRepository
        if isUITesting {
            store = InMemoryFavoritesRepository()
        } else if let persistent = try? SwiftDataFavoritesRepository.make() {
            store = persistent
        } else {
            store = InMemoryFavoritesRepository()
        }
        favorites = FavoritesViewModel(repository: store) { codes in try await cached.metars(for: codes) }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(searchUseCase: searchUseCase, favorites: favorites) { [cache] in
                await cache.invalidate()
            }
                .preferredColorScheme(.dark)
        }
    }
}
