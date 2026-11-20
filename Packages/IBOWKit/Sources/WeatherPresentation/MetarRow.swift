import DesignSystem
import SwiftUI
import WeatherDomain

public struct MetarRow: View {
    let metar: Metar
    let isSelected: Bool
    @Environment(\.horizontalSizeClass) private var sizeClass

    public init(metar: Metar, isSelected: Bool) {
        self.metar = metar
        self.isSelected = isSelected
    }

    private var isHighlighted: Bool { isSelected && sizeClass == .regular }

    public var body: some View {
        GlassCard(isHighlighted ? .outlined : .standard) {
            VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                HStack(alignment: .firstTextBaseline) {
                    Text(metar.station.value)
                        .font(DS.Typography.headlineMedium)
                        .foregroundStyle(DS.Color.onSurface)
                    Spacer(minLength: DS.Spacing.sm)
                    FlightCategoryBadge(metar.flightCategory)
                }
                Text(metar.displayName)
                    .font(DS.Typography.bodyMedium)
                    .foregroundStyle(DS.Color.onSurfaceVariant)
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: DS.Spacing.md) { details }
                    VStack(alignment: .leading, spacing: DS.Spacing.xs) { details }
                }
                .font(DS.Typography.labelSmall)
                .foregroundStyle(DS.Color.onSurfaceMuted)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(metar.spokenSummary)
        .accessibilityHint("Abre el METAR completo")
        .accessibilityIdentifier("metar-row-\(metar.station.value)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    @ViewBuilder private var details: some View {
        if let wind = metar.wind {
            Label { Text(wind.shortDescription) } icon: { Image(systemName: "wind").foregroundStyle(Palette.primary.color) }
        }
        if let temp = metar.temperatureText {
            Label { Text(temp) } icon: { Image(systemName: "thermometer.medium").foregroundStyle(Palette.illusOrange.color) }
        }
    }
}
