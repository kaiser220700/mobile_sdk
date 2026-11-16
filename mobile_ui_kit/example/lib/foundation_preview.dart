import 'package:material_ui/material_ui.dart';
import 'package:mobile_ui_kit/mobile_ui_kit.dart' as ui;

/// Composed screen for reviewing the default visual system.
class FoundationPreview extends StatefulWidget {
  const FoundationPreview({super.key});

  @override
  State<FoundationPreview> createState() => _FoundationPreviewState();
}

class _FoundationPreviewState extends State<FoundationPreview> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = ui.Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('UI foundations')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'A clear starting point.',
            style: t.title.copyWith(fontSize: 32),
          ),
          const SizedBox(height: 8),
          Text(
            'Consistent colors, comfortable spacing and purposeful states.',
            style: t.bodyLarge.copyWith(color: t.textMuted),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final entry in {
                'Primary': t.primary,
                'Success': t.success,
                'Warning': t.warning,
                'Error': t.error,
                'Info': t.info,
              }.entries)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 80,
                      height: 48,
                      decoration: BoxDecoration(
                        color: entry.value,
                        borderRadius: BorderRadius.circular(t.radiusMd),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(entry.key, style: t.caption),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: t.surface,
              border: Border.all(color: t.border),
              borderRadius: BorderRadius.circular(t.radiusLg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Project settings',
                        style: t.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const ui.Badge.text(
                      label: 'Saved',
                      semantic: ui.BadgeSemantic.success,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'The defaults work together. Your brand can build on them.',
                  style: t.body.copyWith(color: t.textMuted),
                ),
                const SizedBox(height: 24),
                ui.TextField(
                  controller: _name,
                  label: 'Project name',
                  placeholder: 'Workspace',
                ),
                const SizedBox(height: 16),
                ui.TextField(
                  controller: _email,
                  label: 'Contact email',
                  placeholder: 'you@example.com',
                  errorText: 'Enter a valid email address',
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ui.Button(label: 'Save changes', onPressed: () {}),
                    ui.Button(
                      label: 'Preview',
                      variant: ui.ButtonVariant.outline,
                      onPressed: () {},
                    ),
                    const ui.Button(label: 'Unavailable', onPressed: null),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              ui.Badge.text(label: 'Ready', semantic: ui.BadgeSemantic.success),
              ui.Badge.text(
                label: 'Needs attention',
                semantic: ui.BadgeSemantic.warning,
              ),
              ui.Badge.text(label: 'Failed', semantic: ui.BadgeSemantic.error),
              ui.Badge.text(
                label: 'Information',
                semantic: ui.BadgeSemantic.info,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
