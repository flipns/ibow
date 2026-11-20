public struct SearchMetarsUseCase: Sendable {
    private let repository: any WeatherRepository

    public init(repository: any WeatherRepository) {
        self.repository = repository
    }

    public func callAsFunction(query: String) async throws -> [Metar] {
        let codes = try AirportQuery.parse(query)
        guard !codes.isEmpty else { return [] }
        let result = try await repository.metars(for: codes)
        let order = Dictionary(uniqueKeysWithValues: codes.enumerated().map { ($1, $0) })
        return result.sorted { (order[$0.station] ?? .max) < (order[$1.station] ?? .max) }
    }
}
