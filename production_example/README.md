# Production SDK integration

A small host app using only mobile_sdk. It exercises production app wiring,
refresh, pagination and refreshing after the last page. It has no backend
credentials or developer tool/native Firebase dependencies.

Run from this folder:

```sh
flutter pub get
flutter test
flutter build apk --release
flutter build ios --release --no-codesign
```

This is a build/smoke consumer, not a station-app release or a distribution-signed
application. The workspace boundary check verifies its resolved dependencies.
Station-app integration and Firebase distribution remain separate app work.
