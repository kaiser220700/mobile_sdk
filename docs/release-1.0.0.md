# Chuẩn bị release Git 1.0.0 — 16/10/2026

## Phạm vi chốt

Tám package stable dùng version 1.0.0: mobile_sdk, mobile_sdk_core,
mobile_app_base, mobile_ui_kit, mobile_update, mobile_sdk_firebase_core,
mobile_sdk_firebase_remote_config và mobile_devtool.

mobile_fuzz và mobile_screen_draw dùng version experimental 0.1.0 riêng.
DevTool không phụ thuộc hay tự mount hai công cụ này. Host đăng ký action,
panel và tự quản lý overlay/lifecycle. Test cũ đi cùng package được tách;
example kiểm chứng ghép hai công cụ với menu DevTool.

API tên ngắn được chốt qua public barrel. Tên public cũ tiếp tục được hỗ trợ
trong dòng 1.x. Cách đổi import và thay đổi composition DevTool được ghi tại
[migration-1.0.0.md](migration-1.0.0.md). Implementation trong src không thuộc
cam kết public. Các kiểu refresh upstream được export cũng thuộc cam kết 1.x.

## Bằng chứng kiểm tra

| Kiểm tra | Kết quả |
| --- | --- |
| Version/changelog stable + version experimental riêng | Pass: verify_release_metadata.sh main |
| Dependency graph production không kéo tooling/Firebase | Pass: verify_boundaries.py |
| DevTool không kéo Fuzz/Screen Draw; hai công cụ độc lập | Pass: verify_boundaries.py |
| Flutter 3.44.6 / Dart 3.12.2: toàn workspace | Pass; rerun production/refresh và overlay lifecycle sau chỉnh test |
| Flutter 3.47.4 / Dart 3.13.3: toàn workspace | Pass: verify_workspace.sh |
| Android release consumer, Flutter 3.47.4 | Build thành công |
| Android release consumer, Flutter 3.44.6 | Build thành công |
| iOS release consumer, Flutter 3.47.4, không codesign | Build thành công |
| Host mở/đóng Fuzz và Screen Draw qua action | Test pass |
| Hủy overlay trước deferred insertion / remove-dispose | Pass trên cả hai Flutter SDK |

Production consumer dùng AppShell và RefreshView để kiểm tra tải trang, hết
trang, refresh rồi tải trang tiếp. Luồng này phát hiện và đã sửa việc refresh
không reset trạng thái no-more. Có test hồi quy trong UI Kit và consumer.
DevTool cũng đã sửa lifecycle attach: owner có thể hủy overlay trước frame
insert đầu tiên và remove/dispose an toàn; example dispose entry với owner.

Artifact Android Flutter 3.47.4:
`production_example/build/release-validation/flutter-3.47.4.apk`.
SHA-256:
`50645329a4cf64aefb736479a8fd5240cb5a79c5c81da29d860fa94eba1405dc`.

Artifact Android Flutter 3.44.6:
`production_example/build/release-validation/flutter-3.44.6.apk`.
SHA-256: `649a42a7d15213dd57f712b6fa7a8e417cd948d0c9d1c45e91ab16d2d737c55c`.

Artifact iOS:
`production_example/build/ios/iphoneos/Runner.app` (không codesign).
Consumer native target Android theo Flutter (API 24 với 3.47.4) và iOS 15.
Đây là compile/widget-test smoke, không phải bằng chứng chạy trên thiết bị
hoặc bản phân phối đã ký. Firebase adapters được kiểm bằng fake; chưa kiểm
native với Firebase project thật trong lượt SDK này.

## Phát hành và giới hạn

Kênh của bản này là Git. Version 1.0.0 đang được chuẩn bị local; chưa tạo/push
tag v1.0.0 và chưa xuất bản pub.dev. Sau khi kiểm tra cuối hoàn tất, commit,
đưa thay đổi qua quy trình merge của repo và tạo tag bất biến theo
[release-workflow.md](release-workflow.md).

Pub.dev không thuộc release này: publish_to vẫn là none. License, publisher,
tên package, hosted dependency constraints và publish dry-run cần một lượt
chuẩn bị công khai riêng; không tự chọn license thay chủ sở hữu.

Station-app chưa đổi revision, chưa migration source, chưa build/phân phối
Firebase trong lượt này. App có gate/quy trình riêng; SDK consumer production
ở repo này không thay thế nghiệm thu release của station-app.

Rollback: khôi phục đồng thời commit app, SDK revision và lockfile trước đó,
resolve dependency và build lại đúng flavor. Không di chuyển tag đã phát hành.
