import DesignSystem
import DetailFeature
import SearchFeature
import SwiftUI
import WeatherDomain

/// App shell: a tab bar whose first tab hosts the search/detail split view.
struct ContentView: View {
    @State private var viewModel: SearchViewModel
    @State private var selection: ICAOCode?

    init(searchUseCase: SearchMetarsUseCase) {
        _viewModel = State(initialValue: SearchViewModel { query in
            try await searchUseCase(query: query)
        })
    }

    var body: some View {
        TabView {
            Tab("Buscar", systemImage: "magnifyingglass") { searchTab }
            Tab("Favoritos", systemImage: "star") {
                PlaceholderTab(title: "Favoritos", systemImage: "star",
                               message: "Guarda aeropuertos desde su detalle para verlos aquí.")
            }
            Tab("Recientes", systemImage: "clock") {
                PlaceholderTab(title: "Recientes", systemImage: "clock",
                               message: "Tus últimas búsquedas aparecerán aquí.")
            }
            Tab("Ajustes", systemImage: "slider.horizontal.3") {
                PlaceholderTab(title: "Ajustes", systemImage: "slider.horizontal.3",
                               message: "Unidades y preferencias, próximamente.")
            }
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
                DetailView(metar: metar)
                    .id(metar.id)   // reset reader state when the selected airport changes
            } else {
                ContentUnavailableView("Selecciona un aeropuerto", systemImage: "airplane")
                    .background { AtmosphericBackground() }
            }
        }
    }
}
