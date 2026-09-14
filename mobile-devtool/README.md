# mobile_devtool

> Phạm vi publish của package chỉ gồm Network và Trace. Barrel export
> `lib/mobile_devtool.dart` cùng `.pubignore` loại các tool khác khỏi archive;
> các phần Chrome/Fuzz Tap/Screen Draw bên dưới chỉ dành cho source workspace
> và preview nội bộ.

Flutter SDK dùng chung cho developer tooling trong các mobile experience —
"Reusable Flutter SDK for non-production mobile developer tools" (xem
docstring `lib/mobile_devtool.dart`). Package cung cấp overlay, controller và
model độc lập với business domain: bubble launcher kéo-thả, tool sheet mở thẳng
chức năng đầu tiên và có menu đổi chức năng, network/trace/fuzz-tap log panel, feature-flag panel generic, annotation
("Screen Draw") tool, fuzz-tap crash hunter dựa trên Semantics tree, JSON
formatter, KV table, và provider observer nhẹ cho Riverpod.

**Chỉ bật ở non-production build** (dev/sit/uat) — dùng
`MobileDevToolController.disabled()` làm binding cho flavor `prod` để mọi lệnh
ghi log bị bỏ qua mà business code không cần tự branch theo flavor; SDK không
có logic tự tắt ở prod, đó là trách nhiệm của app host qua wiring flavor.

## Cài đặt

Thêm dependency dạng path (trong cùng repo, giống app host) hoặc git:

```yaml
dependencies:
  mobile_devtool:
    path: ../mobile-devtool
    # hoặc: git: { url: <repo-url>, path: mobile-devtool, ref: <tag/commit> }
```

Dependency thật của package (`mobile-devtool/pubspec.yaml`):

| Package | Vai trò |
|---|---|
| `flutter` (SDK) | Widget framework |
| `lucide_icons_flutter: ^3.1.15` | Icon bubble launcher + shape picker |
| `flutter_test`, `flutter_lints` (dev) | Test + lint nội bộ package |

Yêu cầu: Dart `>=3.12.0 <4.0.0`, Flutter `>=3.44.0`.

## Danh mục export (`lib/mobile_devtool.dart`)

