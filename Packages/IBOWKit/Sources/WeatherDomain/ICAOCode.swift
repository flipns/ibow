import Foundation

public struct ICAOCode: Sendable, Hashable, Comparable, CustomStringConvertible {
    public let value: String

    public init?(_ raw: String) {
        let candidate = raw.trimmingCharacters(in: .whitespaces).uppercased()
        guard candidate.count == 4,
              candidate.allSatisfy({ $0.isASCII && ($0.isLetter || $0.isNumber) })
        else { return nil }
        self.value = candidate
    }

    public var description: String { value }

    public static func < (lhs: ICAOCode, rhs: ICAOCode) -> Bool { lhs.value < rhs.value }
}
