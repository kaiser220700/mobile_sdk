# mobile_ui_kit

Reusable Flutter interaction and overlay primitives. Components own behavior
and accessibility semantics; the host app owns composition, content and visual
tokens through `UiKitThemeData`.

## Interactive preview

The standalone preview is also a cross-platform reference for the HTML team:

```bash
cd mobile_ui_kit/example
flutter pub get
flutter run
```

It includes search, category filters, live component states and five editable
theme tokens: `primary`, `surface`, `border`, `text` and `error`.

The cross-platform contract is [preview/component_map.json](preview/component_map.json).
Use `components[].id` as the stable key, `components[].html` for the HTML
implementation and `components[].flutterWidget` for the app implementation.
For example, `button` maps to `<button>` on HTML and `UiKitButton` on Flutter.

## Host integration

```yaml
dependencies:
  mobile_ui_kit:
    path: ../mobile_ui_kit
```

Override the runtime tokens from the host app:

```dart
ThemeData(
  extensions: const [
    UiKitThemeData(
      primary: Color(0xFF176B87),
      primaryBg: Color(0xFFE3F4F8),
    ),
  ],
)
```

The package does not depend on a business app. Its only non-Flutter runtime
dependency is `skeletonizer` v3, used by `UiKitSkeleton`.

The fallback theme is intentionally neutral. Product-specific palettes, such
as an ACN theme, belong in the host app or a separate theme package that
depends on `mobile_ui_kit`.

## Component map

| Stable id | HTML | Flutter |
| --- | --- | --- |
| `button` | `<button>` | `UiKitButton` |
| `status-pill` | `<span data-status>` | `UiKitBadge` (`text`, `textIcon`, `icon`) |
| `text-field` | `<input>` | `UiKitTextField` |
| `select-field` | `<select>` | `UiKitSelectField` |
| `filter-chip` | `<button role="checkbox">` | `UiKitFilterChip` |
| `checkbox` | `<input type="checkbox">` | `UiKitCheckbox` |
| `radio` | `<input type="radio">` | `UiKitRadio` |
| `switch` | `<input role="switch">` | `UiKitSwitch` |
| `tabs` | `[role="tablist"]` | `UiKitTabs` |
| `dialog` | `<dialog>` | `UiKitDialog` |
| `toast-overlay` | `[role="status"]` | `UiKitToastOverlay` |
| `tooltip` | `[role="tooltip"]` | `UiKitTooltip` |
| `progress` | `<progress>` | `UiKitDeterminateProgress` |
| `stat-tile` | `<article data-stat>` | `UiKitStatTile` |
| `key-value` | `<dl>` | `UiKitKeyValue` |
| `timeline` | `<ol data-timeline>` | `UiKitTimeline` |
| `stepper` | `<ol data-stepper>` | `UiKitStepper` |

The JSON file is the complete list, including foundation, layout, navigation,
disclosure, motion and overlay primitives.
