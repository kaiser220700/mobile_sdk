# Nâng mobile_ui_kit lên 1.0.0-rc.3

Ngày cập nhật: 2026-11-25. Đây là hotfix candidate độc lập từ local `main` tại `18ec3ed`
(UI Kit `1.0.0-rc.1`). Không chờ hoặc merge toàn nhánh `release/0.8.0`.
Giữ số `1.0.0-rc.3` để không trùng candidate `rc.2` của nhánh tích hợp; đây chưa
phải stable, chưa có tag hay bản phân phối mới. Chỉ `mobile_ui_kit` tăng version;
các package khác giữ nguyên. Không tự đổi revision hoặc mã Station App.

## Khả năng mới và cách app thu gọn lớp bọc

| Component | Khả năng trong rc.3 | Việc phía app khi được giao nâng cấp |
| --- | --- | --- |
| ListItem | `body`, `meta`, `bodyGap`, `metaGap`, `crossAxisAlignment`; giữ `leading`/`trailing`/`titleStyle` | Đặt thời gian trong `meta`, chấm ở `trailing`, căn hàng `start`, đặt `titleStyle` theo trạng thái chưa đọc |
| StatTile | `leading`, `body`, `meta`, `trailing`, `semanticLabel`; giá trị mặc định dùng `theme.numeric` | Giữ wrapper ánh xạ `bad` thành `valueColor`; app vẫn sở hữu luật số nào đáng lo |
| Button | `ButtonLoadingBehavior.external` | Truyền `loading: sending`, giữ callback thật trong `onPressed`; host dùng LoadingController/LoadingOverlay để trình bày chờ |
| AlertBanner | `quote`, `quoteSource`, các style tương ứng, `leading`, `body`, `meta`, `trailing`, `showBorder` | Dùng icon của app, nội dung/trích dẫn và hình không viền; `neutral` đã tồn tại từ trước |
| TimelineItem | `leading`, `body`, `meta`, `trailing`; kích thước marker lấy từ theme | App đặt marker và thời gian theo thiết kế; SDK giữ đường nối, không vẽ đường sau mốc cuối |
| OtpField | Một TextField thật mặc định, cell builder tùy biến; legacy mode tường minh | Giữ lớp bọc cho nhãn/lỗi/token; dùng `OtpController.setText` khi đặt cả mã |
| Skeleton | Export thêm `Skeleton` bên cạnh `Bone`/`PaintingEffect` | Các app dùng `Skeleton.leaf` có thể import qua UI Kit |

`body` thay phần title/description mặc định; `meta` nằm dưới phần đó. ListItem
vẫn nhận `title` làm dữ liệu tương thích, nhưng app cần đưa tên vào nội dung
hoặc `semanticLabel` nếu body tùy biến không có chữ. Timeline giữ time bên phải
khi không dùng meta/trailing; có meta thì host sở hữu dòng thời gian bên dưới.
StatTile đặt leading trên phần chính; trailing nằm cạnh header hoặc body tùy biến.
Alert giữ quote/source/meta/action ngay cả khi host thay body. Quote không tự thêm
dấu ngoặc hoặc tên người nói để app quyết định ngôn ngữ/trình bày.

```dart
ui.ListItem(
  title: title,
  description: description,
  titleStyle: unread ? tokens.bodySemibold : tokens.body,
  crossAxisAlignment: CrossAxisAlignment.start,
  meta: Text(timestamp, style: tokens.caption),
  trailing: unread
      ? ui.Badge(variant: ui.BadgeVariant.dot)
      : null,
  hideChevron: true,
  onTap: openNotification,
);

ui.Button(
  label: 'Gửi',
  loading: sending,
  loadingBehavior: ui.ButtonLoadingBehavior.external,
  onPressed: submit,
);
```

`external` giữ nguyên nội dung/màu của nút, bỏ spinner/gap và khóa pointer,
keyboard, semantic activation. Không truyền `onPressed: null` chỉ vì sending:
callback null vẫn có nghĩa nút disabled và dùng màu disabled. SDK không tự tạo
overlay toàn app hoặc ép mọi tác vụ phải dùng cùng chính sách loading.

## OTP: thay đổi hành vi mặc định

