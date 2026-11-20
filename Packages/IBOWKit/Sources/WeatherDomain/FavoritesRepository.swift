public protocol FavoritesRepository: Sendable {
    func favorites() async throws -> [ICAOCode]
    func setFavorite(_ code: ICAOCode, isFavorite: Bool) async throws
}
