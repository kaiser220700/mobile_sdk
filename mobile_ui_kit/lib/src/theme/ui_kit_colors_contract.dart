import "package:flutter/painting.dart";

/// Contract màu cho `AppButton` — 7 variant × trạng thái pressed/disabled.
/// Package không có giá trị mặc định nào; app-layer implement toàn bộ.
abstract class UiKitButtonColors {
  Color get primaryBg;
  Color get primaryBgPressed;
  Color get primaryBgDisabled;
  Color get primaryFg;

  Color get secondaryBg;
  Color get secondaryBgPressed;
  Color get secondaryFg;

  /// Màu chữ/icon disabled dùng chung cho primary/secondary/tertiary/
  /// outline/ghost/danger/success (không phải onPrimary — variant đó có bộ
  /// disabled riêng).
  Color get fgDisabled;

  Color get tertiaryBg;
  Color get tertiaryBgPressed;
  Color get tertiaryBgDisabled;
  Color get tertiaryFg;

  Color get outlineBorder;
  Color get outlineBorderDisabled;
  Color get outlineGhostBgPressed;
  Color get outlineGhostFg;

  Color get dangerBg;
  Color get dangerBgPressed;
  Color get dangerBgDisabled;
  Color get dangerFg;

  Color get successBg;
  Color get successBgPressed;
  Color get successBgDisabled;
  Color get successFg;

  Color get onPrimaryBg;
  Color get onPrimaryBgPressed;
  Color get onPrimaryBgDisabled;
  Color get onPrimaryFg;
  Color get onPrimaryFgDisabled;
}

/// Contract màu cho `AppRadio`.
abstract class UiKitRadioColors {
  Color get selected;
  Color get selectedInverse;
  Color get border;
  Color get disabled;
}

/// Contract màu cho `AppTabs` (underline + pill variant).
abstract class UiKitTabsColors {
  Color get background;
  Color get border;
  Color get labelDisabled;
  Color get labelActivePill;
  Color get labelActive;
  Color get labelInactive;
  Color get iconDisabled;
  Color get pressedOverlay;
  Color get pillActiveBg;
  Color get pillInactiveBg;
  Color get underlineIndicator;
  Color get badgeBgInvert;
  Color get badgeBgDefault;
  Color get badgeFgInvert;
  Color get badgeFgDefault;
}

/// Contract màu cho `AppAccordion` — không phân theo state (disabled dùng
/// opacity, không đổi màu).
abstract class UiKitAccordionColors {
  Color get title;
  Color get content;
  Color get divider;
}

/// Contract màu cho `AppProgressBar` — theo semantic + track mặc định.
abstract class UiKitProgressColors {
  Color get primary;
  Color get success;
  Color get warning;
  Color get error;
  Color get info;
  Color get trackDefault;
  Color get valueLabel;
}

/// Contract màu cho `AppDivider`.
abstract class UiKitDividerColors {
  Color get line;
  Color get label;
}

/// Contract màu cho `AppTooltip`.
abstract class UiKitTooltipColors {
  Color get background;
  Color get text;
}

/// Contract màu cho `AppPopover`.
abstract class UiKitPopoverColors {
  Color get background;
  Color get border;
  Color get backdrop;
}

/// Contract màu cho `AppMenu` (dropdown + sheet).
abstract class UiKitMenuColors {
  Color get itemTitleDisabled;
  Color get itemTitleDestructive;
  Color get itemTitleDefault;
  Color get itemShortcut;
  Color get panelBackground;
  Color get panelBorder;
  Color get sheetTitle;
  Color get sheetDescription;
}

/// Contract màu cho `AppPicker`.
abstract class UiKitPickerColors {
  Color get searchFill;
  Color get searchPlaceholder;
  Color get emptyText;
  Color get skeletonBg;
  Color get panelBackground;
  Color get panelBorder;
  Color get itemLabelDisabled;
  Color get itemLabelSelected;
  Color get itemLabelDefault;
  Color get itemSublabelDisabled;
  Color get itemSublabelDefault;
  Color get itemHighlightBg;
}

/// Contract màu cho `AppOtpInput`.
abstract class UiKitOtpColors {
  Color get borderDefault;
  Color get borderError;
  Color get borderSuccess;
  Color get maskDot;
  Color get text;
  Color get errorText;
  Color get helperText;
}

/// Contract màu cho `AppIconCircleButton`.
abstract class UiKitIconCircleButtonColors {
  Color get mutedBg;
  Color get mutedBgPressed;
  Color get mutedFg;
  Color get primaryBg;
  Color get primaryBgPressed;
  Color get primaryFg;
}

/// Contract màu cho `StaticAppBar` + `TopAppBarHome` (dùng chung field
/// bg/border/text theo tone/stuck/iconStyle).
abstract class UiKitAppBarColors {
  Color get surfaceBackground;
  Color get surfaceMutedBackground;
  Color get border;
  Color get title;
  Color get subtitle;
  Color get iconButtonFilledBg;
  Color get iconButtonFilledBgPressed;
  Color get iconButtonPlainBgPressed;
  Color get iconFg;
  Color get iconFgDisabled;
  Color get badgeBg;
  Color get badgeFg;

  // TopAppBarHome onPrimary tone
  Color get onPrimaryAvatarBg;
  Color get onPrimaryAvatarFg;
  Color get onPrimaryPressedOverlay;
  Color get onPrimaryGreeting;
  Color get onPrimaryUserName;
  Color get onPrimaryIconBg;
  Color get onPrimaryIconFg;
}

/// Granular color contracts reserved for app-specific adapters.
///
/// Runtime UI Kit components use [UiKitThemeData] instead. These contracts
/// remain exported for consumers that need a component-specific palette or
/// are migrating from an older adapter-based integration.
abstract class UiKitColorsContract {
  UiKitButtonColors get button;
  UiKitRadioColors get radio;
  UiKitTabsColors get tabs;
  UiKitAccordionColors get accordion;
  UiKitProgressColors get progress;
  UiKitDividerColors get divider;
  UiKitTooltipColors get tooltip;
  UiKitPopoverColors get popover;
  UiKitMenuColors get menu;
  UiKitPickerColors get picker;
  UiKitOtpColors get otp;
  UiKitIconCircleButtonColors get iconCircleButton;
  UiKitAppBarColors get appBar;
}
