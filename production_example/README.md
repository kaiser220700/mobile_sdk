# Minimal production UI integration

This consumer depends directly on mobile_ui_kit. The host owns MaterialApp.
It deliberately resolves no mobile_sdk umbrella, mobile_app_base, core, update,
Firebase or developer tool packages. Add other modules only when needed.

Widget tests cover refresh, pagination, reaching the last page and refreshing
before loading more again. The workspace boundary check verifies the minimal
graph. Native builds are smoke artifacts, not distribution-signed releases.

Run flutter pub get, flutter test, flutter build apk --release, or
flutter build ios --release --no-codesign from this folder.
