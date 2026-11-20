import Foundation
import Testing
@testable import WeatherPresentation

@Suite("ObservationAge")
struct ObservationAgeTests {
    private let now = Date(timeIntervalSince1970: 1_000_000)

    private func text(secondsAgo: TimeInterval) -> String? {
        ObservationAge.text(from: now.addingTimeInterval(-secondsAgo), now: now)
    }

    @Test func underAMinute() { #expect(text(secondsAgo: 30) == "hace menos de 1 min") }
    @Test func minutes() { #expect(text(secondsAgo: 12 * 60 + 40) == "hace 12 min") }
    @Test func exactHour() { #expect(text(secondsAgo: 3600) == "hace 1 h") }
    @Test func hoursAndMinutes() { #expect(text(secondsAgo: 3600 * 2 + 5 * 60) == "hace 2 h 5 min") }
    @Test func days() { #expect(text(secondsAgo: 3600 * 49) == "hace 2 d") }
    @Test func futureObservationReadsAsNow() { #expect(text(secondsAgo: -120) == "ahora") }
    @Test func unknownObservationTimeHasNoAge() {
        #expect(ObservationAge.text(from: .distantPast, now: now) == nil)
    }
}
