/// Reads whole Vietnamese dong amounts without floating-point rounding.
///
/// Negative amounts are prefixed with "âm". Zero is "không đồng".
String vietnameseDongInWords(int amount) {
  return vietnameseDongBigIntInWords(BigInt.from(amount));
}

/// Accepts exact amounts beyond the native integer range.
String vietnameseDongBigIntInWords(BigInt number) {
  if (number.isNegative) {
    return 'âm ${vietnameseDongBigIntInWords(-number)}';
  }
  if (number == BigInt.zero) return 'không đồng';

  const units = [
    '',
    'một',
    'hai',
    'ba',
    'bốn',
    'năm',
    'sáu',
    'bảy',
    'tám',
    'chín',
  ];
  const levels = ['', 'nghìn', 'triệu'];
  final thousand = BigInt.from(1000);

  String readThreeDigits(int n) {
    int hundred = n ~/ 100;
    int ten = (n % 100) ~/ 10;
    int unit = n % 10;

    String result = '';

    if (hundred > 0) {
      result += '${units[hundred]} trăm';
    }

    if (ten > 1) {
      result += '${result.isNotEmpty ? ' ' : ''}${units[ten]} mươi';
      if (unit == 1) {
        result += ' mốt';
      } else if (unit == 5) {
        result += ' lăm';
      } else if (unit > 0) {
        result += ' ${units[unit]}';
      }
    } else if (ten == 1) {
      result += '${result.isNotEmpty ? ' ' : ''}mười';
      if (unit == 5) {
        result += ' lăm';
      } else if (unit > 0) {
        result += ' ${units[unit]}';
      }
    } else if (ten == 0 && unit > 0) {
      if (hundred > 0) {
        result += ' lẻ ${units[unit]}';
      } else {
        result += units[unit];
      }
    }

    return result.trim();
  }

  List<String> parts = [];
  int level = 0;

  while (number > BigInt.zero) {
    final chunk = (number % thousand).toInt();

    if (chunk > 0) {
      final levelText = [
        levels[level % 3],
        for (var i = 0; i < level ~/ 3; i++) 'tỷ',
      ].where((part) => part.isNotEmpty).join(' ');
      String chunkText = readThreeDigits(chunk);

      final isHighestChunk = number < thousand;

      if (!isHighestChunk && chunk < 100) {
        if (chunk < 10) {
          chunkText = 'không trăm lẻ $chunkText';
        } else {
          chunkText = 'không trăm $chunkText';
        }
      }

      parts.add('$chunkText $levelText'.trim());
    }

    number ~/= thousand;
    level++;
  }

  return '${parts.reversed.join(' ')} đồng';
}
