# Kiểm tra SDK trước commit — 16/10/2026

## Phạm vi và môi trường

- Toàn bộ package và app ví dụ trong workspace; Flutter 3.47.4, Dart 3.13.3,
  macOS arm64. Không sửa hay nâng dependency của Station/Client/Garage.
- Kiểm format, analyze, test, dependency boundaries và release metadata bằng
  `./tool/verify_workspace.sh`. Lượt cuối đã hoàn tất xanh trước commit (exit code 0).
- Rà ownership/dispose của timer, ticker, controller, focus, subscription,
  overlay; rà giới hạn log của DevTool và Fuzz.

## Lỗi xác nhận và sửa trong lượt kiểm

1. Remote Config: start đồng thời có thể trả về trước khi setup xong; fetch
   đồng thời bị lặp; kết quả về muộn sau dispose chưa được chặn. Gộp tác vụ
   đang chạy, chặn reuse, bỏ kết quả muộn, bắt lỗi update stream và dispose
   idempotent. Ba regression test mới thất bại trước khi sửa, qua sau sửa.
2. Motion/FadeMotion/ListEntrance: tạo CurvedAnimation mỗi build mà không
   dispose wrapper, tích lũy status listener. Dùng CurveTween qua drive khi
   không cần reverseCurve, không tạo listener cần dispose riêng.
3. Countdown: đổi duration tạo ticker thứ hai trên SingleTickerProvider gây
   assertion. Đã tái hiện trong bài rebuild rồi chuyển sang TickerProvider
   hỗ trợ controller được thay thế; controller cũ vẫn dispose trước khi thay.
4. Autocomplete: debounce dùng Future.delayed không hủy được timer khi gỡ widget.
   Chuyển sang timer + completer có hủy; bỏ query cũ, không khởi chạy sau dispose.
   Materialize iterable kết quả một lần để tránh duyệt lại lazy iterable theo index.
5. Firebase runtime: một adapter dispose thất bại làm bỏ dọn các adapter sau.
   Đã tái hiện bằng regression test; nay dọn hết theo thứ tự ngược rồi trả lỗi
   đầu tiên, các caller dispose dùng chung một Future.

## Kiểm tài nguyên động

`mobile_ui_kit/test/lifecycle_test.dart` dùng leak_tracker_flutter_testing
(dev dependency, không phải runtime dependency):

- 20 chu kỳ mount/unmount, mỗi chu kỳ 5 rebuild, gồm motion đang loop, fade,
  list entrance, countdown đổi duration, search, autocomplete, toast, overlay
  và loading lease; unmount rồi dispose các controller do host sở hữu.
- Không còn ticker hoạt động, pending timer hay callback ném lỗi sau unmount.
- Gate dispose của leak tracker qua; không có đối tượng được tracker báo thiếu
  dispose trong các đường chạy này. Không bao phủ mọi widget hay mọi input.
- Đã thử thêm chế độ experimentalAllNotGCed: có báo đối tượng chưa được GC.
  Bài đối chứng chỉ dùng Flutter MaterialApp/Scaffold/TextField, nhập chữ rồi
  gỡ widget và dispose controller, cũng báo 412 đối tượng chưa được GC; đối
  chứng Text thuần qua. Vì tín hiệu này chưa tách được SDK khỏi framework/test
  harness, KHÔNG dùng nó làm gate ổn định hoặc kết luận không có heap leak.
  Probe tạm đã xóa; giữ gate disposal mặc định và ghi rõ giới hạn tại đây.

## Hiệu năng đã đo

Chạy bản AOT của `mobile_sdk_core/benchmark/money_benchmark.dart`, 20.000 lượt
warmup + 9 mẫu × 20.000 chuyển đổi; bộ số có zero, âm, nhóm khuyết và nghìn tỷ:

- Median: **1,265 microsecond/chuyển đổi**.
- Mẫu chậm nhất: **1,3879 microsecond/chuyển đổi**.
- Max RSS process benchmark: **18.497.536 byte**; đây là toàn process benchmark,
  không phải lượng rò rỉ hay heap của app UI.
- Checksum giữ kết quả tính toán được sử dụng. Không đặt threshold CI theo máy
  này vì tải hệ thống và kiến trúc CPU thay đổi.

Không suy rộng kết quả này thành FPS, thời gian khung hình hoặc hiệu năng mọi
API. Chưa đo native heap Firebase/plugin, profile animation trên điện thoại,
hoặc soak test nhiều giờ. Native memory và hiệu năng frame cần đo trong app host
ở profile mode với workload thật trước khi khẳng định không có leak/jank.

## Kết quả cuối

- `./tool/verify_workspace.sh`: PASS trên toàn workspace, bao gồm format,
  analyze, 142 test Dart/Flutter trong 13 suite và 6 kiểm thử chính sách Python; dependency boundaries
  và release metadata đều qua.
- Kiểm format bổ sung cho benchmark và `git diff --check`: PASS.
- Probe GC thử nghiệm và test chụp ảnh tạm không nằm trong commit. Ảnh preview
  tài liệu và benchmark nguồn được giữ; log, binary benchmark và build/cache
  không đưa vào commit.
- Chưa push, merge main, tạo tag hay publish. Các cải thiện ưu tiên sau trong
  báo cáo Station (route guard, async view...) chưa thuộc phạm vi triển khai.
