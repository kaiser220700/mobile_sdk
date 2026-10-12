#!/usr/bin/env bash

# Enforces the shared package-version convention for a target branch. This is
# intentionally separate from verify_workspace.sh so it can run before the
# more expensive Flutter checks in CI.
set -euo pipefail

branch="${1:-${GITHUB_BASE_REF:-${GITHUB_REF_NAME:-$(git branch --show-current)}}}"
packages=(
  mobile_sdk
  mobile_sdk_core
  mobile_sdk_firebase_core
  mobile_sdk_firebase_remote_config
  mobile_ui_kit
  mobile_app_base
  mobile_update
  mobile-devtool
)

version_for() {
  awk '/^version:/{print $2; exit}' "$1/pubspec.yaml"
}

fail() {
  echo "Release metadata check failed: $*" >&2
  exit 1
}

shared_version="$(version_for "${packages[0]}")"
[[ -n "$shared_version" ]] || fail "${packages[0]} has no version."

for package in "${packages[@]:1}"; do
  version="$(version_for "$package")"
  [[ "$version" == "$shared_version" ]] ||
    fail "$package is $version; expected $shared_version."
done

stable_version='^[0-9]+\.[0-9]+\.[0-9]+$'
development_version='^[0-9]+\.[0-9]+\.[0-9]+-dev\.[0-9]+$'

case "$branch" in
  develop)
    [[ "$shared_version" =~ $development_version ]] ||
      fail "develop must use X.Y.Z-dev.N; found $shared_version."
    ;;
  release/*)
    expected_version="${branch#release/}"
    [[ "$expected_version" =~ $stable_version ]] ||
      fail "release branch must be named release/X.Y.Z; found $branch."
    [[ "$shared_version" == "$expected_version" ]] ||
      fail "$branch must use $expected_version; found $shared_version."
    ;;
  main)
    [[ "$shared_version" =~ $stable_version ]] ||
      fail "main must use a stable X.Y.Z version; found $shared_version."
    ;;
  *)
    echo "Release metadata: $branch is not a managed release branch; version $shared_version accepted."
    exit 0
    ;;
esac

if [[ "$branch" == main || "$branch" == release/* ]]; then
  grep -q "^## $shared_version - " CHANGELOG.md ||
    fail "CHANGELOG.md needs a $shared_version release heading."
fi

echo "Release metadata: $branch uses shared version $shared_version."
