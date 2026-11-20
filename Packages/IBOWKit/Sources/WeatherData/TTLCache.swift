import Foundation

public actor TTLCache<Key: Hashable & Sendable, Value: Sendable> {
    private struct Entry {
        let value: Value
        let expiresAt: Date
    }

    private var storage: [Key: Entry] = [:]
    private let ttl: TimeInterval
    private let now: @Sendable () -> Date

    public init(ttl: TimeInterval, now: @escaping @Sendable () -> Date = { Date() }) {
        self.ttl = ttl
        self.now = now
    }

    public func value(for key: Key) -> Value? {
        guard let entry = storage[key] else { return nil }
        guard entry.expiresAt > now() else {
            storage[key] = nil
            return nil
        }
        return entry.value
    }

    public func insert(_ value: Value, for key: Key) {
        storage[key] = Entry(value: value, expiresAt: now().addingTimeInterval(ttl))
    }

    public func removeAll() { storage.removeAll() }
}
