import DesignSystem
import SwiftUI
import WeatherDomain

public struct FlightCategoryBadge: View {
    private let category: FlightCategory
    public init(_ category: FlightCategory) { self.category = category }

    public var body: some View {
        StatusBadge(category.title, systemImage: category.systemImage, tone: category.tone)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(category.spokenName)
    }
}
