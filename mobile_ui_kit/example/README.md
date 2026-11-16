# mobile_ui_kit preview

Interactive component preview for `mobile_ui_kit`.

The canonical entry point is the package portal at the repository root:

```bash
npm ci
npm run showcase:build
npm run dev
```

Open `http://localhost:4173/#showcase`. This preview supports web only; the
Android/iOS runners have been removed. To develop it separately without
opening a desktop browser automatically, run from this directory:

```bash
flutter pub get
flutter run -d web-server
```

`?component=button` filters the preview to one component and is used by the portal.

Use the search/filter controls to inspect each component, then open the palette
button to change the five shared theme tokens. The HTML ↔ Flutter contract is
in `../preview/component_map.json`.
