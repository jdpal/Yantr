import Foundation

@MainActor
final class AppModel: ObservableObject {
    @Published var menuBarItems: [MenuBarItem] = []
    @Published var selectedSection: AppSection = .menuBar
    @Published var permissionState: AccessibilityPermissionService.State = .unknown
    @Published var lastErrorMessage: String?

    let permissions = AccessibilityPermissionService()
    let scanner = MenuBarScanner()
    let layoutController = MenuBarLayoutController()
    let loginItemService = LoginItemService()

    init() {
        permissionState = permissions.currentState
        Task { await refreshMenuBarItems() }
    }

    func refreshMenuBarItems() async {
        permissionState = permissions.currentState
        do {
            menuBarItems = try await scanner.scan()
            lastErrorMessage = nil
        } catch {
            lastErrorMessage = error.localizedDescription
        }
    }

    func requestAccessibility() {
        permissions.request()
        permissionState = permissions.currentState
    }

    func moveItem(_ id: UUID, to visibility: MenuBarVisibility, before targetID: UUID? = nil) {
        guard id != targetID else { return }
        guard let sourceIndex = menuBarItems.firstIndex(where: { $0.id == id }) else { return }
        var item = menuBarItems.remove(at: sourceIndex)
        item.visibility = visibility

        if let targetID,
           let destinationIndex = menuBarItems.firstIndex(where: { $0.id == targetID }) {
            menuBarItems.insert(item, at: destinationIndex)
        } else {
            menuBarItems.append(item)
        }

        normalizeOrder()
        layoutController.saveDesiredLayout(menuBarItems)
    }

    func normalizeOrder() {
        for index in menuBarItems.indices {
            menuBarItems[index].order = index
        }
    }
}

enum AppSection: String, CaseIterable, Identifiable {
    case menuBar = "Menu Bar"
    case shortcuts = "Shortcuts"
    case automations = "Automations"
    case settings = "Settings"

    var id: String { rawValue }
}
