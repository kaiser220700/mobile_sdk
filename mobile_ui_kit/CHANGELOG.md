# Changelog

All notable changes to this package are documented in this file.

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
