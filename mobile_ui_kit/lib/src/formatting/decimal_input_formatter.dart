import 'package:flutter/services.dart';

/// Decimal editing without grouping or conversion through floating point.
class DecimalInputFormatter extends TextInputFormatter {
  DecimalInputFormatter({
    this.decimalDigits = 2,
    this.decimalSeparator = '.',
    this.allowNegative = false,
    this.maxIntegerDigits,
  }) {
    if (decimalDigits < 0 ||
        (maxIntegerDigits != null && maxIntegerDigits! < 1) ||
        (decimalSeparator != '.' && decimalSeparator != ',')) {
      throw ArgumentError('Invalid decimal input configuration');
    }
  }

  final int decimalDigits;
  final String decimalSeparator;
  final bool allowNegative;
  final int? maxIntegerDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (!newValue.composing.isCollapsed) return newValue;
    var text = newValue.text.replaceAll(RegExp('[.,]'), decimalSeparator);
    final sign = allowNegative ? '-?' : '';
    final separator = RegExp.escape(decimalSeparator);
    if (!RegExp('^$sign[0-9]*($separator[0-9]*)?\$').hasMatch(text)) {
      return oldValue;
    }
    final unsigned = text.startsWith('-') ? text.substring(1) : text;
    final parts = unsigned.split(decimalSeparator);
    if ((maxIntegerDigits != null && parts.first.length > maxIntegerDigits!) ||
        (parts.length > 1 &&
            (decimalDigits == 0 || parts.last.length > decimalDigits))) {
      return oldValue;
    }
    final insertion = text.startsWith(decimalSeparator)
        ? 0
        : text.startsWith('-$decimalSeparator')
        ? 1
        : -1;
    if (insertion >= 0) {
      text = text.replaceRange(insertion, insertion, '0');
    }
    int offset(int value) => value < 0
        ? value
        : value + (insertion >= 0 && value >= insertion ? 1 : 0);
    return newValue.copyWith(
      text: text,
      selection: newValue.selection.copyWith(
        baseOffset: offset(newValue.selection.baseOffset),
        extentOffset: offset(newValue.selection.extentOffset),
      ),
    );
  }
}
