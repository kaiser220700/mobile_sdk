import tempfile
import unittest
from pathlib import Path

from verify_ui_tokens import validate, violations


class UiTokenPolicyTest(unittest.TestCase):
    def test_widget_literals_are_rejected(self):
        source = 'TextStyle(fontSize: 24); Color(0xFF000000); Colors.red;'
        self.assertEqual(len(violations(source)), 3)

    def test_multiline_and_constructor_variants_are_rejected(self):
        self.assertEqual(len(violations('fontSize:\n .5; Color.fromARGB(255, 0, 0, 0);')), 2)

    def test_comments_strings_and_transparency_are_allowed(self):
        source = '''// Colors.red fontSize: 24
/* Color(0xFF000000) */
final example = "Colors.blue and fontSize: 14";
final raw = r'Color(0xFF000000)';
final transparent = Colors.transparent;
final style = theme.numeric;'''
        self.assertEqual(violations(source), [])

    def test_only_token_definitions_are_exempt(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            lib = root / 'mobile_ui_kit/lib/src'
            (lib / 'theme').mkdir(parents=True)
            (lib / 'theme/ui_kit_theme.dart').write_text('Color(0xFF000000);')
            self.assertEqual(validate(root), [])
            (lib / 'theme/unrelated.dart').write_text('Colors.blue;')
            self.assertEqual(len(validate(root)), 1)


if __name__ == '__main__':
    unittest.main()
