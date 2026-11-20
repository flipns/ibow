import Foundation
import WeatherDomain

extension Wind {
    /// "270° · 10 kt · G20"
    public var shortDescription: String {
        let dir: String
        switch direction {
        case .variable: dir = "VRB"
        case .degrees(let d): dir = String(format: "%03d°", d)
        }
        var text = "\(dir) · \(speedKnots) kt"
        if let gustKnots { text += " · G\(gustKnots)" }
        return text
    }

    public var spokenDescription: String {
        let dir: String
        switch direction {
        case .variable: dir = "viento variable"
        case .degrees(let d): dir = "viento de \(d) grados"
        }
        var text = "\(dir), \(speedKnots) nudos"
        if let gustKnots { text += ", con rachas de \(gustKnots)" }
        return text
    }
}

extension Visibility {
    /// "≥ 10 km" when the report only says "more than 6 SM / 9999"; otherwise the value in km.
    public var shortDescription: String {
        let km = meters / 1000
        if isLowerBound && km >= 9.5 { return "≥ 10 km" }
        let text = km.formatted(.number.precision(.fractionLength(km >= 10 ? 0 : 1)))
        return "\(isLowerBound ? "≥ " : "")\(text) km"
    }
}

extension Wind {
    /// For the one-line hero summary: "viento 240° a 15 kt".
    public var summaryDescription: String {
        guard speedKnots > 0 else { return "viento en calma" }
        switch direction {
        case .variable: return "viento variable a \(speedKnots) kt"
        case .degrees(let d): return "viento \(d)° a \(speedKnots) kt"
        }
    }
}

extension ICAOCode {
    /// "L E M D" so VoiceOver spells the code instead of trying to pronounce it.
    public var spelled: String { value.map(String.init).joined(separator: " ") }
}

extension Metar {
    public var displayName: String { name ?? station.value }

    public var temperatureText: String? {
        temperatureC.map { "\(Int($0.rounded()))°" }
    }

    /// One sentence per row for VoiceOver.
    public var spokenSummary: String {
        var parts = ["\(displayName), \(station.spelled)", flightCategory.spokenName]
        if let wind { parts.append(wind.spokenDescription) }
        if let temperatureC { parts.append("temperatura \(Int(temperatureC.rounded())) grados") }
        return parts.joined(separator: ". ")
    }
}
