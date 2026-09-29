# Blueprint Firebase mở rộng cho `mobile_sdk`

> Đích khi triển khai: repo `mobile_sdk`, copy tài liệu này vào `docs/firebase-blueprint.md`.
> Ngày: 29/09/2026. Phạm vi: Flutter iOS/Android; không thay thế BFF, Identity hoặc Platform của từng sản phẩm.

## 1. Mục tiêu

Mọi project mobile có thể dùng toàn bộ năng lực Firebase qua `mobile_sdk`, theo API public,
typed và test được. Project chỉ sở hữu Firebase project/flavor, khóa cấu hình native, copy,
điều hướng và nghiệp vụ. SDK không biết `station`, `order`, role, BFF route hay chuỗi hiển thị
của một sản phẩm cụ thể.

"Open hết" nghĩa là mọi module đều có public export, tài liệu, test giả lập và điểm mở rộng;
không có capability Firebase bị khóa trong một app. Nó **không** nghĩa là mọi app bắt buộc kéo
mọi plugin Firebase vào binary.

## 2. Cấu trúc đề nghị — một repo, nhiều package public

```text
mobile_sdk/                              # vẫn là một GitHub project
├── packages/
│   ├── mobile_sdk/                      # core, không phụ thuộc Firebase
│   ├── mobile_sdk_firebase_core/         # bootstrap + module lifecycle
│   ├── mobile_sdk_firebase_analytics/
│   ├── mobile_sdk_firebase_crashlytics/
│   ├── mobile_sdk_firebase_performance/
│   ├── mobile_sdk_firebase_remote_config/
│   ├── mobile_sdk_firebase_messaging/
│   ├── mobile_sdk_firebase_app_check/
│   ├── mobile_sdk_firebase_in_app_messaging/
│   └── mobile_sdk_firebase/              # facade/meta package, kéo tất cả module trên
├── tooling/
│   ├── fastlane/                         # template App Distribution
│   ├── firebase-test-lab/                # script/CI template Test Lab
│   └── firebase-console/                 # schema Remote Config, checklist alert/rollout
└── docs/
```

Tất cả ở **cùng một repo**, cùng versioning/release process. App muốn "all-in" chỉ depend
`mobile_sdk` + `mobile_sdk_firebase`; app muốn binary gọn có thể depend riêng module cần dùng.
Dart không có optional dependency thực sự cho một package đã import: để tất cả FlutterFire plugin
trong core sẽ buộc mọi consumer kéo native plugin/Gradle setup. Tách package là cách mở API mà vẫn
cho phép opt-in.

## 3. Ranh giới sở hữu

| SDK mở cho mọi project                                                                                        | Project bắt buộc tự sở hữu                                                                               |
| --------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| Lifecycle module, adapter Firebase, default an toàn, cache/fetch/error mapping, trace, typed config, test fake | Firebase project,`google-services.json`/`GoogleService-Info.plist`, flavor/package ID, quyền iOS/Android |
| Policy version, update state, UI primitive có slot/callback                                                    | Store URL, phiên bản build, câu i18n, branding, khi nào cho phép force-update                            |
| Event envelope, redaction, dashboard/alert/CI template                                                          | Event nghiệp vụ, consent/privacy policy, BigQuery retention, BFF/server key                                 |
| FCM token lifecycle client                                                                                      | Ai là người nhận, nội dung notification, authorization và gửi push qua BFF                             |
| App Check token client                                                                                          | BFF/boundary phải verify token và quyết định chặn request                                               |

## 4. Public API tối thiểu

### 4.1 Core

```dart
enum UpdateRequirement { none, soft, force }

final class MobileUpdateConfig {
  const MobileUpdateConfig({
    required this.enabled,
    required this.minVersion,
    required this.latestVersion,
    required this.storeUrl,
  });
}

abstract interface class ConfigSource {
  Future<ConfigSnapshot> load();
  Stream<ConfigSnapshot> get changes;
}

abstract interface class TelemetryReporter {
  Future<void> event(TelemetryEvent event);
  Future<T> trace<T>(String name, Future<T> Function() action);
  Future<void> recordError(Object error, StackTrace stackTrace, {bool fatal = false});
}
```

Core nhận interface, không import FlutterFire. Mọi dữ liệu event qua một `TelemetryEvent` typed,
validation key/value và redaction trước khi đến adapter.

### 4.2 Firebase core

```dart
final class MobileFirebase {
  static Future<MobileFirebaseRuntime> initialize({
    required FirebaseApp app,
    required Set<MobileFirebaseModule> modules,
    required MobileFirebasePrivacy privacy,
  });
}

enum MobileFirebaseModule {
  analytics,
  crashlytics,
  performance,
  remoteConfig,
  messaging,
  appCheck,
  inAppMessaging,
}
```

SDK chỉ nhận `FirebaseApp` đã được project khởi tạo. Không đưa Firebase options, service account,
APNs key, store URL hoặc secret vào SDK.

### 4.3 Remote Config typed và custom

```dart
final config = MobileRemoteConfigSchema([
  ConfigKey.bool('maintenance_enabled', defaultValue: false),
  ConfigKey.int('task_refresh_seconds', defaultValue: 60, min: 15, max: 3600),
  ConfigKey.json<UpdatePolicy>('update_policy',
      defaultValue: UpdatePolicy.disabled(), decoder: UpdatePolicy.fromJson),
]);

final snapshot = await remoteConfig.load(config);
final enabled = snapshot.require(config.key<bool>('maintenance_enabled'));
```

