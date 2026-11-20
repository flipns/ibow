import DesignSystem
import Foundation
import SwiftUI
import WeatherDomain

struct WindRose: View {
    let wind: Wind?

    var body: some View {
        Canvas { context, size in
            let c = CGPoint(x: size.width / 2, y: size.height / 2)
            let r = min(size.width, size.height) / 2 - 4
            context.stroke(Path(ellipseIn: CGRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2)),
                           with: .color(.white.opacity(0.35)), lineWidth: 1)
            for i in 0..<8 {
                let a = Double(i) * .pi / 4
                let len: CGFloat = i % 2 == 0 ? 8 : 4
                var tick = Path()
                tick.move(to: CGPoint(x: c.x + (r - len) * sin(a), y: c.y - (r - len) * cos(a)))
                tick.addLine(to: CGPoint(x: c.x + r * sin(a), y: c.y - r * cos(a)))
                context.stroke(tick, with: .color(.white.opacity(0.5)), lineWidth: 1)
            }
            if case .degrees(let deg)? = wind?.direction {
                // Arrow points where the wind is blowing TO (direction is where it comes FROM).
                let a = (Double(deg) + 180) * .pi / 180
                let tip = CGPoint(x: c.x + (r - 10) * sin(a), y: c.y - (r - 10) * cos(a))
                let tail = CGPoint(x: c.x - (r - 10) * sin(a), y: c.y + (r - 10) * cos(a))
                var shaft = Path(); shaft.move(to: tail); shaft.addLine(to: tip)
                context.stroke(shaft, with: .color(Palette.primary.color), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                for side in [-0.5, 0.5] {
                    var head = Path(); head.move(to: tip)
                    head.addLine(to: CGPoint(x: tip.x - 12 * sin(a + side), y: tip.y + 12 * cos(a + side)))
                    context.stroke(head, with: .color(Palette.primary.color), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                }
            }
        }
        .overlay(alignment: .top) { Text("N").font(DS.Typography.micro).foregroundStyle(DS.Color.onSurfaceVariant).offset(y: -2) }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityHidden(true)
    }
}
