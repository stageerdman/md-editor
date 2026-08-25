import SwiftUI

/// Minimal settings per spec section 8: font, size, appearance — nothing else.
struct SettingsView: View {
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        Form {
            Picker("Font", selection: $settings.fontName) {
                ForEach(AppSettings.availableFonts, id: \.self) { name in
                    Text(name).tag(name)
                }
            }

            Stepper(value: $settings.fontSize, in: 10...32, step: 1) {
                Text("Size: \(Int(settings.fontSize))")
            }

            Picker("Appearance", selection: Binding(
                get: { settings.appearanceMode },
                set: { settings.appearanceMode = $0 }
            )) {
                ForEach(AppSettings.AppearanceMode.allCases) { mode in
                    Text(mode.rawValue.capitalized).tag(mode)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(24)
        .frame(width: 360)
    }
}
