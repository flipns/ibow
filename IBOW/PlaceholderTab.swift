import DesignSystem
import SwiftUI

struct PlaceholderTab: View {
    let title: LocalizedStringKey
    let systemImage: String
    let message: LocalizedStringKey

    var body: some View {
        NavigationStack {
            ContentUnavailableView {
                Label(title, systemImage: systemImage)
            } description: {
                Text(message)
            }
            .foregroundStyle(DS.Color.onSurface)
            .background { AtmosphericBackground() }
        }
    }
}
