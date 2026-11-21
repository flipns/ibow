import Foundation
import WeatherDomain

struct MetarDTO: Decodable, Sendable {
    struct CloudDTO: Decodable, Sendable {
        let cover: String?
        let base: Int?

        private enum CodingKeys: String, CodingKey { case cover, base }

        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            cover = try? c.decodeIfPresent(String.self, forKey: .cover)
            base = c.lossyDouble(.base).map(Int.init)
        }
    }

    let icaoId: String
    let name: String?
    let obsTime: Double?
    let temp: Double?
    let dewp: Double?
    let wdirDegrees: Int?
    let wdirIsVariable: Bool
    let wspd: Double?
    let wgst: Double?
    let visibMiles: Double?
    let visibIsLowerBound: Bool
    let altim: Double?
    let wxString: String?
    let rawOb: String
    let lat: Double?
    let lon: Double?
    let elev: Double?
    let clouds: [CloudDTO]
    let fltCat: String?

    private enum CodingKeys: String, CodingKey {
        case icaoId, name, obsTime, temp, dewp, wdir, wspd, wgst, visib, altim
        case wxString, rawOb, lat, lon, elev, clouds, fltCat
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        icaoId = try c.decode(String.self, forKey: .icaoId)
        rawOb = try c.decode(String.self, forKey: .rawOb)
        name = try? c.decodeIfPresent(String.self, forKey: .name)
        obsTime = c.lossyDouble(.obsTime)
        temp = c.lossyDouble(.temp)
        dewp = c.lossyDouble(.dewp)
        wspd = c.lossyDouble(.wspd)
        wgst = c.lossyDouble(.wgst)
        altim = c.lossyDouble(.altim)
        lat = c.lossyDouble(.lat)
        lon = c.lossyDouble(.lon)
        elev = c.lossyDouble(.elev)
        wxString = try? c.decodeIfPresent(String.self, forKey: .wxString)
        fltCat = try? c.decodeIfPresent(String.self, forKey: .fltCat)
        clouds = (try? c.decodeIfPresent([CloudDTO].self, forKey: .clouds)) ?? []

        if let number = c.lossyDouble(.wdir) {
            wdirDegrees = Int(number); wdirIsVariable = false
        } else if let text = try? c.decodeIfPresent(String.self, forKey: .wdir), text.uppercased() == "VRB" {
            wdirDegrees = nil; wdirIsVariable = true
        } else {
            wdirDegrees = nil; wdirIsVariable = false
        }

        if let number = c.lossyDouble(.visib) {
            visibMiles = number; visibIsLowerBound = false
        } else if let text = try? c.decodeIfPresent(String.self, forKey: .visib) {
            let plus = text.hasSuffix("+")
            visibMiles = Double(text.trimmingCharacters(in: CharacterSet(charactersIn: "+ ")))
            visibIsLowerBound = plus
        } else {
            visibMiles = nil; visibIsLowerBound = false
        }
    }

    func toDomain() -> Metar? {
        guard let station = ICAOCode(icaoId) else { return nil }

        let wind: Wind? = wspd.map { speed in
            Wind(
                direction: wdirIsVariable ? .variable : (wdirDegrees.map { .degrees($0) } ?? .variable),
                speedKnots: Int(speed),
                gustKnots: wgst.map(Int.init)
            )
        }

        return Metar(
            station: station,
            name: name,
            observedAt: obsTime.map { Date(timeIntervalSince1970: $0) } ?? .distantPast,
            rawText: rawOb,
            temperatureC: temp,
            dewpointC: dewp,
            wind: wind,
            visibility: visibMiles.map { Visibility(statuteMiles: $0, isLowerBound: visibIsLowerBound) },
            altimeterHPa: altim,
            clouds: clouds.map { CloudLayer(cover: Self.cover($0.cover), baseFeet: $0.base) },
            weather: wxString?.isEmpty == false ? wxString : nil,
            flightCategory: FlightCategory(apiValue: fltCat),
            latitude: lat,
            longitude: lon,
            elevationMeters: elev
        )
    }

    private static func cover(_ raw: String?) -> CloudLayer.Cover {
        switch raw?.uppercased() {
        case "CLR", "SKC", "NCD", "NSC", "CAVOK": .clear
        case "FEW": .few
        case "SCT": .scattered
        case "BKN": .broken
        case "OVC": .overcast
        case "VV": .verticalVisibility
        default: .unknown
        }
    }
}

extension KeyedDecodingContainer {
    func lossyDouble(_ key: Key) -> Double? {
        if let value = try? decodeIfPresent(Double.self, forKey: key) { return value }
        if let text = try? decodeIfPresent(String.self, forKey: key) { return Double(text) }
        return nil
    }
}
