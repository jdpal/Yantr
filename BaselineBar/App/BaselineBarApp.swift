import SwiftUI

@main
struct BaselineBarApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        MenuBarExtra("BaselineBar", systemImage: "menubar.rectangle") {
            MenuBarPopoverView()
                .environmentObject(appModel)
        }
        .menuBarExtraStyle(.window)

        Window("BaselineBar", id: "main") {
            MainWindowView()
                .environmentObject(appModel)
                .frame(minWidth: 760, minHeight: 520)
        }
        .defaultSize(width: 920, height: 640)

        Settings {
            SettingsView()
                .environmentObject(appModel)
                .frame(width: 520)
                .padding()
        }
    }
}