Module phải cung cấp:

- decoder `bool`, `int`, `double`, `String`, enum, JSON và custom decoder;
- default ngay trong binary; validate range/schema trước khi activate;
- snapshot immutable, metadata source/default/cache/remote và stream cập nhật;
- fetch timeout/minimum interval theo environment do project truyền;
- log kết quả fetch/activate nhưng không log toàn bộ config hay dữ liệu nhạy cảm;
- fake in-memory để unit/widget test không khởi tạo Firebase;
- `UpdatePolicy` là một schema mẫu, không phải giới hạn capability Remote Config.

Remote Config chỉ đổi nhánh **đã có trong binary**. Không chứa secret, token, khóa API, quyền,
endpoint tin cậy hoặc dữ liệu cần người dùng đồng ý.

### 4.4 Các module Firebase mở

| Module           | API public SDK                                                                  | Quy tắc an toàn                                                                            |
| ---------------- | ------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| Analytics        | `event`, user property allow-list, screen view, consent collection            | Không email, phone, token, mã trạm hoặc role; project định nghĩa taxonomy nghiệp vụ |
| Crashlytics      | Flutter/platform error handler, breadcrumb có redaction, custom key allow-list | Không ghi request body/PII; handler cũ phải được giữ và khôi phục khi dispose      |
| Performance      | startup/network/custom trace                                                    | Trace name stable, không dùng URL/payload làm metric name                                 |
| Remote Config    | schema typed, fetch/cache/realtime update, rollout metadata                     | default fail-open, feature flag không được thay authorization                            |
| Messaging        | permission, token refresh, foreground/background event envelope                 | SDK không tự gửi token cho server; project/BFF quyết định đăng ký/gỡ token         |
| App Check        | provider activation, lấy token/retry                                           | Bắt buộc backend verify trước khi coi là bảo vệ thật                                 |
| In-App Messaging | trigger/event abstraction và message action callback                           | Project tự quyết nội dung, deep link và consent; không bypass policy/authorization      |
| App Distribution | Fastlane/CLI/CI template, release notes contract                                | Đây là tooling release, không phải Flutter runtime module                               |
| Test Lab         | CI command/template, artifact/result parser                                     | Chạy trước phát hành, không thay test local hay dogfood                                |

## 5. Project integration chuẩn

```dart
await Firebase.initializeApp(); // project chọn đúng flavor/native config

final firebase = await MobileFirebase.initialize(
  app: Firebase.app(),
  modules: {
    MobileFirebaseModule.analytics,
    MobileFirebaseModule.crashlytics,
    MobileFirebaseModule.performance,
    MobileFirebaseModule.remoteConfig,
    MobileFirebaseModule.appCheck,
  },
  privacy: const MobileFirebasePrivacy(
    analyticsEnabled: true,
    crashlyticsEnabled: true,
    allowedEventKeys: {'app_version', 'build_number', 'environment'},
  ),
);
```

Project được import mọi module và tự chọn module active theo local/SIT/UAT/preprod/prod. Local có
thể dùng fake/disabled runtime nhưng phải chạy cùng contract. UI update generic có thể nằm SDK,
song project phải truyền `String Function(BuildContext)`/Widget slot và `openStore(Uri)` để giữ i18n,
branding và platform navigation ở host.

## 6. Lộ trình triển khai

1. Tạo workspace packages, melos/CI, common lint và semantic versioning; public API có dartdoc.
2. Chuyển `MobileUpdatePolicy` hiện có về core, thêm `ConfigSource`, `TelemetryReporter`, fakes.
3. Xây `mobile_sdk_firebase_remote_config` trước: schema typed, validation, cache và test fake.
4. Xây analytics + Crashlytics + Performance với privacy/redaction contract, rồi migrate Version Health
   của `station-app` sang adapter SDK.
5. Tách FCM client lifecycle đã có trong app sang messaging module; BFF token registration vẫn ở app.
6. Thêm App Check; chỉ bật enforcement sau khi BFF/boundary đã verify và có dashboard lỗi.
7. Thêm tooling App Distribution/Test Lab, rollout/alert checklist và sample app Flutter đủ flavor.
8. Thêm In-App Messaging sau cùng, sau khi có consent và action routing contract.

## 7. Acceptance criteria

- Mỗi module export API công khai, có fake và unit test không cần Firebase native.
- App có thể dùng `remote_config` mà không phải kéo messaging/App Check; facade all-in vẫn hoạt động.
- Lỗi Firebase không làm crash app hoặc force-update khi không có đường cài hợp lệ.
- Không có PII/secret trong config, telemetry, Crashlytics key hay trace name.
- App Check có server verification test trước khi enforcement.
- CI build Android/iOS theo ít nhất Local và một Firebase flavor; tooling có smoke Test Lab/App Distribution.
- Mỗi capability có runbook Console: key/schema/default, rollout/rollback, dashboard/alert, owner và expiry.

## 8. Không làm

- Không biến Firebase thành backend nghiệp vụ thứ hai: không Firestore/Auth/Functions thay BFF, Identity
  hoặc Platform của sản phẩm hiện hữu.
- Không có generic API `Map<String, dynamic>` cho config hay analytics; mọi key phải typed/allow-list.
- Không cho Remote Config cấp role, nới authorization, phát secret hoặc tự chạy code mới.
- Không tự đăng ký FCM token/gửi notification tới server không có contract/authorization của project.
