import DesignSystem
import SearchFeature
import SwiftUI
import WeatherData
import WeatherDomain

@main
struct IBOWApp: App {
    private let searchUseCase: SearchMetarsUseCase

    init() {
        FontRegistry.registerIfNeeded()

        // Composition root: the only place that knows concrete types of every layer.
        let remote = RemoteWeatherRepository()
        let cached = CachedWeatherRepository(base: remote)      // 3-minute in-memory TTL
        searchUseCase = SearchMetarsUseCase(repository: cached)
    }

    var body: some Scene {
        WindowGroup {
            ContentView(searchUseCase: searchUseCase)
                .preferredColorScheme(.dark)
        }
    }
}
