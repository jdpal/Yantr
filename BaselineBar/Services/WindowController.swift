import AppKit
import ApplicationServices

final class WindowController {
    enum WindowError: LocalizedError {
        case accessibilityPermissionRequired
        case noFrontmostApplication
        case noFocusedWindow

        var errorDescription: String? {
            switch self {
            case .accessibilityPermissionRequired: return "Accessibility permission is required."
            case .noFrontmostApplication: return "No frontmost application was found."
            case .noFocusedWindow: return "No focused window was found."
            }
        }
    }

    func moveFrontWindow(to placement: WindowPlacement) throws {
        guard AXIsProcessTrusted() else { throw WindowError.accessibilityPermissionRequired }
        guard let app = NSWorkspace.shared.frontmostApplication else { throw WindowError.noFrontmostApplication }

        let appElement = AXUIElementCreateApplication(app.processIdentifier)
        var windowValue: CFTypeRef?
        guard AXUIElementCopyAttributeValue(appElement, kAXFocusedWindowAttribute as CFString, &windowValue) == .success,
              let windowValue,
              CFGetTypeID(windowValue) == AXUIElementGetTypeID() else {
            throw WindowError.noFocusedWindow
        }

        let window = unsafeBitCast(windowValue, to: AXUIElement.self)
        guard let screen = NSScreen.main else { return }
        let visible = screen.visibleFrame

        let target: CGRect
        switch placement {
        case .leftHalf:
            target = CGRect(x: visible.minX, y: visible.minY, width: visible.width / 2, height: visible.height)
        case .rightHalf:
            target = CGRect(x: visible.midX, y: visible.minY, width: visible.width / 2, height: visible.height)
        case .centered:
            target = CGRect(x: visible.minX + visible.width * 0.15,
                            y: visible.minY + visible.height * 0.10,
                            width: visible.width * 0.70,
                            height: visible.height * 0.80)
        case .maximized:
            target = visible
        }

        setFrame(target, on: window)
    }

    private func setFrame(_ frame: CGRect, on window: AXUIElement) {
        var position = frame.origin
        var size = frame.size

        if let positionValue = AXValueCreate(.cgPoint, &position) {
            AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, positionValue)
        }
        if let sizeValue = AXValueCreate(.cgSize, &size) {
            AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, sizeValue)
        }
    }
}
