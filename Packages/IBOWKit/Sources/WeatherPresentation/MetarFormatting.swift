import Foundation
import WeatherDomain

extension Wind {
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
    public var shortDescription: String {
        let km = meters / 1000
        if isLowerBound && km >= 9.5 { return "≥ 10 km" }
        let text = km.formatted(.number.precision(.fractionLength(km >= 10 ? 0 : 1)))
        return "\(isLowerBound ? "≥ " : "")\(text) km"
    }
}

extension Wind {
    public var summaryDescription: String {
        guard speedKnots > 0 else { return "viento en calma" }
        switch direction {
        case .variable: return "viento variable a \(speedKnots) kt"
        case .degrees(let d): return "viento \(d)° a \(speedKnots) kt"
        }
    }
}

extension ICAOCode {
    public var spelled: String { value.map(String.init).joined(separator: " ") }
}

extension Metar {
    public var displayName: String { name ?? station.value }

    public var temperatureText: String? {
        temperatureC.map { "\(Int($0.rounded()))°" }
    }

    public var spokenSummary: String {
        var parts = ["\(displayName), \(station.spelled)", flightCategory.spokenName]
        if let wind { parts.append(wind.spokenDescription) }
        if let temperatureC { parts.append("temperatura \(Int(temperatureC.rounded())) grados") }
        return parts.joined(separator: ". ")
    }
}

/// What a METAR says about the sky. A report with no cloud group at all is *not* a clear sky:
/// only CAVOK, or an explicit "clear" layer, is.
public enum SkyReport: Sendable, Equatable {
    case noData, clear, layers
}

extension Metar {
    public var skyReport: SkyReport {
        if clouds.isEmpty {
            return rawText.uppercased().split(separator: " ").contains("CAVOK") ? .clear : .noData
        }
        return clouds.allSatisfy { $0.cover == .clear } ? .clear : .layers
    }

    /// Spoken temperature and dew point; a missing value is left out, never read as zero.
    public var spokenTemperatureAndDewpoint: String {
        var parts: [String] = []
        if let temperatureC { parts.append("temperatura \(Int(temperatureC.rounded())) grados") }
        if let dewpointC { parts.append("punto de rocío \(Int(dewpointC.rounded())) grados") }
        return parts.isEmpty ? "temperatura y punto de rocío sin dato" : parts.joined(separator: ", ")
    }

    public var spokenPressure: String {
        altimeterHPa.map { "QNH \(Int($0)) hectopascales" } ?? "QNH sin dato"
    }
}
