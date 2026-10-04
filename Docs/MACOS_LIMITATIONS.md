# macOS Platform Limits and Compatibility Policy

## External menu-bar ordering
Apple's public `NSStatusItem` API is designed for an app to manage its own status item. It does not provide a public global API to reorder arbitrary third-party status items.

Accessibility can expose and control UI elements from other processes, but status-item accessibility trees vary by implementation and macOS release.

Therefore:
- BaselineBar always lets the user define a desired layout.
- The app separately reports whether a discovered item is manageable.
- Applying external movement must be implemented through tested compatibility adapters.
- Do not introduce private frameworks or undocumented API without an explicit product decision.
- Do not claim universal compatibility.

## Permissions
Accessibility is required for inspecting/controlling supported external UI and moving windows.

Request permission in context. The app should remain useful without it by allowing desired-layout editing and its own settings.

## Sandbox
The starter project disables the App Sandbox because Accessibility/UI automation utilities commonly need capabilities that conflict with a conventional sandboxed Mac App Store model. Before distribution, choose a distribution path and review signing, notarization, hardened runtime, privacy copy, and App Store eligibility.
