struct QuickAirport: Identifiable {
    let code: String
    let city: String
    var id: String { code }

    static let suggestions: [QuickAirport] = [
        .init(code: "LEMD", city: "Madrid"),
        .init(code: "LEVC", city: "Valencia"),
        .init(code: "KJFK", city: "New York"),
        .init(code: "LFPG", city: "París"),
        .init(code: "EGLL", city: "Londres"),
        .init(code: "NTAA", city: "Teahupo'o")
    ]
}
