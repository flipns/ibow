import Foundation
import Testing
import WeatherDomain
@testable import WeatherPresentation

@MainActor
@Suite("Formatting")
struct FormattingTests {
    @Test func windShortDescription() {
        #expect(Wind(direction: .degrees(90), speedKnots: 8, gustKnots: 18).shortDescription == "090° · 8 kt · G18")
        #expect(Wind(direction: .variable, speedKnots: 3, gustKnots: nil).shortDescription == "VRB · 3 kt")
    }

    @Test func icaoIsSpelledForVoiceOver() {
        #expect(ICAOCode("lemd")!.spelled == "L E M D")
    }

    @Test func spokenWindMentionsGusts() {
        let wind = Wind(direction: .degrees(270), speedKnots: 10, gustKnots: 20)
        #expect(wind.spokenDescription == "viento de 270 grados, 10 nudos, con rachas de 20")
    }

    @Test func everyCategoryHasLabelsAndIcon() {
        for category in FlightCategory.allCases {
            #expect(!category.title.isEmpty)
            #expect(!category.spokenName.isEmpty)
            #expect(!category.systemImage.isEmpty)
        }
    }

    @Test func missingValuesAreNeverSpokenAsZero() {
        let none = Metar(station: ICAOCode("KCEW")!, name: nil, observedAt: .distantPast, rawText: "KCEW",
                         temperatureC: nil, dewpointC: nil, wind: nil, visibility: nil, altimeterHPa: nil, clouds: [],
                         weather: nil, flightCategory: .unknown, latitude: nil, longitude: nil, elevationMeters: nil)
        #expect(none.spokenTemperatureAndDewpoint == "temperatura y punto de rocío sin dato")
        #expect(none.spokenPressure == "QNH sin dato")
        #expect(!none.spokenSummary.contains("grados"))
    }

    @Test func presentValuesAreSpoken() {
        let full = Metar(station: ICAOCode("LEMD")!, name: nil, observedAt: .distantPast, rawText: "LEMD",
                         temperatureC: 11.4, dewpointC: 8, wind: nil, visibility: nil, altimeterHPa: 1024, clouds: [],
                         weather: nil, flightCategory: .vfr, latitude: nil, longitude: nil, elevationMeters: nil)
        #expect(full.spokenTemperatureAndDewpoint == "temperatura 11 grados, punto de rocío 8 grados")
        #expect(full.spokenPressure == "QNH 1024 hectopascales")
    }
}
