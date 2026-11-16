# Minimal production UI integration

This consumer depends directly on mobile_ui_kit. The host owns MaterialApp.
It deliberately resolves no mobile_sdk umbrella, mobile_app_base, core, update,
Firebase or developer tool packages. Add other modules only when needed.

Widget tests cover refresh, pagination, reaching the last page and refreshing
before loading more again. The workspace boundary check verifies the minimal
graph. This folder is a source and widget-test fixture; its native app runners
have been removed. The root package portal hosts the interactive UI showcase.

Run `flutter pub get` and `flutter test` from this folder. Run `npm run dev`
from the repository root for the package portal.
