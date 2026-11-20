import Foundation

public nonisolated enum ObservationAge {
    public static func text(from observedAt: Date, now: Date) -> String? {
        let seconds = now.timeIntervalSince(observedAt)
        guard seconds < 60 * 60 * 24 * 365 else { return nil }
        guard seconds >= 60 else { return seconds < 0 ? "ahora" : "hace menos de 1 min" }

        let minutes = Int(seconds / 60)
        if minutes < 60 { return "hace \(minutes) min" }

        let hours = minutes / 60
        if hours < 24 {
            let rest = minutes % 60
            return rest == 0 ? "hace \(hours) h" : "hace \(hours) h \(rest) min"
        }
        return "hace \(hours / 24) d"
    }
}
