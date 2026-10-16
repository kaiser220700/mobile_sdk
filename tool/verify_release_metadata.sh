#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ref="${1:-${GITHUB_BASE_REF:-${GITHUB_REF_NAME:-$(git branch --show-current)}}}"
exec python3 "$ROOT_DIR/tool/verify_release_metadata.py" "$ref"
