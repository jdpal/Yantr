# BaselineBar MVP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans for native execution, or superpowers:subagent-driven-development if the user selects it. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete the requested native menu-bar and graphical automation MVP, with honest capability reporting and evidence-backed verification.

**Architecture:** Evolve the existing SwiftUI app through independently testable milestones. Separate persistent desired configuration from transient observations and place macOS interactions behind injected protocols. AppModel composes services and presents state; services execute operations and verify results.

**Tech Stack:** Swift 6, SwiftUI, AppKit, ApplicationServices, ServiceManagement, documented Carbon hotkey APIs, XCTest, unified logging. macOS 13+, arm64 and x86_64. No third-party runtime frameworks.

**Spec:** [Approved MVP design](../specs/2026-10-04-baselinebar-mvp-design.md)

**Execution status:** Plan prepared for review; no product changes made. Execution method awaits user selection. Recommended: Native, because this starter's model and service interfaces evolve together and the work benefits from one implementer maintaining that context, followed by an independent final review.

## Global Constraints

- Use Swift 6, SwiftUI, and AppKit on macOS 13 or later, targeting both arm64 and x86_64.
- Use documented public Apple APIs, no third-party runtime frameworks, no scripting, and no private menu-bar manipulation.
- Preserve existing persisted configuration.
- Keep the four primary sections: Menu Bar, Shortcuts, Automations, Settings.
- Diagnostics belongs inside Settings.
- Desired organisation is not evidence of successful external control.
- Build and run available tests after each substantial unit before proceeding.
- Automated tests must never move the user's real menu items or windows.
- Unverified hardware and permission tests must remain marked unverified.
- Product code must not request Accessibility at startup, fabricate observations, or report an external operation successful without verification.

## Workspace and verification commands

The workspace currently has no Git repository, generated Xcode project, or XcodeGen executable on PATH. Do not invent commits or branch status. Retain an execution ledger at `Docs/superpowers/plans/2026-10-04-baselinebar-mvp-progress.md`; record completed tasks, test evidence, deviations, and blockers. A future Git setup must not overwrite existing files.

Use the existing `project.yml` as the build definition. Include a native `BaselineBar.xcodeproj` with a shared scheme and test target so a fresh checkout can build without installing XcodeGen. Generate with XcodeGen if available; otherwise author the project directly, check its settings against `project.yml`, and document that generation path. Remove `BaselineBar.xcodeproj/` from `.gitignore`; keep user-specific Xcode state ignored.

Build command (**B**):

```sh
xcodebuild -project BaselineBar.xcodeproj -scheme BaselineBar -configuration Debug -destination 'platform=macOS' -derivedDataPath DerivedData CODE_SIGNING_ALLOWED=NO build
```

Test command (**T**):

```sh
xcodebuild -project BaselineBar.xcodeproj -scheme BaselineBar -configuration Debug -destination 'platform=macOS' -derivedDataPath DerivedData CODE_SIGNING_ALLOWED=NO test
```

Targeted red/green commands use **T** with `-only-testing:BaselineBarTests/<test class>/<test method>`. A red step must show the intended assertion failure after prerequisites compile; missing imports, unrelated compiler errors, and test crashes are not acceptable substitutes. Entire-suite green means `TEST SUCCEEDED` with no unexplained compiler warnings. Store lengthy build/test logs under `DerivedData/Verification/` and record summaries in the ledger.

Test hosting must not initialise real AppModel services. Prefer a hostless testable library target for models/services if necessary; otherwise guard app startup through an explicit test-host composition that never registers hotkeys, requests permissions, scans live AX, or moves windows. This is a build boundary, not test-only branches scattered throughout business logic.

## Review Focus

