public enum WeatherError: Error, Sendable, Equatable {
    /// The user typed something that is not a valid ICAO code.
    case invalidCode(String)
    case network
    case server(statusCode: Int)
    case decoding
}
