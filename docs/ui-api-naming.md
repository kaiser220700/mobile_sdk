# UI API naming

The package remains `mobile_ui_kit`. Import its public barrel with `as ui` and
use component names without a `UiKit`, `Mobile` or `Sdk` prefix:

```dart
import 'package:flutter/material.dart';
import 'package:mobile_ui_kit/mobile_ui_kit.dart' as ui;

ui.Button(onPressed: save, child: const Text('Save'));
ui.RefreshView(onRefresh: reload, child: taskList);
```

These public names are type aliases to the existing implementations, so theme
extensions, controller ownership, enum values, widget state and constructors
retain their behavior. `UiKit*` names remain available for migration; they are
not removed by this organization change. Stability is decided per package;
implementation file names remain unchanged.

Alias the import even when using `mobile_sdk`, which re-exports this UI API.
Names such as `TextField`, `Theme`, `ThemeData`, `Icon` and `Scaffold` overlap
with Flutter. Keeping old names does not prevent ambiguous identifiers in an
unprefixed import: migrate the import and qualify its UI references together.
If the app cannot migrate yet, explicitly hide new conflicting names.

`RefreshView` expresses the list capability instead of the implementation's
refresh/load-more combination. `Autocomplete<T>` expresses what the field does;
`onSearch` may use either a local or remote data source. `RefreshScope` supplies
scroll/refresh defaults for a subtree; it is not only a visual theme. The
upstream `RefreshConfiguration` export keeps its previous meaning.

Button accepts either `child` (arbitrary widget content) or the existing string
`label`. Existing `Button.text` and `Button.icon` constructors still work. Text
and icons inside a custom child inherit button styling; custom child semantics
are preserved unless `semanticsLabel` explicitly supplies the accessible name.
This change does not rename existing constructor parameters or change defaults.

## Name mapping

