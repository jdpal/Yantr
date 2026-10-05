import AppKit
import SwiftUI

struct MainWindowView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        NavigationSplitView {
            List(AppSection.allCases, selection: $model.selectedSection) { section in
                Label(section.rawValue, systemImage: icon(for: section))
                    .tag(section)
            }
            .navigationSplitViewColumnWidth(min: 170, ideal: 190)
        } detail: {
            Group {
                switch model.selectedSection {
                case .menuBar:
                    MenuBarLayoutView()
                case .shortcuts:
                    PlaceholderSectionView(
                        title: "Shortcuts",
                        message: "Global shortcuts and window actions are the next implementation milestone.",
                        systemImage: "keyboard"
                    )
                case .automations:
                    PlaceholderSectionView(
                        title: "Automations",
                        message: "Build simple trigger → action rules here without requiring Lua.",
                        systemImage: "bolt"
                    )
                case .settings:
                    SettingsView()
                        .padding(16)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            Task { await model.refreshMenuBarItems() }
        }
        .alert("Yantr", isPresented: Binding(
            get: { model.lastErrorMessage != nil },
            set: { if !$0 { model.lastErrorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { model.lastErrorMessage = nil }
        } message: {
            Text(model.lastErrorMessage ?? "")
        }
    }

    private func icon(for section: AppSection) -> String {
        switch section {
        case .menuBar: return "menubar.rectangle"
        case .shortcuts: return "keyboard"
        case .automations: return "bolt"
        case .settings: return "gearshape"
        }
    }
}

private struct PlaceholderSectionView: View {
    let title: String
    let message: String
    let systemImage: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 34))
                .foregroundStyle(.secondary)
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}