1. Corrupt/future persisted data must survive startup and ordinary edits until the user explicitly resolves recovery; Task 2 tests this.
2. Identical titles, changing PIDs, and disappearing AX elements must never redirect movement to a different item; Tasks 3–4 test this.
3. Permission loss or a preset switch during pending reconciliation/reveal must prevent stale writes; Tasks 4–5 test this.
4. Recording cancellation and partial hotkey registration failure must leave one correct set of live bindings; Task 8 tests this.
5. Chained app-activation rules must terminate predictably without unbounded work or silent action reordering; Task 9 tests this.

## Shared contracts

Use these names consistently across tasks. Codable/Sendable value types cross service boundaries; AX handles stay inside the AX implementation.

- `MenuBarItem`: observed `id: String`, `title`, owner bundle/name, optional frame, visibility, and capability metadata. `MenuBarItemConfiguration`: persistent `id: String`, `itemIdentifier: String`, `visibilityMode`, `sortOrder`.
- `MenuBarLayoutPreset`: `id: UUID`, `name: String`, `items: [MenuBarItemConfiguration]`.
- `AppConfiguration`: schema version, presets, selected/default preset IDs, shortcuts, rules, reveal duration. `ConfigurationStore.load() throws -> AppConfiguration`; `save(_ configuration: AppConfiguration) throws`.
- `PermissionChecking.isAccessibilityGranted: Bool`. `MenuBarDiscovering.discover() async -> DiscoverySnapshot`.
- `MenuBarItemPositioning.canReposition(_ item: MenuBarItem) -> Bool`; `move(_ item: MenuBarItem, to targetPosition: CGPoint) async throws`. The supported implementation does fresh preflight and verification.
- `MenuBarVisibilityControlling.canSetVisibility(_ item: MenuBarItem) -> Bool`; `setVisible(_ visible: Bool, item: MenuBarItem) async throws`. No initial external adapter claims this capability without evidence.
- `MenuBarLayoutCoordinator.reconcile(_ desired: [MenuBarItemConfiguration]) async -> LayoutReport`; `schedule(_ desired: [MenuBarItemConfiguration])`; `reveal(duration: RevealDuration)`; `dismissReveal()`. Published report contains status and per-item outcomes.
- `WindowManaging.perform(_ action: WindowAction) async throws`. `ApplicationLaunching.perform(_ action: ApplicationAction) async throws`.
- `ShortcutRegistering.replace(_ bindings: [ShortcutBinding]) throws`; `suspend()`; `resume() throws`; `stop()`. Bindings have stable IDs, key/modifier combinations, and action callbacks or dispatch IDs.
- `AutomationActionExecuting.execute(_ action: AutomationAction) async throws`; `AutomationEngine.handle(_ event: AutomationEvent) async`. Engine consumes persisted rules, condition context, action executor, and an injected clock.

Concrete SDK wrappers with AppKit state are MainActor-isolated. A serial AX executor owns synchronous AX calls and produces snapshots; no blanket `@unchecked Sendable` escape hatch. Pure transformations are nonisolated value operations.

### Task 1: Make the starter build reproducibly

**Files:** `project.yml`, `.gitignore`, `BaselineBar.xcodeproj/project.pbxproj`, shared scheme, `BaselineBar/App/BaselineBarApp.swift`, `BaselineBar/Services/AccessibilityPermissionService.swift`, `BaselineBar/Views/MainWindowView.swift`, `BaselineBar/Views/SettingsView.swift`, `Tests/BaselineBarTests.swift`, `README.md`.

**Interfaces:** Preserve the existing app entry point and four navigation sections. Produce a buildable app/test scheme targeting macOS 13 and Swift 6; subsequent tasks use **B/T**.

