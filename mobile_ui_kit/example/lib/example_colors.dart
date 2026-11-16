import "package:material_ui/material_ui.dart";
import "package:mobile_ui_kit/mobile_ui_kit.dart" as ui;

/// Five knobs used by the preview to demonstrate app-level theming.
///
/// The legacy [ui.ColorsContract] is implemented as well so the example is
/// a useful adapter reference for an app that still uses the granular
/// contracts. Runtime widgets consume [theme] through [ui.ThemeData].
class ExampleColors implements ui.ColorsContract {
  const ExampleColors({
    this.primary = ui.Theme.primary,
    this.surface = ui.Theme.surface,
    this.border = ui.Theme.border,
    this.text = ui.Theme.text,
    this.error = ui.Theme.error,
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

  ui.ThemeData get theme => ui.ThemeData.fromDefaults(
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

  // Granular adapter surface. These contracts predate ui.ThemeData and
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
  ui.ButtonColors get button => _button;
  @override
  ui.RadioColors get radio => _radio;
  @override
  ui.TabsColors get tabs => _tabs;
  @override
  ui.AccordionColors get accordion => _accordion;
  @override
  ui.ProgressColors get progress => _progress;
  @override
  ui.DividerColors get divider => _divider;
  @override
  ui.TooltipColors get tooltip => _tooltip;
  @override
  ui.PopoverColors get popover => _popover;
  @override
  ui.MenuColors get menu => _menu;
  @override
  ui.PickerColors get picker => _picker;
  @override
  ui.OtpColors get otp => _otp;
  @override
  ui.IconCircleButtonColors get iconCircleButton => _iconCircleButton;
  @override
  ui.AppBarColors get appBar => _appBar;
}

// The runtime package currently reads ui.ThemeData. Returning a neutral
// palette from the legacy adapter keeps this example focused on the five
// globally editable tokens without pretending that every old contract is a
// separate source of truth.
class _ExampleButtonColors implements ui.ButtonColors {
  const _ExampleButtonColors();
  @override
  dynamic noSuchMethod(Invocation invocation) => ui.Theme.primary;
}

class _ExampleRadioColors implements ui.RadioColors {
  const _ExampleRadioColors();
  @override
  dynamic noSuchMethod(Invocation invocation) => ui.Theme.primary;
}

class _ExampleTabsColors implements ui.TabsColors {
  const _ExampleTabsColors();
  @override
  dynamic noSuchMethod(Invocation invocation) => ui.Theme.primary;
}

class _ExampleAccordionColors implements ui.AccordionColors {
  const _ExampleAccordionColors();
  @override
  dynamic noSuchMethod(Invocation invocation) => ui.Theme.primary;
}

class _ExampleProgressColors implements ui.ProgressColors {
  const _ExampleProgressColors();
  @override
  dynamic noSuchMethod(Invocation invocation) => ui.Theme.primary;
}

class _ExampleDividerColors implements ui.DividerColors {
  const _ExampleDividerColors();
  @override
  dynamic noSuchMethod(Invocation invocation) => ui.Theme.primary;
}

class _ExampleTooltipColors implements ui.TooltipColors {
  const _ExampleTooltipColors();
  @override
  dynamic noSuchMethod(Invocation invocation) => ui.Theme.primary;
}

class _ExamplePopoverColors implements ui.PopoverColors {
  const _ExamplePopoverColors();
  @override
  dynamic noSuchMethod(Invocation invocation) => ui.Theme.primary;
}

class _ExampleMenuColors implements ui.MenuColors {
  const _ExampleMenuColors();
  @override
  dynamic noSuchMethod(Invocation invocation) => ui.Theme.primary;
}

class _ExamplePickerColors implements ui.PickerColors {
  const _ExamplePickerColors();
  @override
  dynamic noSuchMethod(Invocation invocation) => ui.Theme.primary;
}

class _ExampleOtpColors implements ui.OtpColors {
  const _ExampleOtpColors();
  @override
  dynamic noSuchMethod(Invocation invocation) => ui.Theme.primary;
}

class _ExampleIconCircleButtonColors implements ui.IconCircleButtonColors {
  const _ExampleIconCircleButtonColors();
  @override
  dynamic noSuchMethod(Invocation invocation) => ui.Theme.primary;
}

class _ExampleAppBarColors implements ui.AppBarColors {
  const _ExampleAppBarColors();
  @override
  dynamic noSuchMethod(Invocation invocation) => ui.Theme.primary;
}
