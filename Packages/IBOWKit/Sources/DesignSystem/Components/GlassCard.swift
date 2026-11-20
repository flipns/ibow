import SwiftUI

public nonisolated enum GlassTier: Sendable {
    /// Neutral translucent card.
    case standard
    /// Cyan→blue gradient. Use once per screen (the hero card).
    case accent
    /// Neutral fill with a cyan border, to mark the primary tile without a second gradient.
    case outlined
}

/// Translucent card. No system material on purpose: `.ultraThinMaterial` desaturates the atmospheric
/// colours into flat grey on a dark base, while a plain translucent fill lets the blobs tint the card.
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
            .background { fill(shape) }
            .overlay { border(shape) }
        // No drop shadow on purpose: SwiftUI paints it *behind* a translucent fill, which is what
        // turned the cards into matte grey. CSS box-shadow in the design is clipped to the outside.
    }

    @ViewBuilder private func border(_ shape: RoundedRectangle) -> some View {
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
            // DESIGN: linear-gradient(135deg, cyan 20 %, blue 20 %)
            shape.fill(LinearGradient(
                colors: [Palette.atmosCyan.color.opacity(0.22), Palette.atmosBlue.color.opacity(0.22)],
                startPoint: .topLeading, endPoint: .bottomTrailing))
        } else {
            // Slightly brighter at the top-left so the card reads as glass, not as a flat grey slab.
            shape.fill(LinearGradient(
                colors: [Color.white.opacity(0.14), Color.white.opacity(0.07)],
                startPoint: .topLeading, endPoint: .bottomTrailing))
        }
    }
}
