# Roadmap Mobile SDK

Cập nhật: 2026-11-25. Branch làm việc hiện tại: `release/0.7.0`.
Đợt 0.7.x đã hoàn tất theo phạm vi kiểm tra trong repo và GitHub-only; pilot app thật
được bỏ qua theo yêu cầu chủ sở hữu. Bằng chứng: [báo cáo 0.7.x](validation-0.7.x.md).

Roadmap này thay thế kế hoạch cũ đi theo một version chung từ `0.7.x` đến
`1.0.0`. Repo phát triển theo từng package và capability; native có các mốc
riêng trong [PLAN native SDK](PLAN-native-sdk.md). Chỉ đánh dấu hoàn thành khi
có source, kiểm tra hoặc bằng chứng tích hợp tương ứng.

## Hotfix UI Kit độc lập

Theo yêu cầu chủ sở hữu ngày 2026-11-25, các sửa OTP, khả năng tùy biến widget,
token và trợ năng được tách từ local main `18ec3ed` vào nhánh
`hotfix/mobile-ui-kit-rc3`; không cần đợi release/0.8.0. Version UI Kit là
1.0.0-rc.3, các package khác giữ nguyên. Đã fast-forward main local tới hotfix
`41cd41b` theo yêu cầu chủ sở hữu; chưa push/tag hoặc chạy kiểm tra Flutter có
biên dịch. Xem [migration và giới hạn](migration-1.0.0-rc.3.md).
AsyncView, RouteTransitionGuard và showcase mở rộng tiếp tục thuộc nhánh tích hợp.

## 1. Hiện trạng

Version lấy từ `pubspec.yaml`; nhóm và mức trưởng thành lấy từ
[package catalog](package-catalog.json). Snapshot dưới đây áp dụng tại ngày cập nhật:

| Package | Version | Trạng thái |
| --- | --- | --- |
| `mobile_ui_kit` | `1.0.0-rc.3` | Candidate; chưa xác nhận stable |
| `mobile_sdk`, `mobile_app_base` | `0.8.0-dev.0` | Development; giữ compatibility và app wiring tùy chọn |
| `mobile_sdk_core`, `mobile_update` | `0.8.0-dev.0` | Development; logic và contract độc lập provider |
| `mobile_sdk_firebase_core`, `mobile_sdk_firebase_remote_config` | `0.8.0-dev.0` | Development; adapter opt-in |
| `mobile_devtool` | `0.8.0-dev.0` | Development; công cụ ngoài production |
| `mobile_fuzz`, `mobile_screen_draw` | `0.1.0-dev.0` | Experimental; opt-in |
| SDK Kotlin/Compose và Swift/SwiftUI | Chưa có | Mới có PLAN; chưa có module, artifact hay test native |

Tên branch `release/0.7.0` là nơi đang gom thay đổi, không đổi version của các
package và không phát hành lại tag `v0.7.0`. Các tag cũ giữ nguyên snapshot.
Không có cam kết mọi package phải đạt `1.0.0` cùng lúc.

## 2. Nền tảng kỹ thuật đã hoàn thành

- [x] Phân nhóm application libraries, adapters, developer tools và compatibility;
  giữ nguyên đường dẫn Git dependency, cho phép app chọn từng package.
- [x] Flutter 3.50.0 / Dart 3.14.0, FVM và CI được cập nhật; có hướng dẫn
  migration sang `material_ui` cho app host.
- [x] Khôi phục `mobile_app_base` để umbrella và các fixture cũ resolve được.
- [x] Bổ sung API tên ngắn, giữ các entrypoint compatibility; cải thiện theme,
  media picker, loading lease và các lỗi lifecycle đã được tái hiện.
- [x] Có lệnh kiểm tra workspace, dependency boundaries và release metadata;
  Firebase và developer tools được kiểm soát theo graph của từng consumer.
- [x] Có web tổng quan package, version, dependency và tài liệu; showcase chạy
  widget thật của UI Kit bằng Flutter Web.
- [x] Bỏ native runner của các demo Flutter; giữ source/example và widget test;
  CI build portal và Flutter Web thay APK demo.
- [x] Có PLAN mở rộng native với phạm vi, điều kiện kiểm thử và phát hành từng mốc.

Bằng chứng: [Flutter 3.50 migration](flutter-3.50-migration.md),
[kiểm tra lifecycle](precommit-validation-2026-10-16.md) và commit `f5e6d2c`.
Lượt xác nhận trước merge trên `feat/friendly-ui-api` đã qua format/analyze,
142 test Dart/Flutter, 6 test release policy, 6 test portal và build web.
Các con số này là bằng chứng của snapshot đó, không phải kết quả tự động cho
mọi thay đổi sau này.

App pilot bên ngoài chưa có bằng chứng nghiệm thu revision này trong repo.
Web showcase chưa chứng minh UI khớp từng pixel với app Android/iOS, và test
Firebase hiện có dùng fake, chưa chứng minh integration với project thật.

