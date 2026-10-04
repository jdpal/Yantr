# Codex Prompt 02 — Menu-bar Discovery

Improve menu-bar discovery using public macOS Accessibility APIs.

Requirements:
1. Create an `ObservedMenuBarItem` model separate from the user's desired layout model.
2. Record owner PID, bundle ID, AX role/subrole, title/description, identifier, and frame where available.
3. Generate a stable identity fingerprint without depending on array position.
4. Build a diagnostics view that can export/copy a redacted JSON snapshot for debugging.
5. Categorize each item as `manageable`, `observedOnly`, or `unknown`.
6. Never claim an external item was hidden or moved unless the operation can be verified by rescanning.
7. Add tests for identity matching and rescan reconciliation.
