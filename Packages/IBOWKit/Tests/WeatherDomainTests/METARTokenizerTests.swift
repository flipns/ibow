import Testing
import WeatherDomain

@Suite("METARTokenizer")
struct METARTokenizerTests {
    @Test func classifiesATypicalReport() {
        let raw = "LEMD 191830Z 27010G20KT 240V300 9999 -RA FEW040 BKN100 12/05 Q1018 NOSIG"
        let kinds = METARTokenizer.tokenize(raw).map(\.kind)

        #expect(kinds == [
            .station, .observationTime, .wind, .windVariation, .visibility,
            .presentWeather, .clouds, .clouds, .temperature, .pressure, .trend,
        ])
    }

    @Test func handlesVariableWindNegativeTempsAndUSUnits() {
        let tokens = METARTokenizer.tokenize("KJFK 191851Z VRB03KT 10SM CLR M02/M10 A3002")
        #expect(tokens.map(\.kind) == [.station, .observationTime, .wind, .visibility, .clouds, .temperature, .pressure])
    }

    @Test func everythingAfterRMKIsRemarks() {
        let tokens = METARTokenizer.tokenize("LEBL 191830Z 9999 RMK AO2 SLP123")
        #expect(tokens.suffix(3).allSatisfy { $0.kind == .remarks })
    }

    @Test func tokensKeepOriginalTextAndStableIDs() {
        let tokens = METARTokenizer.tokenize("LEMD  191830Z")
        #expect(tokens.map(\.text) == ["LEMD", "191830Z"])
        #expect(tokens.map(\.id) == [0, 1])
    }

    @Test func realReportWithMETARPrefixAndCAVOK() {
        let tokens = METARTokenizer.tokenize("METAR LEBL 201030Z 32007KT CAVOK 15/07 Q1020 NOSIG")
        #expect(tokens.map(\.kind) == [.modifier, .station, .observationTime, .wind, .visibility, .temperature, .pressure, .trend])
    }

    @Test func realReportWithWindVariation() {
        let tokens = METARTokenizer.tokenize("METAR LEMD 201030Z 17003KT 130V210 9999 FEW013 11/08 Q1024 NOSIG")
        #expect(tokens.map(\.kind) == [.modifier, .station, .observationTime, .wind, .windVariation, .visibility, .clouds, .temperature, .pressure, .trend])
    }
}
