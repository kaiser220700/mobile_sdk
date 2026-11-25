import "package:material_ui/material_ui.dart";
import "package:flutter/services.dart";

import "package:mobile_ui_kit/src/otp/ui_kit_otp_controller.dart";
import "package:mobile_ui_kit/src/theme/ui_kit_theme.dart";

/// [singleField] uses one native input for reliable soft-keyboard editing.
/// [segmented] retains the legacy per-digit focus/controller behavior; its empty
/// cell backspace handler requires a hardware key event.
enum UiKitOtpInputMode { singleField, segmented }

typedef UiKitOtpCellBuilder = Widget Function(
  BuildContext context,
  int index,
  String value,
  bool active,
);

/// Widget đè lên trên 1 ô [TextField] để vẽ trạng thái hiển thị tuỳ ý
/// (VD dot mask) — app-layer cung cấp qua [UiKitOtpField.overlayBuilder].
typedef UiKitOtpOverlayBuilder = Widget? Function(
  BuildContext context,
  int index,
  String value,
  bool hasFocus,
);

/// App-layer style 1 ô input qua `InputDecoration` chuẩn Material — thay vì
/// ép 1 kiểu visual cố định, package chỉ cung cấp state (`hasFocus`) để app
/// quyết định border/màu theo state (focus/error/success...).
typedef UiKitOtpDecorationBuilder = InputDecoration Function(
  BuildContext context,
  int index,
  bool hasFocus,
);

/// OTP behavior with app-owned cells. The default is one native text field
/// behind a visual row, so paste/autofill and soft-keyboard delete edit one code.
/// Existing decoration/overlay builders continue to style each visual cell.
/// Choose [UiKitOtpInputMode.segmented] only for legacy per-cell focus behavior.
class UiKitOtpField extends StatefulWidget {
  const UiKitOtpField({
    required this.controller,
    this.decorationBuilder,
    this.cellBuilder,
    this.inputMode = UiKitOtpInputMode.singleField,
    this.semanticLabel,
    this.overlayBuilder,
    this.onChanged,
    this.onCompleted,
    this.enabled = true,
    this.autofocus = false,
    this.spacing,
    this.itemWidth,
    this.itemHeight,
    this.textStyle,
    super.key,
  }) : assert(decorationBuilder != null || cellBuilder != null),
       assert(
         inputMode != UiKitOtpInputMode.segmented || decorationBuilder != null,
       ),
       assert(spacing == null || spacing >= 0),
       assert(itemWidth == null || itemWidth > 0),
       assert(itemHeight == null || itemHeight > 0);

  final UiKitOtpController controller;

  final UiKitOtpDecorationBuilder? decorationBuilder;
  final UiKitOtpCellBuilder? cellBuilder;
  final UiKitOtpInputMode inputMode;
  final String? semanticLabel;

  /// Khi trả về non-null cho 1 ô, lớp overlay này được vẽ đè lên trên
  /// (dùng cho mask: ô input thật ẩn màu chữ, overlay tự vẽ dot).
  final UiKitOtpOverlayBuilder? overlayBuilder;

  final ValueChanged<String>? onChanged;

  final ValueChanged<String>? onCompleted;

  final bool enabled;

  final bool autofocus;

  final double? spacing;

  final double? itemWidth;

  final double? itemHeight;

  final TextStyle? textStyle;

  @override
  State<UiKitOtpField> createState() => _UiKitOtpFieldState();
}

class _UiKitOtpFieldState extends State<UiKitOtpField> {
  late final TextEditingController _input;
  late String _lastText;
  String? _lastCompleted;

