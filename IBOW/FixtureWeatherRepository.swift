import Foundation
import WeatherDomain

/// Deterministic repository used only when the app is launched with `-ui-testing`.
/// Lets UI tests exercise the real UI and view models without the network.
nonisolated struct FixtureWeatherRepository: WeatherRepository {
    func metars(for codes: [ICAOCode]) async throws -> [Metar] {
        // The report group (ddHHmmZ) is derived from `observedAt`, so both always agree.
        let observedAt = Date().addingTimeInterval(-12 * 60)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        let c = calendar.dateComponents([.day, .hour, .minute], from: observedAt)
        let zulu = String(format: "%02d%02d%02dZ", c.day ?? 1, c.hour ?? 0, c.minute ?? 0)
        return codes.map { code in
            Metar(station: code, name: "\(code.value) Fixture Airport", observedAt: observedAt,
                  rawText: "METAR \(code.value) \(zulu) 24015KT 9999 FEW040 12/08 Q1018",
                  temperatureC: 12, dewpointC: 8, wind: nil, visibility: nil, altimeterHPa: 1018, clouds: [],
                  weather: nil, flightCategory: .vfr, latitude: nil, longitude: nil, elevationMeters: nil)
        }
    }
}
