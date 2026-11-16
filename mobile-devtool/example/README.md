# mobile_devtool example

Reference preview source for the `mobile_devtool` package. Native runners have
been removed; the root package portal is the entry point for package browsing
and the UI Kit web showcase. This fixture uses the optional `mobile_app_base`
helper included in the repository, updated for Flutter 3.50.

This example uses the same shared app-host base as the SDK showcase:

```text
lib/
└── main.dart                  # package preview and composition root

../../mobile_app_base/
├── lib/src/app_config.dart
└── lib/src/mobile_app_shell.dart
```

The package example owns its panels, feature flags and demo state. The shared
base owns only environment configuration, `MaterialApp`, theme and navigator
wiring. Production can use `MobileDevToolController.disabled()` through
`AppConfig` without changing log call sites.

Run from this directory:

```bash
fvm flutter pub get
fvm flutter analyze
```
