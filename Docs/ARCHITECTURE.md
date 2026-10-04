# Technical Architecture

## UI layer
SwiftUI for main screens and settings. AppKit remains available for lifecycle, workspaces, screens, and lower-level macOS integration.

## Core modules
### AppModel
Owns user-visible state and coordinates services.

### MenuBarScanner
Attempts public Accessibility-based discovery. Treat discovery as capability-based because different status-item implementations expose different AX trees.

### MenuBarLayoutController
Stores the desired layout. Applying that layout is delegated to future compatibility adapters rather than hard-coding private APIs.

### AccessibilityPermissionService
Checks/request Accessibility permission using `AXIsProcessTrusted` / `AXIsProcessTrustedWithOptions`.

### WindowController
Uses AX position and size attributes on the focused window.

### LoginItemService
Uses `SMAppService.mainApp` on macOS 13+.

## Compatibility adapter design
Create protocol:

```swift
protocol MenuBarItemAdapter {
    func canManage(_ item: ObservedMenuBarItem) -> Bool
    func move(_ item: ObservedMenuBarItem, to target: CGPoint) async throws
    func setVisibility(_ item: ObservedMenuBarItem, _ state: MenuBarVisibility) async throws
}
```

Adapters must be explicit about supported apps/OS versions. Failed capability checks must degrade to "Observed only".

## Persistence
Use Codable + UserDefaults for MVP. Move to SwiftData when presets, rule history, and richer automation state justify it.

## Automation engine
Represent automation as serializable Trigger → [Action]. Keep trigger detection and action execution in separate services. Do not expose Lua in v1.
