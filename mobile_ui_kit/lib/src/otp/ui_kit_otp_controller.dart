import "package:flutter/material.dart";

/// Controller quản lý giá trị + focus của [UiKitOtpField] — thay
/// `FOtpFieldControl.managed`. Headless, không phụ thuộc `forui`.
///
/// API surface (giữ ổn định cho caller): constructor `length`, [text],
/// [isComplete], [valueAt], [setChar], [backspaceAt], [clear],
/// [focusNodes], [textControllers].
class UiKitOtpController extends ChangeNotifier {
  UiKitOtpController({required this.length})
    : assert(length > 0, "length phải > 0"),
      _values = List.filled(length, ""),
      focusNodes = List.generate(length, (_) => FocusNode()),
      textControllers = List.generate(length, (_) => TextEditingController());

  final int length;
  final List<String> _values;
  final List<FocusNode> focusNodes;
  final List<TextEditingController> textControllers;

  String get text => _values.join();

  bool get isComplete => _values.every((v) => v.isNotEmpty);

  String valueAt(int index) => _values[index];

  /// Cập nhật ký tự tại [index]. Nếu [char] rỗng → xoá ô đó. Nếu [char] có
  /// nhiều ký tự (paste/autofill đổ nguyên mã vào 1 ô) → phân phối từ
  /// [index] qua [_fillFrom].
  void setChar(int index, String char) {
    if (char.isEmpty) {
      _values[index] = "";
      textControllers[index].clear();
      notifyListeners();
      return;
    }
    if (char.length > 1) {
      _fillFrom(index, char);
      return;
    }
    _values[index] = char;
    if (textControllers[index].text != char) {
      textControllers[index].text = char;
    }
    notifyListeners();
    if (index < length - 1) {
      focusNodes[index + 1].requestFocus();
    } else {
      focusNodes[index].unfocus();
    }
  }

  void _fillFrom(int startIndex, String pasted) {
    final digits = pasted.replaceAll(RegExp(r"\D"), "");
    var cursor = startIndex;
    for (final ch in digits.split("")) {
      if (cursor >= length) break;
      _values[cursor] = ch;
      textControllers[cursor].text = ch;
      cursor++;
    }
    notifyListeners();
    final nextEmpty = _values.indexWhere((v) => v.isEmpty);
    if (nextEmpty == -1) {
      focusNodes[length - 1].unfocus();
    } else {
      focusNodes[nextEmpty].requestFocus();
    }
  }

  /// Xử lý backspace tại [index]: nếu ô hiện tại còn ký tự → xoá tại chỗ;
  /// nếu đã rỗng → nhảy về ô trước và xoá ô đó (hành vi OTP input chuẩn).
  void backspaceAt(int index) {
    if (_values[index].isNotEmpty) {
      setChar(index, "");
      return;
    }
    if (index == 0) return;
    focusNodes[index - 1].requestFocus();
    setChar(index - 1, "");
  }

  void clear() {
    for (var i = 0; i < length; i++) {
      _values[i] = "";
      textControllers[i].clear();
    }
    notifyListeners();
    focusNodes.first.requestFocus();
  }

  @override
  void dispose() {
    for (final n in focusNodes) {
      n.dispose();
    }
    for (final c in textControllers) {
      c.dispose();
    }
    super.dispose();
  }
}