| Nhóm | Export | Mô tả |
|---|---|---|
| **Chrome / mount** | `MobileDevToolChrome` | Chrome tổng hợp (bubble + root menu + Screen Draw overlay + Fuzz Tap overlay), mount qua `MobileDevToolChrome.attach(navigatorKey, builder)` như 1 `OverlayEntry` thật — không bọc widget tree của host. |
| | `MobileDevToolOverlay` | Cách mount cũ, bọc `child` bằng `Stack` — dùng khi host đã quen compose overlay kiểu này (vd trong `MaterialApp.builder`). |
| | `MobileDevToolBubble` | Nút launcher tròn kéo-thả, tự mờ dần khi không tương tác, tap để mở tool sheet. |
| | `MobileDevToolConfiguration` | Cấu hình chrome: `title`, `hostActions`, `panels`, `menuItems`, `hiddenMenuItemIds`, `featureFlags`, `accentColor`. |
| | `MobileDevToolRootMenu` | Bottom-sheet mở thẳng Network; Screen Draw và Fuzz Tap là quick actions trên header, các tool còn lại đổi qua menu header; `Dev Tool Info` hiển thị phạm vi publish và roadmap. |
| | `MobileDevToolTheme` | Hằng số màu/bo góc/shadow nội bộ chrome — mặc định nền trắng, chữ đen; `accentColor` có thể đổi màu nhấn. |
| | `MobileDevToolFacade` (`MobileDevTool`) | Facade tĩnh `MobileDevTool.trace()/startNetwork()/completeNetwork()/failNetwork()` cho call site không có DI — cần `attachInstance(controller)` trước. |
| **Controller / model dữ liệu** | `MobileDevToolController` | `ChangeNotifier` giữ network + trace log (giới hạn `maxEntries`), có `.disabled()` cho prod; export kèm `MobileDevToolNetworkRequest/Entry`, `MobileDevToolNetworkKind/Status`, `MobileDevToolTraceEntry`, và `entry.toCurl(...)`. |
| | `MobileDevToolUiState` | Các `ValueNotifier`/`ChangeNotifier` nhẹ dùng chung trong UI: `MobileDevToolNetworkSearch`, `MobileDevToolNetworkStatusFilter<T>`, `MobileDevToolRevealState`, `MobileDevToolScrollDelta`, `MobileDevToolBubblePosition`, `MobileDevToolBubbleIdle`. |
| | `MobileDevToolProviderObserver` | Theo dõi vòng đời Riverpod provider (add/dispose/update) không subscribe state — host forward từ `ProviderObserver` của mình, đọc `liveProviders` (`ValueNotifier`). |
| **Network / Trace panel** | `MobileDevToolNetworkLogPanel` | Danh sách network log, filter theo `kind`/status, copy cURL qua `curlBuilder`. |
| | `MobileDevToolTraceLogPanel` | Danh sách trace log dạng text, double-tap để copy. |
| **Feature flag** | `MobileDevToolFeatureFlagPanel` | Danh sách toggle generic cho `MobileDevToolFeatureFlag` do host đăng ký — thay app tự viết enum/preview-hub riêng. |
| **Fuzz Tap (crash hunter)** | `MobileDevToolFuzzTapOverlay` | Overlay toàn màn hình có nền mờ 25%, panel trạng thái + report luôn mở, không tự đóng khi phiên dừng. |
| | `MobileDevToolFuzzTapOverlayState` (`Active`) | State hiển thị overlay Fuzz Tap. |
| | `MobileDevToolFuzzPresetSheet` (`showMobileDevToolFuzzPresetSheet`) | Bottom-sheet 3 bước: chọn preset hoặc tuỳ chỉnh tick interval/thời lượng → xem trước → "Chạy". |
| | `MobileDevToolFuzzRunPreset` | 3 preset dựng sẵn (Nhẹ/Chuẩn/...) khai báo tick interval + session duration. |
| | `MobileDevToolFuzzTapRunner` | Engine: mỗi tick quét Semantics tree tìm widget bấm được, thỉnh thoảng cuộn ngẫu nhiên, gọi 1 target ngẫu nhiên qua `SemanticsOwner.performAction` — không hit-test/gesture thật nên không thay thế Patrol/`integration_test`; tự dừng khi có lỗi network mới hoặc hết target liên tiếp. |
| | `MobileDevToolFuzzRunLog` / `MobileDevToolFuzzRunLogPanel` | Lịch sử phiên chạy Fuzz Tap, nhóm theo session. |
| | `MobileDevToolExcludeFromFuzzTap` | Bọc subtree UI của chính dev tool để runner không tự bấm nút "Dừng" của nó. |
| **Screen Draw (annotation)** | `MobileDevToolAnnotationTool` | `ChangeNotifier` state vẽ chú thích (hình chữ nhật/tròn/mũi tên/đường/tooltip), lọc theo route hiện tại, theo dõi scroll offset. |
| | `MobileDevToolAnnotationOverlay` | Overlay toàn màn hình: toolbar kéo-thả (thu gọn/mở rộng) + canvas vẽ. |
| | `MobileDevToolAnnotationCanvas` | `CustomPaint` vẽ các annotation hiện có + đang thao tác. |
| | `MobileDevToolShapeButton` | Nút chọn hình trong toolbar Screen Draw. |
| **Hiển thị dữ liệu chung** | `MobileDevToolJsonFormatter` | `.format(value, {omitGraphQLTypeNames})` pretty-print JSON (tự parse chuỗi JSON) + `.formatGraphQLDocument()` lược bỏ dòng `__typename`. |
| | `MobileDevToolKvTable` / `MobileDevToolKvRow` | Bảng 2 cột key–value, tap để copy giá trị. |
| | `MobileDevToolExpandablePanel` | Panel thu gọn/mở rộng đơn giản có tiêu đề. |
| | `MobileDevToolExpandableSecretText` | Text ẩn/hiện dạng monospace cho giá trị nhạy cảm (token, key...), double-tap copy. |
| **Cấu hình đăng ký từ host** | `MobileDevToolMenuItem`, `MobileDevToolPanel`, `MobileDevToolFeatureFlag`, `MobileDevToolHostAction` (trong `mobile_devtool_configuration.dart`) | Model host dùng để đăng ký tool/tab/toggle/action riêng của app vào `MobileDevToolConfiguration`. `MobileDevToolBuiltInIds` cho phép ẩn hoặc thay thế tool built-in. |
| **Chi tiết vẽ (thường không cần import trực tiếp)** | `MobileDevToolDragTapDetector` | Gesture detector phân biệt tap/drag dùng cho bubble + toolbar kéo-thả. |

