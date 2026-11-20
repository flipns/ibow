import DesignSystem
import SwiftUI
import WeatherDomain
import WeatherPresentation

/// Presentational view: receives a report, owns only the "which token is selected" UI state.
public struct DetailView: View {
    private let metar: Metar
    @State private var pickedID: Int
    @ScaledMetric(relativeTo: .body) private var roseSize = 96.0
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let tokens: [METARToken]

    public init(metar: Metar) {
        self.metar = metar
        // The leading "METAR" label adds nothing for the reader, so it is not offered as a chip.
        let tokens = METARTokenizer.tokenize(metar.rawText).filter { $0.text != "METAR" }
        self.tokens = tokens
        // One-time seed: start on the wind group, the most informative one.
        _pickedID = State(initialValue: tokens.first { $0.kind == .wind }?.id ?? 0)
    }

    private var picked: METARToken? { tokens.first { $0.id == pickedID } }

    public var body: some View {
        ScrollView {
            VStack(spacing: DS.Spacing.lg) {
                hero
                reader
                tiles
            }
            .padding(DS.Spacing.md)
        }
        .background { AtmosphericBackground() }
        .navigationTitle(metar.station.value)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    // MARK: Hero

    private var hero: some View {
        GlassCard(.accent) {
            VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                HStack(alignment: .firstTextBaseline) {
                    Text(metar.station.value).font(DS.Typography.headlineLarge)
                    Spacer()
                    FlightCategoryBadge(metar.flightCategory)
                }
                Text(metar.displayName)
                    .font(DS.Typography.bodyMedium).foregroundStyle(DS.Color.onSurfaceVariant)
                if let temp = metar.temperatureText {
                    Text(temp).font(DS.Typography.displayLarge)
                        .accessibilityLabel("Temperatura \(temp.dropLast()) grados")
                }
                Text("Observado a las \(metar.observedAt, format: Date.FormatStyle(date: .omitted, time: .shortened, timeZone: .gmt)) UTC")
                    .font(DS.Typography.caption).foregroundStyle(DS.Color.onSurfaceMuted)
            }
            .foregroundStyle(DS.Color.onSurface)
        }
        .accessibilityElement(children: .combine)
    }

    // MARK: Interactive reader

    private var reader: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            Text("Lee el METAR").font(DS.Typography.headlineSmall).foregroundStyle(DS.Color.onSurface)
            Text("Toca un grupo para ver qué significa.")
                .font(DS.Typography.bodySmall).foregroundStyle(DS.Color.onSurfaceVariant)

            GlassCard {
                FlowLayout(spacing: DS.Spacing.sm) {
                    ForEach(tokens) { token in
                        TokenChip(token: token, isSelected: token.id == pickedID) { pickedID = token.id }
                    }
                }
            }

