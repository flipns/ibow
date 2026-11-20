import DesignSystem
import WeatherDomain

extension FlightCategory {
    public var title: String {
        switch self {
        case .vfr: "VFR"
        case .mvfr: "MVFR"
        case .ifr: "IFR"
        case .lifr: "LIFR"
        case .unknown: "—"
        }
    }

    /// Read aloud by VoiceOver instead of letter-by-letter acronyms.
    public var spokenName: String {
        switch self {
        case .vfr: "condiciones de vuelo visual"
        case .mvfr: "condiciones visuales marginales"
        case .ifr: "condiciones de vuelo instrumental"
        case .lifr: "condiciones instrumentales bajas"
        case .unknown: "condiciones desconocidas"
        }
    }

    public var systemImage: String {
        switch self {
        case .vfr: "checkmark.circle"
        case .mvfr: "exclamationmark.circle"
        case .ifr: "exclamationmark.triangle"
        case .lifr: "xmark.octagon"
        case .unknown: "questionmark.circle"
        }
    }

    public var tone: StatusTone {
        switch self {
        case .vfr: .positive
        case .mvfr: .info
        case .ifr: .critical
        case .lifr: .warning
        case .unknown: .neutral
        }
    }
}
