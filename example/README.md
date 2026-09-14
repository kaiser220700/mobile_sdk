# mobile_sdk example

App demo duy nhất cho toàn bộ SDK trong repository này.

## App base

`example/` là reference composition root cho app host. Phần wiring dùng chung
được đóng gói trong `mobile_app_base`, và cũng được dùng bởi
`mobile-devtool/example/`:

```text
lib/
└── main.dart                  # bootstrap + SDK showcase feature

mobile_app_base/
├── lib/src/app_config.dart        # environment và capability flags của host
└── lib/src/mobile_app_shell.dart  # MaterialApp, theme, navigator wiring
```

`AppConfig` và `MobileAppShell` là app-host base dùng chung, không thuộc
business package như `mobile_devtool`. Cả SDK showcase và package preview đều
dùng cùng contract này.
`mobile_devtool` chỉ được mount khi `enableDeveloperTools` bật; production có
thể dùng `MobileDevToolController.disabled()` mà business code không cần
branch theo flavor. Khi app thật lớn dần, phần showcase trong `main.dart` nên
được chuyển tiếp sang `lib/features/sdk_showcase/` theo cùng boundary này.

App dùng trực tiếp ba package local:

- `mobile_ui_kit`: các primitive UI headless và overlay.
- `mobile_devtool`: developer tools overlay, network log và trace log.
- `mobile_update`: version parsing và update policy force/soft.

Chạy từ thư mục này:

```bash
flutter pub get
flutter run
```

Nếu cần tạo thư mục native cho một checkout mới, chạy thêm:

```bash
flutter create --platforms=android,ios .
```

Màn hình được chia thành ba tab. Bubble ở góc màn hình mở `mobile_devtool`;
`mobile_ui_kit` được dùng trực tiếp trong tab UI Kit; tab Update Policy mô
phỏng config từ remote và hiển thị quyết định của `mobile_update`.
