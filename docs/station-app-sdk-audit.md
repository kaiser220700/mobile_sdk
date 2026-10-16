# Rà Station App để cải thiện SDK

Ngày rà: 2026-10-16. Đọc mã nguồn và test, không chạy app hoặc suite Station,
không sửa app, dependency hay ticket của app. MediaPicker và loading lease đã triển khai trong SDK; các mục còn lại là đề xuất.

Nguồn: `/Users/longnh/Mobile_PJ/scms-viper/srcroot/mobile-experiences/station-app`.

## Nên ưu tiên trong mobile_ui_kit

| Ưu tiên | Nguồn app | SDK hiện có / khoảng trống | Hướng xử lý và điều kiện nghiệm thu |
| --- | --- | --- | --- |
| P1 | docs/mobile-sdk-requests/SDK-4.md; order_contract_page.dart, counter_verification_page.dart | MediaPicker chưa có source sheet builder, upload indeterminate; errorText chưa hiện ở ô trống; nút đổi/bỏ dùng Material trực tiếp | Mở điểm tùy biến source sheet và controls, thêm uploading độc lập progress, errorStyle. Khóa chọn/đổi/bỏ khi upload; test cả ô trống/có preview, theme, cancel, semantics. Giữ tương thích lời gọi cũ. |
| P1 | lib/ui/widgets/app_loading_overlay.dart; test/widget/button_loading_overlay_test.dart | LoadingController show/hide là trạng thái đơn, chưa có ownership cho nhiều tác vụ | Thêm API token hoặc lease cho loading; release idempotent, try/finally, dọn khi dispose. Kiểm A/B chạy cùng lúc, A xong vẫn giữ B, lỗi và gỡ widget đều nhả đúng. Chốt rõ quan hệ với hide/success/error trước khi thêm API. Không bắt mọi nút dùng overlay toàn app. |
| P2 | lib/ui/widgets/app_tap_guard.dart; test/widget/action_bar_swap_guard_test.dart | Pressable có throttle nhưng chưa xét route đang transition | Ưu tiên guard riêng hoặc opt-in. Kiểm forward/reverse animation, nested navigator, route không có animation, tap/keyboard/semantics. Không áp mặc định toàn kit vì có màn cố ý cho tương tác khi animation. |
| P2 | lib/ui/widgets/async_view.dart; test/widget/async_view_test.dart | Có skeleton/loading/alert nhưng thiếu một mẫu phối hợp trạng thái async | Cân nhắc component nhận state thuần + builders: initial loading, data, refreshing với data cũ, lỗi nền, retry đang chạy. Adapter Riverpod ở app/example, không thêm Riverpod vào kit. Quyết định riêng cách báo lỗi nền thay vì giấu lỗi. |

## Ý tưởng có thể tách nhưng cần nhu cầu tích hợp rõ

- `ForegroundNotificationFilter`: bộ lọc ID có giới hạn bộ nhớ, ghép cặp khác
  kênh trong cửa sổ thời gian. Test đã có cho SSE/FCM đảo thứ tự, thiếu ID,
  khác ID cùng nội dung và tin kế tiếp. Nếu tách, nhận input có kiểu thay vì
  tên field payload Station, cấu hình capacity/window, reset theo session và
  kiểm hết hạn/eviction. Ghép nội dung khi thiếu ID là heuristic, cần opt-in;
  không đặt trong ToastQueue vì queue không biết danh tính notification.
- `DirectFile`: retry theo giai đoạn: upload xong thì retry complete cùng
  uploadId; link xem hết hạn thì xin lại có giới hạn. Đây là yêu cầu tốt cho
  một transfer adapter tương lai; giữ mục đích upload, GraphQL, mã ORDER_* và
  receipt của Station ở app. Test phân biệt lỗi mạng, URL hết hạn, lỗi nghiệp
  vụ và phản hồi xác nhận bị mất; không retry mọi mutation mặc định.
- `NotificationStream`: generation guard, stop/reconnect và parser SSE. Có thể
  học cho lifecycle adapter; chưa cần mở một package SSE chỉ cho một consumer.
- `normalizeSearch`: nhu cầu bỏ dấu có thể tái sử dụng, nhưng luật bỏ dấu chấm,
  gạch nối và khoảng trắng phục vụ tìm biển số. Tách chính sách normalize trước
  khi dùng chung; bổ sung Unicode tổ hợp, ký tự đặc biệt và test va chạm.

## Học cách kiểm thử, giữ implementation ở app

- `TokenStore`, `AuthRepositoryImpl`, `SessionGuard`, `SessionScope`: phiên có
  epoch; refresh đồng thời dùng chung tác vụ trong cùng epoch; đọc/ghi token
  đến muộn không được hồi sinh phiên cũ hoặc làm chết phiên mới. Test
  `session_race_test.dart` dùng Completer điều khiển thứ tự storage/network.
  Đưa các tình huống này vào review lifecycle Firebase/Remote Config hiện có;
  không mang Keycloak, secure storage hoặc Riverpod session registry vào core.
- `KeyboardInsetGuard`: có bằng chứng app/device và test, nhưng chủ động unfocus
  khi vào nền và ghi đè MediaQuery là chính sách UX/workaround rộng. Giữ ở app;
  muốn tách phải xác minh trên các Flutter/platform được hỗ trợ, bỏ debug probe,
  kiểm hardware keyboard, focus, resume và safe area.
- Sheet/action bar/theme/token, quyền vai trò, nhãn trạng thái đơn, mutation
  thanh toán và idempotency nghiệp vụ tiếp tục do app sở hữu. Chỉ chuyển primitive
  khi tách được khỏi router, backend, brand và state manager.

## Kết luận phạm vi

Đã triển khai MediaPicker với sourcePicker/control builders, uploading và errorStyle;
LoadingController có acquire/run/activeCount. Có test hành vi và hướng dẫn trong
mobile_ui_kit/README.md. Station App chưa được nâng SDK hoặc sửa tích hợp.
Không gom các ý tưởng còn lại thành package helpers hoặc nâng tất cả thành API
stable 1.0 chỉ vì đã có implementation ở Station.
