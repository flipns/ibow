/// Port implemented by the Data layer.
public protocol WeatherRepository: Sendable {
    /// Latest METAR for each requested station. Must honour task cancellation
    /// by throwing `CancellationError`.
    func metars(for codes: [ICAOCode]) async throws -> [Metar]
}
