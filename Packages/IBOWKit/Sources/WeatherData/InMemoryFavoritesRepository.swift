import WeatherDomain

public actor InMemoryFavoritesRepository: FavoritesRepository {
    private var stored: [ICAOCode]

    public init(initial: [ICAOCode] = []) { stored = initial }

    public func favorites() -> [ICAOCode] { stored }

    public func setFavorite(_ code: ICAOCode, isFavorite: Bool) {
        stored.removeAll { $0 == code }
        if isFavorite { stored.insert(code, at: 0) }
    }
}
