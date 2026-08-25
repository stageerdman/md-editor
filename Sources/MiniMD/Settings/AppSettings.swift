import SwiftUI

/// User-facing preferences: editor font, size, and appearance.
/// Intentionally minimal — see spec section 8 ("Minimal Settings").
final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    enum AppearanceMode: String, CaseIterable, Identifiable {
        case system, light, dark
        var id: String { rawValue }

        var colorScheme: ColorScheme? {
            switch self {
            case .system: return nil
            case .light: return .light
            case .dark: return .dark
            }
        }
    }

    @AppStorage("editorFontName") var fontName: String = "System Mono" {
        willSet { objectWillChange.send() }
    }
    @AppStorage("editorFontSize") var fontSize: Double = 16 {
        willSet { objectWillChange.send() }
    }
    @AppStorage("appearanceMode") var appearanceModeRaw: String = AppearanceMode.system.rawValue {
        willSet { objectWillChange.send() }
    }

    var appearanceMode: AppearanceMode {
        get { AppearanceMode(rawValue: appearanceModeRaw) ?? .system }
        set { appearanceModeRaw = newValue.rawValue }
    }

    static let availableFonts: [String] = [
        "System Mono", "System Sans", "System Serif",
        "SF Mono", "Menlo", "Monaco", "New York", "Helvetica Neue"
    ]

    func resolvedFont(size: CGFloat) -> NSFont {
        switch fontName {
        case "System Mono":
            return NSFont.monospacedSystemFont(ofSize: size, weight: .regular)
        case "System Sans":
            return NSFont.systemFont(ofSize: size)
        case "System Serif":
            return NSFont(descriptor: NSFont.systemFont(ofSize: size).fontDescriptor.withDesign(.serif) ?? NSFont.systemFont(ofSize: size).fontDescriptor, size: size)
                ?? NSFont.systemFont(ofSize: size)
        default:
            return NSFont(name: fontName, size: size) ?? NSFont.systemFont(ofSize: size)
        }
    }
}
