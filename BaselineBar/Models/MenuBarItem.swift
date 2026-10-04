import Foundation

struct MenuBarItem: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var bundleIdentifier: String?
    var accessibilityIdentifier: String?
    var ownerPID: Int32?
    var frame: CGRectCodable?
    var visibility: MenuBarVisibility
    var order: Int
    var canBeManaged: Bool

    init(
        id: UUID = UUID(),
        title: String,
        bundleIdentifier: String? = nil,
        accessibilityIdentifier: String? = nil,
        ownerPID: Int32? = nil,
        frame: CGRect? = nil,
        visibility: MenuBarVisibility = .visible,
        order: Int = 0,
        canBeManaged: Bool = true
    ) {
        self.id = id
        self.title = title
        self.bundleIdentifier = bundleIdentifier
        self.accessibilityIdentifier = accessibilityIdentifier
        self.ownerPID = ownerPID
        self.frame = frame.map(CGRectCodable.init)
        self.visibility = visibility
        self.order = order
        self.canBeManaged = canBeManaged
    }
}

enum MenuBarVisibility: String, Codable, CaseIterable, Identifiable {
    case visible = "Visible"
    case automatic = "Auto"
    case hidden = "Hidden"

    var id: String { rawValue }
}

struct CGRectCodable: Codable, Hashable {
    var x: Double
    var y: Double
    var width: Double
    var height: Double

    init(_ rect: CGRect) {
        x = rect.origin.x
        y = rect.origin.y
        width = rect.size.width
        height = rect.size.height
    }

    var cgRect: CGRect {
        CGRect(x: x, y: y, width: width, height: height)
    }
}
