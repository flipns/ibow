import Foundation
import Testing
import WeatherDomain
@testable import WeatherPresentation

private func metar(raw: String, clouds: [CloudLayer] = [], lat: Double? = nil, lon: Double? = nil, at t: TimeInterval = 0) -> Metar {
    Metar(station: ICAOCode("LEMD")!, name: nil, observedAt: Date(timeIntervalSince1970: t), rawText: raw,
          temperatureC: nil, dewpointC: nil, wind: nil, visibility: nil, altimeterHPa: nil, clouds: clouds,
          weather: nil, flightCategory: .vfr, latitude: lat, longitude: lon, elevationMeters: nil)
}

@MainActor
@Suite("WeatherCondition")
struct WeatherConditionTests {
    @Test func presentWeatherWinsOverClouds() {
        let m = metar(raw: "METAR LFPG 201230Z 24015KT 9999 -SHRA BKN020TCU 12/08 Q1002",
                      clouds: [CloudLayer(cover: .broken, baseFeet: 2000)])
        #expect(WeatherCondition(m) == .showers)
    }

    @Test func thunderstormBeatsEverything() {
        #expect(WeatherCondition(metar(raw: "METAR LEMD 201230Z 24015KT 5000 +TSRA BKN020CB 12/08 Q1002")) == .thunderstorm)
    }

    @Test func fogAndMist() {
        #expect(WeatherCondition(metar(raw: "METAR LEMD 201230Z 00000KT 0400 FG VV001 05/05 Q1020")) == .fog)
    }

    @Test func cloudCoverWhenNoPhenomena() {
        func cond(_ cover: CloudLayer.Cover) -> WeatherCondition {
            WeatherCondition(metar(raw: "METAR LEMD 201230Z 24005KT 9999 12/08 Q1020", clouds: [CloudLayer(cover: cover, baseFeet: 3000)]))
        }
        #expect(cond(.few) == .fewClouds)
        #expect(cond(.scattered) == .scattered)
        #expect(cond(.broken) == .broken)
        #expect(cond(.overcast) == .overcast)
        #expect(WeatherCondition(metar(raw: "METAR LEBL 201030Z 32007KT CAVOK 15/07 Q1020")) == .clear)
    }

    @Test func everyConditionHasSymbolsAndSpeech() {
        let all: [WeatherCondition] = [.clear, .fewClouds, .scattered, .broken, .overcast, .fog, .drizzle, .rain, .showers, .thunderstorm, .snow, .hail]
        for c in all {
            #expect(!c.spokenName.isEmpty)
            #expect(!c.symbolName(isDaylight: true).isEmpty)
            #expect(!c.symbolName(isDaylight: false).isEmpty)
        }
    }

    @Test func daylightMadridInNovember() {
        // 2026-11-20 12:00Z (midday) and 23:00Z (night) at Madrid (40.47N, 3.56W)
        let noon = Date(timeIntervalSince1970: 1_795_262_400)
        let night = noon.addingTimeInterval(11 * 3600)
        #expect(Daylight.isDaylight(at: noon, latitude: 40.47, longitude: -3.56))
        #expect(!Daylight.isDaylight(at: night, latitude: 40.47, longitude: -3.56))
    }

    @Test func unknownLocationAssumesDaylight() {
        #expect(Daylight.isDaylight(at: .now, latitude: nil, longitude: nil))
    }

    @Test func visibilityAndWindSummaries() {
        #expect(Visibility(statuteMiles: 6, isLowerBound: true).shortDescription == "≥ 10 km")
        #expect(Wind(direction: .degrees(240), speedKnots: 15, gustKnots: 35).summaryDescription == "viento 240° a 15 kt")
        #expect(Wind(direction: .variable, speedKnots: 0, gustKnots: nil).summaryDescription == "viento en calma")
    }
}
