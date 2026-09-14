import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:mobile_ui_kit/src/otp/ui_kit_otp_controller.dart";

/// Widget đè lên trên 1 ô [TextField] để vẽ trạng thái hiển thị tuỳ ý
/// (VD dot mask) — app-layer cung cấp qua [UiKitOtpField.overlayBuilder].
typedef UiKitOtpOverlayBuilder =
    Widget? Function(
      BuildContext context,
      int index,
      String value,
      bool hasFocus,
    );

/// App-layer style 1 ô input qua `InputDecoration` chuẩn Material — thay vì
/// ép 1 kiểu visual cố định, package chỉ cung cấp state (`hasFocus`) để app
/// quyết định border/màu theo state (focus/error/success...).
typedef UiKitOtpDecorationBuilder =
    InputDecoration Function(BuildContext context, int index, bool hasFocus);

/// OTP field headless — thay `FOtpField`. Tự quản auto-advance, backspace
/// nhảy ô trước, paste/autofill đổ nguyên mã vào ô đầu, keyboard number-pad,
/// `AutofillHints.oneTimeCode`. Package KHÔNG ép UI: [decorationBuilder]
/// (bắt buộc) style ô input Material chuẩn; [overlayBuilder] (optional) vẽ
/// đè 1 lớp riêng (VD mask dot) khi cần ẩn giá trị thật — dùng cách "1
/// TextField với `style: TextStyle(color: Colors.transparent)` + overlay
/// đè `Positioned.fill`" để vừa ẩn số thật vừa vẫn nhận input/focus/
/// autofill bình thường.
class UiKitOtpField extends StatefulWidget {
  const UiKitOtpField({
    required this.controller,
    required this.decorationBuilder,
    this.overlayBuilder,
    this.onChanged,
    this.onCompleted,
    this.enabled = true,
    this.autofocus = false,
    this.spacing = 8,
    this.itemWidth = 44,
    this.itemHeight = 48,
    this.textStyle,
    super.key,
  });

  final UiKitOtpController controller;

  final UiKitOtpDecorationBuilder decorationBuilder;

  /// Khi trả về non-null cho 1 ô, lớp overlay này được vẽ đè lên trên
  /// (dùng cho mask: ô input thật ẩn màu chữ, overlay tự vẽ dot).
  final UiKitOtpOverlayBuilder? overlayBuilder;

  final ValueChanged<String>? onChanged;

  final ValueChanged<String>? onCompleted;

  final bool enabled;

  final bool autofocus;

  final double spacing;

  final double itemWidth;

  final double itemHeight;

  final TextStyle? textStyle;

  @override
  State<UiKitOtpField> createState() => _UiKitOtpFieldState();
}

class _UiKitOtpFieldState extends State<UiKitOtpField> {
  bool _wasComplete = false;

  @override
  void initState() {
    super.initState();
    _wasComplete = widget.controller.isComplete;
    widget.controller.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant UiKitOtpField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleControllerChanged);
      widget.controller.addListener(_handleControllerChanged);
      _wasComplete = widget.controller.isComplete;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    super.dispose();
  }

  void _handleControllerChanged() {
    final controller = widget.controller;
    widget.onChanged?.call(controller.text);
    final isComplete = controller.isComplete;
    if (isComplete && !_wasComplete) {
      widget.onCompleted?.call(controller.text);
      TextInput.finishAutofillContext();
    }
    _wasComplete = isComplete;
  }

  void _handleBackspace(int index) {
    widget.controller.backspaceAt(index);
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return FocusTraversalGroup(
      child: AutofillGroup(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < controller.length; i++) ...[
              if (i > 0) SizedBox(width: widget.spacing),
              SizedBox(
                width: widget.itemWidth,
                height: widget.itemHeight,
                child: _OtpDigitField(
                  index: i,
                  controller: controller,
                  decorationBuilder: widget.decorationBuilder,
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
    final isFirst = index == 0;
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
        maxLength: isFirst ? controller.length : 1,
        autofillHints: isFirst ? const [AutofillHints.oneTimeCode] : null,
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
