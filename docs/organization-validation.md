# Organization validation — 2026-10-16

This record supersedes the unpublished workspace-wide 1.0.0 proposal at commit
1f86577. No published Git tags are moved, no package folders are relocated,
and no external application is modified.

## Current scope

- mobile_ui_kit: 1.0.0-rc.1, release candidate.
- Existing app/core/update/Firebase/DevTool packages and compatibility umbrella:
  0.8.0-dev.0. These versions can evolve independently.
- Fuzz/Screen Draw: independent 0.1.0-dev.0 experimental packages.
- No package is declared stable just because workspace tests pass.
- The catalog records role/maturity; each pubspec owns its version.

## Compatibility and integration

The mobile_sdk barrel retains app/core/UI/update exports and its AppBase
dependency. Its existing path and import URI are unchanged. A widget test
constructs AppShell through the umbrella and verifies its navigator/home.

The recommended direct-package consumer now owns MaterialApp and depends only
on mobile_ui_kit. Its graph test forbids the umbrella, AppBase, core, update,
Firebase and developer tools. Refresh/pagination/no-more recovery tests remain.

Earlier breaking DevTool extraction changes are not undone or silently claimed
backward-compatible. The historical migration document describes those changes.
The current organization step introduces no additional public API removal.

## Release policy

- Different versions are accepted on main/develop/feature branches.
- release/<package>/<version> and <package>/v<version> validate only the selected
  release version; unrelated packages can remain in development.
- Selected releases require dated package notes.
- Experimental packages remain 0.x; stable 1.x promotion requires changing the
  catalog maturity explicitly.
- Six policy tests exercise positive and negative cases.
- Legacy workspace tags are retained; no new tag is created in this task.

## Evidence

| Check | Result |
| --- | --- |
| Independent metadata policy and six tests | Pass |
| Legacy AppShell/umbrella widget test | Pass |
| Direct production consumer, Flutter 3.44.6 | Pass |
| Full workspace format/analyze/tests, Flutter 3.47.4 | Pass |
| Minimal consumer dependency boundary | Pass |
| Android release direct consumer | Pass, Flutter 3.47.4 |
| iOS release direct consumer, no codesign | Pass, Flutter 3.47.4 |

Native artifacts are smoke builds, not store/distribution-signed applications.
Firebase-native project integration and device-level user acceptance are not
new evidence from this organizational change. Historical native build results
remain in release-1.0.0.md and apply to that older snapshot.

## Next release decision

UI Kit can continue candidate validation before its own 1.0.0 promotion.
Other packages need their own demonstrated consumer need, public scope and
relevant integration validation. There is no requirement to promote or bump
them together. Git-based distribution remains in place; pub.dev stays disabled.
