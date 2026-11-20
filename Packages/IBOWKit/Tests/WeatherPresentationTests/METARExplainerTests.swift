import Testing
import WeatherDomain
@testable import WeatherPresentation

@Suite("METARExplainer")
struct METARExplainerTests {
    private func explain(_ raw: String, at index: Int = 0) -> TokenExplanation {
        METARExplainer.explain(METARTokenizer.tokenize(raw)[index])
    }

    @Test func windWithGusts() {
        #expect(explain("27010G20KT").detail == "Viento del 270°, 10 nudos. Con rachas de 20 nudos.")
    }

    @Test func variableAndCalmWind() {
        #expect(explain("VRB03KT").detail.contains("variable"))
        #expect(explain("00000KT").detail == "Calma.")
    }

    @Test func observationTime() {
        #expect(explain("191830Z").detail.contains("Día 19"))
        #expect(explain("191830Z").detail.contains("18:30 UTC"))
    }

    @Test func visibility() {
        #expect(explain("9999").detail == "10 km o más.")
        #expect(explain("4000").detail == "4000 metros.")
        #expect(explain("CAVOK").title == "CAVOK")
    }

    @Test func cloudsWithHeightAndConvective() {
        #expect(explain("FEW013").detail.contains("1300 ft"))
        #expect(explain("BKN030CB").detail.contains("cumulonimbos"))
    }

    @Test func negativeTemperatureAndDewpoint() {
        #expect(explain("M02/M10").detail == "Temperatura -2 °C, punto de rocío -10 °C.")
    }

    @Test func pressureInBothUnits() {
        #expect(explain("Q1024").detail.hasPrefix("1024 hPa"))
        #expect(explain("A3002").detail == "30.02 inHg.")
    }

    @Test func presentWeather() {
        let d = explain("-SHRA").detail
        #expect(d.contains("lluvia"))
        #expect(d.contains("débil"))
    }

    @Test func everyTokenKindProducesAnExplanation() {
        let raw = "METAR LEMD 201030Z AUTO 17003KT 130V210 9999 -RA FEW013 11/08 Q1024 NOSIG RMK X"
        for token in METARTokenizer.tokenize(raw) {
            let e = METARExplainer.explain(token)
            #expect(!e.title.isEmpty && !e.detail.isEmpty, "token \(token.text)")
        }
    }
}
