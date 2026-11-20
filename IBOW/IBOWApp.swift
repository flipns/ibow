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

    init() {
        FontRegistry.registerIfNeeded()

        // Composition root: the only place that knows concrete types of every layer.
        let remote = RemoteWeatherRepository()
        let cached = CachedWeatherRepository(base: remote)      // 3-minute in-memory TTL
        searchUseCase = SearchMetarsUseCase(repository: cached)

        // Favorites persist in SwiftData; if the store can't open, fall back to memory instead of crashing.
        let store = (try? SwiftDataFavoritesRepository.make())
            ?? (try! SwiftDataFavoritesRepository.make(inMemory: true))
        favorites = FavoritesViewModel(repository: store) { codes in try await cached.metars(for: codes) }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(searchUseCase: searchUseCase, favorites: favorites)
                .preferredColorScheme(.dark)
        }
    }
}
