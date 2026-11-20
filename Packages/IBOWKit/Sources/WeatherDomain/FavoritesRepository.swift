/// Port for the user's favorite airports. Implemented by the Data layer (SwiftData).
public protocol FavoritesRepository: Sendable {
    /// Favorite codes, most recently added first.
    func favorites() async throws -> [ICAOCode]
    /// Idempotent: adding an existing favorite or removing a missing one is a no-op.
    func setFavorite(_ code: ICAOCode, isFavorite: Bool) async throws
}
