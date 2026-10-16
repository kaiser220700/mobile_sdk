#!/usr/bin/env python3
"""Check resolved SDK/consumer graphs and direct package imports after pub get."""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
TOOLING = {"mobile_devtool", "mobile_fuzz", "mobile_screen_draw"}
FIREBASE = {"firebase_core", "firebase_remote_config",
            "mobile_sdk_firebase_core", "mobile_sdk_firebase_remote_config"}
rules = {
    "mobile_sdk": TOOLING | FIREBASE,
    "production_example": TOOLING | FIREBASE,
    "mobile-devtool": {"mobile_fuzz", "mobile_screen_draw"},
    "mobile_fuzz": {"mobile_devtool", "mobile_screen_draw", "mobile_sdk"},
    "mobile_screen_draw": {"mobile_devtool", "mobile_fuzz", "mobile_sdk"},
}
errors = []
for package, forbidden in rules.items():
    config = ROOT / package / ".dart_tool/package_config.json"
    if not config.exists():
        errors.append(f"{package}: run flutter pub get first")
        continue
    names = {item["name"] for item in json.loads(config.read_text())["packages"]}
    for dependency in sorted(names & forbidden):
        errors.append(f"{package} resolves forbidden dependency {dependency}")
    for source in (ROOT / package / "lib").rglob("*.dart"):
        imports = re.findall(r"""(?:import|export)\s+['"]package:([^/]+)/""",
                             source.read_text())
        for dependency in set(imports) & forbidden:
            errors.append(f"{source.relative_to(ROOT)} imports {dependency}")
if errors:
    raise SystemExit("\n".join(errors))
print("Dependency boundaries: production, DevTool, Fuzz and Screen Draw passed.")
