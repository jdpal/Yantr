# Codex Prompt 04 — Shortcuts and Automation

Build the first Hammerspoon-inspired automation layer without Lua.

Requirements:
1. Add a global hotkey service.
2. Add actions: launch/focus app, move front window, apply saved menu-bar layout.
3. Add triggers: hotkey, app launched, display count changed.
4. Add a simple rule editor using `When` and `Do` sections.
5. Persist Codable rules.
6. Add an execution log with timestamp, rule name, action, and success/failure.
7. Avoid polling where Workspace/display notifications can be used.
8. Add unit tests for rule serialization and execution routing.
