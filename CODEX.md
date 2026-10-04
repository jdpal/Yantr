# Instructions for Codex

You are building BaselineBar, a native macOS utility.

## Product intent
Keep the UX simpler than Bartender and make common Hammerspoon-like actions visual rather than script-first.

## Non-negotiables
- SwiftUI + AppKit where appropriate.
- macOS 13+ for the MVP.
- No undocumented/private macOS APIs unless the human explicitly approves them.
- Capability-detect external menu-bar control. Do not fake success.
- Request Accessibility permission only in context.
- Keep business logic out of SwiftUI views.
- Add tests for persistence, rule serialization, identity matching, and layout ordering.
- Each milestone must build before starting the next.

## Definition of done for a change
1. Code compiles on current Xcode.
2. No warnings introduced without explanation.
3. Existing tests pass.
4. New logic has focused tests where feasible.
5. User-facing failure states are explicit.
6. README/docs updated if behavior or setup changes.

## First task
Read `Docs/PRODUCT_SPEC.md`, `Docs/ARCHITECTURE.md`, `Docs/MACOS_LIMITATIONS.md`, and `Docs/BUILD_PLAN.md`. Then execute `CodexPrompts/01-foundation.md`.