| Existing name | New public name (with `ui` import) |
| --- | --- |
| `UiKitAccordion` | `ui.Accordion` |
| `UiKitAccordionColors` | `ui.AccordionColors` |
| `UiKitAccordionItem` | `ui.AccordionItem` |
| `UiKitAlertAction` | `ui.AlertAction` |
| `UiKitAlertBanner` | `ui.AlertBanner` |
| `UiKitAlertSemantic` | `ui.AlertSemantic` |
| `UiKitAnchoredOverlay` | `ui.AnchoredOverlay` |
| `UiKitAppBarColors` | `ui.AppBarColors` |
| `UiKitAsyncSuggestionField` | `ui.Autocomplete` |
| `UiKitAvatar` | `ui.Avatar` |
| `UiKitAvatarShape` | `ui.AvatarShape` |
| `UiKitAvatarSize` | `ui.AvatarSize` |
| `UiKitAvatarStack` | `ui.AvatarStack` |
| `UiKitAvatarStatus` | `ui.AvatarStatus` |
| `UiKitBadge` | `ui.Badge` |
| `UiKitBadgeSemantic` | `ui.BadgeSemantic` |
| `UiKitBadgeShape` | `ui.BadgeShape` |
| `UiKitBadgeSize` | `ui.BadgeSize` |
| `UiKitBadgeVariant` | `ui.BadgeVariant` |
| `UiKitBottomNavigation` | `ui.BottomNavigation` |
| `UiKitBottomNavigationItem` | `ui.BottomNavigationItem` |
| `UiKitBouncingMotion` | `ui.BouncingMotion` |
| `UiKitButton` | `ui.Button` |
| `UiKitButtonColors` | `ui.ButtonColors` |
| `UiKitButtonLoadingBehavior` | `ui.ButtonLoadingBehavior` |
| `UiKitButtonSize` | `ui.ButtonSize` |
| `UiKitButtonVariant` | `ui.ButtonVariant` |
| `UiKitCardShell` | `ui.CardShell` |
| `UiKitCheckbox` | `ui.Checkbox` |
| `UiKitCheckboxSize` | `ui.CheckboxSize` |
| `UiKitColorsContract` | `ui.ColorsContract` |
| `UiKitCountBadge` | `ui.CountBadge` |
| `UiKitCountdown` | `ui.Countdown` |
| `UiKitDashedBorder` | `ui.DashedBorder` |
| `UiKitDeterminateProgress` | `ui.DeterminateProgress` |
| `UiKitDialog` | `ui.Dialog` |
| `UiKitDialogAction` | `ui.DialogAction` |
| `UiKitDialogSemantic` | `ui.DialogSemantic` |
| `UiKitDivider` | `ui.Divider` |
| `UiKitDividerColors` | `ui.DividerColors` |
| `UiKitFadeMotion` | `ui.FadeMotion` |
| `UiKitFileAttachmentTile` | `ui.FileAttachmentTile` |
| `UiKitFilterChip` | `ui.FilterChip` |
| `UiKitFlipCounter` | `ui.FlipCounter` |
| `UiKitIcon` | `ui.Icon` |
| `UiKitIconCircleButtonColors` | `ui.IconCircleButtonColors` |
| `UiKitIconColor` | `ui.IconColor` |
| `UiKitIconSize` | `ui.IconSize` |
| `UiKitItem` | `ui.Item` |
| `UiKitKeyValue` | `ui.KeyValue` |
| `UiKitKeyValueLayout` | `ui.KeyValueLayout` |
| `UiKitListEntrance` | `ui.ListEntrance` |
| `UiKitListItem` | `ui.ListItem` |
| `UiKitListItemDivider` | `ui.ListItemDivider` |
| `UiKitListItemSize` | `ui.ListItemSize` |
| `UiKitLoadMoreContentBuilder` | `ui.LoadMoreContentBuilder` |
| `UiKitLoadingController` | `ui.LoadingController` |
| `UiKitLoadingOverlay` | `ui.LoadingOverlay` |
| `UiKitLoadingStep` | `ui.LoadingStep` |
| `UiKitLoadingStepBuilder` | `ui.LoadingStepBuilder` |
| `UiKitMediaPicker` | `ui.MediaPicker` |
| `UiKitMediaSource` | `ui.MediaSource` |
| `UiKitMenuColors` | `ui.MenuColors` |
| `UiKitMotion` | `ui.Motion` |
| `UiKitMotionBuilder` | `ui.MotionBuilder` |
| `UiKitMotionDirection` | `ui.MotionDirection` |
| `UiKitMotionFrame` | `ui.MotionFrame` |
| `UiKitMotionKeyframe` | `ui.MotionKeyframe` |
| `UiKitOtpColors` | `ui.OtpColors` |
| `UiKitOtpController` | `ui.OtpController` |
| `UiKitOtpDecorationBuilder` | `ui.OtpDecorationBuilder` |
| `UiKitOtpField` | `ui.OtpField` |
| `UiKitOtpOverlayBuilder` | `ui.OtpOverlayBuilder` |
| `UiKitOverlayController` | `ui.OverlayController` |
| `UiKitPickerColors` | `ui.PickerColors` |
| `UiKitPopoverColors` | `ui.PopoverColors` |
| `UiKitPressable` | `ui.Pressable` |
| `UiKitPressableBuilder` | `ui.PressableBuilder` |
| `UiKitPressableState` | `ui.PressableState` |
| `UiKitProgressColors` | `ui.ProgressColors` |
| `UiKitQuantityStepper` | `ui.QuantityStepper` |
| `UiKitRadio` | `ui.Radio` |
| `UiKitRadioColors` | `ui.RadioColors` |
| `UiKitRefreshConfiguration` | `ui.RefreshScope` |
| `UiKitRefreshContentBuilder` | `ui.RefreshContentBuilder` |
| `UiKitRefreshLoadMore` | `ui.RefreshView` |
| `UiKitScaffold` | `ui.Scaffold` |
| `UiKitSearch` | `ui.Search` |
| `UiKitSelectField` | `ui.SelectField` |
| `UiKitShimmer` | `ui.Shimmer` |
| `UiKitSkeleton` | `ui.Skeleton` |
| `UiKitStatTile` | `ui.StatTile` |
| `UiKitStatTileLayout` | `ui.StatTileLayout` |
| `UiKitStatTrend` | `ui.StatTrend` |
| `UiKitStep` | `ui.Step` |
| `UiKitStepper` | `ui.Stepper` |
| `UiKitSwitch` | `ui.Switch` |
| `UiKitSwitchSize` | `ui.SwitchSize` |
| `UiKitTabBadge` | `ui.TabBadge` |
| `UiKitTabItem` | `ui.TabItem` |
| `UiKitTabs` | `ui.Tabs` |
| `UiKitTabsColors` | `ui.TabsColors` |
| `UiKitTabsLayout` | `ui.TabsLayout` |
| `UiKitTabsVariant` | `ui.TabsVariant` |
| `UiKitTextField` | `ui.TextField` |
| `UiKitTextFieldType` | `ui.TextFieldType` |
| `UiKitTextFieldVariant` | `ui.TextFieldVariant` |
| `UiKitTheme` | `ui.Theme` |
| `UiKitThemeData` | `ui.ThemeData` |
| `UiKitTimeline` | `ui.Timeline` |
| `UiKitTimelineItem` | `ui.TimelineItem` |
| `UiKitTimelineStatus` | `ui.TimelineStatus` |
| `UiKitTitle` | `ui.Title` |
| `UiKitTitleDescriptionSize` | `ui.TitleDescriptionSize` |
| `UiKitTitleHeadingSize` | `ui.TitleHeadingSize` |
| `UiKitToastAppearance` | `ui.ToastAppearance` |
| `UiKitToastContent` | `ui.ToastContent` |
| `UiKitToastDragBehavior` | `ui.ToastDragBehavior` |
| `UiKitToastEntrance` | `ui.ToastEntrance` |
| `UiKitToastOverlay` | `ui.ToastOverlay` |
| `UiKitToastQueue` | `ui.ToastQueue` |
| `UiKitToastRequest` | `ui.ToastRequest` |
| `UiKitToastSurface` | `ui.ToastSurface` |
| `UiKitToastType` | `ui.ToastType` |
| `UiKitTooltip` | `ui.Tooltip` |
| `UiKitTooltipColors` | `ui.TooltipColors` |
| `UiKitTooltipCoordinator` | `ui.TooltipCoordinator` |
| `UiKitUnitTextField` | `ui.UnitTextField` |
