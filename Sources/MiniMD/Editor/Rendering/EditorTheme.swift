import AppKit

/// Fonts and colors used when rendering markdown live-preview attributes.
/// Centralized so rendering code never hardcodes a font or color inline.
struct EditorTheme {
    var bodyFont: NSFont
    var textColor: NSColor = .labelColor
    var mutedColor: NSColor = .tertiaryLabelColor
    var linkColor: NSColor = .linkColor
    var quoteColor: NSColor = .secondaryLabelColor
    var codeBackground: NSColor = NSColor.textBackgroundColor.blendedGray(amount: 0.06)
    var hrColor: NSColor = .separatorColor

    init(settings: AppSettings) {
        self.bodyFont = settings.resolvedFont(size: CGFloat(settings.fontSize))
    }

    func headingFont(level: Int) -> NSFont {
        let sizes: [Int: CGFloat] = [1: 28, 2: 24, 3: 20, 4: 18, 5: 16, 6: 15]
        let size = sizes[level] ?? bodyFont.pointSize
        return NSFont.boldSystemFont(ofSize: size)
    }

    func monospacedFont(size: CGFloat? = nil) -> NSFont {
        NSFont.monospacedSystemFont(ofSize: size ?? bodyFont.pointSize, weight: .regular)
    }

    /// Font used for a syntax marker when it's kept visible (cursor on that line) — small and muted.
    var visibleMarkerFont: NSFont {
        NSFont.systemFont(ofSize: max(bodyFont.pointSize - 2, 10))
    }

    /// Effectively-invisible font used to fold a marker while keeping it in the text buffer.
    var foldedMarkerFont: NSFont {
        NSFont.systemFont(ofSize: 0.1)
    }
}

private extension NSColor {
    func blendedGray(amount: CGFloat) -> NSColor {
        blended(withFraction: amount, of: .gray) ?? self
    }
}
