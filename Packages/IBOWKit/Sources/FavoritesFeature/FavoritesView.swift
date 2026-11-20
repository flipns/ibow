import DesignSystem
import SwiftUI
import WeatherDomain
import WeatherPresentation

/// Sidebar/root column of the Favorites tab (same selection pattern as the search screen).
public struct FavoritesView: View {
    private let viewModel: FavoritesViewModel
    @Binding private var selection: ICAOCode?

    public init(viewModel: FavoritesViewModel, selection: Binding<ICAOCode?>) {
        self.viewModel = viewModel
        self._selection = selection
    }

    public var body: some View {
        Group {
            if viewModel.codes.isEmpty {
                // HIG: an empty section explains why it is empty instead of being hidden or disabled.
                ContentUnavailableView {
                    Label("Sin favoritos", systemImage: "star")
                } description: {
                    Text("Toca la estrella en el detalle de un aeropuerto para tenerlo aquí.")
                }
                .foregroundStyle(DS.Color.onSurface)
            } else {
                list
            }
        }
        .background { AtmosphericBackground() }
        .navigationTitle("Favoritos")
        .task { await viewModel.load() }
    }

    private var list: some View {
        List(selection: $selection) {
            switch viewModel.state {
            case .failed(let error) where viewModel.favoriteMetars.isEmpty:
                Text(Self.text(for: error))
                    .font(DS.Typography.bodyMedium)
                    .foregroundStyle(DS.Color.accentSoft)
                    .favoriteRow()
            case .loading where viewModel.favoriteMetars.isEmpty:
                ProgressView().tint(DS.Color.primary)
                    .frame(maxWidth: .infinity).padding(DS.Spacing.lg)
                    .accessibilityLabel("Cargando")
                    .favoriteRow()
            default:
                ForEach(viewModel.favoriteMetars) { metar in
                    MetarRow(metar: metar, isSelected: selection == metar.id)
                        .favoriteRow()
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .refreshable { await viewModel.refreshMetars() }
    }

    static func text(for error: WeatherError) -> String {
        switch error {
        case .network: "Sin conexión. Desliza hacia abajo para reintentar."
        case .server(let code): "El servicio respondió con un error (\(code))."
        default: "No se pudieron cargar tus favoritos."
        }
    }
}

private extension View {
    func favoriteRow() -> some View {
        self
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: DS.Spacing.xs, leading: DS.Spacing.md,
                                      bottom: DS.Spacing.xs, trailing: DS.Spacing.md))
    }
}
