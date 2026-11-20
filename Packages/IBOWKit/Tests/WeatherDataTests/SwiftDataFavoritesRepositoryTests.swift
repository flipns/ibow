import Foundation
import Testing
import WeatherDomain
@testable import WeatherData

@Suite("SwiftDataFavoritesRepository")
struct SwiftDataFavoritesRepositoryTests {
    private let lemd = ICAOCode("LEMD")!
    private let lebl = ICAOCode("LEBL")!

    private func makeSUT() throws -> SwiftDataFavoritesRepository {
        try SwiftDataFavoritesRepository.make(inMemory: true)
    }

    @Test func startsEmpty() async throws {
        let sut = try makeSUT()
        #expect(try await sut.favorites().isEmpty)
    }

    @Test func addedFavoriteIsReturned() async throws {
        let sut = try makeSUT()
        try await sut.setFavorite(lemd, isFavorite: true)
        #expect(try await sut.favorites() == [lemd])
    }

    @Test func addingTwiceDoesNotDuplicate() async throws {
        let sut = try makeSUT()
        try await sut.setFavorite(lemd, isFavorite: true)
        try await sut.setFavorite(lemd, isFavorite: true)
        #expect(try await sut.favorites() == [lemd])
    }

    @Test func newestFirst() async throws {
        let sut = try makeSUT()
        try await sut.setFavorite(lemd, isFavorite: true)
        try await Task.sleep(for: .milliseconds(5))
        try await sut.setFavorite(lebl, isFavorite: true)
        #expect(try await sut.favorites() == [lebl, lemd])
    }

    @Test func removeDeletesAndIsIdempotent() async throws {
        let sut = try makeSUT()
        try await sut.setFavorite(lemd, isFavorite: true)
        try await sut.setFavorite(lemd, isFavorite: false)
        try await sut.setFavorite(lemd, isFavorite: false)
        #expect(try await sut.favorites().isEmpty)
    }
}
