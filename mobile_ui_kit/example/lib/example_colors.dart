import "package:flutter/material.dart";
import "package:mobile_ui_kit/mobile_ui_kit.dart";

/// Five knobs used by the preview to demonstrate app-level theming.
///
/// The legacy [UiKitColorsContract] is implemented as well so the example is
/// a useful adapter reference for an app that still uses the granular
/// contracts. Runtime widgets consume [theme] through [UiKitThemeData].
class ExampleColors implements UiKitColorsContract {
  const ExampleColors({
    this.primary = const Color(0xFF176B87),
    this.surface = Colors.white,
    this.border = const Color(0xFFD7E1E5),
    this.text = const Color(0xFF17242A),
    this.error = const Color(0xFFB42318),
  });

  final Color primary;
  final Color surface;
  final Color border;
  final Color text;
  final Color error;

  ExampleColors copyWith({
    Color? primary,
    Color? surface,
    Color? border,
    Color? text,
    Color? error,
  }) => ExampleColors(
    primary: primary ?? this.primary,
    surface: surface ?? this.surface,
    border: border ?? this.border,
    text: text ?? this.text,
    error: error ?? this.error,
  );

  UiKitThemeData get theme => UiKitThemeData.fromDefaults(
    primary: primary,
    primaryBg: _tint(primary, .88),
    surface: surface,
    surfaceMuted: _mix(surface, border, .28),
    text: text,
    textMuted: _mix(text, surface, .48),
    textDisabled: _mix(text, surface, .72),
    error: error,
    errorBg: _tint(error, .9),
    border: border,
    borderStrong: _mix(border, text, .16),
    borderControl: _mix(border, text, .46),
    focusRing: _tint(primary, .48),
  );

  static Color _mix(Color first, Color second, double amount) =>
      Color.lerp(first, second, amount)!;

  static Color _tint(Color color, double amount) =>
      Color.lerp(color, Colors.white, amount)!;

  // Granular adapter surface. These contracts predate UiKitThemeData and
  // are intentionally kept here as a small, copyable migration example.
  static final _button = _ExampleButtonColors();
  static final _radio = _ExampleRadioColors();
  static final _tabs = _ExampleTabsColors();
  static final _accordion = _ExampleAccordionColors();
  static final _progress = _ExampleProgressColors();
  static final _divider = _ExampleDividerColors();
  static final _tooltip = _ExampleTooltipColors();
  static final _popover = _ExamplePopoverColors();
  static final _menu = _ExampleMenuColors();
  static final _picker = _ExamplePickerColors();
  static final _otp = _ExampleOtpColors();
  static final _iconCircleButton = _ExampleIconCircleButtonColors();
  static final _appBar = _ExampleAppBarColors();

  @override
  UiKitButtonColors get button => _button;
  @override
  UiKitRadioColors get radio => _radio;
  @override
  UiKitTabsColors get tabs => _tabs;
  @override
  UiKitAccordionColors get accordion => _accordion;
  @override
  UiKitProgressColors get progress => _progress;
  @override
  UiKitDividerColors get divider => _divider;
  @override
  UiKitTooltipColors get tooltip => _tooltip;
  @override
  UiKitPopoverColors get popover => _popover;
  @override
  UiKitMenuColors get menu => _menu;
  @override
  UiKitPickerColors get picker => _picker;
  @override
  UiKitOtpColors get otp => _otp;
  @override
  UiKitIconCircleButtonColors get iconCircleButton => _iconCircleButton;
  @override
  UiKitAppBarColors get appBar => _appBar;
}

// The runtime package currently reads UiKitThemeData. Returning a neutral
// palette from the legacy adapter keeps this example focused on the five
// globally editable tokens without pretending that every old contract is a
// separate source of truth.
class _ExampleButtonColors implements UiKitButtonColors {
  const _ExampleButtonColors();
  @override
  dynamic noSuchMethod(Invocation invocation) => UiKitTheme.primary;
}

class _ExampleRadioColors implements UiKitRadioColors {
  const _ExampleRadioColors();
  @override
  dynamic noSuchMethod(Invocation invocation) => UiKitTheme.primary;
}

class _ExampleTabsColors implements UiKitTabsColors {
  const _ExampleTabsColors();
  @override
  dynamic noSuchMethod(Invocation invocation) => UiKitTheme.primary;
}

class _ExampleAccordionColors implements UiKitAccordionColors {
  const _ExampleAccordionColors();
  @override
  dynamic noSuchMethod(Invocation invocation) => UiKitTheme.primary;
}

class _ExampleProgressColors implements UiKitProgressColors {
  const _ExampleProgressColors();
  @override
  dynamic noSuchMethod(Invocation invocation) => UiKitTheme.primary;
}

class _ExampleDividerColors implements UiKitDividerColors {
  const _ExampleDividerColors();
  @override
  dynamic noSuchMethod(Invocation invocation) => UiKitTheme.primary;
}

class _ExampleTooltipColors implements UiKitTooltipColors {
  const _ExampleTooltipColors();
  @override
  dynamic noSuchMethod(Invocation invocation) => UiKitTheme.primary;
}

class _ExamplePopoverColors implements UiKitPopoverColors {
  const _ExamplePopoverColors();
  @override
  dynamic noSuchMethod(Invocation invocation) => UiKitTheme.primary;
}

class _ExampleMenuColors implements UiKitMenuColors {
  const _ExampleMenuColors();
  @override
  dynamic noSuchMethod(Invocation invocation) => UiKitTheme.primary;
}

class _ExamplePickerColors implements UiKitPickerColors {
  const _ExamplePickerColors();
  @override
  dynamic noSuchMethod(Invocation invocation) => UiKitTheme.primary;
}

class _ExampleOtpColors implements UiKitOtpColors {
  const _ExampleOtpColors();
  @override
  dynamic noSuchMethod(Invocation invocation) => UiKitTheme.primary;
}

class _ExampleIconCircleButtonColors implements UiKitIconCircleButtonColors {
  const _ExampleIconCircleButtonColors();
  @override
  dynamic noSuchMethod(Invocation invocation) => UiKitTheme.primary;
}

class _ExampleAppBarColors implements UiKitAppBarColors {
  const _ExampleAppBarColors();
  @override
  dynamic noSuchMethod(Invocation invocation) => UiKitTheme.primary;
}
