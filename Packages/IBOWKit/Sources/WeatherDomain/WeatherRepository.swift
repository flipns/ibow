public protocol WeatherRepository: Sendable {
    func metars(for codes: [ICAOCode]) async throws -> [Metar]
}
