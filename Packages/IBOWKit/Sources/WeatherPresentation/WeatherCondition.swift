import Foundation
import WeatherDomain

/// What the sky looks like, derived from the report (present-weather groups first, then cloud cover).
public nonisolated enum WeatherCondition: Sendable, Equatable {
    case clear, fewClouds, scattered, broken, overcast
    case fog, drizzle, rain, showers, thunderstorm, snow, hail

    public init(_ metar: Metar) {
        let codes = Self.phenomena(in: metar)
        if codes.contains("TS") { self = .thunderstorm }
        else if codes.contains("GR") || codes.contains("GS") { self = .hail }
        else if codes.contains("SN") || codes.contains("SG") { self = .snow }
        else if codes.contains("SH") { self = .showers }
        else if codes.contains("RA") { self = .rain }
        else if codes.contains("DZ") { self = .drizzle }
        else if !codes.isDisjoint(with: ["FG", "BR", "HZ", "FU", "DU", "SA", "VA"]) { self = .fog }
        else {
            let order: [CloudLayer.Cover] = [.clear, .few, .scattered, .broken, .overcast]
            let rank = metar.clouds.map { layer -> Int in
                switch layer.cover {
                case .verticalVisibility: 4
                default: order.firstIndex(of: layer.cover) ?? 0
                }
            }.max() ?? 0
            self = [.clear, .fewClouds, .scattered, .broken, .overcast][rank]
        }
    }

    /// Two-letter codes from every present-weather group ("-SHRA" → SH, RA).
    static func phenomena(in metar: Metar) -> Set<String> {
        var result = Set<String>()
        let tokens = METARTokenizer.tokenize(metar.rawText).filter { $0.kind == .presentWeather }.map(\.text)
            + (metar.weather?.split(separator: " ").map(String.init) ?? [])
        for token in tokens {
            var s = Substring(token)
            if s.hasPrefix("-") || s.hasPrefix("+") { s = s.dropFirst() }
            if s.hasPrefix("VC") { s = s.dropFirst(2) }
            while s.count >= 2 { result.insert(String(s.prefix(2))); s = s.dropFirst(2) }
        }
        return result
    }

    public var spokenName: String {
        switch self {
        case .clear: "cielo despejado"
        case .fewClouds: "pocas nubes"
        case .scattered: "nubes dispersas"
        case .broken: "nubosidad fragmentada"
        case .overcast: "cielo cubierto"
        case .fog: "niebla o neblina"
        case .drizzle: "llovizna"
        case .rain: "lluvia"
        case .showers: "chubascos"
        case .thunderstorm: "tormenta"
        case .snow: "nieve"
        case .hail: "granizo"
        }
    }

    public func symbolName(isDaylight: Bool) -> String {
        switch self {
        case .clear: isDaylight ? "sun.max" : "moon.stars"
        case .fewClouds, .scattered: isDaylight ? "cloud.sun" : "cloud.moon"
        case .broken: "cloud"
        case .overcast: "cloud.fill"
        case .fog: "cloud.fog"
        case .drizzle: "cloud.drizzle"
        case .rain: "cloud.rain"
        case .showers: isDaylight ? "cloud.sun.rain" : "cloud.moon.rain"
        case .thunderstorm: "cloud.bolt.rain"
        case .snow: "cloud.snow"
        case .hail: "cloud.hail"
        }
    }
}

/// Approximate day/night from sun elevation (ignores the equation of time, good to ~15 min).
public nonisolated enum Daylight {
    public static func isDaylight(at date: Date, latitude: Double?, longitude: Double?) -> Bool {
        guard let latitude, let longitude else { return true }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        let dayOfYear = Double(calendar.ordinality(of: .day, in: .year, for: date) ?? 1)
        let utcHours = Double(calendar.component(.hour, from: date)) + Double(calendar.component(.minute, from: date)) / 60

        let rad = Double.pi / 180
        let declination = 23.44 * sin(360.0 / 365.0 * (dayOfYear - 81) * rad)
        let solarTime = utcHours + longitude / 15
        let hourAngle = 15 * (solarTime - 12)
        let sinElevation = sin(latitude * rad) * sin(declination * rad)
            + cos(latitude * rad) * cos(declination * rad) * cos(hourAngle * rad)
        return asin(sinElevation) / rad > -0.833
    }
}
