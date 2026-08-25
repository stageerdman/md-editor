import SwiftUI

/// The single editor window's content — no sidebar, no tabs, no chrome, per
/// spec ("no vaults, no plugins, no file browser").
struct ContentView: View {
    @Binding var document: MarkdownDocument
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        MarkdownTextView(text: $document.text, theme: EditorTheme(settings: settings))
            .frame(minWidth: 480, minHeight: 360)
    }
}
