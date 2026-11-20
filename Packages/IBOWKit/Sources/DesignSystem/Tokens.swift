import SwiftUI

public enum DS {
    public enum Color {
        public static let surface = Palette.surface.color
        public static let surfaceAlt = Palette.surfaceAlt.color
        public static let primary = Palette.primary.color
        public static let onPrimary = Palette.onPrimary.color
        public static let onSurface = SwiftUI.Color.white
        /// Opaque slate-300 instead of the spec's white @ 60 % (see `Palette.secondaryTextOnSurface`).
        public static let onSurfaceVariant = Palette.secondaryTextOnSurface.color
        /// Same opaque colour as `onSurfaceVariant`; the spec's white @ 40 % fails AA.
        public static let onSurfaceMuted = Palette.mutedTextOnSurface.color
        public static let glass = SwiftUI.Color.white.opacity(0.10)
        public static let glassStrong = Palette.primary.color.opacity(0.20)
        public static let borderGlass = SwiftUI.Color.white.opacity(0.20)
        public static let borderFaint = SwiftUI.Color.white.opacity(0.10)
        public static let borderAccent = Palette.primary.color.opacity(0.30)
        public static let accentSoft = Palette.accentSoft.color
        public static let error = Palette.error.color
    }

    public enum Radius {
        public static let sm: CGFloat = 8
        public static let md: CGFloat = 16
        public static let lg: CGFloat = 24
        public static let xl: CGFloat = 32
    }

    public enum Spacing {
        public static let xs: CGFloat = 4
        public static let sm: CGFloat = 8
        public static let md: CGFloat = 16
        public static let lg: CGFloat = 24
        public static let xl: CGFloat = 32
        public static let cardPadding: CGFloat = 20
    }

    /// Manrope styles. All scale with Dynamic Type via `relativeTo`.
    public enum Typography {
        public static let displayLarge = font(48, .light, relativeTo: .largeTitle)
        public static let headlineLarge = font(24, .bold, relativeTo: .title)
        public static let headlineMedium = font(20, .bold, relativeTo: .title2)
        public static let headlineSmall = font(18, .bold, relativeTo: .title3)
        public static let bodyMedium = font(14, .medium, relativeTo: .body)
        public static let bodySmall = font(13, .medium, relativeTo: .callout)
        public static let labelMedium = font(14, .semibold, relativeTo: .subheadline)
        public static let labelSmall = font(12, .semibold, relativeTo: .footnote)
        public static let caption = font(12, .medium, relativeTo: .caption)
        public static let micro = font(10, .semibold, relativeTo: .caption2)
        public static let numeral = font(24, .bold, relativeTo: .title)

        static func font(_ size: CGFloat, _ weight: Font.Weight, relativeTo style: Font.TextStyle) -> Font {
            Font.custom("Manrope", size: size, relativeTo: style).weight(weight)
        }
    }
}
