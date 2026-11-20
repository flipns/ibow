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

        let remote = RemoteWeatherRepository()
        let cached = CachedWeatherRepository(base: remote)
        searchUseCase = SearchMetarsUseCase(repository: cached)

        let store: any FavoritesRepository
        do {
            store = try SwiftDataFavoritesRepository.make()
        } catch {
            store = InMemoryFavoritesRepository()
        }
        favorites = FavoritesViewModel(repository: store) { codes in try await cached.metars(for: codes) }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(searchUseCase: searchUseCase, favorites: favorites)
                .preferredColorScheme(.dark)
        }
    }
}