## Tích hợp

```yaml
dependencies:
  mobile_devtool:
    path: ../mobile-devtool
```

Hai cách mount, cùng chrome bên dưới (`MobileDevToolChrome`):

**1. `MobileDevToolChrome.attach` (khuyến nghị)** — chèn thẳng vào `Overlay` của
`Navigator`, không wrap widget tree của host:

```dart
final controller = MobileDevToolController();
final navigatorKey = GlobalKey<NavigatorState>();

// gọi 1 lần, ví dụ trong State.initState() của widget gốc app
final entry = MobileDevToolChrome.attach(
  navigatorKey: navigatorKey,
  builder: (context) => MobileDevToolChrome(
    controller: controller,
    configuration: MobileDevToolConfiguration(title: "My app developer tools"),
    navigatorKey: navigatorKey,
  ),
);
// và entry.remove() trong State.dispose()
```

`builder` được gọi lại mỗi lần `Overlay` rebuild — bọc nó bằng `Consumer`/
`ConsumerWidget` (nếu host dùng Riverpod) để `configuration` (panels/feature
flags) luôn phản ánh state mới nhất mà không cần tự gọi
`OverlayEntry.markNeedsBuild()`.

**2. `MobileDevToolOverlay` (wrap widget tree)** — cách cũ, vẫn giữ cho host
nào đã quen compose overlay kiểu này (ví dụ trong `MaterialApp.builder`):

```dart
MobileDevToolOverlay(
  enabled: !kReleaseMode,
  controller: controller,
  configuration: MobileDevToolConfiguration(
    title: "My app developer tools",
    hostActions: [
      MobileDevToolHostAction(label: "App-specific tools", onPressed: openAppTools),
    ],
  ),
  child: const AppRoot(),
)
```

`MobileDevToolController` giữ tối đa 200 request mặc định để tránh tăng bộ nhớ
không giới hạn. Có thể cấu hình bằng `MobileDevToolController(maxEntries: 500)`
và cần gọi `controller.dispose()` khi host không còn dùng controller. Dùng
`MobileDevToolController.disabled()` cho build production — mọi lệnh ghi log
bị bỏ qua, business code không cần tự branch theo flavor.

App ghi network/trace log qua controller, không cần phụ thuộc vào UI:

```dart
final id = controller.startNetwork(
  MobileDevToolNetworkRequest(label: "Load profile", method: "GET", endpoint: url),
);
controller.completeNetwork(id, response: payload, statusCode: 200);
```

Mỗi entry tự export được cURL để copy/replay:

```dart
final curl = entry.toCurl(graphQlUrl: F.graphQLUrl, restBaseUrl: F.apiUrl, bearerToken: token);
```

SDK không sở hữu auth, router, storage hoặc design system của app host. Tool
đặc thù app được giữ ở app host và được đăng ký qua `hostActions`, hoặc — cho
màn hình đầy đủ — qua `MobileDevToolConfiguration.panels`:

```dart
MobileDevToolConfiguration(
  panels: [
    MobileDevToolPanel(
      id: "auth-tool",
      label: "Auth Tool",
      icon: Icons.lock_outline,
      builder: (context) => const AuthToolSheet(), // widget của app, dùng AppButton/ViewModel riêng
    ),
  ],
  featureFlags: [
    MobileDevToolFeatureFlag(
      id: "home-list-mock",
      label: "Home List Mock",
      getter: () => ref.read(homeListMockEnabledProvider),
      setter: (value) => ref.read(homeListMockEnabledProvider.notifier).set(value),
    ),
  ],
)
```

Với tool cần custom thứ tự hoặc thay thế/ẩn built-in, dùng
`MobileDevToolConfiguration.menuItems`. Đây là API tổng quát hơn `panels` và
`hostActions`; hai API cũ vẫn được giữ để tương thích:

```dart
MobileDevToolConfiguration(
  menuItems: [
    MobileDevToolMenuItem(
      id: "account-tool",
      label: "Account",
      icon: Icons.account_circle_outlined,
      order: 80,
      builder: (context) => const AccountToolPanel(),
    ),
    MobileDevToolMenuItem(
      id: "storage-tool",
      label: "Storage",
      icon: Icons.storage_outlined,
      order: 90,
      builder: (context) => const StorageToolPanel(),
    ),
    // Override the built-in Network screen.
    MobileDevToolMenuItem(
      id: MobileDevToolBuiltInIds.network,
      label: "My Network",
      builder: (context) => const MyNetworkPanel(),
    ),
  ],
  hiddenMenuItemIds: {MobileDevToolBuiltInIds.trace},
)
```

