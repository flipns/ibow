import Testing
import WeatherDomain
@testable import WeatherData

@Suite("InMemoryFavoritesRepository")
struct InMemoryFavoritesRepositoryTests {
    private let lemd = ICAOCode("LEMD")!
    private let lebl = ICAOCode("LEBL")!

    @Test func addsNewestFirstWithoutDuplicates() async {
        let sut = InMemoryFavoritesRepository()
        await sut.setFavorite(lemd, isFavorite: true)
        await sut.setFavorite(lebl, isFavorite: true)
        await sut.setFavorite(lemd, isFavorite: true)
        #expect(await sut.favorites() == [lemd, lebl])
    }

    @Test func removeIsIdempotent() async {
        let sut = InMemoryFavoritesRepository(initial: [lemd])
        await sut.setFavorite(lemd, isFavorite: false)
        await sut.setFavorite(lemd, isFavorite: false)
        #expect(await sut.favorites().isEmpty)
    }
}
