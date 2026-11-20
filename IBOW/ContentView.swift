import DesignSystem
import DetailFeature
import SearchFeature
import SwiftUI
import WeatherDomain

/// App shell. `NavigationSplitView` collapses to a stack on compact width (iPhone, Duo outer display)
/// and shows both columns on regular width (Duo inner display, iPad) with no device-specific code.
struct ContentView: View {
    @State private var viewModel: SearchViewModel
    @State private var selection: ICAOCode?

    init(searchUseCase: SearchMetarsUseCase) {
        _viewModel = State(initialValue: SearchViewModel { query in
            try await searchUseCase(query: query)
        })
    }

    var body: some View {
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
