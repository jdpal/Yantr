# BaselineBar MVP design

Status: proposed for review. Product implementation has not begun.

## Purpose and scope

Build a native, lightweight macOS menu-bar utility for people who want simple
menu-bar organisation and graphical Mac automation. The user's supplied twenty
prompts are the product requirements. They supersede older repository documents
that defer saved layouts, conditions, and chained actions until after the MVP.

Use Swift 6, SwiftUI, and AppKit on macOS 13 or later, targeting both arm64 and
x86_64. Use documented public Apple APIs, no third-party runtime frameworks,
no scripting, and no private menu-bar manipulation. Preserve existing persisted
configuration. Keep the four primary sections: Menu Bar, Shortcuts, Automations,
Settings. Diagnostics belongs inside Settings.

Completion requires a clean build, passing automated tests, and an evidence-based
release report. Unverified hardware and permission tests must remain marked
unverified. Desired organisation is not evidence of successful external control.

## Existing project assessment

The workspace contains a SwiftUI starter and an XcodeGen definition, but no
generated Xcode project, no Package.swift, and no Git repository. XcodeGen was
not found on PATH. Installed tools report Xcode 27.0 and Swift 6.4.

Baseline typechecking, with Swift 6 and an explicit macOS 13 deployment target,
failed on `kAXTrustedCheckOptionPrompt` shared mutable state in
`AccessibilityPermissionService.swift`. This was a typecheck, not a complete
application build or test run. Additional issues observed in source:

- `ContentUnavailableView` and the two-argument SwiftUI `onChange` overload
  exceed the deployment target.
- Discovery substitutes fictional sample items when permission is missing or
  discovery is empty, and the sample items default to manageable.
- Discovery inspects application menus rather than specifically distinguishing
  menu extras; IDs are random on each scan and frame data is omitted.
- Layout application can return success without invoking any external operation.
- Saved desired layout is never loaded by AppModel.
- Window placement uses AppKit coordinates directly as Accessibility coordinates,
  chooses NSScreen.main, and ignores AX write errors.
- Shortcuts and automations are placeholders. Existing tests cover only rectangle
  encoding and visibility raw values.

## Approach

Evolve the existing application in ordered, buildable milestones. Preserve its
SwiftUI entry point, navigation, and native appearance; replace incomplete
services behind protocols and introduce missing models incrementally.

Alternatives considered:

1. Rebuild the app from scratch. This discards useful starter UI without solving
   platform limitations and increases migration risk.
2. Implement only the foundation. This matches the repository's older first-task
   note but does not satisfy the user's complete supplied request.
3. Incrementally complete the requested MVP, verifying each substantial change.
   This is the recommended approach.

The full task spans several subsystems. The foundation is the first implementation
unit; menu-bar discovery/control, shortcuts/windows, automation, and release
verification follow with explicit acceptance criteria below.

## Architecture

Use one application target with logical folders for App, Models, Services,
MenuBar, Automation, Shortcuts, WindowManagement, Permissions, Persistence, and
Settings. Keep XCTest-compatible test targets independent of live system control.

AppModel is a MainActor composition root and observable presentation model. It
owns long-lived service instances, routes user actions, and publishes summaries.
Views contain presentation bindings rather than AX or persistence operations.

Codable value types represent configuration, actions, rules, and observation
snapshots. Platform handles remain inside service implementations. Inject
permissions, discovery, positioning, window access, application workspace,
shortcut registration, login registration, persistence, and timing into business
logic. Tests use mocks rather than manipulating the developer's menu bar.

Keep blocking AX calls off the UI thread in a serial service executor with bounded
messaging timeouts. AppKit operations requiring the main thread stay on MainActor.
Do not transfer AXUIElement handles casually between concurrency domains or
silence checking using blanket unchecked Sendable declarations.

## Foundation and persistence

Produce a reproducible Xcode build with app and unit-test targets, macOS 13
deployment settings, and both CPU architectures. XcodeGen remains a development
tool, not an application dependency. Include the generated project or a verified
generation path so the workspace can actually build.

Configure agent-style menu-bar operation using LSUIElement, a compact popover,
and an explicitly opened configuration window. No permission prompt occurs at
startup. Use unified logging with privacy-aware fields.

Store a versioned Codable configuration containing presets, selected/default
preset IDs, shortcuts, rules, and reveal preferences. Persist edits immediately
and expose decoding/writing errors. Preserve corrupt or unknown-version data
rather than overwriting it with defaults.

Migrate the existing `desiredMenuBarLayout.v1` payload using a legacy decoder.
Keep the old Visible/Auto/Hidden raw-value interpretation and retain unmatched
entries. Match old items to new observations only when identity is unambiguous;
do not silently discard or guess duplicate items. Preserve the legacy payload
until the replacement configuration is successfully written.

## Discovery and observed state