`AccountToolPanel` và `StorageToolPanel` nên do app host sở hữu để kết nối
đúng auth/session service hoặc secure storage. SDK chỉ host và hiển thị widget;
không tự đọc, lưu hoặc log token/credential.

Cách này giữ dependency-inversion: nội dung panel vẫn do app tự viết (vì nó
cần domain model/design-system riêng), nhưng cách nó được host/hiển thị hoàn
toàn do SDK điều phối — app không tự quản lý bubble hay sheet-stepping.

Điều này tránh package dependency ngược vào business domain của từng app.

## Trạng thái migrate (2026-09-10) — hoàn tất

Toàn bộ cơ chế generic của dev tool đã chuyển hẳn vào package này; app host
(`node_mobile_app`) không còn file dev tool nội bộ nào ngoài panel nghiệp vụ.
SDK sở hữu: `MobileDevToolController` (network/trace log + `toCurl()` +
`.disabled()` cho prod), JSON formatter, KV table, expandable panel/secret
text, annotation tool + canvas + overlay toolbar (Semantics-based, dùng
`ExcludeFromFuzzTap` để loại UI của chính nó), fuzz-tap engine (detect widget
bấm được qua Semantics tree, không còn phụ thuộc runtime type của bất kỳ
widget app nào), `MobileDevToolRootMenu` (bottom-sheet mở thẳng chức năng đầu
tiên, quick actions Screen Draw/Fuzz Tap trên header và menu đổi chức năng),
`MobileDevToolBubble` (launcher kéo-thả), và `MobileDevToolChrome` (bubble +
root menu + Screen Draw overlay + Fuzz Tap overlay gộp vào 1 chrome duy nhất —
mount qua `MobileDevToolChrome.attach` như 1 `Overlay` entry thật, thay vì 2
lớp `MobileDevToolOverlay(child: DevToolOverlay(...))` lồng nhau trong widget
tree như bản đầu tiên). Root menu có thêm `Dev Tool Info` để phân biệt các
tool đã publish (`Network`, `Trace`) với các tool đang phát triển/preview nội
bộ (`Fuzz Tap`, `Fuzz Tap Log`, `Screen Draw`, `Feature Flags`).

Cách dùng cuối cùng ở app host (`lib/app/app.dart`) — `MobileDevToolChrome.attach`
gọi 1 lần trong `_AppState.initState()`, `builder` bọc bằng `Consumer` để
panels/feature-flags/controller luôn theo state mới nhất:

```dart
_devToolEntry = MobileDevToolChrome.attach(
  navigatorKey: router.navigatorKey,
  builder: (context) => Consumer(
    builder: (context, ref, _) => MobileDevToolChrome(
      controller: ref.watch(mobileDevToolControllerProvider), // .disabled() ở prod
      configuration: MobileDevToolConfiguration(
        panels: appDevToolPanels(context, ref),           // sheet nghiệp vụ đầy đủ
        featureFlags: appDevToolFeatureFlags(context, ref), // toggle đơn giản
        hostActions: appDevToolHostActions(ref),            // hành động không có nội dung sheet
      ),
      navigatorKey: router.navigatorKey,
      currentRouteKey: ref.watch(devToolRouteKeyProvider),   // Screen Draw/Fuzz Tap scope theo route
      scrollDelta: ref.watch(devToolScrollDeltaProvider),    // Screen Draw canvas theo kịp nội dung cuộn
    ),
  ),
);
// và _devToolEntry?.remove() trong _AppState.dispose()
```

`MaterialApp.builder` không còn wrap `child` bằng `Stack`/`MobileDevToolOverlay`
nữa — chỉ giữ 1 `NotificationListener<ScrollNotification>` mỏng để bơm
`devToolScrollDeltaProvider`, vì overlay giờ nằm ngoài widget subtree của
trang nên không tự thấy `ScrollNotification` của nó.

3 hàm `appDevToolPanels`/`appDevToolFeatureFlags`/`appDevToolHostActions` nằm ở
`lib/core/dev_tool/app_dev_tool_panels.dart` của app host — đây là nơi DUY
NHẤT app còn "biết" về business logic của dev tool (auth, storage, KYC, mock
data...); SDK không import ngược bất kỳ thứ gì từ app.
