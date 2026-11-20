import Foundation

public enum FlightCategory: String, Sendable, Hashable, CaseIterable {
    case vfr, mvfr, ifr, lifr, unknown

    public init(apiValue: String?) {
        self = apiValue.flatMap { Self(rawValue: $0.lowercased()) } ?? .unknown
    }
}

public struct Wind: Sendable, Hashable {
    public enum Direction: Sendable, Hashable {
        case variable
        case degrees(Int)
    }
    public let direction: Direction
    public let speedKnots: Int
    public let gustKnots: Int?

    public init(direction: Direction, speedKnots: Int, gustKnots: Int?) {
        self.direction = direction
        self.speedKnots = speedKnots
        self.gustKnots = gustKnots
    }
}

public struct Visibility: Sendable, Hashable {
    public let statuteMiles: Double
    /// `true` when the report says "10+" (more than the value).
    public let isLowerBound: Bool

    public init(statuteMiles: Double, isLowerBound: Bool = false) {
        self.statuteMiles = statuteMiles
        self.isLowerBound = isLowerBound
    }

    public var meters: Double { statuteMiles * 1609.344 }
}

public struct CloudLayer: Sendable, Hashable {
    public enum Cover: String, Sendable, Hashable {
        case clear, few, scattered, broken, overcast, verticalVisibility, unknown
    }
    public let cover: Cover
    public let baseFeet: Int?

    public init(cover: Cover, baseFeet: Int?) {
        self.cover = cover
        self.baseFeet = baseFeet
    }
}

public struct Metar: Sendable, Hashable, Identifiable {
    public var id: String { "\(station.value)-\(observedAt.timeIntervalSince1970)" }

    public let station: ICAOCode
    public let name: String?
    public let observedAt: Date
    public let rawText: String
    public let temperatureC: Double?
    public let dewpointC: Double?
    public let wind: Wind?
    public let visibility: Visibility?
    public let altimeterHPa: Double?
    public let clouds: [CloudLayer]
    public let weather: String?
    public let flightCategory: FlightCategory
    public let latitude: Double?
    public let longitude: Double?
    public let elevationMeters: Double?

    public init(
        station: ICAOCode, name: String?, observedAt: Date, rawText: String,
        temperatureC: Double?, dewpointC: Double?, wind: Wind?, visibility: Visibility?,
        altimeterHPa: Double?, clouds: [CloudLayer], weather: String?,
        flightCategory: FlightCategory, latitude: Double?, longitude: Double?,
        elevationMeters: Double?
    ) {
        self.station = station
        self.name = name
        self.observedAt = observedAt
        self.rawText = rawText
        self.temperatureC = temperatureC
        self.dewpointC = dewpointC
        self.wind = wind
        self.visibility = visibility
        self.altimeterHPa = altimeterHPa
        self.clouds = clouds
        self.weather = weather
        self.flightCategory = flightCategory
        self.latitude = latitude
        self.longitude = longitude
        self.elevationMeters = elevationMeters
    }
}
