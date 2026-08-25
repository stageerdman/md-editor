import AppKit

/// Applies inline-span attributes (bold, italic, code, strikethrough, links)
/// for one classified line, folding markers when the cursor isn't touching
/// that span.
enum InlineStyler {
    static func style(_ spans: [InlineSpan], activeSpanIndex: Int?, textStorage: NSTextStorage, theme: EditorTheme) {
        for (index, span) in spans.enumerated() {
            let isActive = index == activeSpanIndex
            switch span.kind {
            case .bold:
                addTrait(.bold, to: span.contentRange, in: textStorage)
            case .italic:
                addTrait(.italic, to: span.contentRange, in: textStorage)
            case .code:
                textStorage.addAttributes([
                    .font: theme.monospacedFont(size: theme.bodyFont.pointSize - 1),
                    .backgroundColor: theme.codeBackground
                ], range: span.contentRange)
            case .strikethrough:
                textStorage.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: span.contentRange)
            case .link:
                textStorage.addAttributes([
                    .foregroundColor: theme.linkColor,
                    .underlineStyle: NSUnderlineStyle.single.rawValue,
                    .underlineColor: theme.linkColor
                ], range: span.contentRange)
            }
            for marker in span.markerRanges {
                SyntaxFolding.apply(marker, in: textStorage, theme: theme, folded: !isActive)
            }
        }
    }

    private static func addTrait(_ trait: NSFontDescriptor.SymbolicTraits, to range: NSRange, in textStorage: NSTextStorage) {
        textStorage.enumerateAttribute(.font, in: range, options: []) { value, subrange, _ in
            let base = (value as? NSFont) ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)
            var traits = base.fontDescriptor.symbolicTraits
            traits.insert(trait)
            let descriptor = base.fontDescriptor.withSymbolicTraits(traits)
            let font = NSFont(descriptor: descriptor, size: base.pointSize) ?? base
            textStorage.addAttribute(.font, value: font, range: subrange)
        }
    }
}
