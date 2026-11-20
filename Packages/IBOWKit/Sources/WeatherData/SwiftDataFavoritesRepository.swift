import Foundation
import SwiftData
import WeatherDomain

@Model
final class FavoriteRecord {
    @Attribute(.unique) var code: String
    var addedAt: Date

    init(code: String, addedAt: Date) {
        self.code = code
        self.addedAt = addedAt
    }
}

/// SwiftData-backed favorites. `@ModelActor` gives it its own serial executor and `ModelContext`,
/// so database work never touches the main actor.
@ModelActor
public actor SwiftDataFavoritesRepository: FavoritesRepository {
    /// Composition-root factory (the model type is internal, so the container is built here).
    public static func make(inMemory: Bool = false) throws -> SwiftDataFavoritesRepository {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: inMemory)
        let container = try ModelContainer(for: FavoriteRecord.self, configurations: configuration)
        return SwiftDataFavoritesRepository(modelContainer: container)
    }

    public func favorites() throws -> [ICAOCode] {
        let descriptor = FetchDescriptor<FavoriteRecord>(sortBy: [SortDescriptor(\.addedAt, order: .reverse)])
        return try modelContext.fetch(descriptor).compactMap { ICAOCode($0.code) }
    }

    public func setFavorite(_ code: ICAOCode, isFavorite: Bool) throws {
        let value = code.value
        let existing = try modelContext.fetch(
            FetchDescriptor<FavoriteRecord>(predicate: #Predicate { $0.code == value }))
        if isFavorite {
            guard existing.isEmpty else { return }
            modelContext.insert(FavoriteRecord(code: value, addedAt: Date()))
        } else {
            existing.forEach { modelContext.delete($0) }
        }
        try modelContext.save()
    }
}