`OtpInputMode.singleField` là mặc định mới. Dán, autofill, thay selection và xóa
lùi đi qua một native text input. Các cell nhìn thấy được loại khỏi cây semantics;
TextField thật giữ editing actions, autofill hint và tên `semanticLabel` của host.
Cell co theo chiều rộng hẹp; style lấy từ `theme.numeric` khi không ghi đè.

```dart
ui.OtpField(
  controller: otp,
  semanticLabel: 'Mã xác thực',
  cellBuilder: (context, index, value, active) => MyOtpCell(
    value: value,
    active: active,
  ),
  onCompleted: submitCode,
);
```

`decorationBuilder` và `overlayBuilder` cũ vẫn hoạt động cho các cell nhìn thấy.
Khi dùng `cellBuilder`, builder đó sở hữu toàn bộ cell và thay hai builder cũ.
Callback completion chạy một lần cho mỗi mã hoàn chỉnh mới; xóa về mã chưa đủ
cho phép hoàn thành lại cùng mã. Callback host có thể clear/reject đồng bộ mà
không gửi một mã cũ. `setText` chỉ cập nhật giá trị, không đổi focus.

`focusNodes.first` quản lý focus của input thật trong singleField. Các
`textControllers` vẫn phản ánh từng chữ số, nhưng app đặt cả mã bằng `setText`,
không gán trực tiếp text controller từng ô. App đang dựa vào focus từng ô có
thể tạm chọn `inputMode: ui.OtpInputMode.segmented`; mode đó giữ hành vi cũ và
vẫn chỉ xử lý backspace trên ô trống qua KeyEvent. Chưa coi mode legacy là đã
sửa lỗi IME. Dán nhiều số vào mọi ô legacy được phân phối từ ô được dán.

## Theme và token

Các field cũ của constructor đầy đủ vẫn giữ; field mới có mặc định để lời gọi
cũ không bị buộc sửa ngay. `copyWith` và `lerp` mang theo token mới.

- `numeric`: mặc định kế thừa `title`, thêm tabular figures; app có thể đặt
  font số riêng. StatTile, Countdown và OTP dùng token này khi không có style
  riêng. Countdown vì vậy dùng numeric/title thay bodyLarge trước đây; app muốn
  giữ cỡ cũ có thể truyền `style` riêng.
- `display`: bậc chữ lớn của Title; Title không còn ghi đè fontSize bằng số.
- `sizes: ComponentSizes(...)`: rowMd/rowLg, chipHeight, statMinHeight, dotSize,
  controlSm/Md/Lg, iconSm/Md/Lg, otpWidth/Height, timelineIndicator/Column/Icon.
  `statMinHeight` mặc định 0 để giữ layout cũ. Chip giữ vùng chạm tối thiểu theo
  `touchMinTarget` khi hình chip nhỏ hơn vùng chạm.
- `motion: MotionTokens(...)`: fast/base/slow và curve. Chip, Checkbox, Radio,
  Select, Search, Switch, Dialog và LoadingOverlay nhận thời lượng từ theme;
  tham số widget được ưu tiên. Reduced motion đưa thời lượng về zero. Các
  timeline/keyframe motion có thời lượng nghiệp vụ riêng vẫn giữ cấu hình cũ.
- `shadowColor`, `searchShadowColor`, `thumbShadowColor`, `scrim`: thay màu
  bóng/barrier viết trực tiếp trong component.

```dart
final tokens = ui.ThemeData.fromDefaults(
  numeric: const TextStyle(
    fontFamily: 'monospace',
    fontSize: 24,
    fontFeatures: [FontFeature.tabularFigures()],
  ),
  sizes: const ui.ComponentSizes(
    rowMd: 64, rowLg: 80, chipHeight: 32, statMinHeight: 96, dotSize: 8,
  ),
  motion: const ui.MotionTokens(
    fast: Duration(milliseconds: 120),
    base: Duration(milliseconds: 180),
    curve: Curves.easeInOut,
  ),
);
```

Một số thuộc tính public trước đây luôn có default giờ nullable để phân biệt
“host chưa đặt” với giá trị override: OTP dimensions/decorationBuilder,
Timeline dimensions, Badge dotSize, MediaPicker previewOverlayColor và
animationDuration của các control vừa nêu. Lời gọi truyền giá trị vẫn dùng
được; code đọc trực tiếp thuộc tính cần xử lý null hoặc đọc token đã resolve.

## Trợ năng và loading

