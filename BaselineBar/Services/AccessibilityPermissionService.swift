import AppKit
@preconcurrency import ApplicationServices

final class AccessibilityPermissionService {
    enum State: Equatable {
        case unknown
        case granted
        case denied
    }

    var currentState: State {
        AXIsProcessTrusted() ? .granted : .denied
    }

    func request() {
        let options = [
            kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true
        ] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
    }

    func openSystemSettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") else { return }
        NSWorkspace.shared.open(url)
    }
}
