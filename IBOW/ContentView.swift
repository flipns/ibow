import DesignSystem
import DetailFeature
import FavoritesFeature
import SearchFeature
import SwiftUI
import WeatherDomain

struct ContentView: View {
    @State private var viewModel: SearchViewModel
    @State private var favorites: FavoritesViewModel
    @State private var selection: ICAOCode?
    @State private var favoritesSelection: ICAOCode?

    init(searchUseCase: SearchMetarsUseCase, favorites: FavoritesViewModel) {
        _favorites = State(initialValue: favorites)
        _viewModel = State(initialValue: SearchViewModel { query in
            try await searchUseCase(query: query)
        })
    }

    var body: some View {
        TabView {
            Tab("Buscar", systemImage: "magnifyingglass") { searchTab }
            Tab("Favoritos", systemImage: "star") { favoritesTab }
        }
        .tint(DS.Color.primary)
    }

    /// `NavigationSplitView` collapses to a stack on compact width (iPhone, Duo outer display)
    /// and shows both columns on regular width (Duo inner display, iPad) with no device-specific code.
    private var searchTab: some View {
        NavigationSplitView {
            SearchView(viewModel: viewModel, selection: $selection)
        } detail: {
            if let metar = viewModel.metar(for: selection) {
                detail(metar)
            } else {
                ContentUnavailableView("Selecciona un aeropuerto", systemImage: "airplane")
                    .background { AtmosphericBackground() }
            }
        }
    }

    private var favoritesTab: some View {
        NavigationSplitView {
            FavoritesView(viewModel: favorites, selection: $favoritesSelection)
        } detail: {
            if let metar = favorites.metar(for: favoritesSelection) {
                detail(metar)
            } else {
                ContentUnavailableView("Selecciona un favorito", systemImage: "star")
                    .background { AtmosphericBackground() }
            }
        }
    }

    private func detail(_ metar: Metar) -> some View {
        DetailView(
            metar: metar,
            isFavorite: favorites.isFavorite(metar.station),
            onToggleFavorite: {
                favorites.remember(metar)
                Task { await favorites.toggle(metar.station) }
            }
        )
        .id(metar.id)   // reset reader state when the selected airport changes
    }
}
