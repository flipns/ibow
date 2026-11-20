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
}
