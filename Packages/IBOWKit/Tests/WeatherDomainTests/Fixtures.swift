import Foundation
import WeatherDomain

extension Metar {
    static func fixture(_ icao: String, category: FlightCategory = .vfr) -> Metar {
        Metar(
            station: ICAOCode(icao)!, name: nil, observedAt: Date(timeIntervalSince1970: 1_700_000_000),
            rawText: "\(icao) 191830Z 27010KT 9999 FEW040 12/05 Q1018",
            temperatureC: 12, dewpointC: 5, wind: Wind(direction: .degrees(270), speedKnots: 10, gustKnots: nil),
            visibility: Visibility(statuteMiles: 6.2), altimeterHPa: 1018, clouds: [],
            weather: nil, flightCategory: category, latitude: nil, longitude: nil, elevationMeters: nil
        )
    }
}
