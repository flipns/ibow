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
        List(selection: $selection) {
            header.favoriteRow()
            content
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background { AtmosphericBackground() }
        .refreshable { await viewModel.refreshMetars() }
        #if os(iOS)
        .toolbar(.hidden, for: .navigationBar)   // same custom header as the search screen
        #endif
        .task { await viewModel.load() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
            Text("Favoritos")
                .font(DS.Typography.headlineLarge)
                .foregroundStyle(DS.Color.onSurface)
                .accessibilityAddTraits(.isHeader)
            Text("Tus aeropuertos guardados")
                .font(DS.Typography.bodyMedium)
                .foregroundStyle(DS.Color.accentSoft)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, DS.Spacing.md)
    }

    @ViewBuilder private var content: some View {
        if viewModel.codes.isEmpty {
            // HIG: an empty section explains why it is empty instead of being hidden or disabled.
            message("star", "Sin favoritos", "Toca la estrella en el detalle de un aeropuerto para tenerlo aquí.")
                .favoriteRow()
        } else {
            switch viewModel.state {
            case .failed(let error) where viewModel.favoriteMetars.isEmpty:
                message("exclamationmark.triangle", "No se pudo cargar", Self.text(for: error)).favoriteRow()
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
    }

    private func message(_ icon: String, _ title: String, _ detail: String) -> some View {
        VStack(spacing: DS.Spacing.sm) {
            Image(systemName: icon).font(.largeTitle).foregroundStyle(DS.Color.accentSoft)
                .accessibilityHidden(true)
            Text(title).font(DS.Typography.headlineSmall).foregroundStyle(DS.Color.onSurface)
            Text(detail).font(DS.Typography.bodyMedium).foregroundStyle(DS.Color.accentSoft)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(DS.Spacing.lg)
        .accessibilityElement(children: .combine)
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
