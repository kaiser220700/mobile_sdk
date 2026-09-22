# mobile_sdk

Unified entry point for the mobile SDK. The individual packages remain
internally modular, but a host application needs one dependency and one import.

```yaml
dependencies:
  mobile_sdk:
    path: ../mobile_sdk
```

```dart
import "package:mobile_sdk/mobile_sdk.dart";
```

The entry point exports `mobile_app_base`, `mobile_devtool`, `mobile_ui_kit`,
and `mobile_update`.
