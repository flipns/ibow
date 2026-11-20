import DesignSystem
import SwiftUI
import WeatherDomain
import WeatherPresentation

struct MetarRow: View {
    let metar: Metar

    var body: some View {
        GlassCard {
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
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Abre el METAR completo")
    }

    @ViewBuilder private var details: some View {
        if let wind = metar.wind { Label(wind.shortDescription, systemImage: "wind") }
        if let temp = metar.temperatureText { Label(temp, systemImage: "thermometer.medium") }
    }
}
