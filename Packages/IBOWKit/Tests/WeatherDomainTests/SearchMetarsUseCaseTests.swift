import Testing
import WeatherDomain

private actor MockRepository: WeatherRepository {
    private(set) var receivedCodes: [[ICAOCode]] = []
    var result: Result<[Metar], WeatherError>

    init(result: Result<[Metar], WeatherError>) { self.result = result }

    func metars(for codes: [ICAOCode]) async throws -> [Metar] {
        receivedCodes.append(codes)
        return try result.get()
    }
}

@Suite("SearchMetarsUseCase")
struct SearchMetarsUseCaseTests {
    @Test func blankQueryDoesNotHitRepository() async throws {
        let repo = MockRepository(result: .success([]))
        let sut = SearchMetarsUseCase(repository: repo)

        #expect(try await sut(query: "   ").isEmpty)
        #expect(await repo.receivedCodes.isEmpty)
    }

    @Test func passesParsedCodesAndKeepsTypedOrder() async throws {
        // The API may return stations in any order.
        let repo = MockRepository(result: .success([.fixture("LEBL"), .fixture("LEMD")]))
        let sut = SearchMetarsUseCase(repository: repo)

        let result = try await sut(query: "lemd lebl")

        #expect(result.map(\.station.value) == ["LEMD", "LEBL"])
        #expect(await repo.receivedCodes.first?.map(\.value) == ["LEMD", "LEBL"])
    }

    @Test func invalidCodeFailsBeforeRepository() async {
        let repo = MockRepository(result: .success([]))
        let sut = SearchMetarsUseCase(repository: repo)

        await #expect(throws: WeatherError.invalidCode("XX")) { try await sut(query: "LEMD XX") }
        #expect(await repo.receivedCodes.isEmpty)
    }

    @Test func propagatesRepositoryErrors() async {
        let repo = MockRepository(result: .failure(.network))
        let sut = SearchMetarsUseCase(repository: repo)

        await #expect(throws: WeatherError.network) { try await sut(query: "LEMD") }
    }
}
