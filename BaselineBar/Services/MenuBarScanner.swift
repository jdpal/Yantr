import AppKit
import ApplicationServices

struct MenuBarScanner {
    enum ScanError: LocalizedError {
        case accessibilityPermissionRequired

        var errorDescription: String? {
            switch self {
            case .accessibilityPermissionRequired:
                return "Accessibility permission is required to inspect external menu-bar items."
            }
        }
    }

    func scan() async throws -> [MenuBarItem] {
        guard AXIsProcessTrusted() else { throw ScanError.accessibilityPermissionRequired }

        let runningApps = NSWorkspace.shared.runningApplications
        var discovered: [MenuBarItem] = []

        for app in runningApps {
            let appElement = AXUIElementCreateApplication(app.processIdentifier)
            var menuBarValue: CFTypeRef?
            let result = AXUIElementCopyAttributeValue(
                appElement,
                kAXExtrasMenuBarAttribute as CFString,
                &menuBarValue
            )

            guard result == .success,
                  let menuBarValue,
                  CFGetTypeID(menuBarValue) == AXUIElementGetTypeID() else {
                continue
            }

            let extrasMenuBar = unsafeBitCast(menuBarValue, to: AXUIElement.self)
            var childrenValue: CFTypeRef?
            let childrenResult = AXUIElementCopyAttributeValue(
                extrasMenuBar,
                kAXChildrenAttribute as CFString,
                &childrenValue
            )

            guard childrenResult == .success,
                  let children = childrenValue as? [AXUIElement] else {
                continue
            }

            for (index, child) in children.enumerated() {
                let title = stringAttribute(kAXTitleAttribute, from: child)
                    ?? stringAttribute(kAXDescriptionAttribute, from: child)
                    ?? app.localizedName
                    ?? "Menu item"

                discovered.append(
                    MenuBarItem(
                        title: title,
                        bundleIdentifier: app.bundleIdentifier,
                        ownerPID: app.processIdentifier,
                        visibility: .visible,
                        order: index,
                        canBeManaged: false
                    )
                )
            }
        }

        // The public Accessibility tree is inconsistent across status-item implementations.
        // Remove obvious duplicates and keep this scanner replaceable by a compatibility layer.
        let unique = Dictionary(grouping: discovered) {
            "\($0.bundleIdentifier ?? "unknown")|\($0.title)"
        }
        .compactMap { $0.value.first }
        .sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }

        return unique
    }

    private func stringAttribute(_ attribute: String, from element: AXUIElement) -> String? {
        var value: CFTypeRef?
        guard AXUIElementCopyAttributeValue(element, attribute as CFString, &value) == .success else {
            return nil
        }
        return value as? String
    }

}
