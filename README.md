# Yantr — Codex Build Kit

A native macOS menu-bar manager and lightweight automation app.

## Product goal
Yantr combines two ideas in one deliberately simple app:

1. **Menu-bar control** — discover menu-bar items, let the user choose what stays visible, define ordering, and save layouts.
2. **Mac automation** — global shortcuts, window actions, app launching, and simple trigger → action rules inspired by Hammerspoon.

The product should feel substantially simpler than Bartender and substantially easier than writing Hammerspoon Lua.

## Target
- macOS 13 Ventura or later for the first build
- Apple Silicon and Intel
- Swift 6 / SwiftUI + AppKit
- Accessibility permission requested only when a feature needs it
- No private API dependency in the core architecture

## What is in this kit
- `project.yml` — XcodeGen project definition
- `BaselineBar/` — starter Swift source
- `Docs/PRODUCT_SPEC.md` — product requirements
- `Docs/ARCHITECTURE.md` — technical architecture
- `Docs/MACOS_LIMITATIONS.md` — platform constraints and compatibility policy
- `Docs/BUILD_PLAN.md` — staged implementation plan
- `CODEX.md` — instructions for Codex
- `CodexPrompts/` — ready-to-use build prompts

## Generate the Xcode project
Install XcodeGen on the Mac, then run:

```bash
brew install xcodegen
xcodegen generate
open BaselineBar.xcodeproj
```

If you do not want XcodeGen, create a new macOS App project in Xcode named `Yantr`, then copy the `BaselineBar/` folder into the project.

## First run
1. Build and launch.
2. Open Yantr from the menu bar.
3. Grant Accessibility only when prompted by a feature that requires it.
4. Use the Layout screen to arrange discovered items into Visible, Auto, and Hidden groups.

## Important platform constraint
Apple does not expose a general public API to arbitrarily reorder all third-party status items. Yantr therefore separates:

- **Desired layout state** — always supported in our app.
- **Observed menu-bar state** — discovered through public Accessibility APIs where possible.
- **Applied external movement** — attempted only when an item can be reliably identified and manipulated.

Never use undocumented/private API as a silent fallback. If an item cannot be moved reliably, surface that state in the UI.

## Working name
This app is now named Yantr.
