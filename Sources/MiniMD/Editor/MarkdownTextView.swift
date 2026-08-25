import SwiftUI
import AppKit

/// SwiftUI bridge to the live-preview markdown editor. Owns no formatting
/// logic itself — parsing lives in `BlockParser`/`InlineParser`, rendering in
/// `MarkdownAttributer`; this file only wires an `NSTextView` to that
/// pipeline and to the SwiftUI text binding.
struct MarkdownTextView: NSViewRepresentable {
    @Binding var text: String
    var theme: EditorTheme

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        let textView = ClickableMarkdownTextView()

        textView.delegate = context.coordinator
        textView.coordinator = context.coordinator
        textView.string = text
        textView.isRichText = false
        textView.isEditable = true
        textView.isSelectable = true
        textView.allowsUndo = true
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.textContainerInset = NSSize(width: 16, height: 16)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.containerSize = NSSize(width: 0, height: CGFloat.greatestFiniteMagnitude)

        scrollView.documentView = textView
        scrollView.hasVerticalScroller = true
        scrollView.drawsBackground = true

        context.coordinator.textView = textView
        context.coordinator.theme = theme
        context.coordinator.reparseAndRender()

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        context.coordinator.theme = theme
        guard let textView = context.coordinator.textView else { return }
        if textView.string != text {
            let selection = textView.selectedRange()
            textView.string = text
            textView.setSelectedRange(selection)
        }
        context.coordinator.reparseAndRender()
    }
}
