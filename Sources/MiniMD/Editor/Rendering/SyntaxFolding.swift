import AppKit

/// Applies the "fold" (hide) / "reveal" (show, muted) treatment to a range of
/// syntax-marker characters. Folding never deletes characters — it shrinks
/// the marker to a near-zero-width, transparent glyph so the raw text buffer
/// stays byte-identical to what gets saved (spec section 5, "text attribute
/// folding").
enum SyntaxFolding {
    static func fold(_ range: NSRange, in textStorage: NSTextStorage, theme: EditorTheme) {
        guard range.length > 0 else { return }
        textStorage.addAttributes([
            .font: theme.foldedMarkerFont,
            .foregroundColor: NSColor.clear,
            .kern: -theme.foldedMarkerFont.pointSize
        ], range: range)
    }

    static func reveal(_ range: NSRange, in textStorage: NSTextStorage, theme: EditorTheme) {
        guard range.length > 0 else { return }
        textStorage.addAttributes([
            .font: theme.visibleMarkerFont,
            .foregroundColor: theme.mutedColor
        ], range: range)
    }

    static func apply(_ range: NSRange, in textStorage: NSTextStorage, theme: EditorTheme, folded: Bool) {
        folded ? fold(range, in: textStorage, theme: theme) : reveal(range, in: textStorage, theme: theme)
    }
}