## 3. Thứ tự công việc tiếp theo

| Mốc | Mục tiêu | Hiện trạng | Điều kiện hoàn thành |
| --- | --- | --- | --- |
| F0 | Đồng bộ branch và quy trình release | Hoàn tất trong repo | Branch hiện tại được kiểm tra đầy đủ; không bỏ qua metadata |
| F1 | Pilot Flutter trên app thực tế | Bỏ qua cho đợt 0.7.x theo yêu cầu chủ sở hữu | Ghi quyết định và giới hạn; không coi là test pass hay điều kiện chặn F2 |
| F2 | Chốt snapshot GitHub 0.7.x | Hoàn tất trong repo | Kiểm tra trong repo, build web, tài liệu/policy, changelog và commit; không yêu cầu publish hoặc pilot |
| F3 | Cải thiện theo phản hồi consumer | Backlog theo nhu cầu | Mỗi thay đổi có phạm vi, test lỗi/hành vi cần thiết và consumer xác nhận |
| P0 | Chốt contract và nền tảng native | Chưa triển khai | Đặc tả update, fixture Dart, ADR và toolchain được ghi nhận theo PLAN |
| P1–P2 | Update policy Kotlin rồi Swift | Chờ contract P0 | Contract test, sample và consumer đóng gói độc lập trên từng nền tảng |
| P3–P6 | Core, adapters, UI và tools native | Dự kiến theo pilot | Chỉ mở từng capability có nhu cầu và bằng chứng theo PLAN |

F0–F2 là phạm vi hoàn thành của đợt hiện tại. F1 được miễn cho đợt 0.7.x,
không cần chọn hoặc sửa một app bên ngoài để đóng đợt này. Native P0–P6 là
công việc tiếp theo độc lập; package vẫn giữ stage/version hiện có.

### F0 — Branch và release policy

- [x] Gom thay đổi hiện có từ `feat/friendly-ui-api` vào `release/0.7.0`.
- [x] Cho phép riêng `release/0.7.0` làm integration branch; vẫn kiểm tra toàn
  bộ tên, version, maturity và changelog của từng package.
- [x] Giữ ref `release/<package>/<version>` và tag `<package>/v<version>` nếu
  cần ghi nhận một package; không cho phép tùy ý branch/version chung mới.
- [x] Thêm regression test: branch hiện tại chấp nhận mixed versions nhưng
  metadata sai vẫn thất bại; package release vẫn phải có version/note đúng.
