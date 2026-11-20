public enum WeatherError: Error, Sendable, Equatable {
    case invalidCode(String)
    case network
    case server(statusCode: Int)
    case decoding
}
