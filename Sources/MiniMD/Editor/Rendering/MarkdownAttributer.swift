import AppKit

/// Orchestrates a full re-render: resets base attributes, then delegates
/// per-line to `BlockStyler` and `InlineStyler`. A line is "active" (its
/// syntax marks are revealed instead of folded) when the cursor/selection
/// touches it — this is what gives the Obsidian-style "click a line to see
/// its raw markdown" behavior (spec section 5.4).
enum MarkdownAttributer {
    static func apply(to textStorage: NSTextStorage, lines: [MarkdownLine], selectedRange: NSRange, theme: EditorTheme) {
        textStorage.beginEditing()
        defer { textStorage.endEditing() }

        let full = NSRange(location: 0, length: textStorage.length)
        textStorage.setAttributes([.font: theme.bodyFont, .foregroundColor: theme.textColor], range: full)

        for line in lines {
            let lineIsActive = touches(selectedRange, line.contentRange)
            BlockStyler.style(line, isActive: lineIsActive, textStorage: textStorage, theme: theme)

            let activeSpanIndex = lineIsActive
                ? line.inlineSpans.firstIndex { touches(selectedRange, $0.fullRange) }
                : nil
            InlineStyler.style(line.inlineSpans, activeSpanIndex: activeSpanIndex, textStorage: textStorage, theme: theme)
        }
    }

    /// True if the selection is inside, or (for a caret) sitting right at the
    /// edge of, the given range — so folded marks reveal as soon as the
    /// cursor arrives at either boundary of the line/span.
    private static func touches(_ selection: NSRange, _ range: NSRange) -> Bool {
        if NSIntersectionRange(selection, range).length > 0 { return true }
        if selection.length == 0 {
            return selection.location >= range.location && selection.location <= NSMaxRange(range)
        }
        return false
    }
}
