import "package:flutter/material.dart";

import "mobile_devtool_configuration.dart";

/// Generic toggle list for host-registered [MobileDevToolFeatureFlag]s —
/// replaces an app maintaining its own bespoke enum/preview-hub UI.
class MobileDevToolFeatureFlagPanel extends StatefulWidget {
  const MobileDevToolFeatureFlagPanel({required this.flags, super.key});

  final List<MobileDevToolFeatureFlag> flags;

  @override
  State<MobileDevToolFeatureFlagPanel> createState() =>
      _MobileDevToolFeatureFlagPanelState();
}

class _MobileDevToolFeatureFlagPanelState
    extends State<MobileDevToolFeatureFlagPanel> {
  late final Map<String, bool> _values = {
    for (final flag in widget.flags) flag.id: flag.getter(),
  };

  @override
  Widget build(BuildContext context) {
    if (widget.flags.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          "Không có feature flag nào",
          style: TextStyle(color: Theme.of(context).hintColor),
        ),
      );
    }

    return ListView(
      shrinkWrap: true,
      children: [
        for (final flag in widget.flags)
          SwitchListTile(
            title: Text(flag.label),
            subtitle: flag.description == null ? null : Text(flag.description!),
            value: _values[flag.id] ?? flag.getter(),
            onChanged: (value) {
              setState(() => _values[flag.id] = value);
              flag.setter(value);
            },
          ),
      ],
    );
  }
}
