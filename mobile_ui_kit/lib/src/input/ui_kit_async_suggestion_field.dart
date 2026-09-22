import "dart:async";

import "package:flutter/material.dart";

import "package:mobile_ui_kit/src/theme/ui_kit_theme.dart";

/// A typed autocomplete field that keeps remote searching owned by the host.
///
/// [onSearch] may call a local cache or a remote API. This widget owns only
/// debounce timing, option presentation, and selection interaction.
class UiKitAsyncSuggestionField<T extends Object> extends StatefulWidget {
  const UiKitAsyncSuggestionField({
    required this.label,
    required this.onSearch,
    required this.optionBuilder,
    required this.optionLabel,
    required this.onSelected,
    this.controller,
    this.focusNode,
    this.placeholder,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.minSearchLength = 1,
    this.enabled = true,
    this.maxOptionsHeight = 240,
    this.errorText,
    this.helperText,
    super.key,
  }) : assert(minSearchLength >= 0),
       assert(maxOptionsHeight > 0);

  final String label;
  final FutureOr<Iterable<T>> Function(String query) onSearch;
  final Widget Function(BuildContext context, T option) optionBuilder;
  final String Function(T option) optionLabel;
  final ValueChanged<T> onSelected;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? placeholder;
  final Duration debounceDuration;
  final int minSearchLength;
  final bool enabled;
  final double maxOptionsHeight;
  final String? errorText;
  final String? helperText;

  @override
  State<UiKitAsyncSuggestionField<T>> createState() =>
      _UiKitAsyncSuggestionFieldState<T>();
}

class _UiKitAsyncSuggestionFieldState<T extends Object>
    extends State<UiKitAsyncSuggestionField<T>> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _ownsController = false;
  bool _ownsFocusNode = false;

  @override
  void initState() {
    super.initState();
    _configureOwnedState();
  }

  void _configureOwnedState() {
    _ownsController = widget.controller == null;
    _ownsFocusNode = widget.focusNode == null;
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void didUpdateWidget(covariant UiKitAsyncSuggestionField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (_ownsController) _controller.dispose();
      _ownsController = widget.controller == null;
      _controller = widget.controller ?? TextEditingController();
    }
    if (oldWidget.focusNode != widget.focusNode) {
      if (_ownsFocusNode) _focusNode.dispose();
      _ownsFocusNode = widget.focusNode == null;
      _focusNode = widget.focusNode ?? FocusNode();
    }
  }

  Future<Iterable<T>> _optionsFor(TextEditingValue value) async {
    final query = value.text.trim();
    if (query.length < widget.minSearchLength) return <T>[];
    if (widget.debounceDuration > Duration.zero) {
      await Future<void>.delayed(widget.debounceDuration);
    }
    return widget.onSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiKitTheme.of(context);
    final hasError = widget.errorText != null;
    final color = hasError ? theme.error : theme.border;
    return RawAutocomplete<T>(
      textEditingController: _controller,
      focusNode: _focusNode,
      displayStringForOption: widget.optionLabel,
      optionsBuilder: _optionsFor,
      onSelected: widget.onSelected,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) =>
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.label, style: theme.bodyMedium),
              SizedBox(height: theme.spacingXs),
              TextField(
                controller: controller,
                focusNode: focusNode,
                enabled: widget.enabled,
                onSubmitted: (_) => onFieldSubmitted(),
                decoration: InputDecoration(
                  hintText: widget.placeholder,
                  filled: true,
                  fillColor: widget.enabled
                      ? theme.surface
                      : theme.surfaceMuted,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: theme.spacingMd,
                    vertical: theme.spacingMd,
                  ),
                  enabledBorder: _border(theme, color),
                  focusedBorder: _border(theme, color, width: 2),
                  disabledBorder: _border(theme, theme.border),
                ),
              ),
              if (widget.errorText != null || widget.helperText != null) ...[
                SizedBox(height: theme.spacingXs),
                Text(
                  widget.errorText ?? widget.helperText!,
                  style: theme.caption.copyWith(
                    color: hasError ? theme.error : theme.textMuted,
                  ),
                ),
              ],
            ],
          ),
      optionsViewBuilder: (context, selectOption, options) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          color: theme.surface,
          elevation: 6,
          borderRadius: BorderRadius.circular(theme.radiusMd),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: widget.maxOptionsHeight),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options.elementAt(index);
                return InkWell(
                  onTap: () => selectOption(option),
                  child: widget.optionBuilder(context, option),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  OutlineInputBorder _border(
    UiKitThemeData theme,
    Color color, {
    double width = 1,
  }) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(theme.radiusMd),
    borderSide: BorderSide(color: color, width: width),
  );

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }
}
