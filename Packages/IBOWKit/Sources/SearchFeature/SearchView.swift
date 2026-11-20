import DesignSystem
import SwiftUI
import WeatherDomain

/// Sidebar/root column of the app's `NavigationSplitView`.
/// Uses `List(selection:)` so that selection pushes the detail on compact width
/// (iPhone, Duo outer display) and shows it side by side on regular width (Duo inner display, iPad).
public struct SearchView: View {
    @Bindable private var viewModel: SearchViewModel
    @Binding private var selection: ICAOCode?

    public init(viewModel: SearchViewModel, selection: Binding<ICAOCode?>) {
        self.viewModel = viewModel
        self._selection = selection
    }

    public var body: some View {
        List(selection: $selection) {
            if case .results(let metars) = viewModel.state {
                ForEach(metars) { metar in
                    MetarRow(metar: metar, isSelected: selection == metar.id)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: DS.Spacing.xs, leading: DS.Spacing.md,
                                                  bottom: DS.Spacing.xs, trailing: DS.Spacing.md))
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background { AtmosphericBackground() }
        .overlay { stateOverlay }
        .safeAreaInset(edge: .top, spacing: DS.Spacing.sm) { searchField }
        .refreshable { await viewModel.refresh() }
        .navigationTitle("Buscar")
        #if os(iOS)
        .scrollDismissesKeyboard(.interactively)
        .navigationBarTitleDisplayMode(.large)
        #endif
    }

    private var searchField: some View {
        HStack(spacing: DS.Spacing.sm) {
            Image(systemName: "magnifyingglass").accessibilityHidden(true)
            TextField("ICAO: LEMD, LEBL…", text: $viewModel.query)
                #if os(iOS)
                .textInputAutocapitalization(.characters)
                #endif
                .autocorrectionDisabled()
                .submitLabel(.search)
                .onSubmit { viewModel.submit() }
                .accessibilityLabel("Códigos ICAO de aeropuertos")
                .accessibilityHint("Separa varios códigos con comas")
            if !viewModel.query.isEmpty {
                Button { viewModel.query = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .frame(minWidth: 44, minHeight: 44)
                }
                .accessibilityLabel("Borrar búsqueda")
            }
        }
        .font(DS.Typography.bodyMedium)
        .foregroundStyle(DS.Color.onSurface)
        .padding(.horizontal, DS.Spacing.md)
        .frame(minHeight: 52)
        .background(DS.Color.glass, in: Capsule())
        .overlay { Capsule().strokeBorder(DS.Color.borderGlass, lineWidth: 1) }
        .padding(.horizontal, DS.Spacing.md)
    }

    @ViewBuilder private var stateOverlay: some View {
        switch viewModel.state {
        case .idle:
            message("airplane", "Busca un aeropuerto", "Escribe uno o varios códigos ICAO, por ejemplo LEMD, LEBL.")
        case .loading:
            ProgressView().tint(DS.Color.primary)
                .accessibilityLabel("Cargando")
        case .empty:
            message("questionmark.circle", "Sin resultados", "No hay METAR reciente para esos códigos.")
        case .failed(let error):
            message("exclamationmark.triangle", "No se pudo cargar", LocalizedStringKey(Self.text(for: error)))
        case .results:
            EmptyView()
        }
    }

    private func message(_ icon: String, _ title: LocalizedStringKey, _ detail: LocalizedStringKey) -> some View {
        VStack(spacing: DS.Spacing.sm) {
            Image(systemName: icon).font(.largeTitle).foregroundStyle(DS.Color.accentSoft)
                .accessibilityHidden(true)
            Text(title).font(DS.Typography.headlineSmall).foregroundStyle(DS.Color.onSurface)
            Text(detail).font(DS.Typography.bodyMedium).foregroundStyle(DS.Color.onSurfaceVariant)
                .multilineTextAlignment(.center)
        }
        .padding(DS.Spacing.lg)
        .accessibilityElement(children: .combine)
    }

    static func text(for error: WeatherError) -> String {
        switch error {
        case .invalidCode(let raw): "«\(raw)» no es un código ICAO válido (4 caracteres)."
        case .network: "Sin conexión. Revisa tu red e inténtalo de nuevo."
        case .server(let code): "El servicio respondió con un error (\(code))."
        case .decoding: "La respuesta del servicio no se pudo leer."
        }
    }
}
