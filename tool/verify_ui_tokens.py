#!/usr/bin/env python3
"""Reject visual literals in UI widgets; token definitions own the defaults.

This is a lightweight source guard, not a Dart analyzer. It ignores Dart
comments and strings and allows Colors.transparent (a rendering instruction).
"""
import argparse
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DEFINITIONS = {"theme/ui_kit_theme.dart", "theme/ui_kit_component_tokens.dart"}
# Preserve newlines/offsets while masking comments and string contents.
NON_CODE = re.compile(
    r'''//[^\n]*|/\*.*?\*/|r?""".*?"""|r?\'\'\'.*?\'\'\'|r?"(?:\\.|[^"\\])*"|r?\'(?:\\.|[^\'\\])*\' ''',
    re.S | re.X,
)
RULES = {
    "font size must come from a theme token": re.compile(r"\bfontSize\s*:\s*[-+]?\s*(?:\d|\.\d)"),
    "color must come from a theme token": re.compile(r"\bColor\s*(?:\(\s*(?:0x|\d)|\.\s*(?:fromARGB|fromRGBO)\s*\()"),
    "named color must come from a theme token": re.compile(r"\bColors\s*\.\s*(?!transparent\b)\w+"),
}


def violations(source):
    code = NON_CODE.sub(lambda m: re.sub(r"[^\n]", " ", m[0]), source)
    return sorted((code.count("\n", 0, match.start()) + 1, message)
                  for message, pattern in RULES.items() for match in pattern.finditer(code))


def validate(root):
    errors = []
    lib = root / "mobile_ui_kit/lib/src"
    for path in sorted(lib.rglob("*.dart")):
        if path.relative_to(lib).as_posix() in DEFINITIONS:
            continue
        errors.extend(f"{path.relative_to(root)}:{line}: {message}"
                      for line, message in violations(path.read_text()))
    return errors


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=ROOT)
    errors = validate(parser.parse_args().root)
    if errors:
        raise SystemExit("\n".join(errors))
    print("UI tokens: no visual font/color literals outside token definitions.")


if __name__ == "__main__":
    main()
