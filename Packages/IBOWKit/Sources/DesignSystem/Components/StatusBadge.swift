import SwiftUI

public nonisolated enum StatusTone: Sendable {
    case positive, info, warning, critical, neutral

    var rgb: RGB {
        switch self {
        case .positive: Palette.green
        case .info: Palette.blue
        case .warning: Palette.magenta
        case .critical: Palette.red
        case .neutral: Palette.white
        }
    }
}

/// Colour-tinted pill that always carries a text label and (optionally) an icon,
/// so meaning is never conveyed by colour alone.
public struct StatusBadge: View {
    private let title: String
    private let systemImage: String?
    private let tone: StatusTone

    public init(_ title: String, systemImage: String? = nil, tone: StatusTone) {
        self.title = title
        self.systemImage = systemImage
        self.tone = tone
    }

    public var body: some View {
        HStack(spacing: DS.Spacing.xs) {
            if let systemImage { Image(systemName: systemImage).imageScale(.small) }
            Text(title)
        }
        .font(DS.Typography.labelSmall)
        .foregroundStyle(tone.rgb.color)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(tone.rgb.color.opacity(0.16), in: Capsule())
        .overlay { Capsule().strokeBorder(tone.rgb.color.opacity(0.4), lineWidth: 1) }
    }
}
