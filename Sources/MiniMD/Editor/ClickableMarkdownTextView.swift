import AppKit

/// An `NSTextView` that intercepts clicks on checklist markers (toggle) and
/// cmd-clicks on links (open in browser) before falling back to normal text
/// editing behavior.
final class ClickableMarkdownTextView: NSTextView {
    weak var coordinator: MarkdownTextView.Coordinator?

    override func mouseDown(with event: NSEvent) {
        guard let coordinator else {
            super.mouseDown(with: event)
            return
        }

        let point = convert(event.locationInWindow, from: nil)
        let index = characterIndexForInsertion(at: point)

        if let line = coordinator.line(at: index),
           case .checklistItem = line.kind,
           let marker = line.markerRange,
           NSLocationInRange(index, marker) {
            coordinator.toggleChecklist(on: line)
            return
        }

        if event.modifierFlags.contains(.command), let line = coordinator.line(at: index) {
            for span in line.inlineSpans {
                if case .link(let url) = span.kind, NSLocationInRange(index, span.fullRange) {
                    coordinator.openLink(urlString: url)
                    return
                }
            }
        }

        super.mouseDown(with: event)
    }
}