Backport sửa Pressable semantic activation/keyboard/throttle từ nhánh tích hợp
vào hotfix; main tại điểm tách chưa có sửa này. Cũng giữ sửa Button overflow
cần cho label và child trên layout hẹp. ListItem/StatTile cho nội dung con cung cấp tên tự
nhiên. Nếu truyền semanticLabel tường minh, tên đó thay semantics con để không
đọc lặp. Alert giữ semantics nội dung và action thay vì lặp title/description
qua label cha. LoadingOverlay khóa pointer, focus và semantics của màn bên dưới
khi visible; khi ẩn, nội dung overlay không được đọc trong thời gian fade-out.

## Dependency, phát hành và giới hạn

Chưa tách Skeleton/Refresh thành package mới và chưa thay engine. UI Kit vẫn
phụ thuộc và phơi type `skeletonizer`/`pull_to_refresh_flutter3`; import qua
wrapper giúp app không phải khai trực tiếp khi các use case đã đủ, nhưng không
làm dependency graph độc lập khỏi hai engine. Khi đổi engine cần migration riêng.

App Station hiện dùng Flutter 3.47.8 và SDK revision 1fb67ba. Candidate này tiếp
tục yêu cầu Flutter 3.50/Dart 3.14 và `material_ui` như main tại điểm tách; không chỉ đổi ref
để lấy fix. Đọc [migration nền tảng](flutter-3.50-migration.md), chốt revision
chung cho các package cùng graph, rồi mới thay lớp bọc và xác nhận giao diện.

Tag dự kiến khi đủ điều kiện phát hành: `mobile_ui_kit/v1.0.0-rc.3`. Chưa tạo
hoặc push tag; chính sách tag tùy chọn hiện tại không đổi. Changelog ghi theo
widget; việc thông báo cho app và nâng ref là bước tích hợp riêng, chưa gửi
thông báo ra ngoài trong lượt sửa source này.

Không ẩn/xóa API công khai hoặc gắn experimental hàng loạt dựa trên usage một
app. Cần inventory các consumer và quyết định scope stable riêng; quy tắc “hai
app” cho toàn UI Kit chưa được tự áp như một thay đổi chính sách.

## Bằng chứng kiểm tra của lượt sửa

- Đã kiểm parse/format Dart, source guard không màu/cỡ chữ literal ngoài token,
  test Python của guard/release metadata và kiểm metadata candidate.
- Đã thêm test Flutter cho OTP paste/IME editing update/autofill hint/selection,
  callback reentrant/controller replacement/semantics/legacy paste; slot,
  external loading, theme interpolation/consumption và reduced motion.
- Chưa chạy Flutter analyze, Flutter test, build hay render. Không tạo golden
  baseline từ hình chưa render/kiểm. Các test IME dùng editing update giả lập,
  không chứng minh bàn phím mềm Android/TalkBack trên thiết bị thật.
- CI có source-policy job riêng và workspace Flutter suite hiện có. Chưa thêm
  runner Android/emulator hoặc baseline golden; hai mục này cần kiểm thiết bị
  và tạo/duyệt ảnh baseline trong lượt được phép biên dịch. Chưa đánh dấu pass.

## Nhánh và đường phát hành hotfix

Nhánh `hotfix/mobile-ui-kit-rc3` bắt đầu trực tiếp từ local main `18ec3ed`.
Không chứa hai commit riêng của release/0.8.0 (`56b77b1`, `b5d9e93`),
không export AsyncView/RouteTransitionGuard hoặc mang theo kế hoạch native.
Preview riêng ở `mobile_ui_kit/example/lib/hotfix_main.dart`; showcase chính
giữ snapshot của main. Merge riêng hotfix vào main rồi forward-port vào nhánh
tích hợp; không dùng merge toàn nhánh 0.8.0 để phân phối sửa lỗi này.

Theo yêu cầu chủ sở hữu, ngày 2026-11-25 đã fast-forward `main` local từ
`18ec3ed` lên commit hotfix `41cd41b`. Không merge nhánh release/0.8.0;
checkout đó và các thay đổi đang dở vẫn được giữ nguyên.

Kiểm tra remote chưa thành công vì SSH trả `Permission denied (publickey)`;
GitHub CLI cũng chưa đăng nhập. Chưa xác nhận main trên server có đổi sau ref
local; chưa push, tạo PR hoặc tag. Kiểm tra Flutter có biên dịch vẫn chưa chạy.