  @override
  void initState() {
    super.initState();
    _lastText = widget.controller.text;
    _lastCompleted = widget.controller.isComplete ? _lastText : null;
    _input = TextEditingController(text: _lastText);
    _input.addListener(_refreshCells);
    widget.controller.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant UiKitOtpField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleControllerChanged);
      widget.controller.addListener(_handleControllerChanged);
      _lastText = widget.controller.text;
      _lastCompleted = widget.controller.isComplete ? _lastText : null;
      _syncInput();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    _input.removeListener(_refreshCells);
    _input.dispose();
    super.dispose();
  }

  void _refreshCells() {
    if (mounted) setState(() {});
  }

  void _syncInput() {
    final text = widget.controller.text;
    if (_input.text != text) {
      _input.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
  }

  void _handleControllerChanged() {
    final controller = widget.controller;
    final text = controller.text;
    _syncInput();
    _refreshCells();
    if (text == _lastText) return;
    _lastText = text;
    final complete = controller.isComplete;
    final shouldComplete = complete && _lastCompleted != text;
    _lastCompleted = complete ? text : null;
    widget.onChanged?.call(text);
    // A host callback may clear or replace the code synchronously.
    if (!mounted ||
        widget.controller != controller ||
        controller.text != text) {
      return;
    }
    if (shouldComplete) {
      TextInput.finishAutofillContext();
      widget.onCompleted?.call(text);
    }
  }

  Widget _singleInput(BuildContext context) {
    final theme = UiKitTheme.of(context);
    final controller = widget.controller;
    final focus = controller.focusNodes.first;
    final style = widget.textStyle ?? theme.numeric;
    return AnimatedBuilder(
      animation: focus,
      builder: (context, _) => LayoutBuilder(
        builder: (context, constraints) {
          final wantedGap = widget.spacing ?? theme.spacingSm;
          final maxWidth = constraints.maxWidth;
          final gap = maxWidth.isFinite
              ? wantedGap
                    .clamp(0.0, maxWidth / (controller.length * 2))
                    .toDouble()
              : wantedGap;
          final available = maxWidth.isFinite
              ? ((maxWidth - gap * (controller.length - 1)) / controller.length)
                    .clamp(0.0, double.infinity)
                    .toDouble()
              : widget.itemWidth ?? theme.sizes.otpWidth;
          final width = (widget.itemWidth ?? theme.sizes.otpWidth)
              .clamp(0.0, available)
              .toDouble();
          final selection = _input.selection.extentOffset;
          final active = (selection < 0 ? _input.text.length : selection).clamp(
            0,
            controller.length - 1,
          );
          return SizedBox(
            width: width * controller.length + gap * (controller.length - 1),
            child: Stack(
              children: [
                ExcludeSemantics(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < controller.length; i++) ...[
                        if (i > 0) SizedBox(width: gap),
                        SizedBox(
                          width: width,
                          height: widget.itemHeight ?? theme.sizes.otpHeight,
                          child: _cell(
                            context,
                            i,
                            focus.hasFocus && active == i,
                            style,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Positioned.fill(
                  child: Semantics(
                    label: widget.semanticLabel,
                    child: TextField(
                      controller: _input,
                      focusNode: focus,
                      enabled: widget.enabled,
                      autofocus: widget.autofocus,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.oneTimeCode],
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(controller.length),
                      ],
                      style: style.copyWith(color: Colors.transparent),
                      cursorColor: Colors.transparent,
                      showCursor: false,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        filled: false,
                        isCollapsed: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: controller.setText,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _cell(BuildContext context, int index, bool active, TextStyle style) {
    final value = widget.controller.valueAt(index);
    if (widget.cellBuilder != null) {
      return widget.cellBuilder!(context, index, value, active);
    }
    final overlay = widget.overlayBuilder?.call(context, index, value, active);
    return Stack(
      fit: StackFit.expand,
      children: [
        InputDecorator(
          isFocused: active,
          isEmpty: value.isEmpty,
          decoration: widget.decorationBuilder!(context, index, active)
              .copyWith(enabled: widget.enabled),
          child: Center(
            child: Text(overlay == null ? value : "", style: style),
          ),
        ),
        if (overlay != null)
          Positioned.fill(child: IgnorePointer(child: overlay)),
      ],
    );
  }

  void _handleBackspace(int index) {
    widget.controller.backspaceAt(index);
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    if (widget.inputMode == UiKitOtpInputMode.singleField) {
      return AutofillGroup(child: _singleInput(context));
    }
    final theme = UiKitTheme.of(context);

    return FocusTraversalGroup(
      child: AutofillGroup(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < controller.length; i++) ...[
              if (i > 0) SizedBox(width: widget.spacing ?? theme.spacingSm),
              SizedBox(
                width: widget.itemWidth ?? theme.sizes.otpWidth,
                height: widget.itemHeight ?? theme.sizes.otpHeight,
                child: _OtpDigitField(
                  index: i,
                  controller: controller,
                  decorationBuilder: widget.decorationBuilder!,
                  overlayBuilder: widget.overlayBuilder,
                  enabled: widget.enabled,
                  autofocus: widget.autofocus && i == 0,
                  textStyle: widget.textStyle,
                  onBackspace: _handleBackspace,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OtpDigitField extends StatefulWidget {
  const _OtpDigitField({
    required this.index,
    required this.controller,
    required this.decorationBuilder,
    required this.overlayBuilder,
    required this.enabled,
    required this.autofocus,
    required this.textStyle,
    required this.onBackspace,
  });

  final int index;
  final UiKitOtpController controller;
  final UiKitOtpDecorationBuilder decorationBuilder;
  final UiKitOtpOverlayBuilder? overlayBuilder;
  final bool enabled;
  final bool autofocus;
  final TextStyle? textStyle;
  final ValueChanged<int> onBackspace;

  @override
  State<_OtpDigitField> createState() => _OtpDigitFieldState();
}

class _OtpDigitFieldState extends State<_OtpDigitField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.controller.focusNodes[widget.index];
    _focusNode.addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(covariant _OtpDigitField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newFocusNode = widget.controller.focusNodes[widget.index];
    if (newFocusNode != _focusNode) {
      _focusNode.removeListener(_handleFocusChanged);
      _focusNode = newFocusNode;
      _focusNode.addListener(_handleFocusChanged);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChanged);
    super.dispose();
  }

  void _handleFocusChanged() {
    if (mounted) setState(() {});
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      final value = widget.controller.valueAt(widget.index);
      if (value.isEmpty) {
        widget.onBackspace(widget.index);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final index = widget.index;
    final hasFocus = _focusNode.hasFocus;

    final overlay = widget.overlayBuilder?.call(
      context,
      index,
      controller.valueAt(index),
      hasFocus,
    );

    final effectiveStyle = overlay != null
        ? (widget.textStyle ?? const TextStyle()).copyWith(
            color: Colors.transparent,
          )
        : widget.textStyle;

    final field = Focus(
      onKeyEvent: _handleKeyEvent,
      child: TextField(
        controller: controller.textControllers[index],
        focusNode: _focusNode,
        enabled: widget.enabled,
        autofocus: widget.autofocus,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        autofillHints: const [AutofillHints.oneTimeCode],
        style: effectiveStyle,
        showCursor: overlay == null,
        decoration: widget.decorationBuilder(context, index, hasFocus),
        onChanged: (value) => controller.setChar(index, value),
      ),
    );

    if (overlay == null) return field;

    return Stack(
      children: [
        field,
        Positioned.fill(child: IgnorePointer(child: overlay)),
      ],
    );
  }
}
