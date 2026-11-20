import SwiftUI

public struct AtmosphericBackground: View {
    public init() {}

    public var body: some View {
        DS.Color.surface
            .overlay(alignment: .topTrailing) {
                blob(Palette.atmosCyan, opacity: 0.30, size: 280, blur: 90).offset(x: 90, y: -70)
            }
            .overlay(alignment: .topLeading) {
                blob(Palette.atmosIndigo, opacity: 0.26, size: 260, blur: 90).offset(x: -120, y: 340)
            }
            .overlay(alignment: .bottomTrailing) {
                blob(Palette.atmosBlue, opacity: 0.30, size: 280, blur: 100).offset(x: 100, y: 70)
            }
            .clipped()
            .ignoresSafeArea()
            .accessibilityHidden(true)
    }

    private func blob(_ color: RGB, opacity: Double, size: CGFloat, blur: CGFloat) -> some View {
        Circle().fill(color.color.opacity(opacity)).frame(width: size, height: size).blur(radius: blur)
    }
}
