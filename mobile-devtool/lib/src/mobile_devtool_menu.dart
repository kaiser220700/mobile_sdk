import "mobile_devtool_configuration.dart";

/// Resolves a host's root-menu entries using a
/// [MobileDevToolConfiguration].
///
/// This is deliberately presentation-free: a host can keep its existing
/// launcher, sheet surface, and theme, then render the returned entries in
/// its own menu. Entries supplied by [items] are the host's defaults;
/// [MobileDevToolConfiguration.menuItems] may add or replace them and
/// [MobileDevToolConfiguration.hiddenMenuItemIds] always wins.
class MobileDevToolMenu {
  const MobileDevToolMenu._();

  /// Returns visible entries sorted by [MobileDevToolMenuItem.order].
  ///
  /// An item in [configuration.menuItems] with the same `id` replaces the
  /// matching item from [items]. If more than one custom item has the same
  /// `id`, the final declaration wins. This also makes a custom item with
  /// `visible: false` a concise way to remove one host-owned entry.
  static List<MobileDevToolMenuItem> resolve({
    required Iterable<MobileDevToolMenuItem> items,
    required MobileDevToolConfiguration configuration,
  }) {
    final resolved = <String, MobileDevToolMenuItem>{};

    for (final item in [...items, ...configuration.menuItems]) {
      if (configuration.hiddenMenuItemIds.contains(item.id)) continue;
      resolved[item.id] = item;
    }

    final visible = resolved.values.where((item) => item.visible).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    return List.unmodifiable(visible);
  }
}
