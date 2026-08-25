import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    /// Matches the UTI declared in Info.plist so this app is a valid
    /// candidate handler for `.md` files (spec section 3).
    static var markdown: UTType {
        UTType(exportedAs: "net.daringfireball.markdown", conformingTo: .plainText)
    }
}

/// Raw UTF-8 markdown text. This is the single source of truth — the editor
/// only ever applies *display* attributes on top of this string; nothing is
/// added to or transformed in what gets written back to disk.
struct MarkdownDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.markdown, .plainText] }
    static var writableContentTypes: [UTType] { [.markdown, .plainText] }

    var text: String

    init(text: String = "") {
        self.text = text
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.text = string
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(text.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
}
