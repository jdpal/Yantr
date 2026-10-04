import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var model: AppModel
    @State private var launchAtLogin = false

    var body: some View {
        Form {
            Section("Permissions") {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Accessibility")
                        Text("Needed to inspect and control supported external UI elements.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button(model.permissionState == .granted ? "Granted" : "Enable") {
                        model.requestAccessibility()
                    }
                    .disabled(model.permissionState == .granted)
                }
            }

            Section("General") {
                Toggle("Launch at login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { _, newValue in
                        do {
                            try model.loginItemService.setEnabled(newValue)
                        } catch {
                            model.lastErrorMessage = error.localizedDescription
                            launchAtLogin = model.loginItemService.isEnabled
                        }
                    }
            }
        }
        .formStyle(.grouped)
        .onAppear {
            launchAtLogin = model.loginItemService.isEnabled
            model.permissionState = model.permissions.currentState
        }
    }
}
