# Roadmap Mobile SDK

> The unpublished global 1.0.0 plan below is historical. Current scope and
> independent package maturity are defined in [package organization](package-organization.md)
> and [the package catalog](package-catalog.json). UI is a candidate; other
> packages are not automatically stable. Existing paths/umbrella exports stay.


> Trạng thái: chuẩn bị bản Git 1.0.0; phạm vi và bằng chứng hiện hành ở
> [release-1.0.0.md](release-1.0.0.md). Các mốc dưới đây là lịch sử kế hoạch.

## 1. Ý nghĩa của 1.0.0

`1.0.0` là cam kết ổn định cho các capability đang có, không phải mốc phải hoàn
thành mọi ý tưởng của một mobile platform. App host có thể dùng SDK mà biết API
nào được hỗ trợ và các bản `1.x` không phá vỡ API đã công khai. Việc bỏ API, dù đã
deprecate trước, cần major version mới.

Phạm vi hiện có gồm `mobile_sdk_core`, `mobile_app_base`, `mobile_ui_kit`,
`mobile_devtool`, `mobile_update`, và Firebase core/Remote Config ở dạng opt-in. Fuzz/Screen Draw là package
experimental 0.1.0 độc lập, không nằm trong cam kết stable 1.x.
`mobile_sdk` tiếp tục là entry point không kéo Firebase/native plugin.

## 2. Phạm vi phát hành 1.0.0

1. **Chốt API hiện có** — review public export của từng package; API chưa chắc
   chắn được giữ internal hoặc đánh dấu experimental. Không cần thêm capability
   mới để lên `1.0.0`.
2. **Kiểm tra cơ bản đáng tin** — format, analyze và test hiện có phải chạy xanh
   trên toàn workspace; bổ sung test cho bug/failure mode rõ ràng nếu còn thiếu.
3. **Tài liệu đủ dùng** — README/quickstart của từng package, ví dụ tích hợp cơ
   bản và changelog/migration notes từ `0.3.0`.
4. **Release discipline tối thiểu** — các package mang cùng version, có tag/release
   note và cách quay lại version trước. CI có thể bắt đầu đơn giản với analyze và
   test; build matrix/device farm là cải tiến sau `1.0.0`.
5. **Giữ ranh giới hiện tại** — Firebase vẫn opt-in; app host tiếp tục sở hữu
   branding, i18n, business logic, credential và backend.

## 3. Release gate

Chỉ cần đạt các điều kiện sau trước khi phát hành:

- [x] Các package stable ở `1.0.0`; hai công cụ experimental ở `0.1.0`, changelog có release note và breaking change rõ ràng.
- [x] Public API được chốt; không export nhầm implementation nội bộ.
- [x] `dart`/`flutter analyze` và test của mọi package đang có chạy xanh.
- [x] Example hoặc quickstart kiểm chứng được luồng import/tích hợp cơ bản.
- [x] `mobile_sdk` core-only không kéo Firebase; Remote Config vẫn là opt-in.
- [x] Update policy không force update khi không có store URL hợp lệ.
- [ ] Publish tag Git `v1.0.0` sau merge; hướng dẫn rollback đã có trong migration.

## 4. Các bản trước 1.0.0

Các bản `0.x` chỉ chuẩn bị và làm chắc capability hiện có. Có thể gộp hoặc bỏ
một mốc nếu công việc đã hoàn tất; không dùng chúng để mở rộng platform.

| Mốc | Mục tiêu nhỏ gọn | Kết quả cần có |
| --- | --- | --- |
| `0.4.x` | Nền tảng phát hành | Một lệnh format/analyze/test toàn workspace và CI cơ bản. |
| `0.5.x` | Hardening | Sửa các failure mode rõ ràng của config/update/devtool; mỗi bug blocker có test hồi quy. |
| `0.6.x` | API và tài liệu | Review barrel export, chốt stable/experimental/internal; README/example và changelog đủ dùng. |
| `0.7.x` | Pilot nhẹ | Một app host thử tích hợp bản pre-release, ghi nhận vấn đề API hoặc migration. |
| `0.8.x` | Beta | Chỉ sửa lỗi, hoàn thiện migration note và release process. |
| `0.9.x` | Release candidate | Đóng băng API tại `1.0.0-rc.1`; chỉ nhận bug/doc blocker. |
| `1.0.0` | Stable core | Phát hành khi release gate ở trên xanh. |

## 5. Sau 1.0.0 — hướng mở, không cam kết lịch

| Mốc | Hướng chính |
| --- | --- |
| `1.0.0` | Stable core hiện có. |
| `1.1+` | Test/E2E toolkit. |
| `1.2+` | Telemetry và usage analytics. |
| `1.3+` | Service adapters. |
| Sau đó | Mở rộng dần thành mobile developer platform. |

Các mốc là thứ tự ưu tiên dự kiến, không phải lời hứa rằng mọi hạng mục trong
một hàng phải hoàn thành trước khi phát hành bản tiếp theo.

Các ý tưởng dưới đây có giá trị nhưng không chặn `1.0.0`:

- **Test/E2E toolkit:** fake, test harness và adapter cho một dịch vụ E2E nếu ít
  nhất hai app host dùng được. Adapter là tooling/dev dependency opt-in; từng app
  vẫn sở hữu test account, sandbox và business flow.
- **Usage telemetry cho UI kit:** reporter opt-in, consent-aware, chỉ ghi event
  chuẩn như displayed/pressed/changed; không gửi nội dung input, PII hay secret.
- **Firebase/observability adapter khác:** Analytics, Crashlytics, Performance,
  Messaging hoặc App Check chỉ thêm khi có contract, fake, privacy review và
  runbook riêng.
- **Developer platform:** CI/CD template, device test, devtool mở rộng và service
  integrations chỉ phát triển khi chứng minh tái sử dụng giữa các app.

Với mọi capability mới: core không phụ thuộc một provider; provider nằm ở package
adapter opt-in; app host sở hữu credential, consent, business data và backend.
Chỉ tạo abstraction dùng chung khi có ít nhất hai app hưởng lợi, có owner, test,
tài liệu và đường rollback.

## 6. Quyết định còn mở

- Đã chốt cho bản này: Git/tag; pub.dev là công việc publish riêng.
- Flutter tối thiểu 3.44.6 / Dart 3.12.2; native Firebase opt-in tuân theo minimum của plugin tương ứng.
- Những public API nào cần gắn experimental thay vì cam kết stable ngay?
- Có app host nào phù hợp để thử `1.0.0-rc.1` trước release chính thức?
