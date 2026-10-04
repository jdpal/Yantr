# Build Plan

## Milestone 0 — Foundation
- Generate Xcode project.
- Confirm signing and launch.
- Confirm menu-bar extra + main window.
- Add logging and a small compatibility diagnostics screen.

## Milestone 1 — Menu-bar model
- Persist desired layout.
- Implement in-column reorder, not only cross-column drag.
- Improve observed-item identity so IDs survive rescans.
- Separate Apple system items, Control Center items, and third-party status items where observable.

## Milestone 2 — Compatibility layer
- Add adapter protocol.
- Build diagnostics that captures AX role, subrole, title, identifier, frame, owner PID, and bundle ID.
- Test movement only for items with stable identity/frame data.
- Add restore-after-relaunch logic.

## Milestone 3 — Shortcuts/windows
- Global hotkey registry.
- Launch/focus app action.
- Window left/right/center/maximize.
- Multi-display targeting.

## Milestone 4 — Automations
- Rule editor.
- Hotkey/app/display triggers.
- Menu layout/window/app actions.
- Enable/disable and execution log.

## Milestone 5 — Quality
- Accessibility UX.
- Recovery from app relaunch and screen changes.
- Intel + Apple Silicon test pass.
- Signing/notarization.
- Crash/error telemetry only if privacy policy permits.
