import SwiftUI

@main
struct MiniMDApp: App {
    @StateObject private var settings = AppSettings.shared

    var body: some Scene {
        DocumentGroup(newDocument: MarkdownDocument()) { file in
            ContentView(document: file.$document)
                .environmentObject(settings)
                .preferredColorScheme(settings.appearanceMode.colorScheme)
        }

        Settings {
            SettingsView()
                .environmentObject(settings)
        }
    }
}
