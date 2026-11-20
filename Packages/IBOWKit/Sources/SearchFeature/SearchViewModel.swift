import Foundation
import Observation
import WeatherDomain

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

    public func metar(for code: ICAOCode?) -> Metar? {
        guard let code, case .results(let metars) = state else { return nil }
        return metars.first { $0.station == code }
    }
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

    private var typedCodes: [String] {
        query.split(whereSeparator: { !($0.isLetter || $0.isNumber) }).map { $0.uppercased() }
    }

    public func isSelected(code: String) -> Bool { typedCodes.contains(code.uppercased()) }

    public func toggle(code: String) {
        var codes = typedCodes
        let code = code.uppercased()
        if let index = codes.firstIndex(of: code) { codes.remove(at: index) } else { codes.append(code) }
        query = codes.joined(separator: ", ")
    }

    public func submit() { schedule(debounced: false) }

    public func refresh() async {
        schedule(debounced: false)
        await task?.value
    }

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
            guard current == generation, !Task.isCancelled else { return }
            state = metars.isEmpty ? .empty : .results(metars)
        } catch is CancellationError {
            return
        } catch {
            guard current == generation, !Task.isCancelled else { return }
            state = .failed(error as? WeatherError ?? .network)
        }
    }
}
