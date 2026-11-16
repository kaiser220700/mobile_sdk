# Changelog

All notable changes to this package are documented in this file.

## Unreleased

- Breaking: require Flutter 3.50 / Dart 3.14 and use standalone `material_ui`
  types. Hosts must migrate Material imports and theme values together.
- Bridge legacy refresh indicators to the standalone host theme/localizations.

- Add configurable DecimalInputFormatter with caret and IME preservation.
- Add BottomActionArea for device bottom spacing inside Scaffold layouts.
- Fix autocomplete debounce to skip superseded searches and pending work after
  disposal or configuration changes. Ignore stale async results and expose
  onSearchError for failed current queries instead of an unhandled async error.
- Extend MediaPicker with host source presentation/control builders, explicit
  indeterminate uploading, empty-field errors and error styling. Block actions
  during upload and ignore late source results after disposal or state changes.
- Add LoadingController.acquire/run/activeCount for independent concurrent tasks;
  preserve manual loading states and make lease release idempotent.
- Refresh default light visuals with blue/slate semantic colors, 6/12/16/24 radii
  and 48px minimum touch targets. This intentionally changes fallback appearance.
- Add Theme.material() to synchronize the kit with Material colors/typography,
  app bars, input decoration and bottom sheets. Add a composed foundations preview
  and default foreground contrast tests.
- Fix default TextField error typography to use the semantic error color;
  preserve explicit host helperStyle overrides.
- Cancel pending autocomplete debounce timers on replacement/disposal and
  materialize lazy options once. Remove per-build CurvedAnimation listeners
  from motion/list entrance and allow Countdown duration changes safely.
- Add a bounded repeated-lifecycle check with Flutter disposal leak tracking.

## 1.0.0-rc.1 - 2026-10-16

- Reset exhausted pagination after a successful refresh, with regression coverage.

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

- Added composable timeline motion primitives.
- Added structured SDK-owned toast notifications with queueing, safe-area
  placement, auto-dismiss, tap actions, drag dismissal, and optional
  slide-from-top entrance motion.
- Added `UiKitToastAppearance.leading` for a host-provided leading widget;
  artwork replaces the type/default icon without icon color treatment.

### Fixed

- Improved `lockDownward` toast drag activation and axis handling.

## 0.5.0 - 2026-10-08

### Changed

- Updated outline buttons to use a 1 dp `borderControl` border by default,
  with per-button color and width overrides.
- Added a 16 dp minimum bottom safe-area inset to `UiKitBottomNavigation`.
- Added per-instance visual overrides for inputs, selection controls, tabs,
  lists, timelines, steppers, cards, content surfaces, avatars, and dialogs.

## 0.4.0 - 2026-09-29

### Changed

- Aligned package version with the `0.4.0` workspace release.

## 0.3.0 - 2026-09-29

### Changed

- Aligned package version with the `0.3.0` workspace release.

## 0.2.4 - 2026-09-28

### Fixed

- Kept `UiKitFilterChip` rendering static when `animationDuration` is `Duration.zero`, so hosts can disable chip animation completely.

## 0.2.3 - 2026-09-28

### Added

- Added `UiKitFilterChip` overrides for size, spacing, colors, borders, text, animation, tap throttling, trailing text, and skeleton rendering.

## 0.2.2 - 2026-09-28

### Added

- Added `UiKitCountBadge`, `UiKitScaffold`, and `UiKitBottomNavigation` to the public UI kit API.

## 0.2.1 - 2026-09-28

### Added

- Added opt-in host overrides for button loading, text-field height and submission, badge layout, key-value layout, and stat tiles; existing defaults were preserved.

## 0.2.0 - 2026-09-22

### Added

- Added `UiKitAsyncSuggestionField` for debounced asynchronous option search.
- Added file-attachment, avatar-stack, dashed-border, media-picker, countdown,
  motion, and quantity-stepper components.
- Added `UiKitPressable` support for selected, checked, and toggled semantics,
  plus configurable tap throttling.
- Added component previews and coverage for list items, motion, pressable
  controls, and themes.

### Changed

- Made `UiKitThemeData` require a complete token set; use
  `UiKitThemeData.fromDefaults` for partial overrides.
- Moved checkbox, filter-chip, switch, tabs, select field, and related
  interactive controls onto the shared `UiKitPressable` interaction model.
- Enhanced buttons, list items, stats, steppers, text fields, and the theme
  contract to use the expanded UI-kit primitives.

### Fixed

- Prevented duplicate press callbacks by throttling successive taps by default;
  controls that need rapid repeated input can opt out with `Duration.zero`.
- Standardized accessibility state and enabled/disabled interaction handling
  across checkbox, filter-chip, switch, and tab controls.
- Ensured partial theme overrides are explicit instead of silently mixing host
  values with package defaults.

## 0.1.0 - 2026-09-14

### Added

- Initial release of the shared UI-kit primitives and theme tokens.
