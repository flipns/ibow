import Foundation
import Observation
import WeatherDomain

/// Search screen logic.
///
/// Guarantees:
/// - A new query cancels the previous task (debounce sleep or in-flight request).
/// - A response that belongs to an older query is never shown (generation check),
///   even if the underlying request ignores cancellation.
/// - Cancellation is not an error.
@Observable
public final class SearchViewModel {
    public enum State: Equatable {
        case idle
        case loading
        case results([Metar])
        case empty
        case failed(WeatherError)
    }

    public private(set) var state: State = .idle
    public var query: String = "" {
        didSet { if query != oldValue { schedule(debounced: true) } }
    }

    public typealias Search = @Sendable (String) async throws -> [Metar]
    public typealias Sleep = @Sendable (Duration) async throws -> Void

    private let search: Search
    private let sleep: Sleep
    private let debounce: Duration
    private var task: Task<Void, Never>?
    private var generation = 0

    public init(
        debounce: Duration = .milliseconds(300),
        sleep: @escaping Sleep = { try await Task.sleep(for: $0) },
        search: @escaping Search
    ) {
        self.debounce = debounce
        self.sleep = sleep
        self.search = search
    }

    /// Keyboard "search" key / pull-to-refresh: no debounce.
    public func submit() { schedule(debounced: false) }

    private func schedule(debounced: Bool) {
        task?.cancel()
        generation += 1
        let current = generation
        let text = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !text.isEmpty else {
            task = nil
            state = .idle
            return
        }

        task = Task { [weak self, debounce, sleep] in
            if debounced {
                try? await sleep(debounce)
                if Task.isCancelled { return }
            }
            await self?.run(text, generation: current)
        }
    }

    private func run(_ text: String, generation current: Int) async {
        guard current == generation else { return }
        state = .loading
        do {
            let metars = try await search(text)
            guard current == generation, !Task.isCancelled else { return }   // stale → drop
            state = metars.isEmpty ? .empty : .results(metars)
        } catch is CancellationError {
            return
        } catch {
            guard current == generation, !Task.isCancelled else { return }
            state = .failed(error as? WeatherError ?? .network)
        }
    }
}
