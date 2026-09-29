# Changelog

All notable changes to this package are documented in this file.

## 0.3.0 - 2026-09-29

### Added

- Exported Firebase-independent typed configuration and telemetry contracts through the unified SDK entry point.

### Changed

- Aligned the SDK entry point with the `0.3.0` workspace release. Firebase adapters remain opt-in dependencies.

## 0.2.4 - 2026-09-28

### Fixed

- Included the UI kit fix for static filter-chip rendering when animation duration is zero.

## 0.2.3 - 2026-09-28

### Added

- Exposed the expanded `UiKitFilterChip` customization through the SDK's UI kit export.

## 0.2.2 - 2026-09-28

### Added

- Exposed the new count badge, scaffold, and bottom navigation components through the SDK's UI kit export.

## 0.2.1 - 2026-09-28

### Added

- Exposed opt-in UI kit host overrides for buttons, text fields, badges, key-value rows, and stat tiles through the SDK's UI kit export.

## 0.2.0 - 2026-09-22

### Added

- Added `mobile_sdk` as one import and dependency for `mobile_app_base`,
  `mobile_devtool`, `mobile_ui_kit`, and `mobile_update`.

### Changed

- Aligned the SDK entry point with version `0.2.0` of its constituent packages.

## 0.1.0 - 2026-09-14

### Added

- Initial release.
