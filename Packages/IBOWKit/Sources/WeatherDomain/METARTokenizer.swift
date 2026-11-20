public enum METARTokenKind: Sendable, Hashable, CaseIterable {
    case station, observationTime, modifier, wind, windVariation, visibility
    case presentWeather, clouds, temperature, pressure, trend, remarks, unknown
}

public struct METARToken: Sendable, Hashable, Identifiable {
    public let id: Int
    public let text: String
    public let kind: METARTokenKind
}

public enum METARTokenizer {
    public static func tokenize(_ raw: String) -> [METARToken] {
        var inRemarks = false
        return raw.split(whereSeparator: \.isWhitespace).enumerated().map { index, part in
            let text = String(part)
            if text == "RMK" { inRemarks = true }
            let kind: METARTokenKind = inRemarks ? .remarks : classify(text, index: index)
            return METARToken(id: index, text: text, kind: kind)
        }
    }

    static func classify(_ t: String, index: Int) -> METARTokenKind {
        if t == "METAR" || t == "SPECI" { return .modifier }
        if t == "AUTO" || t == "COR" || t == "NIL" { return .modifier }
        if t.wholeMatch(of: /\d{6}Z/) != nil { return .observationTime }
        if t.wholeMatch(of: /(\d{3}|VRB)\d{2,3}(G\d{2,3})?(KT|MPS)/) != nil { return .wind }
        if t.wholeMatch(of: /\d{3}V\d{3}/) != nil { return .windVariation }
        if t == "CAVOK" || t.wholeMatch(of: /\d{4}/) != nil
            || t.wholeMatch(of: /(M|P)?(\d+ )?(\d+\/\d+|\d+)SM/) != nil { return .visibility }
        if t.wholeMatch(of: /(FEW|SCT|BKN|OVC|VV)(\d{3}|\/{3})(CB|TCU)?/) != nil
            || ["SKC", "CLR", "NSC", "NCD"].contains(t) { return .clouds }
        if t.wholeMatch(of: /M?\d{2}\/(M?\d{2})?/) != nil { return .temperature }
        if t.wholeMatch(of: /(Q|A)\d{4}/) != nil { return .pressure }
        if ["NOSIG", "BECMG", "TEMPO"].contains(t) { return .trend }
        if t.wholeMatch(of: /[-+]?(VC)?(MI|BC|PR|DR|BL|SH|TS|FZ)?(DZ|RA|SN|SG|IC|PL|GR|GS|UP|BR|FG|FU|VA|DU|SA|HZ|PY|PO|SQ|FC|SS|DS)+/) != nil {
            return .presentWeather
        }
        if index <= 1, t.wholeMatch(of: /[A-Z][A-Z0-9]{3}/) != nil { return .station }
        return .unknown
    }
}