- [ ] Generate/author the Xcode project and shared scheme from existing settings; separate testable services from live app startup if test hosting requires it. Set LSUIElement and explicitly support arm64/x86_64. Match `project.yml` and document the native project workflow.
- [ ] Run **B** and capture existing compiler errors. Fix the observed AX constant concurrency issue through supported isolation/import treatment after checking installed SDK declarations, not by using string guesses or globally disabling concurrency checking.
- [ ] Replace macOS 14-only placeholder/onChange APIs with macOS 13-compatible equivalents. Preserve the menu extra and configuration window.
- [ ] Run **B/T**. Expected: app compiles and both existing model tests pass without invoking real services. Confirm opening the built app is a separate manual action, not an implicit test side effect.
- [ ] Record foundation evidence and remaining runtime checks in the ledger. Do not proceed with feature work while the baseline build is broken.

### Task 2: Persist desired configuration safely

**Files:** `BaselineBar/Models/MenuBarItem.swift`, `BaselineBar/Models/LayoutPreset.swift`, new `BaselineBar/Models/AppConfiguration.swift`, `BaselineBar/Models/MenuBarItemConfiguration.swift`, `BaselineBar/Persistence/ConfigurationStore.swift`, `BaselineBar/Persistence/LegacyConfiguration.swift`, `Tests/PersistenceTests.swift`, `Tests/LayoutOrderingTests.swift`.

**Interfaces:** Produce shared configuration models and throwing store methods. Preserve a dedicated decoder for the old `MenuBarItem` shape and `desiredMenuBarLayout.v1` data. Define action/rule schema types needed by the configuration, with execution deferred to later tasks.

- [ ] Write tests `testLegacyLayoutPreservesModesAndOrder`, `testRoundTripPresetsRulesAndShortcuts`, `testCorruptDataIsNotOverwritten`, and `testFutureSchemaIsNotOverwritten`. Assert old Visible/Auto/Hidden values map correctly, IDs remain traceable, and raw stored data is identical after failed recovery.
- [ ] Run targeted tests red, supplying minimal compiling contract declarations where required. Implement a versioned store with injected data storage, explicit decode/write errors, and recoverable migration. Retain the legacy key until replacement write succeeds.
- [ ] Write/run red ordering tests: moving one item between groups normalises order, moving before itself changes nothing, moving above/below bounds changes nothing, duplicate identities cannot silently replace entries, and missing observed items remain configured.
- [ ] Implement `LayoutEditing.move(itemID:to:before:in:) -> [MenuBarItemConfiguration]` and `normalise(_:)`; reject ambiguous legacy observation matching. Run **B/T**, expected green.

### Task 3: Discover real menu extras and expose diagnostics

**Files:** replace `BaselineBar/Services/MenuBarScanner.swift`; create `BaselineBar/MenuBar/MenuBarDiscoveryService.swift`, `BaselineBar/MenuBar/AccessibilityClient.swift`, `BaselineBar/Models/DiscoverySnapshot.swift`, `Tests/DiscoveryTests.swift`, `Tests/Support/MockAccessibilityClient.swift`.

**Interfaces:** Consume `PermissionChecking` and an injected accessibility/workspace snapshot provider. Produce `DiscoverySnapshot` containing items, per-application diagnostics, and permission/empty/partial/success/failure state. Preserve a temporary scanner bridge only until AppModel integration.

- [ ] Write/run red tests: denied permission returns no fictional items; zero extras is an honest empty state; ordinary application menus are excluded; accessory apps are considered; an unavailable app does not discard successful neighbours.
- [ ] Implement documented menu-extra traversal using `kAXExtrasMenuBarAttribute` where exposed. Read role, subrole, identifier, title/description, frame, PID, and owner. Bound AX messaging timeouts and traversal; keep AX handles inside one executor.
- [ ] Write/run red tests: stable exposed identifiers survive PID/frame changes; duplicate anonymous titles stay distinct and non-controllable; invalidated AX elements produce unavailable diagnostics rather than stale actionable handles.
- [ ] Implement stable identities and conservative capability assessment. Default to observable-only; never infer movement or visibility from press actions. Run **B/T**, expected green.

### Task 4: Verify movement and reconcile desired/observed layout

