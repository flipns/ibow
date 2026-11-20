/// Parses free text such as "lemd, LEBL  lepa" into an ordered, de-duplicated list of ICAO codes.
public enum AirportQuery {
    public static let maxCodes = 10

    public static func parse(_ text: String) throws(WeatherError) -> [ICAOCode] {
        let parts = text
            .split(whereSeparator: { !($0.isLetter || $0.isNumber) })
            .map(String.init)

        var seen = Set<ICAOCode>()
        var result: [ICAOCode] = []
        for part in parts {
            guard let code = ICAOCode(part) else { throw .invalidCode(part) }
            if seen.insert(code).inserted { result.append(code) }
        }
        return Array(result.prefix(maxCodes))
    }
}
