import Testing
@testable import DesignSystem

@MainActor
@Suite("DesignSystem")
struct DesignSystemTests {
    @Test func manropeIsBundled() {
        #expect(FontRegistry.registerIfNeeded())
    }

    @Test func secondaryTextMeetsAA() {
        #expect(RGB.contrast(Palette.secondaryTextOnSurface, Palette.surface) >= 4.5)
    }

    @Test func mutedTextMeetsAA() {
        #expect(RGB.contrast(Palette.mutedTextOnSurface, Palette.surface) >= 4.5)
    }

    @Test func specMutedTextWouldFail() {
        // Documents why we deviate from the 40 % opacity in DESIGN.md.
        let spec = Palette.white.over(Palette.surface, alpha: 0.40)
        #expect(RGB.contrast(spec, Palette.surface) < 4.5)
    }

    @Test func primaryButtonLabelMeetsAA() {
        #expect(RGB.contrast(Palette.onPrimary, Palette.primary) >= 4.5)
    }

    @Test(arguments: [StatusTone.positive, .info, .warning, .critical])
    func badgeTextReadableOnSurface(tone: StatusTone) {
        #expect(RGB.contrast(tone.rgb, Palette.surface) >= 4.5)
    }
}
