import Foundation
import WeatherDomain

/// Deterministic repository used only when the app is launched with `-ui-testing`.
/// Lets UI tests exercise the real UI and view models without the network.
nonisolated struct FixtureWeatherRepository: WeatherRepository {
    func metars(for codes: [ICAOCode]) async throws -> [Metar] {
        codes.map { code in
            Metar(station: code, name: "\(code.value) Fixture Airport", observedAt: Date(),
                  rawText: "METAR \(code.value) 201230Z 24015KT 9999 FEW040 12/08 Q1018",
                  temperatureC: 12, dewpointC: 8, wind: nil, visibility: nil, altimeterHPa: 1018, clouds: [],
                  weather: nil, flightCategory: .vfr, latitude: nil, longitude: nil, elevationMeters: nil)
        }
    }
}
