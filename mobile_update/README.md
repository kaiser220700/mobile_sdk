# mobile_update

Framework-agnostic update policy SDK for Flutter apps.

The package owns version parsing, force/soft decision logic, and the
config/version loading orchestration. The host app supplies its own remote
config adapter, app-version adapter, update dialog, localization, and store
launcher.

The JSON contract uses `store_url`.

It intentionally has no Firebase, Riverpod, `package_info_plus`, or UI
dependency so multiple apps can reuse it with different infrastructure.