            if let picked {
                let explanation = METARExplainer.explain(picked)
                GlassCard {
                    VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                        Text(explanation.title).font(DS.Typography.headlineSmall)
                        Text(explanation.detail).font(DS.Typography.bodyMedium)
                    }
                    .foregroundStyle(DS.Color.onSurface)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(explanation.spoken)
            }
        }
    }

    // MARK: Tiles

    /// Fixed layout from the design: wind full width, then three rows of two half-width tiles.
    /// At accessibility text sizes the halves stack so nothing truncates.
    @ViewBuilder private var tiles: some View {
        VStack(spacing: DS.Spacing.md) {
            if let wind = metar.wind { windTile(wind) }
            pair(visibilityTile, cloudsTile)
            pair(temperatureTile, pressureTile)
        }
    }

    @ViewBuilder private func pair(_ left: some View, _ right: some View) -> some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(spacing: DS.Spacing.md) { left; right }
        } else {
            HStack(alignment: .top, spacing: DS.Spacing.md) {
                left.frame(maxHeight: .infinity)
                right.frame(maxHeight: .infinity)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func windTile(_ wind: Wind) -> some View {
        GlassCard(.outlined) {
            HStack(spacing: DS.Spacing.lg) {
                WindRose(wind: wind).frame(width: roseSize, height: roseSize)
                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    Label { Text("Viento") } icon: { Image(systemName: "wind").foregroundStyle(Palette.primary.color) }
                        .font(DS.Typography.labelSmall).foregroundStyle(DS.Color.onSurfaceVariant)
                    Text("\(wind.speedKnots) kt").font(DS.Typography.numeral)
                    Text(wind.shortDescription).font(DS.Typography.bodySmall)
                        .foregroundStyle(DS.Color.onSurfaceVariant)
                }
                .foregroundStyle(DS.Color.onSurface)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(wind.spokenDescription)
    }

    private var visibilityTile: some View {
        let vis = metar.visibility
        let km = (vis?.meters ?? 0) / 1000
        let value = vis.map { String(format: "%@%.1f km", $0.isLowerBound ? "≥ " : "", km) } ?? "—"
        return Tile(title: "Visibilidad", icon: "eye", tint: Palette.illusGreen, value: value,
                    caption: km >= 9.5 ? "Sin restricción" : nil,
                    spoken: vis.map { "visibilidad \($0.isLowerBound ? "de al menos " : "")\(Int(km.rounded())) kilómetros" } ?? "visibilidad desconocida")
    }

    private var cloudsTile: some View {
        Tile(title: "Nubes", icon: "cloud", tint: Palette.illusCyan, value: cloudsHeadline, caption: metar.clouds.isEmpty ? nil : cloudsText,
             spoken: "nubes: \(cloudsText)")
    }

    private var temperatureTile: some View {
        let t = metar.temperatureC.map { Int($0.rounded()) }
        let d = metar.dewpointC.map { Int($0.rounded()) }
        let margin = (t != nil && d != nil) ? "\(t! - d!)° de margen" : nil
        return Tile(title: "Temp / rocío", icon: "thermometer.medium", tint: Palette.illusOrange,
                    value: "\(t.map(String.init) ?? "—")° / \(d.map(String.init) ?? "—")°",
                    caption: margin,
                    spoken: "temperatura \(t ?? 0) grados, punto de rocío \(d ?? 0)")
    }

    private var pressureTile: some View {
        let trend = tokens.first { $0.kind == .trend }?.text
        return Tile(title: "QNH", icon: "gauge.medium", tint: Palette.illusViolet,
                    value: metar.altimeterHPa.map { "\(Int($0)) hPa" } ?? "—",
                    caption: trend.map { "Tendencia: \($0)" },
                    spoken: "QNH \(Int(metar.altimeterHPa ?? 0)) hectopascales")
    }

    private var cloudsHeadline: String {
        guard let lowest = metar.clouds.compactMap(\.baseFeet).min() else { return "Despejado" }
        return "\(lowest) ft"
    }

    private var cloudsText: String {
        guard !metar.clouds.isEmpty else { return "Despejado" }
        return metar.clouds.map { layer in
            let base = layer.baseFeet.map { "\($0) ft" } ?? ""
            return "\(layer.cover.abbreviation) \(base)".trimmingCharacters(in: .whitespaces)
        }.joined(separator: ", ")
    }
}

private extension CloudLayer.Cover {
    var abbreviation: String {
        switch self {
        case .clear: "CLR"
        case .few: "FEW"
        case .scattered: "SCT"
        case .broken: "BKN"
        case .overcast: "OVC"
        case .verticalVisibility: "VV"
        case .unknown: "—"
        }
    }
}

private struct TokenChip: View {
    let token: METARToken
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(token.text)
                .font(DS.Typography.labelMedium)
                .foregroundStyle(isSelected ? DS.Color.onPrimary : DS.Color.onSurface)
                .padding(.horizontal, 12)
                .frame(minHeight: 44)
                .background(isSelected ? DS.Color.primary : DS.Color.glass, in: Capsule())
                .overlay { Capsule().strokeBorder(isSelected ? DS.Color.accentSoft : DS.Color.borderGlass, lineWidth: isSelected ? 2 : 1) }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(METARExplainer.explain(token).title)
        .accessibilityValue(token.text)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct Tile: View {
    let title: LocalizedStringKey
    let icon: String
    let tint: RGB
    let value: String
    let caption: String?
    let spoken: String

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                Label { Text(title) } icon: { Image(systemName: icon).foregroundStyle(tint.color) }
                    .font(DS.Typography.labelSmall).foregroundStyle(DS.Color.onSurfaceVariant)
                Text(value).font(DS.Typography.numeral).foregroundStyle(DS.Color.onSurface)
                    .minimumScaleFactor(0.7).lineLimit(1)
                if let caption {
                    Text(caption).font(DS.Typography.caption).foregroundStyle(DS.Color.onSurfaceMuted)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spoken)
    }
}