MenuBarDiscoveryService obtains running application snapshots through
NSWorkspace and inspects exposed menu extras through public Accessibility
attributes. Include accessory/system applications where relevant, exclude the
current app where appropriate, and avoid treating ordinary File/Edit menu entries
as status icons. An unavailable AX tree is a diagnostic result, not a fabricated
menu item.

Each observed item contains a stable identity, owner name/bundle ID, title, optional
frame, observed visibility, capability classification, and diagnostic metadata.
Keep unavailable applications in discovery diagnostics separately from known
items. Permission-required, empty, partial, successful, and failed discovery
states must be distinguishable.

Prefer owner bundle identifier plus exposed AX identifier. For missing identifiers,
use a deterministic role/title/occurrence fallback and explicitly treat ambiguous
matches as observable only. Do not use PID or frame as persistent identity.
Revalidate identity after application restarts and immediately before operations.

Classify controllable, observable-only, and unavailable states. Movement and
visibility capabilities are separate: the ability to press a menu item does not
mean it can be moved or hidden. No production sample items are returned.

## Desired layout, reconciliation, and reveal

MenuBarItemConfiguration stores item identity, visibility mode, and order separately
from observations. Persist missing items so preferences survive app termination.
The editor supports Visible, Automatic, and Hidden sections, cross-section drops,
within-section drops, Move Up/Down controls, section menus, reset, and refresh.

Presets support create, rename, duplicate, delete, switch, and set default. Deleting
the selected/default preset selects a valid replacement; the last preset cannot
be deleted. Destructive actions are explicit. Startup selects the default preset;
manual switching and automation both use the same coordinator.

MenuBarItemPositioning gates every attempted move on current permission, current
identity, a valid frame, and a supported movement capability. The initial adapter
may attempt a public AX position write only when that exact attribute is reported
settable. Do not infer general compatibility from that declaration: rediscover and
compare the resulting position within a documented point tolerance before success.

Generic synthetic Command-drag is not a default adapter. Documented event posting
alone does not establish that another application's status item supports movement.
An event-based adapter would need explicit compatibility evidence and the same
preflight and verification path. This initial implementation must work honestly
even if every external item is observable only.

LayoutCoordinator compares desired and observed positions, computes changes only
for supported operations, serialises writes, verifies each result, and returns
synced/partiallySynced/outOfSync/permissionRequired with per-item reasons. Pending
work is debounced; newer generations cancel stale work. There is no retry loop
after unsupported or failed operations. Unknown visibility/order is not synced.

No public general-purpose visibility API is assumed. Hidden and Automatic remain
desired settings where unsupported, with plain-language explanations in the UI.
Automatic means visibility changed by an explicit supported rule/layout action;
it does not imply an unspecified prediction engine.

Reveal uses a transient coordinator override, preserving the saved layout and
ordering. Only items with a verified visibility adapter may change. A cancellable
one-shot timer restores the current desired layout after 5/10/30 seconds, or
explicit dismissal. Layout changes during reveal invalidate obsolete restoration
work. With no compatible items, report that none can be revealed; listing a hidden
item's name is not a successful reveal.

## Shortcuts and application actions

Use a documented global hotkey registration API behind a registry protocol, with
one owned event handler and a deterministic unregister path. Use a local keyboard
event monitor only while recording in the app's UI. Suspend global registrations
during recording and restore them on commit, cancellation, and window dismissal.

Persist key codes and a stable modifier representation. Reject unmodified typing
keys and unsafe/reserved combinations. Detect duplicates across enabled shortcuts
and keyboard-triggered rules. Surface operating-system registration conflicts;
do not claim to enumerate every shortcut registered by other apps. Do not execute
shortcuts during secure event input. No keystroke history is collected.

Support showing BaselineBar, reveal, preset application, window actions, and
application launch/focus. Keep app-local commands separate or explicitly modeled
alongside the shared automation actions.

Application selection displays name, icon, and bundle identifier. Resolve installed
apps using documented workspace/metadata APIs and an application file chooser as
a fallback; do not assume every app lives in /Applications. Persist bundle IDs,
resolve them on execution, and distinguish launch, focus, and launch-or-focus.
Missing applications produce actionable errors.

## Window management

AX window access is behind a protocol. Read the focused window and verify that
position and size attributes are writable. Convert NSScreen frames from AppKit's
coordinate space into Accessibility's global top-left space using the primary
display reference. Work in points, not physical pixels.

Pure frame calculations implement left/right/top/bottom halves, maximise, centre,
next display, and previous display. Choose the current display using greatest
window intersection with a deterministic fallback, respect visibleFrame, preserve
size for centre where possible, and clamp to destination bounds. Display cycling
has a documented deterministic ordering.

Check AX errors, reread final geometry, and report refusal or constraints when an
application's minimum size or window type prevents the requested placement.

## Automation engine and editor

