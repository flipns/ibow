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
            header.plainRow()
            searchField.plainRow()
            quickAirports.plainRow(horizontalInset: 0)

            if case .results(let metars) = viewModel.state {
                summary(metars).plainRow()
                ForEach(metars) { metar in
                    MetarRow(metar: metar, isSelected: selection == metar.id)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: DS.Spacing.xs, leading: DS.Spacing.md,
                                                  bottom: DS.Spacing.xs, trailing: DS.Spacing.md))
                }
            } else {
                stateMessage.plainRow()
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background { AtmosphericBackground() }
        .refreshable { await viewModel.refresh() }
        #if os(iOS)
        .scrollDismissesKeyboard(.interactively)
        .toolbar(.hidden, for: .navigationBar)
        #endif
    }

    // MARK: Header

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                Text("Aeropuertos")
                    .font(DS.Typography.headlineLarge)
                    .foregroundStyle(DS.Color.onSurface)
                    .accessibilityAddTraits(.isHeader)
                Text("Tiempo operativo · METAR")
                    .font(DS.Typography.bodyMedium)
                    .foregroundStyle(DS.Color.onSurfaceVariant)
            }
            Spacer(minLength: DS.Spacing.sm)
            Button {
                Task { await viewModel.refresh() }
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(DS.Typography.labelMedium)
                    .foregroundStyle(DS.Color.onSurface)
                    .frame(width: 44, height: 44)
                    .background(DS.Color.glass, in: Circle())
                    .overlay { Circle().strokeBorder(DS.Color.borderGlass, lineWidth: 1) }
            }
            .buttonStyle(.plain)
            .disabled(viewModel.query.trimmingCharacters(in: .whitespaces).isEmpty)
            .accessibilityLabel("Actualizar")
        }
        .padding(.top, DS.Spacing.md)
    }

    // MARK: Field + chips

    private var searchField: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            Text("Códigos OACI, separados por comas")
                .font(DS.Typography.bodySmall)
                .foregroundStyle(DS.Color.onSurfaceVariant)
            HStack(spacing: DS.Spacing.sm) {
                Image(systemName: "magnifyingglass").accessibilityHidden(true)
                TextField("LEMD, LEBL, LEPA", text: $viewModel.query)
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
                        Image(systemName: "xmark.circle.fill").frame(minWidth: 44, minHeight: 44)
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
    }

    private var quickAirports: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DS.Spacing.sm) {
                ForEach(QuickAirport.suggestions) { airport in
                    let isOn = viewModel.isSelected(code: airport.code)
                    Button { viewModel.toggle(code: airport.code) } label: {
                        HStack(spacing: DS.Spacing.xs) {
                            Text(airport.code).font(DS.Typography.labelMedium)
                            Text(airport.city).font(DS.Typography.bodyMedium)
                                .foregroundStyle(isOn ? DS.Color.onPrimary : DS.Color.onSurfaceVariant)
                        }
                        .foregroundStyle(isOn ? DS.Color.onPrimary : DS.Color.onSurface)
                        .padding(.horizontal, DS.Spacing.md)
                        .frame(minHeight: 44)
                        .background(isOn ? DS.Color.primary : DS.Color.glass, in: Capsule())
                        .overlay { Capsule().strokeBorder(isOn ? DS.Color.accentSoft : DS.Color.borderGlass, lineWidth: 1) }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(airport.city), \(airport.code)")
                    .accessibilityAddTraits(isOn ? .isSelected : [])
                }
            }
            .padding(.horizontal, DS.Spacing.md)
        }
    }

    private func summary(_ metars: [Metar]) -> some View {
        Text(metars.count == 1 ? "1 aeropuerto" : "\(metars.count) aeropuertos")
            .font(DS.Typography.bodySmall)
            .foregroundStyle(DS.Color.onSurfaceMuted)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: States

    @ViewBuilder private var stateMessage: some View {
        switch viewModel.state {
        case .idle:
            message("airplane", "Busca un aeropuerto", "Escribe uno o varios códigos ICAO o toca una sugerencia.")
        case .loading:
            ProgressView().tint(DS.Color.primary)
                .frame(maxWidth: .infinity).padding(DS.Spacing.lg)
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
        .frame(maxWidth: .infinity)
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

private extension View {
    /// Non-selectable, transparent list row for header/field/chips.
    func plainRow(horizontalInset: CGFloat = DS.Spacing.md) -> some View {
        self
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: DS.Spacing.xs, leading: horizontalInset,
                                      bottom: DS.Spacing.xs, trailing: horizontalInset))
            .selectionDisabled()
    }
}
