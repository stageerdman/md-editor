import Foundation

/// Leading-marker recognizers for block-level lines. Kept separate from
/// `BlockParser` so each match rule stays a small, independently testable
/// function.
enum BlockPrefixMatchers {
    static func headingLevel(_ content: String) -> (level: Int, markerLength: Int)? {
        var level = 0
        for ch in content {
            if ch == "#" { level += 1 } else { break }
            if level > 6 { return nil }
        }
        guard level > 0, level <= 6 else { return nil }
        let ns = content as NSString
        guard ns.length > level, ns.character(at: level) == 32 /* space */ else { return nil }
        return (level, level + 1)
    }

    static func blockquotePrefix(_ content: String) -> Int? {
        guard content.hasPrefix(">") else { return nil }
        let ns = content as NSString
        if ns.length > 1, ns.character(at: 1) == 32 { return 2 }
        return 1
    }

    static func checklistPrefix(_ content: String) -> (indent: Int, checked: Bool, markerLength: Int)? {
        let ns = content as NSString
        var i = 0
        while i < ns.length, ns.character(at: i) == 32 { i += 1 }
        let indent = i
        let rest = ns.substring(from: i)
        for bullet in ["- ", "* ", "+ "] {
            if rest.hasPrefix(bullet + "[ ] ") {
                return (indent, false, i + bullet.count + 4)
            }
            if rest.hasPrefix(bullet + "[x] ") || rest.hasPrefix(bullet + "[X] ") {
                return (indent, true, i + bullet.count + 4)
            }
        }
        return nil
    }

    static func unorderedListPrefix(_ content: String) -> (indent: Int, markerLength: Int)? {
        let ns = content as NSString
        var i = 0
        while i < ns.length, ns.character(at: i) == 32 { i += 1 }
        let indent = i
        let rest = ns.substring(from: i)
        for bullet in ["- ", "* ", "+ "] {
            if rest.hasPrefix(bullet) { return (indent, i + bullet.count) }
        }
        return nil
    }

    static func orderedListPrefix(_ content: String) -> (indent: Int, number: Int, markerLength: Int)? {
        let ns = content as NSString
        var i = 0
        while i < ns.length, ns.character(at: i) == 32 { i += 1 }
        let indent = i
        var j = i
        var digits = ""
        while j < ns.length, let scalar = Unicode.Scalar(ns.character(at: j)), CharacterSet.decimalDigits.contains(scalar) {
            digits.append(Character(scalar))
            j += 1
        }
        guard !digits.isEmpty, let number = Int(digits) else { return nil }
        guard j + 1 < ns.length, ns.character(at: j) == 46 /* "." */, ns.character(at: j + 1) == 32 else {
            return nil
        }
        return (indent, number, j + 2)
    }

    static func isHorizontalRule(_ trimmed: String) -> Bool {
        guard trimmed.count >= 3 else { return false }
        let chars = Set(trimmed.replacingOccurrences(of: " ", with: ""))
        guard chars.count == 1, let c = chars.first, "-*_".contains(c) else { return false }
        return trimmed.replacingOccurrences(of: " ", with: "").count >= 3
    }

    static func isTableSeparatorRow(_ trimmed: String) -> Bool {
        guard trimmed.contains("|") else { return false }
        let cells = trimmed.split(separator: "|")
        guard !cells.isEmpty else { return false }
        for cell in cells {
            let c = cell.trimmingCharacters(in: .whitespaces)
            guard !c.isEmpty else { continue }
            let allowed = Set("-:")
            if !c.allSatisfy({ allowed.contains($0) }) { return false }
        }
        return true
    }
}
