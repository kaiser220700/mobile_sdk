import 'package:mobile_sdk_core/money.dart';
import 'package:test/test.dart';

void main() {
  test('reads dong groups and Vietnamese unit variants', () {
    const cases = {
      0: 'không đồng',
      15: 'mười lăm đồng',
      21: 'hai mươi mốt đồng',
      105: 'một trăm lẻ năm đồng',
      1005: 'một nghìn không trăm lẻ năm đồng',
      1015: 'một nghìn không trăm mười lăm đồng',
      1000001: 'một triệu không trăm lẻ một đồng',
      -25: 'âm hai mươi lăm đồng',
    };
    for (final entry in cases.entries) {
      expect(vietnameseDongInWords(entry.key), entry.value);
    }
  });
  test('does not lose groups or precision above native integer range', () {
    expect(
      vietnameseDongBigIntInWords(BigInt.parse('1000000000000000000000')),
      'một nghìn tỷ tỷ đồng',
    );
  });
}
