import Foundation

final class MenuBarLayoutController {
    private let defaultsKey = "desiredMenuBarLayout.v1"

    enum ApplyResult: Equatable {
        case applied
        case partiallyApplied(unmanagedItemCount: Int)
        case storedOnly
    }

    func saveDesiredLayout(_ items: [MenuBarItem]) {
        guard let data = try? JSONEncoder().encode(items) else { return }
        UserDefaults.standard.set(data, forKey: defaultsKey)
    }

    func loadDesiredLayout() -> [MenuBarItem] {
        guard let data = UserDefaults.standard.data(forKey: defaultsKey),
              let items = try? JSONDecoder().decode([MenuBarItem].self, from: data) else {
            return []
        }
        return items
    }

    /// Applies what can be applied through supported compatibility adapters.
    ///
    /// Do not silently introduce private APIs here. Each future adapter must explicitly report
    /// whether an item is identifiable and movable on the current macOS version.
    func apply(_ items: [MenuBarItem]) async -> ApplyResult {
        let unmanagedCount = items.filter { !$0.canBeManaged }.count
        if unmanagedCount == items.count {
            return .storedOnly
        }
        if unmanagedCount > 0 {
            return .partiallyApplied(unmanagedItemCount: unmanagedCount)
        }
        return .applied
    }
}
