import Foundation
import WeatherDomain

public struct RemoteWeatherRepository: WeatherRepository {
    private let transport: any HTTPTransport
    private let baseURL: URL

    public init(
        transport: any HTTPTransport = URLSessionTransport(),
        baseURL: URL = URL(string: "https://aviationweather.gov/api/data/metar")!
    ) {
        self.transport = transport
        self.baseURL = baseURL
    }

    public func metars(for codes: [ICAOCode]) async throws -> [Metar] {
        guard !codes.isEmpty else { return [] }

        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "ids", value: codes.map(\.value).joined(separator: ",")),
            URLQueryItem(name: "format", value: "json"),
        ]
        var request = URLRequest(url: components.url!)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 15

        let data: Data
        let response: HTTPURLResponse
        do {
            (data, response) = try await transport.data(for: request)
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as URLError where error.code == .cancelled {
            throw CancellationError()
        } catch {
            throw WeatherError.network
        }

        switch response.statusCode {
        case 204: return []           // no reports for those stations
        case 200..<300: break
        default: throw WeatherError.server(statusCode: response.statusCode)
        }
        if data.isEmpty { return [] }

        do {
            let dtos = try JSONDecoder().decode([MetarDTO].self, from: data)
            return dtos.compactMap { $0.toDomain() }
        } catch {
            throw WeatherError.decoding
        }
    }
}
