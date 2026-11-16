# Mobile SDK changelog

This file summarizes releases that span the mobile SDK workspace. Package-level
details are maintained beside each package:

- [`mobile_sdk`](mobile_sdk/CHANGELOG.md)
- [`mobile_sdk_core`](mobile_sdk_core/CHANGELOG.md)
- [`mobile_sdk_firebase_core`](mobile_sdk_firebase_core/CHANGELOG.md)
- [`mobile_sdk_firebase_remote_config`](mobile_sdk_firebase_remote_config/CHANGELOG.md)
- [`mobile_app_base`](mobile_app_base/CHANGELOG.md)
- [`mobile_devtool`](mobile-devtool/CHANGELOG.md)
- [`mobile_ui_kit`](mobile_ui_kit/CHANGELOG.md)
- [`mobile_update`](mobile_update/CHANGELOG.md)

## Unreleased

- Restore mobile_app_base on Flutter 3.50 so the compatibility umbrella, SDK
  showcase and DevTool example resolve their local dependencies again.

- Upgrade the workspace to Flutter 3.50.0 / Dart 3.14.0, including FVM and CI.
- Migrate UI packages and demos to standalone Material types; bridge legacy
  refresh indicator theme/localization access. See docs/flutter-3.50-migration.md.

- Organize packages into application libraries, service adapters and developer tools.
- Keep package paths and umbrella exports; recommend direct dependencies by default.
- Replace workspace-wide version alignment with independent package release checks.
- UI Kit is 1.0.0-rc.1; other packages remain development/experimental versions.
- Supersede the unpublished workspace-wide 1.0.0 preparation; no existing tags are moved.

- Add concise public API names while retaining compatibility APIs for migration.
- Extract opt-in Fuzz Tap and Screen Draw as independently versioned experimental tools.
- Hosts register optional tool actions and compose overlays outside DevTool.
- Add production-only integration coverage and dependency boundary checks.
- Restore pagination after refreshing a previously exhausted list.
- Distribution remains Git-based; pub.dev publication stays disabled.

- Apply module-based public API naming to core, app wiring, updates, Firebase and DevTool.

- Add unprefixed UI names for use with an `as ui` import, including `Button`,
  `TextField`, `Autocomplete`, `RefreshView`, `RefreshScope` and `Theme`.
- Keep existing `UiKit*` names available for migration and update examples.
- Support custom button `child` content with inherited styling and semantics.

## 0.7.0 - 2026-10-15

- SDK-12: move refresh/load-more to `mobile_ui_kit` (`UiKitRefreshLoadMore`,
  `UiKitRefreshConfiguration`); keep deprecated aliases in DevTool.
- Remove the DevTool dependency and exports from `mobile_sdk`. Developer
  tooling now requires an explicit `mobile_devtool` dependency and import.

## 0.6.6 - 2026-10-12

### Added

- Added composable timeline motion and structured, SDK-owned toast
  notifications to the UI Kit, including host-provided leading visuals.
- Added presentation-free devtool root-menu composition and host theme
  configuration.

### Changed

- Aligned all SDK packages to `0.6.6`.

## 0.5.0 - 2026-10-08

### Added

- Added comprehensive per-instance appearance overrides across the UI Kit.

### Changed

- Aligned all SDK packages to `0.5.0`.

## 0.4.0 - 2026-09-29

### Added

- Added one workspace command for dependency resolution, formatting checks,
  analysis, and tests across every package and example.
- Added a GitHub Actions verification workflow using Flutter `3.47.4`.

### Changed

- Aligned all SDK packages to `0.4.0`.

## 0.3.0 - 2026-09-29

### Added

- Added Firebase-independent typed config and telemetry contracts with test fakes.
- Added opt-in Firebase module lifecycle and typed Remote Config adapter.

### Fixed

- Prevented force updates without a valid store destination.

### Changed

- Aligned all SDK packages to `0.3.0`; Firebase adapters remain separate dependencies.

## 0.2.4 - 2026-09-28

### Fixed

- Made zero-duration UI-kit filter chips render without animation.

## 0.2.3 - 2026-09-28

### Added

- Expanded filter-chip styling, sizing, trailing text, throttling, and skeleton options.

## 0.2.2 - 2026-09-28

### Added

- Added shared count badge, scaffold, and bottom navigation components.

## 0.2.1 - 2026-09-28

### Added

- Added opt-in host overrides for UI-kit buttons, text fields, badges, key-value rows, and stat tiles.

## 0.2.0 - 2026-09-22

### Added

- Added the `mobile_sdk` unified entry point.
- Expanded the UI kit with async suggestions, media, motion, attachment,
  avatar, border, and quantity-stepper primitives.
- Expanded developer tooling with refresh/load-more helpers and configurable
  launcher and network-log styles.

### Changed

- Aligned all SDK packages to version `0.2.0`.
- Updated the UI-kit theme contract and shared interaction model.

### Fixed

- Prevented duplicate UI-kit press callbacks by throttling rapid repeated taps.
- Made checked, toggled, selected, and disabled semantics consistent across
  shared interactive controls.

## 0.1.0 - 2026-09-14

### Added

- Initial mobile SDK release.
