#!/usr/bin/env python3
"""Validate independent package versions and package-scoped release refs."""
import argparse
import json
import re
import sys
from pathlib import Path

VERSION = re.compile(
    r"^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)"
    r"(?:-([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?$"
)
GROUPS = {"app-library", "service-adapter", "developer-tool", "compatibility"}
STAGES = {"development", "experimental", "candidate", "stable"}


def validate(root, ref):
    errors = []
    try:
        packages = json.loads((root / "docs/package-catalog.json").read_text())["packages"]
    except (OSError, ValueError, KeyError, TypeError) as error:
        return [f"Invalid package catalog: {error}"]
    if not isinstance(packages, list) or not packages:
        return ["Package catalog must contain a nonempty packages list."]
    versions = {}
    notes = {}
    paths = set()
    for entry in packages:
        if not isinstance(entry, dict):
            errors.append("Package catalog entries must be objects.")
            continue
        name, path = entry.get("name"), entry.get("path")
        if not isinstance(name, str) or not re.fullmatch(r"[a-z][a-z0-9_]*", name):
            errors.append(f"Invalid package name: {name!r}")
            continue
        if not isinstance(path, str) or Path(path).is_absolute() or len(Path(path).parts) != 1 or path in {".", ".."}:
            errors.append(f"{name}: package path must remain a root-level folder.")
            continue
        if name in versions or path in paths:
            errors.append(f"{name}: duplicate catalog name/path.")
            continue
        paths.add(path)
        if entry.get("group") not in GROUPS or entry.get("stage") not in STAGES:
            errors.append(f"{name}: invalid group/stage.")
        try:
            pubspec = (root / path / "pubspec.yaml").read_text()
            changelog = (root / path / "CHANGELOG.md").read_text()
        except OSError as error:
            errors.append(f"{name}: {error}")
            continue
        declared = re.search(r"^name:\s*(\S+)\s*$", pubspec, re.M)
        version = re.search(r"^version:\s*(\S+)\s*$", pubspec, re.M)
        if not declared or declared[1] != name:
            errors.append(f"{name}: pubspec name does not match catalog.")
        value = version[1] if version else ""
        match = VERSION.fullmatch(value)
        if not match or any(
            part.isdigit() and len(part) > 1 and part.startswith("0")
            for part in (match[4] or "").split(".")
        ):
            errors.append(f"{name}: invalid version {value!r}.")
            continue
        versions[name] = value
        notes[name] = changelog
        stage = entry.get("stage")
        if stage == "experimental" and match[1] != "0":
            errors.append(f"{name}: experimental packages must remain 0.x.")
        if stage == "development" and match[1] != "0" and not match[4]:
            errors.append(f"{name}: confirm stable stage before releasing a stable 1.x+ version.")
        if stage == "candidate" and not match[4]:
            errors.append(f"{name}: candidate requires a prerelease version.")
        if stage == "stable" and (match[1] == "0" or match[4]):
            errors.append(f"{name}: stable stage requires a non-prerelease 1.x+ version.")
        heading = re.search(r"^## " + re.escape(value) + r" - \d{4}-\d{2}-\d{2}\s*$",
                            changelog, re.M)
        if not heading and (not match[4] or not re.search(r"^## Unreleased\s*$", changelog, re.M)):
            errors.append(f"{name}: add a dated {value} changelog heading or Unreleased for development.")
    target = None
    if ref.startswith("release/"):
        parts = ref.split("/")
        if len(parts) != 3:
            errors.append("Use release/<package>/<version>; workspace-wide release versions are retired.")
        else:
            target = (parts[1], parts[2])
    else:
        tag = re.fullmatch(r"([^/]+)/v(.+)", ref)
        if tag and VERSION.fullmatch(tag[2]):
            target = (tag[1], tag[2])
        elif re.fullmatch(r"v[0-9]+\..*", ref):
            errors.append("Use <package>/v<version> for new tags; existing legacy tags remain unchanged.")
    if target:
        name, value = target
        if name not in versions:
            errors.append(f"Unknown release package: {name}")
        elif versions[name] != value:
            errors.append(f"{name}: release ref requests {value}, pubspec is {versions[name]}.")
        elif not re.search(r"^## " + re.escape(value) + r" - \d{4}-\d{2}-\d{2}\s*$",
                           notes[name], re.M):
            errors.append(f"{name}: release refs require a dated {value} changelog heading.")
    return errors


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("ref", nargs="?", default="main")
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parent.parent)
    args = parser.parse_args()
    errors = validate(args.root, args.ref)
    if errors:
        print("\n".join(errors), file=sys.stderr)
        return 1
    print(f"Release metadata: independent package policy passed for {args.ref}.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
