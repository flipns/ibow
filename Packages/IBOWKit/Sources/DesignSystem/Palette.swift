import SwiftUI

public nonisolated struct RGB: Sendable, Equatable {
    public let r: Double, g: Double, b: Double
    public init(hex: UInt32) {
        r = Double((hex >> 16) & 0xFF) / 255
        g = Double((hex >> 8) & 0xFF) / 255
        b = Double(hex & 0xFF) / 255
    }
    public init(r: Double, g: Double, b: Double) { self.r = r; self.g = g; self.b = b }

    public func over(_ background: RGB, alpha: Double) -> RGB {
        RGB(r: r * alpha + background.r * (1 - alpha),
            g: g * alpha + background.g * (1 - alpha),
            b: b * alpha + background.b * (1 - alpha))
    }

    public var luminance: Double {
        func lin(_ c: Double) -> Double { c <= 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4) }
        return 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b)
    }

    public static func contrast(_ a: RGB, _ b: RGB) -> Double {
        let (hi, lo) = (max(a.luminance, b.luminance), min(a.luminance, b.luminance))
        return (hi + 0.05) / (lo + 0.05)
    }

    public var color: Color { Color(.sRGB, red: r, green: g, blue: b) }
}

public nonisolated enum Palette {
    public static let primary = RGB(hex: 0x38BDF8)
    public static let onPrimary = RGB(hex: 0x0F172A)
    public static let surface = RGB(hex: 0x0F172A)
    public static let surfaceAlt = RGB(hex: 0x222A3A)
    public static let white = RGB(hex: 0xFFFFFF)
    public static let accentSoft = RGB(hex: 0xBAE6FD)
    public static let atmosBlue = RGB(hex: 0x2563EB)
    public static let atmosCyan = RGB(hex: 0x06B6D4)
    public static let atmosIndigo = RGB(hex: 0x6366F1)
    public static let green = RGB(hex: 0x4ADE80)
    public static let blue = RGB(hex: 0x38BDF8)
    public static let red = RGB(hex: 0xF87171)
    public static let magenta = RGB(hex: 0xC084FC)
    public static let error = RGB(hex: 0xEF4444)
    public static let illusCyan = RGB(hex: 0x67E8F9)
    public static let illusOrange = RGB(hex: 0xFB923C)
    public static let illusGreen = RGB(hex: 0x4ADE80)
    public static let illusViolet = RGB(hex: 0xC084FC)

    public static let secondaryTextOnSurface = RGB(hex: 0xCBD5E1)
    public static let mutedTextOnSurface = RGB(hex: 0xCBD5E1)
    
    public static let lightestCardBackdrop = white.over(atmosCyan.over(surface, alpha: 0.30), alpha: 0.14)
    public static let lightestAccentBackdrop = atmosCyan.over(atmosCyan.over(surface, alpha: 0.30), alpha: 0.22)
}
