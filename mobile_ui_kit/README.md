# mobile_ui_kit

Reusable Flutter interaction and overlay primitives. Components own behavior
and accessibility semantics; the host app owns composition, content and visual
tokens through `ui.ThemeData`.

## Public API (candidate/development)

```dart
import 'package:mobile_ui_kit/mobile_ui_kit.dart' as ui;

ui.Button(onPressed: save, child: const Text('Save'));
ui.RefreshView(onRefresh: reload, child: taskList);
```

Use `ui.TextField`, `ui.Theme`, `ui.ThemeData` and other unprefixed component
names. The `ui` import alias avoids collisions with Flutter. Existing `UiKit*`
names remain available. See the [migration table](../docs/ui-api-naming.md).

## 0.2.1 host overrides

This release keeps every existing default unchanged and adds opt-in seams for
host design systems:

- `ui.ButtonLoadingBehavior.showBeforeContent` keeps an action label visible
  while its request is pending.
- `ui.TextField` accepts a fixed `inputHeight` for single-line controls and
  forwards `onSubmitted` from the platform keyboard.
- `ui.Badge` can render a leading status dot and accept bounded dimensions.
- `ui.KeyValue` supports a stacked label/value layout with optional leading
  content, divider and empty-value copy.
- `ui.StatTile` supports value-first hierarchy, visual overrides and a
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
For example, `button` maps to `<button>` on HTML and `ui.Button` on Flutter.

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
    ui.ThemeData.fromDefaults(
      primary: Color(0xFF176B87),
      primaryBg: Color(0xFFE3F4F8),
    ),
  ],
)
```

The package does not depend on a business app. Its only non-Flutter runtime
dependency is `skeletonizer` v3, used by `ui.Skeleton`.

The fallback theme is intentionally neutral. Product-specific palettes, such
as an ACN theme, belong in the host app or a separate theme package that
depends on `mobile_ui_kit`.

## Motion and compact layout primitives

The kit also includes dependency-free motion and composition primitives:
`ui.Motion`, `ui.FadeMotion`, `ui.BouncingMotion`, `ui.Shimmer`, `ui.FlipCounter`,
`ui.AvatarStack`, `ui.DashedBorder`, and `ui.QuantityStepper`. They keep
content and colors owned by the host, while supplying the behavior and
accessibility wiring shared by mobile experiences.

Use `ui.Motion` for a product-specific choreography that needs more than one
of the focused primitives. It owns the ticker, respects the platform reduced-
motion setting, and supplies one normalized timeline to the host's builder.
Set `active` to false when the host knows its content is hidden to pause it:

```dart
ui.Motion(
  duration: const Duration(milliseconds: 1200),
  loop: true,
  builder: (context, frame, child) {
    final scale = frame.valueAt(const [
      ui.MotionKeyframe(0, 1),
      ui.MotionKeyframe(.5, 1.06, Curves.easeOut),
      ui.MotionKeyframe(1, 1, Curves.easeIn),
    ]);
    return Transform.scale(scale: scale, child: child);
  },
  child: const Text('Reward'),
)
```

The interactive preview includes a `timeline-motion` example with reward
landing, attention pulse, and CTA nudge choreography.

For host-owned asynchronous or platform work, use `ui.Autocomplete`,
`ui.FileAttachmentTile`, `ui.MediaPicker`, and `ui.Countdown`. These
widgets expose only UI intents: callers still own searching, camera/file
permissions, uploads, downloads, persistence, and localization.

`ui.Pressable` and the built-in interactive components use a leading-edge
tap throttle of 300 ms by default: the first tap runs immediately and rapid
duplicates are ignored. Set `tapThrottleDuration: Duration.zero` on a direct
`ui.Pressable` when a control intentionally supports rapid repeated taps.

## Component map

| Stable id | HTML | Flutter |
| --- | --- | --- |
| `button` | `<button>` | `ui.Button` |
| `status-pill` | `<span data-status>` | `ui.Badge` (`text`, `textIcon`, `icon`) |
| `avatar-stack` | `<div class="avatar-stack">` | `ui.AvatarStack` |
| `dashed-border` | `<div class="dashed-border">` | `ui.DashedBorder` |
| `text-field` | `<input>` | `ui.TextField` |
| `select-field` | `<select>` | `ui.SelectField` |
| `filter-chip` | `<button role="checkbox">` | `ui.FilterChip` |
| `checkbox` | `<input type="checkbox">` | `ui.Checkbox` |
| `radio` | `<input type="radio">` | `ui.Radio` |
| `switch` | `<input role="switch">` | `ui.Switch` |
| `tabs` | `[role="tablist"]` | `ui.Tabs` |
| `dialog` | `<dialog>` | `ui.Dialog` |
| `toast-overlay` | `[role="status"]` | `ui.ToastOverlay` |
| `tooltip` | `[role="tooltip"]` | `ui.Tooltip` |
| `progress` | `<progress>` | `ui.DeterminateProgress` |
| `stat-tile` | `<article data-stat>` | `ui.StatTile` |
| `key-value` | `<dl>` | `ui.KeyValue` |
| `timeline` | `<ol data-timeline>` | `ui.Timeline` |
| `stepper` | `<ol data-stepper>` | `ui.Stepper` |
| `quantity-stepper` | `<input type="number">` | `ui.QuantityStepper` |
| motion | `[data-enter]`, `[data-bounce]`, shimmer, output | `ui.FadeMotion`, `ui.BouncingMotion`, `ui.Shimmer`, `ui.FlipCounter` |

The JSON file is the complete list, including foundation, layout, navigation,
disclosure, motion and overlay primitives.

## Refresh and pagination (SDK-12)

Use `ui.RefreshView` and `ui.RefreshScope` for production list
refresh/pagination. `onRefresh` returns `FutureOr<void>`; `onLoadMore` returns
`FutureOr<bool>` (`false` marks the end of the list). Existing controllers,
indicator widgets and status enums are exported from this package. No DevTool
dependency is required. See [migration guide](../mobile_sdk/README.md).
