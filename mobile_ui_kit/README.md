# mobile_ui_kit

Reusable Flutter interaction and overlay primitives. Components own behavior
and accessibility semantics; the host app owns composition, content and visual
tokens through `UiKitThemeData`.

## 0.2.1 host overrides

This release keeps every existing default unchanged and adds opt-in seams for
host design systems:

- `UiKitButtonLoadingBehavior.showBeforeContent` keeps an action label visible
  while its request is pending.
- `UiKitTextField` accepts a fixed `inputHeight` for single-line controls and
  forwards `onSubmitted` from the platform keyboard.
- `UiKitBadge` can render a leading status dot and accept bounded dimensions.
- `UiKitKeyValue` supports a stacked label/value layout with optional leading
  content, divider and empty-value copy.
- `UiKitStatTile` supports value-first hierarchy, visual overrides and a
  borderless compact tile.

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
    UiKitThemeData.fromDefaults(
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

## Motion and compact layout primitives

The kit also includes dependency-free motion and composition primitives:
`UiKitMotion`, `UiKitFadeMotion`, `UiKitBouncingMotion`, `UiKitShimmer`, `UiKitFlipCounter`,
`UiKitAvatarStack`, `UiKitDashedBorder`, and `UiKitQuantityStepper`. They keep
content and colors owned by the host, while supplying the behavior and
accessibility wiring shared by mobile experiences.

Use `UiKitMotion` for a product-specific choreography that needs more than one
of the focused primitives. It owns the ticker, respects the platform reduced-
motion setting, and supplies one normalized timeline to the host's builder.
Set `active` to false when the host knows its content is hidden to pause it:

```dart
UiKitMotion(
  duration: const Duration(milliseconds: 1200),
  loop: true,
  builder: (context, frame, child) {
    final scale = frame.valueAt(const [
      UiKitMotionKeyframe(0, 1),
      UiKitMotionKeyframe(.5, 1.06, Curves.easeOut),
      UiKitMotionKeyframe(1, 1, Curves.easeIn),
    ]);
    return Transform.scale(scale: scale, child: child);
  },
  child: const Text('Reward'),
)
```

The interactive preview includes a `timeline-motion` example with reward
landing, attention pulse, and CTA nudge choreography.

For host-owned asynchronous or platform work, use `UiKitAsyncSuggestionField`,
`UiKitFileAttachmentTile`, `UiKitMediaPicker`, and `UiKitCountdown`. These
widgets expose only UI intents: callers still own searching, camera/file
permissions, uploads, downloads, persistence, and localization.

`UiKitPressable` and the built-in interactive components use a leading-edge
tap throttle of 300 ms by default: the first tap runs immediately and rapid
duplicates are ignored. Set `tapThrottleDuration: Duration.zero` on a direct
`UiKitPressable` when a control intentionally supports rapid repeated taps.

## Component map

| Stable id | HTML | Flutter |
| --- | --- | --- |
| `button` | `<button>` | `UiKitButton` |
| `status-pill` | `<span data-status>` | `UiKitBadge` (`text`, `textIcon`, `icon`) |
| `avatar-stack` | `<div class="avatar-stack">` | `UiKitAvatarStack` |
| `dashed-border` | `<div class="dashed-border">` | `UiKitDashedBorder` |
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
| `quantity-stepper` | `<input type="number">` | `UiKitQuantityStepper` |
| motion | `[data-enter]`, `[data-bounce]`, shimmer, output | `UiKitFadeMotion`, `UiKitBouncingMotion`, `UiKitShimmer`, `UiKitFlipCounter` |

The JSON file is the complete list, including foundation, layout, navigation,
disclosure, motion and overlay primitives.
