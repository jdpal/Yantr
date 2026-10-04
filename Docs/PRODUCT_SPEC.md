# BaselineBar Product Specification

## Positioning
A simple macOS utility that keeps the menu bar tidy and adds everyday Mac automation without requiring scripting.

## Product principles
1. Simple by default.
2. Direct manipulation first: drag, drop, click.
3. Advanced automation is optional.
4. Permission requests happen in context.
5. Never pretend an unsupported menu-bar item is controllable.

## MVP
### Menu Bar
- Discover observable menu-bar/status items.
- Show a visual desired-order preview.
- Three groups: Visible, Auto, Hidden.
- Drag items between groups.
- Rearrange items within a group.
- Persist desired layout.
- Report whether each item is manageable on the current OS/app combination.
- Restore/apply manageable layouts after login and app relaunch.

### Shortcuts
- User-defined global hotkeys.
- Launch/focus an app.
- Move active window: left half, right half, center, maximize.
- Reveal BaselineBar hidden-items panel.

### Automations
Initial triggers:
- Hotkey.
- App launched.
- Display count changed.

Initial actions:
- Launch/focus app.
- Apply saved menu-bar layout.
- Move front window.

## Later
- Focus mode triggers.
- Wi-Fi/network triggers.
- Multiple saved layouts.
- Conditions and chained actions.
- Optional advanced scripting API.
- Import assistant for common Hammerspoon hotkeys.

## UX
Primary navigation:
- Menu Bar
- Shortcuts
- Automations
- Settings

Do not add power-user configuration to the main Menu Bar screen.
