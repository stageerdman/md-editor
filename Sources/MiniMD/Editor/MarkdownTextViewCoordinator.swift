import SwiftUI
import AppKit

extension MarkdownTextView {
    /// Bridges `NSTextView` events to the parse/render pipeline and to the
    /// SwiftUI text binding. Also the target for checkbox-click and
    /// cmd-click-link handling triggered by `ClickableMarkdownTextView`.
    final class Coordinator: NSObject, NSTextViewDelegate {
        private let text: Binding<String>
        weak var textView: NSTextView?
        var theme: EditorTheme
        private(set) var lines: [MarkdownLine] = []

        init(text: Binding<String>) {
            self.text = text
            self.theme = EditorTheme(settings: AppSettings.shared)
        }

        func textDidChange(_ notification: Notification) {
            guard let textView else { return }
            text.wrappedValue = textView.string
            reparseAndRender()
        }

        func textViewDidChangeSelection(_ notification: Notification) {
            render()
        }

        func reparseAndRender() {
            guard let textView else { return }
            lines = BlockParser.parse(textView.string)
            render()
        }

        private func render() {
            guard let textView, let storage = textView.textStorage else { return }
            MarkdownAttributer.apply(to: storage, lines: lines, selectedRange: textView.selectedRange(), theme: theme)
        }

        func line(at characterIndex: Int) -> MarkdownLine? {
            lines.first {
                NSLocationInRange(characterIndex, $0.contentRange) || characterIndex == NSMaxRange($0.contentRange)
            }
        }

        func toggleChecklist(on line: MarkdownLine) {
            guard let textView, let marker = line.markerRange,
                  case .checklistItem(_, let checked) = line.kind else { return }
            let ns = textView.string as NSString
            let markerText = ns.substring(with: marker)
            let toggled = checked
                ? markerText.replacingOccurrences(of: "[x] ", with: "[ ] ")
                             .replacingOccurrences(of: "[X] ", with: "[ ] ")
                : markerText.replacingOccurrences(of: "[ ] ", with: "[x] ")
            guard toggled != markerText, textView.shouldChangeText(in: marker, replacementString: toggled) else { return }
            textView.textStorage?.replaceCharacters(in: marker, with: toggled)
            textView.didChangeText()
        }

        func openLink(urlString: String) {
            guard let url = URL(string: urlString) else { return }
            NSWorkspace.shared.open(url)
        }
    }
}
