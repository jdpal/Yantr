# BaselineBar Master Build Prompt for Codex

You are responsible for incrementally building BaselineBar into a shippable native macOS utility.

Read first:
- CODEX.md
- Docs/PRODUCT_SPEC.md
- Docs/ARCHITECTURE.md
- Docs/MACOS_LIMITATIONS.md
- Docs/BUILD_PLAN.md

Then execute prompts 01 through 04 in order. After each prompt:
- Build the app.
- Run tests.
- Report changed files and blockers.
- Commit only a coherent, compiling milestone if the environment supports git.

Critical constraint: there is no supported public Apple API for arbitrary global reordering of all third-party menu-bar items. Use public Accessibility/Core Graphics interfaces only, capability-detect behavior, verify changes, and report unsupported items honestly.
