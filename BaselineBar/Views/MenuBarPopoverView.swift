import SwiftUI

struct MenuBarPopoverView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("BaselineBar")
                .font(.headline)

            Button("Show BaselineBar") {
                openWindow(id: "main")
                NSApplication.shared.activate(ignoringOtherApps: true)
            }

            Divider()

            ForEach(model.menuBarItems.filter { $0.visibility == .hidden }.prefix(6)) { item in
                Text(item.title)
                    .font(.callout)
            }

            if model.menuBarItems.filter({ $0.visibility == .hidden }).isEmpty {
                Text("No hidden items")
                    .foregroundStyle(.secondary)
            }

            Divider()
            Button("Quit") { NSApplication.shared.terminate(nil) }
        }
        .padding(12)
        .frame(width: 280)
    }
}
