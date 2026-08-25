import AppKit

/// Applies block-level attributes (heading size, blockquote indent, list
/// markers, code fences, horizontal rules, tables) for one classified line.
enum BlockStyler {
    static func style(_ line: MarkdownLine, isActive: Bool, textStorage: NSTextStorage, theme: EditorTheme) {
        switch line.kind {
        case .heading(let level):
            textStorage.addAttributes([.font: theme.headingFont(level: level)], range: line.contentRange)
            if let marker = line.markerRange {
                SyntaxFolding.apply(marker, in: textStorage, theme: theme, folded: !isActive)
            }

        case .blockquote:
            let style = NSMutableParagraphStyle()
            style.headIndent = 18
            style.firstLineHeadIndent = 18
            textStorage.addAttributes([
                .paragraphStyle: style,
                .foregroundColor: theme.quoteColor,
                .obliqueness: 0.08
            ], range: line.contentRange)
            if let marker = line.markerRange {
                SyntaxFolding.apply(marker, in: textStorage, theme: theme, folded: !isActive)
            }

        case .unorderedListItem(let indent), .checklistItem(let indent, _):
            applyListIndent(indent: indent, ordered: false, textStorage: textStorage, range: line.contentRange)
            if let marker = line.markerRange {
                styleListMarker(marker, checklist: line.kind, isActive: isActive, textStorage: textStorage, theme: theme)
            }

        case .orderedListItem(let indent, _):
            applyListIndent(indent: indent, ordered: true, textStorage: textStorage, range: line.contentRange)
            if let marker = line.markerRange {
                SyntaxFolding.apply(marker, in: textStorage, theme: theme, folded: !isActive)
            }

        case .fencedCodeFence:
            textStorage.addAttributes([
                .font: theme.monospacedFont(size: theme.bodyFont.pointSize - 2),
                .foregroundColor: theme.mutedColor,
                .backgroundColor: theme.codeBackground
            ], range: line.contentRange)

        case .fencedCodeContent:
            textStorage.addAttributes([
                .font: theme.monospacedFont(),
                .backgroundColor: theme.codeBackground
            ], range: line.contentRange)

        case .horizontalRule:
            SyntaxFolding.apply(line.contentRange, in: textStorage, theme: theme, folded: !isActive)
            if !isActive {
                textStorage.addAttributes([
                    .strikethroughStyle: NSUnderlineStyle.thick.rawValue,
                    .strikethroughColor: theme.hrColor
                ], range: line.contentRange)
            }

        case .tableSeparatorRow:
            SyntaxFolding.apply(line.contentRange, in: textStorage, theme: theme, folded: !isActive)

        case .tableRow:
            textStorage.addAttributes([.font: theme.monospacedFont()], range: line.contentRange)

        case .paragraph, .blank:
            break
        }
    }

    private static func applyListIndent(indent: Int, ordered: Bool, textStorage: NSTextStorage, range: NSRange) {
        let style = NSMutableParagraphStyle()
        let depth = CGFloat(indent) / 2 + 1
        style.headIndent = 20 * depth
        style.firstLineHeadIndent = 20 * depth - 16
        textStorage.addAttributes([.paragraphStyle: style], range: range)
    }

    private static func styleListMarker(_ marker: NSRange, checklist: BlockKind, isActive: Bool, textStorage: NSTextStorage, theme: EditorTheme) {
        if case .checklistItem(_, let checked) = checklist {
            // Checkboxes stay visible and clickable rather than folded (see
            // MarkdownTextView's click handling) — folding them would remove
            // the ability to tap them.
            textStorage.addAttributes([
                .font: theme.visibleMarkerFont,
                .foregroundColor: checked ? NSColor.systemGreen : theme.mutedColor
            ], range: marker)
            return
        }
        SyntaxFolding.apply(marker, in: textStorage, theme: theme, folded: !isActive)
    }
}
