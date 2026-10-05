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