- [x] Cấu hình workspace/portal CI chạy trên push main, develop và release/**;
  metadata workflow tiếp tục kiểm tra ref thực tế, không đổi thành main để né guard.
- [x] `./tool/verify_release_metadata.sh` qua trên chính `release/0.7.0`.

Đây là thay đổi policy có phạm vi rõ, không phải tắt kiểm tra. Tag `v0.7.0` cũ
không bị di chuyển; tên branch không ép mọi package thành version 0.7.0.
Workflow đã được cập nhật trong repo; chưa coi GitHub Actions đã chạy nếu chưa
có kết quả hosted CI tương ứng.

### F1 — Pilot app thật được bỏ qua cho 0.7.x

Chủ sở hữu yêu cầu bỏ qua pilot app bên ngoài ngày 2026-11-16 để chốt đợt hiện
tại bằng kiểm tra trong repo. Không chạy test/build hoặc sửa dependency của
Station/Client/Garage hay app bên ngoài nào trong đợt này.

Quyết định này gỡ pilot khỏi điều kiện hoàn thành 0.7.x. Nó không tạo bằng
chứng app đã tích hợp thành công, không cam kết UI giống 100% mọi thiết bị và
không đổi package candidate/development/experimental thành stable.

Báo cáo consumer có thể bổ sung sau nếu cần; không phải việc còn thiếu để đóng
đợt này. Điều kiện kiểm chứng native trong PLAN vẫn thuộc các mốc native riêng.

### F2 — Chốt snapshot GitHub 0.7.x

- [x] Giữ version và maturity theo từng package; ghi rõ breaking migration
  Flutter 3.50/Material và khác biệt theme mặc định trong tài liệu/changelog.
- [x] Có hướng dẫn tích hợp bằng Git revision và rollback bằng revision/lockfile.
- [x] Phân phối GitHub-only; `publish_to: none` ở mọi package/example; không có
  mốc pub.dev, hosted registry hay tag bắt buộc.
- [x] Bổ sung LICENSE độc quyền, COPYRIGHT và source usage policy của KAISER;
  giữ quyền/license của bên thứ ba.
- [x] Chạy kiểm tra workspace, metadata trên branch hiện tại, portal tests và
  build web; ghi kết quả trong báo cáo 0.7.x.
- [x] Các thay đổi được commit cùng báo cáo 0.7.x; dùng full Git revision khi
  cần tham chiếu snapshot.

Hoàn thành F2 chỉ đóng đợt tích hợp hiện tại. Muốn nâng một package lên stable
sau này vẫn phải chốt scope/support và quyết định maturity riêng; không đánh
dấu stable từ việc bypass pilot lần này.

### F3 — Backlog Flutter sau 0.7.x

Đây là các hướng cần đánh giá, chưa cam kết toàn bộ cho một version:

| Nhóm | Hướng tiếp theo | Điều kiện nhận việc |
| --- | --- | --- |
| UI/interaction | Route transition guard opt-in; AsyncView; tooltip/notification callback; text scaling và Unicode | Tái hiện khoảng trống trong app; không thay chính sách UX của mọi host |
| Config/lifecycle | Timeout, transport errors và failure mode còn thiếu | Có test tái hiện; giữ lifecycle contract và snapshot tốt gần nhất |
| Test toolkit | Fake, harness và E2E adapter dùng chung | Chứng minh tái sử dụng ở ít nhất hai app; account và flow do host quản lý |
| Telemetry | UI event reporter opt-in và adapter observability | Có contract/fake, consent và phạm vi dữ liệu rõ; không ghi nội dung input/secret |
| Service adapters | Analytics, Crashlytics, Performance, Messaging, App Check theo nhu cầu | Có consumer, test project, cấu hình host và runbook riêng |
| Portal/showcase | Bổ sung demo cho component còn thiếu; bộ state/theme và baseline riêng từng nền tảng | Dùng implementation thật; chỉ báo trạng thái đã kiểm chứng, không cam kết giống 100% mọi thiết bị |

Nguồn backlog: [Station audit](station-app-sdk-audit.md),
[helper audit](helper-audit.md), [Firebase rollout](firebase-implementation.md).
Đọc cùng changelog và [báo cáo hardening](precommit-validation-2026-10-16.md):
một số đề xuất cũ như concurrent fetch, media picker và loading lease đã được
triển khai, không mở lại như công việc chưa làm.

## 4. Nhánh phát triển native

Chi tiết kỹ thuật, fixture, ma trận kiểm thử và checklist nằm trong
[PLAN native SDK](PLAN-native-sdk.md). ROADMAP giữ thứ tự và trạng thái tổng quan:

| Mốc | Phạm vi | Đầu ra cần chứng minh |
| --- | --- | --- |
| P0 | Đặc tả update, fixture, ADR, toolchain và pilot | Dart đọc fixture; các trường hợp parser/URL/số và quyết định còn mở được ghi rõ |
| P1 | Update policy Kotlin/JVM; sample Android | Cùng fixture với Dart, test loader/cancellation, consumer resolve Maven artifact và chạy smoke |
| P2 | Update policy Swift; sample iOS | Cùng fixture Dart/Kotlin/Swift, consumer SwiftPM qua revision và test trên iOS Simulator |
| P3 | Typed config, source/fake, telemetry contract | Từng capability có contract/failure test và ví dụ; không port toàn bộ core một lần |
| P4 | Adapter native đầu tiên theo consumer | Fake transport và provider integration; core-only không kéo provider |
| P5 | UI Kit Compose/SwiftUI theo nhóm nhỏ | Button/TextField/Loading/Alert trước; test state, accessibility, lifecycle và baseline riêng |
| P6 | Developer tools native | Logging/debug panel trước; annotation/fuzz chỉ sau đánh giá riêng |

Chưa mốc native nào được đánh dấu hoàn thành. Kotlin/Compose và Swift/SwiftUI
là hướng đã ghi trong PLAN; minimum OS/toolchain và artifact coordinates chưa
được chốt bằng implementation. P4/P5 là capability opt-in; UI không bắt buộc
phụ thuộc Firebase. Web Flutter không phải bằng chứng UI native đã được port.

Mục tiêu thử nghiệm native đầu tiên dừng ở P2: hai app native dùng được update
policy mà không kéo Flutter engine hay UI/provider của SDK. Candidate/stable
native xét riêng từng nền tảng theo điều kiện trong PLAN, không gắn với version
UI Kit Flutter hoặc tên branch `release/0.7.0`.

## 5. Cách duy trì roadmap

Sau mỗi đợt, cập nhật trạng thái mốc và liên kết bằng chứng: revision,
test/build, consumer, lỗi còn mở và bước tiếp theo. Không tự đánh dấu pilot,
native hoặc stable hoàn thành từ kết quả unit test.

F0/F2 đã hoàn tất trong repo; F1 đã được miễn cho đợt này. Việc tiếp theo được
chọn từ F3 theo nhu cầu thực tế hoặc phần
đặc tả update/fixture của native P0. Pilot Flutter không còn là việc bắt buộc
để hoàn thành 0.7.x; chưa tạo module native rỗng hoặc hứa ngày phát hành.

Các báo cáo [release 1.0.0 cũ](release-1.0.0.md) và
[organization validation](organization-validation.md) giữ giá trị lịch sử cho
snapshot được ghi trong đó, không thay thế trạng thái và toolchain hiện tại.
