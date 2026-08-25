import Foundation

/// What a single line of the document represents, block-wise.
enum BlockKind: Equatable {
    case heading(level: Int)
    case blockquote
    case unorderedListItem(indent: Int)
    case orderedListItem(indent: Int, number: Int)
    case checklistItem(indent: Int, checked: Bool)
    case fencedCodeFence(language: String?)
    case fencedCodeContent(language: String?)
    case horizontalRule
    case tableSeparatorRow
    case tableRow
    case paragraph
    case blank
}

/// One line of the document plus everything needed to render it.
struct MarkdownLine {
    /// Range of the line's content, excluding the trailing newline.
    var contentRange: NSRange
    var kind: BlockKind
    /// Leading syntax marker to fold when the cursor isn't on this line
    /// (e.g. "# ", "> ", "- ", "1. ", "- [ ] ").
    var markerRange: NSRange?
    var inlineSpans: [InlineSpan] = []
}

/// An inline formatting run within a line (bold, italic, code, etc).
struct InlineSpan {
    enum Kind: Equatable {
        case bold
        case italic
        case code
        case strikethrough
        case link(url: String)
    }

    var kind: Kind
    /// Full range including the syntax markers, e.g. `**bold**`.
    var fullRange: NSRange
    /// The marker character ranges to fold away, e.g. leading/trailing `**`.
    var markerRanges: [NSRange]
    /// The inner range to style, e.g. `bold`.
    var contentRange: NSRange
}
