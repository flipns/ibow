import Foundation
import Testing
import WeatherDomain

@Suite("AirportQuery")
struct AirportQueryTests {
    @Test func parsesMixedSeparatorsCaseAndDuplicates() throws {
        let codes = try AirportQuery.parse("lemd, LEBL  lemd;lepa")
        #expect(codes.map(\.value) == ["LEMD", "LEBL", "LEPA"])
    }

    @Test func blankInputGivesNoCodes() throws {
        #expect(try AirportQuery.parse("  ,, ").isEmpty)
    }

    @Test(arguments: ["LEM", "LEMDX", "LE-D"])
    func rejectsInvalidCodes(_ input: String) {
        #expect(throws: WeatherError.self) { try AirportQuery.parse(input) }
    }

    @Test func capsNumberOfCodes() throws {
        let many = (0..<30).map { "LE\(String(format: "%02d", $0))" }.joined(separator: ",")
        #expect(try AirportQuery.parse(many).count == AirportQuery.maxCodes)
    }
}
