# Codex Prompt 03 — Layout Engine

Implement the first compatibility-safe layout engine.

Requirements:
1. Add `MenuBarItemAdapter` protocol from the architecture document.
2. Implement capability checks before movement.
3. Add in-column drag reorder to the SwiftUI layout UI.
4. When applying a layout, return per-item results: applied, skipped, unsupported, failed.
5. Rescan and verify after each movement batch.
6. Surface partial success clearly to the user.
7. Add restore logic after observed owner apps relaunch.
8. Do not use private frameworks or undocumented symbols.
