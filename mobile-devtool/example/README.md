# mobile_devtool example

Standalone preview app for the `mobile_devtool` package.

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
flutter pub get
flutter run
```
