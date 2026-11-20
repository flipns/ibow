import Foundation
import Synchronization
import Testing
import WeatherDomain
@testable import WeatherData

private struct StubTransport: HTTPTransport {
    let handler: @Sendable (URLRequest) throws -> (Data, Int)

    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, status) = try handler(request)
        let response = HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil, headerFields: nil)!
        return (data, response)
    }
}

/// Shape follows the documented aviationweather.gov JSON; mixes the awkward cases
/// (string visibility with "+", "VRB" wind, string numbers, null gust, missing cloud base).
private let sample = """
[
 {"icaoId":"LEMD","name":"Madrid/Barajas Intl, MD, ES","obsTime":1763577000,"temp":12,"dewp":5,
  "wdir":270,"wspd":10,"wgst":null,"visib":"6+","altim":1018,"wxString":"-RA",
  "rawOb":"LEMD 191830Z 27010KT 9999 -RA FEW040 12/05 Q1018","lat":40.47,"lon":-3.56,"elev":610,
  "clouds":[{"cover":"FEW","base":4000},{"cover":"CLR","base":null}],"fltCat":"VFR"},
 {"icaoId":"LEBL","wdir":"VRB","wspd":"3","wgst":18,"visib":10,"temp":"14.5",
  "rawOb":"LEBL 191830Z VRB03KT CAVOK 14/09 Q1019","clouds":[],"fltCat":"MVFR"},
 {"icaoId":"BAD","rawOb":"x"}
]
"""

@Suite("RemoteWeatherRepository")
struct RemoteWeatherRepositoryTests {
    @Test func buildsRequestWithCommaSeparatedIds() async throws {
        let captured = LockedBox<URL?>(nil)
        let sut = RemoteWeatherRepository(transport: StubTransport { request in
            captured.set(request.url)
            return (Data("[]".utf8), 200)
        })

        _ = try await sut.metars(for: [ICAOCode("LEMD")!, ICAOCode("LEBL")!])

        let items = URLComponents(url: captured.get()!, resolvingAgainstBaseURL: false)!.queryItems!
        #expect(items.contains(URLQueryItem(name: "ids", value: "LEMD,LEBL")))
        #expect(items.contains(URLQueryItem(name: "format", value: "json")))
    }

    @Test func decodesTolerantlyAndDropsInvalidStations() async throws {
        let sut = RemoteWeatherRepository(transport: StubTransport { _ in (Data(sample.utf8), 200) })

        let result = try await sut.metars(for: [ICAOCode("LEMD")!, ICAOCode("LEBL")!])

        #expect(result.count == 2)
        let madrid = try #require(result.first { $0.station.value == "LEMD" })
        #expect(madrid.visibility == Visibility(statuteMiles: 6, isLowerBound: true))
        #expect(madrid.wind == Wind(direction: .degrees(270), speedKnots: 10, gustKnots: nil))
        #expect(madrid.clouds.map(\.cover) == [.few, .clear])
        #expect(madrid.flightCategory == .vfr)

        let barcelona = try #require(result.first { $0.station.value == "LEBL" })
        #expect(barcelona.wind == Wind(direction: .variable, speedKnots: 3, gustKnots: 18))
        #expect(barcelona.temperatureC == 14.5)
        #expect(barcelona.flightCategory == .mvfr)
    }

    @Test func noContentMeansNoResults() async throws {
        let sut = RemoteWeatherRepository(transport: StubTransport { _ in (Data(), 204) })
        #expect(try await sut.metars(for: [ICAOCode("LEMD")!]).isEmpty)
    }

    @Test func mapsHTTPFailures() async {
        let sut = RemoteWeatherRepository(transport: StubTransport { _ in (Data(), 503) })
        await #expect(throws: WeatherError.server(statusCode: 503)) {
            try await sut.metars(for: [ICAOCode("LEMD")!])
        }
    }

    @Test func mapsGarbageToDecodingError() async {
        let sut = RemoteWeatherRepository(transport: StubTransport { _ in (Data("nope".utf8), 200) })
        await #expect(throws: WeatherError.decoding) { try await sut.metars(for: [ICAOCode("LEMD")!]) }
    }

    @Test func urlCancelledBecomesCancellationError() async {
        let sut = RemoteWeatherRepository(transport: StubTransport { _ in throw URLError(.cancelled) })
        await #expect(throws: CancellationError.self) { try await sut.metars(for: [ICAOCode("LEMD")!]) }
    }

    @Test func otherTransportErrorsBecomeNetworkError() async {
        let sut = RemoteWeatherRepository(transport: StubTransport { _ in throw URLError(.notConnectedToInternet) })
        await #expect(throws: WeatherError.network) { try await sut.metars(for: [ICAOCode("LEMD")!]) }
    }
}

final class LockedBox<T: Sendable>: Sendable {
    private let box: Mutex<T>
    init(_ value: T) { box = Mutex(value) }
    func set(_ v: T) { box.withLock { $0 = v } }
    func get() -> T { box.withLock { $0 } }
}
