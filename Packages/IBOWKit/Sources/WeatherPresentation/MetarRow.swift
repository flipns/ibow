import DesignSystem
import SwiftUI
import WeatherDomain

/// Row content only. Tapping/selection is owned by the enclosing `List(selection:)`,
/// which also gives push navigation when `NavigationSplitView` collapses to compact width.
public struct MetarRow: View {
    let metar: Metar
    let isSelected: Bool
    @Environment(\.horizontalSizeClass) private var sizeClass

    public init(metar: Metar, isSelected: Bool) {
        self.metar = metar
        self.isSelected = isSelected
    }

    /// Selection is only meaningful while the detail is visible beside the list (regular width).
    /// On compact width the list is replaced by the detail, and the selection lingers for a moment after
    /// popping back: highlighting it caused a blue→grey flash. `.outlined` shares the standard padding,
    /// so the content never shifts when the highlight appears or goes away.
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