**Files:** replace `BaselineBar/Services/MenuBarLayoutController.swift`; create `BaselineBar/MenuBar/MenuBarItemPositioning.swift`, `BaselineBar/MenuBar/AXMenuBarPositioningService.swift`, `BaselineBar/MenuBar/MenuBarLayoutCoordinator.swift`, `BaselineBar/Models/LayoutReport.swift`, `Tests/PositioningTests.swift`, `Tests/ReconciliationTests.swift`.

**Interfaces:** Consume discovery, permission, configuration and positioning contracts. Produce `MenuBarOperationResult` cases success/unsupported/permissionRequired/itemNotFound/verificationFailed/failed, and `LayoutSyncStatus` synced/partiallySynced/outOfSync/permissionRequired. Keep errors user-readable and internally logged.

- [ ] Write/run red tests for every outcome, including an AX write returning success while rediscovered geometry is unchanged: result must be verificationFailed, never success. Permission loss, identity ambiguity, invalid/missing frame and unsupported movement must perform zero writes.
- [ ] Implement fresh lookup and `AXUIElementIsAttributeSettable` checks before an AX position write. Rediscover after movement and verify target position within 2 points. Bound any settling retry by count and elapsed time; no unbounded retries or generic Command-drag fallback.
- [ ] Write/run red coordinator tests: unsupported visibility is reported; unchanged known layout produces no writes; partial movement reports actual counts; stale scheduled generations cannot write; permission loss halts remaining operations.
- [ ] Implement per-display comparisons using observed slots where supported, without inventing cross-display placements or equating unknown order with synced. Debounce scheduled work by 250 ms and serialise reconciliation. New requests cancel stale pending work; check generation before each write and after awaits. Run **B/T**, expected green.

### Task 5: Complete layout editor, presets, and truthful reveal

**Files:** `BaselineBar/App/AppModel.swift`, `BaselineBar/Views/MenuBarLayoutView.swift`, `BaselineBar/Views/MenuBarGroupView.swift`, `BaselineBar/Views/MenuBarPopoverView.swift`, new `BaselineBar/MenuBar/PresetController.swift`, `BaselineBar/MenuBar/RevealController.swift`, `Tests/PresetTests.swift`, `Tests/RevealTests.swift`.

**Interfaces:** AppModel publishes desired configurations separately from observations; all layout changes persist through the store and use the coordinator. PresetController produces valid selected/default references after each edit. RevealController is an internal coordinator collaborator, not a second manipulation path.

- [ ] Write/run red tests for create/rename/duplicate/delete/switch/default selection, preventing empty names and deletion of the last preset. Duplicates get new preset IDs and independent item arrays. Deleting a referenced preset yields visible invalid-rule/shortcut validation rather than silently redirecting it.
- [ ] Implement preset operations and load configuration at startup. Route selection changes and manual Apply through the coordinator; restore the default preset at startup. Persist immediately and surface failures without claiming a save succeeded.
- [ ] Wire cross-column and row-level drop targets, Move Up/Down and section menus, Refresh and explicit Reset Layout. Clearly label missing and observed-only items. UI copy separates saved intent from applied results.
- [ ] Write/run red reveal tests using mock visibility capability and clock: no capable items returns unsupported; duplicate reveal creates no repeated movement; 5/10/30-second expiry restores current desired state; dismissal cancels timer; preset changes during reveal do not restore old configuration.
- [ ] Implement transient reveal without editing stored modes. Add compact preset and hidden-item menus to the popover, Open BaselineBar, Settings, Automations and Quit. Run **B/T** and manually check keyboard controls, within-section reorder, empty state and light/dark layouts.

### Task 6: Add verified window actions and coordinate geometry

**Files:** replace `BaselineBar/Services/WindowController.swift`; create `BaselineBar/WindowManagement/WindowManagementService.swift`, `BaselineBar/WindowManagement/WindowGeometry.swift`, `BaselineBar/Models/WindowAction.swift`, `Tests/WindowGeometryTests.swift`, `Tests/WindowManagementTests.swift`.

