import SwiftUI

public struct PrimaryButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DS.Typography.labelMedium)
            .foregroundStyle(DS.Color.onPrimary)
            .frame(maxWidth: .infinity, minHeight: 56)
            .padding(.horizontal, DS.Spacing.lg)
            .background(
                LinearGradient(colors: [Color(hex: 0x22D3EE), Color(hex: 0x38BDF8)],
                               startPoint: .topLeading, endPoint: .bottomTrailing),
                in: Capsule()
            )
            .opacity(configuration.isPressed ? 0.85 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .contentShape(Capsule())
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    public static var dsPrimary: PrimaryButtonStyle { PrimaryButtonStyle() }
}

extension Color {
    init(hex: UInt32) {
        let c = RGB(hex: hex)
        self = Color(.sRGB, red: c.r, green: c.g, blue: c.b)
    }
}
