import CoreText
import Foundation

public enum FontRegistry {
    private static let registered: Bool = {
        let bundle = Bundle.module
        let url = bundle.url(forResource: "Manrope-Variable", withExtension: "ttf")
            ?? bundle.url(forResource: "Manrope-Variable", withExtension: "ttf", subdirectory: "Fonts")
        guard let url else { return false }
        var error: Unmanaged<CFError>?
        let ok = CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
        return ok || error != nil
    }()

    @discardableResult
    public static func registerIfNeeded() -> Bool { registered }
}
