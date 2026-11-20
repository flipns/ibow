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
        // Already-registered is fine (e.g. previews re-running).
        return ok || error != nil
    }()

    /// Call once at app start. Returns false if the font file is missing from the bundle.
    @discardableResult
    public static func registerIfNeeded() -> Bool { registered }
}
