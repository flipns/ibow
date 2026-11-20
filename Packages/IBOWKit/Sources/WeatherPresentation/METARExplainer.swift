import Foundation
import WeatherDomain

public nonisolated struct TokenExplanation: Sendable, Equatable {
    public let title: String
    public let detail: String
    public var spoken: String { "\(title). \(detail)" }
}

public nonisolated enum METARExplainer {
    public static func explain(_ token: METARToken) -> TokenExplanation {
        let t = token.text
        switch token.kind {
        case .station:
            return .init(title: "Estación", detail: "\(t) es el código ICAO del aeropuerto que emite el informe.")
        case .observationTime:
            return observationTime(t)
        case .modifier:
            return modifier(t)
        case .wind:
            return wind(t)
        case .windVariation:
            let p = t.split(separator: "V").map(String.init)
            return .init(title: "Variación del viento",
                         detail: p.count == 2 ? "La dirección oscila entre \(p[0])° y \(p[1])°." : "Dirección variable.")
        case .visibility:
            return visibility(t)
        case .presentWeather:
            return weather(t)
        case .clouds:
            return clouds(t)
        case .temperature:
            return temperature(t)
        case .pressure:
            return pressure(t)
        case .trend:
            return trend(t)
        case .remarks:
            return .init(title: "Observaciones", detail: "Información adicional no codificada para la navegación.")
        case .unknown:
            return .init(title: "Grupo no reconocido", detail: "No tengo una explicación para «\(t)».")
        }
    }

    // MARK: - Groups

    static func observationTime(_ t: String) -> TokenExplanation {
        let d = Array(t.prefix(6))
        guard d.count == 6, let day = Int(String(d[0...1])) else {
            return .init(title: "Hora de observación", detail: "Formato no reconocido.")
        }
        return .init(title: "Hora de observación",
                     detail: "Día \(day) del mes, a las \(String(d[2...3])):\(String(d[4...5])) UTC.")
    }

    static func modifier(_ t: String) -> TokenExplanation {
        switch t {
        case "METAR": .init(title: "Tipo de informe", detail: "Informe meteorológico rutinario de aeródromo.")
        case "SPECI": .init(title: "Tipo de informe", detail: "Informe especial emitido por un cambio significativo.")
        case "AUTO": .init(title: "Observación automática", detail: "Generado por sensores, sin observador humano.")
        case "COR": .init(title: "Corrección", detail: "Sustituye a un informe anterior con errores.")
        default: .init(title: "Modificador", detail: t)
        }
    }

    static func wind(_ t: String) -> TokenExplanation {
        var body = t
        var unit = "nudos"
        if body.hasSuffix("KT") { body.removeLast(2) } else if body.hasSuffix("MPS") { body.removeLast(3); unit = "m/s" }

        let direction = String(body.prefix(3))
        var rest = String(body.dropFirst(3))
        var gust: Int?
        if let g = rest.firstIndex(of: "G") {
            gust = Int(rest[rest.index(after: g)...])
            rest = String(rest[..<g])
        }
        let speed = Int(rest) ?? 0

        if speed == 0 { return .init(title: "Viento", detail: "Calma.") }
        let head = direction == "VRB" ? "Viento de dirección variable" : "Viento del \(Int(direction) ?? 0)°"
        var detail = "\(head), \(speed) \(unit)."
        if let gust { detail += " Con rachas de \(gust) \(unit)." }
        return .init(title: "Viento", detail: detail)
    }

    static func visibility(_ t: String) -> TokenExplanation {
        if t == "CAVOK" {
            return .init(title: "CAVOK",
                         detail: "Visibilidad de 10 km o más, sin nubes por debajo de 5000 ft ni fenómenos significativos.")
        }
        if t.hasSuffix("SM") {
            return .init(title: "Visibilidad", detail: "\(t.dropLast(2)) millas terrestres.")
        }
        guard let meters = Int(t) else { return .init(title: "Visibilidad", detail: t) }
        return .init(title: "Visibilidad",
                     detail: meters >= 9999 ? "10 km o más." : "\(meters) metros.")
    }

    private static let descriptors = ["MI": "bajo", "BC": "bancos de", "PR": "parcial", "DR": "ventisca baja",
                                      "BL": "ventisca alta", "SH": "chubascos de", "TS": "tormenta con", "FZ": "engelante"]
    private static let phenomena = ["DZ": "llovizna", "RA": "lluvia", "SN": "nieve", "SG": "cristales de nieve",
                                    "IC": "cristales de hielo", "PL": "gránulos de hielo", "GR": "granizo",
                                    "GS": "granizo pequeño", "UP": "precipitación desconocida", "BR": "neblina",
                                    "FG": "niebla", "FU": "humo", "VA": "ceniza volcánica", "DU": "polvo",
                                    "SA": "arena", "HZ": "calima", "PY": "espray", "PO": "torbellinos de polvo",
                                    "SQ": "turbonadas", "FC": "tromba/tornado", "SS": "tormenta de arena",
                                    "DS": "tormenta de polvo"]

    static func weather(_ t: String) -> TokenExplanation {
        var s = Substring(t)
        var intensity = "moderada"
        if s.hasPrefix("-") { intensity = "débil"; s = s.dropFirst() }
        else if s.hasPrefix("+") { intensity = "fuerte"; s = s.dropFirst() }
        var nearby = false
        if s.hasPrefix("VC") { nearby = true; s = s.dropFirst(2) }

        var words: [String] = []
        while s.count >= 2 {
            let code = String(s.prefix(2))
            if let w = descriptors[code] ?? phenomena[code] { words.append(w) }
            s = s.dropFirst(2)
        }
        var detail = words.isEmpty ? t : words.joined(separator: " ").capitalizedFirst
        detail += ", intensidad \(intensity)"
        if nearby { detail += ", en las inmediaciones" }
        return .init(title: "Tiempo presente", detail: detail + ".")
    }

    static func clouds(_ t: String) -> TokenExplanation {
        let names = ["FEW": "Nubes escasas (1-2 octavos)", "SCT": "Nubes dispersas (3-4 octavos)",
                     "BKN": "Nubosidad fragmentada (5-7 octavos)", "OVC": "Cielo cubierto (8 octavos)",
                     "VV": "Cielo oscurecido; visibilidad vertical"]
        if let clear = ["SKC": "Cielo despejado", "CLR": "Cielo despejado (sin nubes bajo 12 000 ft)",
                        "NSC": "Sin nubes significativas", "NCD": "Sin nubes detectadas"][t] {
            return .init(title: "Nubes", detail: clear + ".")
        }
        let cover = String(t.prefix(while: { $0.isLetter }))
        let digits = t.dropFirst(cover.count).prefix(3)
        var detail = names[cover] ?? t
        if let hundreds = Int(digits) { detail += " a \(hundreds * 100) ft sobre el aeródromo" }
        if t.hasSuffix("CB") { detail += ", cumulonimbos" }
        if t.hasSuffix("TCU") { detail += ", cúmulos en desarrollo vertical" }
        return .init(title: "Nubes", detail: detail + ".")
    }

    static func temperature(_ t: String) -> TokenExplanation {
        func value(_ raw: Substring) -> String? {
            guard !raw.isEmpty else { return nil }
            let negative = raw.hasPrefix("M")
            guard let n = Int(raw.dropFirst(negative ? 1 : 0)) else { return nil }
            return "\(negative ? -n : n) °C"
        }
        let parts = t.split(separator: "/", omittingEmptySubsequences: false)
        let temp = parts.first.flatMap(value)
        let dew = parts.count > 1 ? value(parts[1]) : nil
        var detail = "Temperatura \(temp ?? "—")"
        if let dew { detail += ", punto de rocío \(dew)" }
        return .init(title: "Temperatura y rocío", detail: detail + ".")
    }

    static func pressure(_ t: String) -> TokenExplanation {
        let digits = t.dropFirst()
        guard let n = Int(digits) else { return .init(title: "Presión", detail: t) }
        if t.hasPrefix("Q") { return .init(title: "Presión (QNH)", detail: "\(n) hPa: ajuste altimétrico al nivel del mar.") }
        return .init(title: "Presión (altímetro)", detail: String(format: "%.2f inHg.", Double(n) / 100))
    }

    static func trend(_ t: String) -> TokenExplanation {
        switch t {
        case "NOSIG": .init(title: "Tendencia", detail: "Sin cambios significativos en las próximas 2 horas.")
        case "BECMG": .init(title: "Tendencia", detail: "Cambio gradual previsto.")
        case "TEMPO": .init(title: "Tendencia", detail: "Cambios temporales previstos.")
        default: .init(title: "Tendencia", detail: t)
        }
    }
}

private extension String {
    nonisolated var capitalizedFirst: String { prefix(1).uppercased() + dropFirst() }
}