**Interfaces:** `WindowGeometry.targetFrame(action:window:visibleFrames:currentIndex:) throws -> CGRect`; `WindowManaging.perform(_:) async throws`. Include leftHalf/rightHalf/topHalf/bottomHalf/maximise/centre/nextDisplay/previousDisplay.

- [ ] Write/run red geometry tests: each half/maximise respects visible bounds; centre preserves size when it fits; oversized windows clamp; negative-origin displays work; next/previous wraps; one display is stable; zero displays fails explicitly.
- [ ] Implement AppKit-to-AX conversion using the primary display reference height, all measurements in points, greatest-intersection screen selection and deterministic fallback/order. Display scale must not multiply point coordinates.
- [ ] Write/run red mock-AX tests for missing permission/focused window, read-only attributes, failed writes, and application minimum size causing verification failure. Implement focused-window access with checked return codes and post-write geometry verification. Run **B/T**; live movement remains a separate manual check.

### Task 7: Add application selection, launch, and focus

**Files:** `BaselineBar/Models/ApplicationAction.swift`, `BaselineBar/Services/ApplicationLauncher.swift`, `BaselineBar/Services/ApplicationCatalog.swift`, `BaselineBar/Views/ApplicationPicker.swift`, `Tests/ApplicationLauncherTests.swift`.

**Interfaces:** `ApplicationAction` launch/focus/launchOrFocus by bundle identifier; `ApplicationLaunching.perform(_:) async throws`; catalog entries contain name, icon presentation reference, bundle ID. Provide an injected workspace adapter for tests.

- [ ] Write/run red tests: focus never launches a missing process; launchOrFocus focuses a running instance; missing installed bundle fails clearly; launch resolves by bundle ID; failed activation is surfaced.
- [ ] Implement NSWorkspace resolution and launch completion handling. Catalog discovery uses documented installed-app/metadata APIs with an NSOpenPanel application picker fallback, not a fixed installation path. Reject bundles without a usable bundle ID.
- [ ] Build a reusable native picker showing name/icon and bundle ID only where useful for selection. Persist bundle ID, not path. Run **B/T**, expected green.

### Task 8: Register and record global shortcuts safely

**Files:** `BaselineBar/Models/KeyboardShortcut.swift`, `BaselineBar/Models/ShortcutAction.swift`, `BaselineBar/Shortcuts/ShortcutRegistry.swift`, `BaselineBar/Shortcuts/CarbonHotKeyBackend.swift`, `BaselineBar/Shortcuts/ShortcutRecorder.swift`, `BaselineBar/Views/ShortcutsView.swift`, `Tests/ShortcutTests.swift`.

**Interfaces:** Stable Codable modifier OptionSet and keyCode; shared ShortcutRegistering contract. `ShortcutAction` includes id/name/enabled/shortcut/action. App-local show/reveal commands are explicit action cases. The later engine shares this registry for rule hotkeys.

- [ ] Write/run red tests: duplicate enabled combinations conflict across shortcuts and rules; disabled shortcuts do not conflict; typing-only shortcuts are rejected; registered IDs dispatch exactly one configured action; secure input suppresses dispatch.
- [ ] Verify installed SDK declarations and use documented Carbon registration/unregistration and secure-input status APIs. Own one event handler. Surface OS registration errors without claiming all external conflicts can be pre-enumerated.
- [ ] Write/run red lifecycle tests: recording suspends bindings; cancellation/dismissal restores once; failed replacement cleans partial registrations and restores the prior valid set where possible; repeated start/stop does not duplicate callbacks.
- [ ] Implement recorder with an app-local event monitor only while recording, explicit cancellation, and cleanup. Add native shortcut CRUD/disable UI and action selection, using the shared application picker and layout IDs. Run **B/T**; verify actual delivery manually without recording keystroke history.

