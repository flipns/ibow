import SwiftUI

/// Dark base with three blurred colour blobs. Static when Reduce Motion is on (it is always static here;
/// blobs never animate, which also keeps battery cost at zero).
public struct AtmosphericBackground: View {
    public init() {}

    public var body: some View {
        ZStack {
            DS.Color.surface
            GeometryReader { proxy in
                let w = proxy.size.width, h = proxy.size.height
                Circle().fill(Palette.atmosBlue.color.opacity(0.35))
                    .frame(width: w * 0.9).blur(radius: 90).offset(x: -w * 0.35, y: -h * 0.12)
                Circle().fill(Palette.atmosCyan.color.opacity(0.25))
                    .frame(width: w * 0.7).blur(radius: 80).offset(x: w * 0.45, y: h * 0.25)
                Circle().fill(Palette.atmosIndigo.color.opacity(0.28))
                    .frame(width: w * 0.8).blur(radius: 90).offset(x: -w * 0.2, y: h * 0.75)
            }
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}
