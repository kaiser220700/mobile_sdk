#!/usr/bin/env bash

# Verifies every Dart/Flutter package in this repository. The command is safe
# for local use and CI: formatting is checked but never rewritten.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEFAULT_FLUTTER_BIN="$ROOT_DIR/.fvm/flutter_sdk/bin/flutter"

if [[ -n "${FLUTTER_BIN:-}" ]]; then
  FLUTTER="$FLUTTER_BIN"
elif [[ -x "$DEFAULT_FLUTTER_BIN" ]]; then
  FLUTTER="$DEFAULT_FLUTTER_BIN"
else
  FLUTTER="$(command -v flutter || true)"
fi

if [[ -z "$FLUTTER" ]]; then
  echo "Flutter was not found. Set FLUTTER_BIN or install Flutter first." >&2
  exit 1
fi

DEFAULT_DART_BIN="$(dirname "$FLUTTER")/dart"
if [[ -x "$DEFAULT_DART_BIN" ]]; then
  DART="$DEFAULT_DART_BIN"
else
  DART="$(command -v dart || true)"
fi

if [[ -z "$DART" ]]; then
  echo "Dart was not found alongside Flutter or on PATH." >&2
  exit 1
fi

PACKAGES="$(
  cd "$ROOT_DIR"
  find . -name pubspec.yaml -not -path '*/.dart_tool/*' -print |
    sed 's|/pubspec.yaml$||' |
    sort
 )"

if [[ -z "$PACKAGES" ]]; then
  echo "No pubspec.yaml files found." >&2
  exit 1
fi

while IFS= read -r package; do
  echo "==> $package: dependencies"
  (
    cd "$ROOT_DIR/$package"
    "$FLUTTER" pub get
  )
done <<< "$PACKAGES"

while IFS= read -r package; do
  echo "==> $package: format"
  (
    cd "$ROOT_DIR/$package"
    format_targets=(lib)
    if [[ -d test ]]; then
      format_targets+=(test)
    fi
    "$DART" format --output=none --set-exit-if-changed "${format_targets[@]}"
  )

  echo "==> $package: analyze"
  (
    cd "$ROOT_DIR/$package"
    "$FLUTTER" analyze --no-pub
  )

  if [[ -d "$ROOT_DIR/$package/test" ]]; then
    echo "==> $package: test"
    (
      cd "$ROOT_DIR/$package"
      "$FLUTTER" test --no-pub
    )
  else
    echo "==> $package: test skipped (no test directory)"
  fi
done <<< "$PACKAGES"
