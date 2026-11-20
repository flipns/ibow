import SwiftUI

public nonisolated enum GlassTier: Sendable {
    case standard
    case accent
    case outlined
}

public struct GlassCard<Content: View>: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var contrast
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
            .background { fill(shape) }
            .overlay { border(shape) }
    }

    @ViewBuilder private func border(_ shape: RoundedRectangle) -> some View {
        if contrast == .increased {
            // HIG: provide a higher-contrast scheme when Increase Contrast is on.
            shape.strokeBorder(Color.white.opacity(0.85), lineWidth: 1.5)
        } else {
            tierBorder(shape)
        }
    }

    @ViewBuilder private func tierBorder(_ shape: RoundedRectangle) -> some View {
        switch tier {
        case .accent: shape.strokeBorder(DS.Color.borderAccent, lineWidth: 1)
        case .outlined: shape.strokeBorder(Palette.primary.color.opacity(0.75), lineWidth: 1.5)
        case .standard: shape.strokeBorder(DS.Color.borderGlass.opacity(0.75), lineWidth: 1)
        }
    }

    @ViewBuilder private func fill(_ shape: RoundedRectangle) -> some View {
        if reduceTransparency {
            shape.fill(DS.Color.surfaceAlt)
        } else if tier == .accent {
            shape.fill(LinearGradient(
                colors: [Palette.atmosCyan.color.opacity(0.22), Palette.atmosBlue.color.opacity(0.22)],
                startPoint: .topLeading, endPoint: .bottomTrailing))
        } else {
            shape.fill(LinearGradient(
                colors: [Color.white.opacity(0.14), Color.white.opacity(0.07)],
                startPoint: .topLeading, endPoint: .bottomTrailing))
        }
    }
}