Separate trigger providers, condition evaluation, and action execution. Providers
listen to workspace launch/activation notifications, screen configuration changes,
and the shared hotkey registry. Start once and remove observers on shutdown.

A rule has one trigger and multiple ordered actions, consistent with the supplied
model. The editor lets users replace the trigger and add/remove conditions and
actions. Support external-display-present and active-application conditions first.
Multiple independent triggers are represented by separate rules, with Duplicate
Rule making that workflow inexpensive.

Validate nonblank names, complete triggers, at least one action, valid bundle IDs,
existing layout references, and conflict-free shortcuts. Invalid drafts cannot be
enabled or saved. Surface stale references after preset deletion or app removal.

Execute each rule's actions sequentially, record per-action failures, and continue
independent later actions without crashing. Guard reentrancy per rule, bound the
event queue, and enforce a cooldown/event-chain budget to contain feedback loops
between launch/focus actions and workspace notifications. Tests use an injected
clock and event source. Keep only bounded diagnostic execution history.

## Permissions, login, and diagnostics

PermissionService checks current trust and presents the supported OS prompt only
after an explicit feature-enablement action. Refresh on application activation,
settings return, and before protected operations. Revoke stale controllability
state when permission is lost. Avoid repeated prompts and idle polling.

Input Monitoring and Apple Events are not requested unless an implemented feature
actually requires them. Explain Accessibility separately for discovery and window
control. Settings offers an explicit path to the system permission controls.

Wrap SMAppService so settings reflect actual enabled/notRegistered/requiresApproval/
notFound state. A failed registration cannot leave the toggle appearing enabled.

Diagnostics includes OS/app version, CPU architecture, permission/login state,
discovery counts, current layout, engine state, and registered shortcut counts.
Detailed item inspection is opt-in and includes owner, bundle ID, title, frame,
capability, and AX status. Copy Diagnostics produces a sanitised summary excluding
clipboard contents, keystrokes, personal paths, and item-title history.

## Implementation units and acceptance criteria

1. Foundation: reproducible clean app build, Swift 6/macOS 13 compatibility,
   menu-bar lifecycle, persistent desired state, migration tests, protocol seams,
   and no fabricated observations or successful external operations.
2. Discovery/layout: deterministic identities, unavailable diagnostics, accessible
   ordering controls, preset CRUD, verified movement, reconciliation, and truthful
   unsupported visibility/reveal reporting.
3. Shortcuts/windows/apps: recorded hotkeys, conflict tests, secure-input guards,
   tested multi-display geometry, and bundle-ID application selection/execution.
4. Automation: modular notification providers, validated native editor, sequential
   actions, conditions, persistence, and bounded loop protection.
5. Reliability/release: permission/login UX, sanitised diagnostics, observer and
   task lifetime review, clean universal build, tests, and manual validation report.

Build and run available tests after each substantial unit before proceeding.

## Verification

Automated tests cover legacy/new persistence round trips and migration; ordering
and visibility transitions; preset lifecycle; desired/observed comparisons; every
operation outcome; debouncing; reveal restoration; permission changes; identity
ambiguity; shortcut conflicts and lifecycle; frame calculations including negative
coordinates, mixed-scale displays, Dock/menu-bar insets and oversized windows;
rule validation, sequencing, action failure, and recursive-event protection;
and login service state/error handling.

Use protocol mocks for AX, NSWorkspace, positioning, windows, hotkeys, login,
and time. Automated tests must never move the user's real menu items or windows.

Manual release checks cover popover/configuration navigation, keyboard access,
light/dark appearance, permission removal/restoration, application restarts,
BaselineBar restarts, actual shortcut delivery, installed-app selection, login
registration, and real supported operations. Measure idle CPU over a defined
interval after settling. Test multiple physical displays and Intel hardware when
available; build coverage is not runtime coverage.

The final report must distinguish implemented, verified, unsupported, and untested
behaviour. If no external item supports reliable movement/visibility, list that
as a material product limitation and do not call general menu-bar management done.
Signing/notarisation and distribution remain separate from an unsigned local build.

## Public API references

- Apple documents the [extras-menu-bar AX attribute](https://developer.apple.com/documentation/applicationservices/kaxextrasmenubarattribute)
  used to distinguish menu extras during discovery.
- Apple documents [SMAppService status](https://developer.apple.com/documentation/servicemanagement/smappservice/status-swift.property)
  as the source of registration/authorisation state.
- The installed Apple SDK's AXUIElement, AXAttributeConstants, Carbon event, and
  AppKit headers must be checked during implementation for supported signatures,
  availability, ownership, and concurrency annotations.

## Review checkpoint

Review this design before implementation planning. The supplied requirements
authorise the product scope; the remaining review is the explicit architectural
checkpoint required by the installed superpowers brainstorming workflow.
No Git commit can be produced in the current workspace because it has no Git
repository. No product source files were changed during this assessment.