### Task 9: Execute modular automation rules with loop protection

**Files:** replace `BaselineBar/Models/AutomationRule.swift`; create `BaselineBar/Automation/AutomationEngine.swift`, `BaselineBar/Automation/AutomationValidator.swift`, `BaselineBar/Automation/ActionExecutor.swift`, `BaselineBar/Automation/WorkspaceTriggerProvider.swift`, `BaselineBar/Automation/DisplayTriggerProvider.swift`, `Tests/AutomationValidationTests.swift`, `Tests/AutomationExecutionTests.swift`.

**Interfaces:** Rule id/name/enabled/one trigger/conditions/ordered actions. Triggers: keyboardShortcut, applicationLaunched, applicationActivated, displayConnected, displayDisconnected. Actions: applyMenuBarLayout, window, application, plus explicit app-local commands required by shortcuts. Conditions: external display present, active application matches bundle ID.

- [ ] Write/run red validation tests for whitespace-only names, missing actions, invalid app IDs, missing preset references and hotkey conflicts. Implement `AutomationValidator.errors(for:configuration:) -> [String]` for both draft saving and enabling persisted rules.
- [ ] Write/run red execution tests: conditions suppress mismatched events; multiple actions execute in order; a failed action is recorded and later actions continue; disabled rules do not execute; reentrant same-rule events are suppressed.
- [ ] Implement engine with injected action services and clock, one active execution per rule, 1-second per-rule cooldown, and a maximum of 32 pending events. Limit execution starts to 10 per 10-second rolling window; on exceeding the budget pause automatic execution and expose an explicit Resume control. Test an A→B→A activation cycle using virtual time and assert bounded work plus the visible paused reason.
- [ ] Use workspace notifications and screen-configuration diffs, starting each provider once and removing observers on stop. Keyboard triggers share Task 8's registry. Log bounded per-action outcomes with private app fields. Run **B/T**, expected green.

### Task 10: Build the native automation editor and wire navigation

**Files:** `BaselineBar/Views/MainWindowView.swift`, `BaselineBar/Views/AutomationsView.swift`, `BaselineBar/Views/AutomationRuleEditor.swift`, `BaselineBar/Views/AutomationActionEditor.swift`, `BaselineBar/App/AppModel.swift`, `Tests/AutomationEditingTests.swift`.

**Interfaces:** Draft editing validates through Task 9 and commits through Task 2. Task 8's action editor and application picker are reused where appropriate. AppModel routes engine/registry actions to one composition of services.

- [ ] Write/run red editor-state tests: duplicate gets a new UUID; cancel leaves stored rule unchanged; invalid draft cannot save/enable; removing one action preserves remaining order; deleting a rule removes its hotkey binding.
- [ ] Implement WHEN / optional AND / ordered DO controls with native pickers, add/remove actions/conditions, replace trigger, rename, enable, duplicate and explicit delete. Hide optional conditions until requested; keep validation beside relevant controls.
- [ ] Replace navigation placeholders and wire persisted rules to providers/registry. One rule has one trigger; Duplicate supports another trigger without introducing an inconsistent multi-trigger schema.
- [ ] Run **B/T** and manually walk creating an app-open → apply-layout + right-half rule. Verify unsupported layout outcomes remain visible rather than being logged as success.

### Task 11: Finish permissions, login, diagnostics, and service lifetimes

**Files:** `BaselineBar/Permissions/PermissionService.swift`, `BaselineBar/Services/LoginItemService.swift`, `BaselineBar/Settings/DiagnosticsService.swift`, `BaselineBar/Views/SettingsView.swift`, `BaselineBar/App/AppModel.swift`, `Tests/PermissionTests.swift`, `Tests/LoginItemTests.swift`, `Tests/DiagnosticsTests.swift`.

