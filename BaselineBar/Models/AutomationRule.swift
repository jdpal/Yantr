import Foundation

struct AutomationRule: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var isEnabled: Bool
    var trigger: Trigger
    var actions: [Action]

    enum Trigger: Codable, Hashable {
        case hotKey(modifiers: [String], key: String)
        case appLaunched(bundleIdentifier: String)
        case displayCountChanged(Int)
    }

    enum Action: Codable, Hashable {
        case launchApp(bundleIdentifier: String)
        case applyMenuBarLayout(name: String)
        case moveFrontWindow(WindowPlacement)
    }
}

enum WindowPlacement: String, Codable, Hashable {
    case leftHalf
    case rightHalf
    case centered
    case maximized
}
