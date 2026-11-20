import DesignSystem
import SwiftUI
import WeatherDomain

public struct SearchView: View {
    @Bindable private var viewModel: SearchViewModel
    @Binding private var selection: Metar?

    public init(viewModel: SearchViewModel, selection: Binding<Metar?>) {
        self.viewModel = viewModel
        self._selection = selection
    }

    public var body: some View {
        ScrollView {
            LazyVStack(spacing: DS.Spacing.md) {
                searchField
                content
            }
            .padding(.horizontal, DS.Spacing.md)
            .padding(.bottom, DS.Spacing.xl)
        }
        .refreshable { viewModel.submit() }
        .background { AtmosphericBackground() }
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
    }

    @ViewBuilder private var content: some View {
        switch viewModel.state {
        case .idle:
            message("airplane", "Busca un aeropuerto", "Escribe uno o varios códigos ICAO, por ejemplo LEMD, LEBL.")
        case .loading:
            ProgressView().tint(DS.Color.primary).padding(.top, DS.Spacing.xl)
                .accessibilityLabel("Cargando")
        case .empty:
            message("questionmark.circle", "Sin resultados", "No hay METAR reciente para esos códigos.")
        case .failed(let error):
            message("exclamationmark.triangle", "No se pudo cargar", Self.text(for: error))
        case .results(let metars):
            ForEach(metars) { metar in
                Button { selection = metar } label: { MetarRow(metar: metar) }
                    .buttonStyle(.plain)
            }
        }
    }

    private func message(_ icon: String, _ title: String, _ detail: String) -> some View {
        VStack(spacing: DS.Spacing.sm) {
            Image(systemName: icon).font(.largeTitle).foregroundStyle(DS.Color.accentSoft)
            Text(title).font(DS.Typography.headlineSmall).foregroundStyle(DS.Color.onSurface)
            Text(detail).font(DS.Typography.bodyMedium).foregroundStyle(DS.Color.onSurfaceVariant)
                .multilineTextAlignment(.center)
        }
        .padding(.top, DS.Spacing.xl)
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