**Interfaces:** PermissionService implements PermissionChecking and explicit request/refresh methods. Login wrapper exposes actual registration state and throwing enable/disable. DiagnosticsService produces a sanitised text summary from snapshots, never reads clipboard data.

- [ ] Write/run red tests: no startup prompt; repeated feature checks do not prompt; permission revocation invalidates capabilities; returning active refreshes status. Implement contextual request, settings navigation and refresh-before-operation without recurring polling.
- [ ] Write/run red login tests for enabled/notRegistered/requiresApproval/notFound and register/unregister errors. Implement SMAppService wrapper and toggle binding that rereads actual state after changes and on activation.
- [ ] Write/run red diagnostics tests asserting required fields and absence of fixture personal paths, item title history and private payloads. Add diagnostics disclosure inside Settings and Copy Diagnostics using only the sanitised summary.
- [ ] Review ownership of observers, AX objects, local monitors, hotkey references, debounce/reveal tasks and app-level service instances. Exercise start/stop twice in mocks and assert one event delivery and complete cancellation. Run **B/T**, expected green.

### Task 12: Verify release readiness and report exact limits

**Files:** `README.md`, `Docs/ARCHITECTURE.md`, `Docs/MACOS_LIMITATIONS.md`, `Docs/RELEASE_REPORT.md`, execution ledger, focused regression tests for discovered issues.

**Interfaces:** This task consumes all earlier implementation and evidence. It produces a reproducible verification record, not an unsupported claim of production readiness.

- [ ] Run clean universal release build:
  `xcodebuild -project BaselineBar.xcodeproj -scheme BaselineBar -configuration Release -destination 'generic/platform=macOS' -derivedDataPath DerivedData CODE_SIGNING_ALLOWED=NO ONLY_ACTIVE_ARCH=NO 'ARCHS=arm64 x86_64' clean build`.
  Expected: BUILD SUCCEEDED; `lipo -archs` on the executable reports arm64 and x86_64. Then run full **T** and inspect all warnings.
- [ ] Review frameworks, imported symbols and SDK documentation for public API usage. Verify deployment target and launch architecture settings. Audit stored data for backward compatibility and copied diagnostics for privacy.
- [ ] Launch the built app for manual popover/configuration, drag/reorder/keyboard, preset, shortcut, automation and settings checks. Do not automatically alter system permission settings or login registration just to complete a test; use explicit user-assisted checks where needed.
- [ ] Observe idle CPU for 60 seconds after a 10-second settling interval, recording sample method, average/range, and system/app versions. Distinguish passive observation from artificial test execution. Check there is no recurring discovery/reconciliation timer.
- [ ] Test physical multiple displays, permission removal/restoration, app restarts and BaselineBar restart where available. Record unperformed checks explicitly, including native Intel/macOS 13 runtime testing if those machines are unavailable.
- [ ] Obtain the independent final code review required by the selected execution workflow. Address important findings with failing regression tests followed by fixes and a full passing suite. Record any deferred findings and rationale.
- [ ] Write the release report with implemented features, actually verified behaviour, known macOS limitations, unsupported external movement/visibility/reveal, remaining bugs, post-MVP suggestions, changed files and exact test results. Explain that an unsigned local build is not a notarised distributable release. Do not mark the MVP finished if requested behaviour is still missing or failing.

## Plan self-review

All twenty user prompts map to tasks: foundation 1–2; discovery 3; editor 5;
positioning/reconciliation 4; presets/reveal/popover 5; shortcuts 8; windows 6;
launcher 7; engine 9; builder 10; permissions/login/diagnostics 11;
reliability/UX/tests/release 1–12. No task is authorised to implement private APIs
or fake external success. The fixed initial loop thresholds and 2-point movement
tolerance are implementation decisions, not claims about universal app compatibility.

The requested MVP remains the scope. Unsupported platform behaviour and absent
test hardware are reportable limits, not reasons to stop implementing independent
supported features. The next action after plan approval and execution-method
selection is Task 1, not another design round.
