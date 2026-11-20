import WeatherDomain

/// Non-persistent favorites. Used as the composition-root fallback when the SwiftData store can't be opened,
/// so the app keeps working (favorites just don't survive a relaunch) instead of crashing.
public actor InMemoryFavoritesRepository: FavoritesRepository {
    private var stored: [ICAOCode]

    public init(initial: [ICAOCode] = []) { stored = initial }

    public func favorites() -> [ICAOCode] { stored }

    public func setFavorite(_ code: ICAOCode, isFavorite: Bool) {
        stored.removeAll { $0 == code }
        if isFavorite { stored.insert(code, at: 0) }   // newest first, like the SwiftData store
    }
}
