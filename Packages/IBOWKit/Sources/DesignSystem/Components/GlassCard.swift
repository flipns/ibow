import SwiftUI

public nonisolated enum GlassTier: Sendable { case standard, accent }

public struct GlassCard<Content: View>: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    private let tier: GlassTier
    private let content: Content

    public init(_ tier: GlassTier = .standard, @ViewBuilder content: () -> Content) {
        self.tier = tier
        self.content = content()
    }

    public var body: some View {
        let shape = RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
        content
            .padding(tier == .accent ? DS.Spacing.lg : DS.Spacing.cardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                if reduceTransparency {
                    shape.fill(DS.Color.surfaceAlt)
                } else {
                    shape.fill(.ultraThinMaterial)
                    shape.fill(tier == .accent ? DS.Color.glassStrong : DS.Color.glass)
                }
            }
            .overlay { shape.strokeBorder(tier == .accent ? DS.Color.borderAccent : DS.Color.borderFaint, lineWidth: 1) }
            .shadow(color: tier == .accent ? Palette.atmosCyan.color.opacity(0.15) : .black.opacity(0.2),
                    radius: tier == .accent ? 16 : 8, y: tier == .accent ? 8 : 4)
    }
}
