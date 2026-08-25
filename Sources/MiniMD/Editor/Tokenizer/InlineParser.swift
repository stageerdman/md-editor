import Foundation

/// Parses inline formatting (bold, italic, code, strikethrough, links) within
/// a single line of text. Regex-based rather than a full CommonMark inline
/// parser — sufficient for live-preview folding on a single small document.
enum InlineParser {
    private struct Rule {
        let regex: NSRegularExpression
        let makeKind: (NSTextCheckingResult, NSString) -> InlineSpan.Kind
        /// Index of the capture group holding the marker length on each side,
        /// used to compute marker vs. content ranges.
        let markerLength: Int
    }

    private static let codeRegex = try! NSRegularExpression(pattern: "`([^`\\n]+)`")
    private static let linkRegex = try! NSRegularExpression(pattern: "\\[([^\\]\\n]+)\\]\\(([^)\\n]+)\\)")
    private static let boldStarRegex = try! NSRegularExpression(pattern: "\\*\\*([^*\\n]+)\\*\\*")
    private static let boldUnderRegex = try! NSRegularExpression(pattern: "__([^_\\n]+)__")
    private static let strikeRegex = try! NSRegularExpression(pattern: "~~([^~\\n]+)~~")
    private static let italicStarRegex = try! NSRegularExpression(pattern: "(?<!\\*)\\*([^*\\n]+)\\*(?!\\*)")
    private static let italicUnderRegex = try! NSRegularExpression(pattern: "(?<!_)_([^_\\n]+)_(?!_)")

    /// - Parameters:
    ///   - content: the full line text (not including the newline).
    ///   - lineRange: where `content` sits in the document's NSString coordinate space.
    ///   - skippingPrefixLength: number of leading characters (a block marker like "- ") to exclude from inline matching.
    static func parse(content: String, lineRange: NSRange, skippingPrefixLength: Int) -> [InlineSpan] {
        let ns = content as NSString
        guard skippingPrefixLength < ns.length else { return [] }
        let searchRange = NSRange(location: skippingPrefixLength, length: ns.length - skippingPrefixLength)

        var claimed: [NSRange] = []
        var spans: [InlineSpan] = []

        func offset(_ r: NSRange) -> NSRange {
            NSRange(location: r.location + lineRange.location, length: r.length)
        }

        func tryClaim(_ range: NSRange) -> Bool {
            for c in claimed where NSIntersectionRange(c, range).length > 0 { return false }
            claimed.append(range)
            return true
        }

        // Code spans first — their contents are literal and must not be
        // touched by later rules.
        for match in codeRegex.matches(in: content, range: searchRange) {
            guard tryClaim(match.range) else { continue }
            let inner = match.range(at: 1)
            spans.append(InlineSpan(
                kind: .code,
                fullRange: offset(match.range),
                markerRanges: [offset(NSRange(location: match.range.location, length: 1)),
                               offset(NSRange(location: NSMaxRange(match.range) - 1, length: 1))],
                contentRange: offset(inner)
            ))
        }

        for match in linkRegex.matches(in: content, range: searchRange) {
            guard tryClaim(match.range) else { continue }
            let textRange = match.range(at: 1)
            let urlRange = match.range(at: 2)
            let url = ns.substring(with: urlRange)
            spans.append(InlineSpan(
                kind: .link(url: url),
                fullRange: offset(match.range),
                markerRanges: [
                    offset(NSRange(location: match.range.location, length: textRange.location - match.range.location)),
                    offset(NSRange(location: NSMaxRange(textRange), length: NSMaxRange(match.range) - NSMaxRange(textRange)))
                ],
                contentRange: offset(textRange)
            ))
        }

        for regex in [boldStarRegex, boldUnderRegex] {
            for match in regex.matches(in: content, range: searchRange) {
                guard tryClaim(match.range) else { continue }
                let inner = match.range(at: 1)
                spans.append(InlineSpan(
                    kind: .bold,
                    fullRange: offset(match.range),
                    markerRanges: [offset(NSRange(location: match.range.location, length: 2)),
                                   offset(NSRange(location: NSMaxRange(match.range) - 2, length: 2))],
                    contentRange: offset(inner)
                ))
            }
        }

        for match in strikeRegex.matches(in: content, range: searchRange) {
            guard tryClaim(match.range) else { continue }
            let inner = match.range(at: 1)
            spans.append(InlineSpan(
                kind: .strikethrough,
                fullRange: offset(match.range),
                markerRanges: [offset(NSRange(location: match.range.location, length: 2)),
                               offset(NSRange(location: NSMaxRange(match.range) - 2, length: 2))],
                contentRange: offset(inner)
            ))
        }

        for regex in [italicStarRegex, italicUnderRegex] {
            for match in regex.matches(in: content, range: searchRange) {
                guard tryClaim(match.range) else { continue }
                let inner = match.range(at: 1)
                spans.append(InlineSpan(
                    kind: .italic,
                    fullRange: offset(match.range),
                    markerRanges: [offset(NSRange(location: match.range.location, length: 1)),
                                   offset(NSRange(location: NSMaxRange(match.range) - 1, length: 1))],
                    contentRange: offset(inner)
                ))
            }
        }

        return spans.sorted { $0.fullRange.location < $1.fullRange.location }
    }
}
