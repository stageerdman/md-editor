import Foundation

/// Splits the full document into classified lines. Re-run on every text
/// change (full-document reparse); simple and fast enough for the
/// single-small-file scope this app targets (spec section 4/5).
enum BlockParser {
    static func parse(_ text: String) -> [MarkdownLine] {
        let ns = text as NSString
        var lines: [MarkdownLine] = []
        var location = 0
        var inFence = false
        var fenceLanguage: String?

        while location <= ns.length {
            let lineRange = ns.lineRange(for: NSRange(location: location, length: 0))
            if lineRange.length == 0 { break }

            var contentRange = lineRange
            let lineString = ns.substring(with: lineRange)
            if lineString.hasSuffix("\r\n") {
                contentRange.length -= 2
            } else if lineString.hasSuffix("\n") || lineString.hasSuffix("\r") {
                contentRange.length -= 1
            }
            let content = ns.substring(with: contentRange)

            lines.append(classify(content: content, contentRange: contentRange, inFence: &inFence, fenceLanguage: &fenceLanguage))

            location = NSMaxRange(lineRange)
        }

        // Trailing empty line (document ends with "\n", or is empty).
        if ns.length == 0 || ns.hasSuffix("\n") {
            let range = NSRange(location: ns.length, length: 0)
            lines.append(MarkdownLine(contentRange: range, kind: .blank))
        }

        return lines
    }

    private static func classify(
        content: String,
        contentRange: NSRange,
        inFence: inout Bool,
        fenceLanguage: inout String?
    ) -> MarkdownLine {
        let trimmed = content.trimmingCharacters(in: .whitespaces)

        if trimmed.hasPrefix("```") {
            if inFence {
                let lang = fenceLanguage
                inFence = false
                fenceLanguage = nil
                return MarkdownLine(contentRange: contentRange, kind: .fencedCodeFence(language: lang))
            } else {
                let lang = String(trimmed.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                fenceLanguage = lang.isEmpty ? nil : lang
                inFence = true
                return MarkdownLine(contentRange: contentRange, kind: .fencedCodeFence(language: fenceLanguage))
            }
        }
        if inFence {
            return MarkdownLine(contentRange: contentRange, kind: .fencedCodeContent(language: fenceLanguage))
        }
        if trimmed.isEmpty {
            return MarkdownLine(contentRange: contentRange, kind: .blank)
        }
        if BlockPrefixMatchers.isHorizontalRule(trimmed) {
            return MarkdownLine(contentRange: contentRange, kind: .horizontalRule)
        }
        if let (level, markerLen) = BlockPrefixMatchers.headingLevel(content) {
            var line = MarkdownLine(contentRange: contentRange, kind: .heading(level: level))
            line.markerRange = NSRange(location: contentRange.location, length: markerLen)
            line.inlineSpans = InlineParser.parse(content: content, lineRange: contentRange, skippingPrefixLength: markerLen)
            return line
        }
        if let markerLen = BlockPrefixMatchers.blockquotePrefix(content) {
            var line = MarkdownLine(contentRange: contentRange, kind: .blockquote)
            line.markerRange = NSRange(location: contentRange.location, length: markerLen)
            line.inlineSpans = InlineParser.parse(content: content, lineRange: contentRange, skippingPrefixLength: markerLen)
            return line
        }
        if let (indent, checked, markerLen) = BlockPrefixMatchers.checklistPrefix(content) {
            var line = MarkdownLine(contentRange: contentRange, kind: .checklistItem(indent: indent, checked: checked))
            line.markerRange = NSRange(location: contentRange.location, length: markerLen)
            line.inlineSpans = InlineParser.parse(content: content, lineRange: contentRange, skippingPrefixLength: markerLen)
            return line
        }
        if let (indent, markerLen) = BlockPrefixMatchers.unorderedListPrefix(content) {
            var line = MarkdownLine(contentRange: contentRange, kind: .unorderedListItem(indent: indent))
            line.markerRange = NSRange(location: contentRange.location, length: markerLen)
            line.inlineSpans = InlineParser.parse(content: content, lineRange: contentRange, skippingPrefixLength: markerLen)
            return line
        }
        if let (indent, number, markerLen) = BlockPrefixMatchers.orderedListPrefix(content) {
            var line = MarkdownLine(contentRange: contentRange, kind: .orderedListItem(indent: indent, number: number))
            line.markerRange = NSRange(location: contentRange.location, length: markerLen)
            line.inlineSpans = InlineParser.parse(content: content, lineRange: contentRange, skippingPrefixLength: markerLen)
            return line
        }
        if trimmed.contains("|") {
            if BlockPrefixMatchers.isTableSeparatorRow(trimmed) {
                return MarkdownLine(contentRange: contentRange, kind: .tableSeparatorRow)
            }
            var line = MarkdownLine(contentRange: contentRange, kind: .tableRow)
            line.inlineSpans = InlineParser.parse(content: content, lineRange: contentRange, skippingPrefixLength: 0)
            return line
        }

        var line = MarkdownLine(contentRange: contentRange, kind: .paragraph)
        line.inlineSpans = InlineParser.parse(content: content, lineRange: contentRange, skippingPrefixLength: 0)
        return line
    }
}
