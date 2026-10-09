import "package:flutter/material.dart";

/// Builds the theme used by SDK-owned devtool chrome and sheets.
///
/// The builder receives the ambient host context. Return [Theme.of] from that
/// context to keep the host's theme unchanged, or return a derived theme for
/// developer tooling only.
typedef MobileDevToolThemeBuilder = ThemeData Function(BuildContext context);

class MobileDevToolHostAction {
  const MobileDevToolHostAction({
    required this.label,
    required this.onPressed,
    this.icon = const IconData(0xe3c9, fontFamily: "MaterialIcons"),
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
}

/// Public menu entry for a host-owned developer tool.
///
/// Provide [builder] for a full-screen tool panel or [onSelect] for a quick
/// action. If [id] matches a built-in id from [MobileDevToolBuiltInIds], this
/// item replaces that built-in entry.
class MobileDevToolMenuItem {
  const MobileDevToolMenuItem({
    required this.id,
    required this.label,
    this.icon,
    this.builder,
    this.onSelect,
    this.order = 100,
    this.visible = true,
  }) : assert(builder != null || onSelect != null);

  final String id;
  final String label;
  final IconData? icon;
  final WidgetBuilder? builder;
  final VoidCallback? onSelect;

  /// Lower values appear earlier in the menu. Built-ins occupy 10–60.
  final int order;

  /// Set to false when the host wants to hide this entry for the current
  /// environment or user role.
  final bool visible;
}

/// Stable IDs for built-in entries that can be hidden or replaced through
/// [MobileDevToolConfiguration.menuItems] and [MobileDevToolConfiguration
/// .hiddenMenuItemIds].
class MobileDevToolBuiltInIds {
  const MobileDevToolBuiltInIds._();

  static const network = "network";
  static const trace = "trace";
  static const fuzzTapLog = "fuzz-tap-log";
  static const screenDraw = "screen-draw";
  static const fuzzTap = "fuzz-tap";
  static const featureFlags = "feature-flags";
  static const devToolInfo = "dev-tool-info";
}

/// A host-owned tool screen registered into the SDK's menu — lets an app
/// register business-specific tooling (auth, storage, mock data...) without
/// the SDK depending on that app's domain. The host builds [builder] with its
/// own widgets/view-models; the SDK only decides when and how to present it.
class MobileDevToolPanel {
  const MobileDevToolPanel({
    required this.id,
    required this.label,
    required this.builder,
    this.icon,
  });

  final String id;
  final String label;
  final IconData? icon;
  final WidgetBuilder builder;
}

/// A host-owned boolean toggle (mock data switch, preview flag...) rendered
/// generically by the SDK's feature-flag panel.
class MobileDevToolFeatureFlag {
  const MobileDevToolFeatureFlag({
    required this.id,
    required this.label,
    required this.getter,
    required this.setter,
    this.description,
  });

  final String id;
  final String label;
  final String? description;
  final ValueGetter<bool> getter;
  final ValueChanged<bool> setter;
}

class MobileDevToolConfiguration {
  const MobileDevToolConfiguration({
    this.title = "Mobile Dev Tool",
    this.hostActions = const [],
    this.panels = const [],
    this.menuItems = const [],
    this.hiddenMenuItemIds = const {},
    this.featureFlags = const [],
    this.accentColor,
    this.bubbleBackgroundColor,
    this.bubbleForegroundColor,
    this.bubbleBorderColor,
    this.themeBuilder,
  });

  final String title;
  final List<MobileDevToolHostAction> hostActions;

  /// Host-owned tool screens appended after the SDK's built-in sections
  /// (network log, trace log...) in the root menu.
  final List<MobileDevToolPanel> panels;

  /// Custom menu entries with full control over ordering and presentation.
  /// Entries can replace a built-in entry by reusing its stable ID.
  final List<MobileDevToolMenuItem> menuItems;

  /// Built-in or custom IDs to omit from the menu.
  final Set<String> hiddenMenuItemIds;

  /// Host-owned boolean toggles rendered by the SDK's generic feature-flag
  /// panel — replaces an app maintaining its own bespoke enum/preview list.
  final List<MobileDevToolFeatureFlag> featureFlags;

  /// Optional branding accent for SDK-drawn chrome (bubble, buttons). Falls
  /// back to the ambient `Theme`'s primary color when omitted.
  final Color? accentColor;

  /// Optional background color for the launcher bubble.
  ///
  /// When [themeBuilder] is supplied this defaults to that theme's
  /// [ColorScheme.surface]. Without a host theme it preserves the SDK's
  /// existing white surface.
  final Color? bubbleBackgroundColor;

  /// Optional icon color for the launcher bubble.
  ///
  /// When [themeBuilder] is supplied this defaults to that theme's
  /// [ColorScheme.primary]. Without a host theme, [accentColor] remains the
  /// legacy fallback.
  final Color? bubbleForegroundColor;

  /// Optional outline color for the launcher bubble.
  ///
  /// When [themeBuilder] is supplied this defaults to that theme's
  /// [ColorScheme.outline]. Without a host theme it preserves the SDK's
  /// existing black outline.
  final Color? bubbleBorderColor;

  /// Optional theme for SDK-owned chrome and the default root sheet.
  ///
  /// When omitted, the SDK keeps its existing light devtool theme. Set this
  /// to `(context) => Theme.of(context)` when the host wants the devtool to
  /// inherit its own theme without taking ownership of the SDK layout.
  final MobileDevToolThemeBuilder? themeBuilder;
}
