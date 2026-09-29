# Changelog

All notable changes to this package are documented in this file.

## 0.3.0 - 2026-09-29

### Changed

- Aligned package version with the `0.3.0` workspace release.

## 0.2.0 - 2026-09-22

### Added

- Exported the complete supported developer-tool surface, including the launcher
  bubble, chrome, configuration, JSON formatter, key-value table, and UI state.
- Added namespaced pull-to-refresh and load-more primitives through
  `MobileDevToolRefreshConfiguration` and `MobileDevToolRefreshLoadMore`.
- Re-exported the supported `pull_to_refresh_flutter3` indicators and controls.
- Added configurable colors and borders for the launcher bubble and network-log
  status filters.

### Changed

- Expanded the public network log panel API with
  `MobileDevToolNetworkStatusFilterStyle`.

## 0.1.0 - 2026-09-14

### Added

- Initial release of non-production network and trace diagnostics.
