# PLAN mở rộng Mobile SDK cho Android và iOS native

Ngày lập: 2026-11-16. Trạng thái: kế hoạch triển khai tăng dần; chưa có implementation native được xác nhận bởi kế hoạch này.

Mục tiêu là để app Flutter, Android native và iOS native chọn từng capability của SDK. Mỗi nền tảng được phát triển, kiểm thử và phát hành theo phạm vi đã chứng minh; không cần hoàn thành toàn bộ SDK cùng lúc.

## 1. Hướng công nghệ

Định hướng kiến trúc của kế hoạch:

| Trách nhiệm | Flutter hiện có | Android native | iOS native |
| --- | --- | --- | --- |
| Ngôn ngữ | Dart | Kotlin | Swift |
| Core, config, update policy | Package Dart thuần | Module Kotlin/JVM, không phụ thuộc UI hay Android framework | Swift library dùng Foundation, không phụ thuộc UI |
| UI Kit | Flutter widgets | Jetpack Compose; dùng Material 3 làm nền khi phù hợp | SwiftUI; ưu tiên control và hành vi theo nền tảng |
| Bất đồng bộ | Future / Stream | Coroutines; Flow cho nguồn thay đổi | async/await; AsyncSequence cho nguồn thay đổi khi cần |
| Tích hợp vào app UI cũ | Theo app Flutter | ComposeView trong Activity/Fragment dùng Views | UIHostingController trong app UIKit |
| Adapter dịch vụ | Adapter Flutter/Dart hiện có | Adapter Kotlin gọi SDK Android của provider | Adapter Swift gọi SDK Apple của provider |
| Phân phối | Giữ cơ chế Git hiện có | Gradle/Maven: JAR cho logic JVM, AAR cho module Android/UI | Swift Package Manager cho source package |

Jetpack Compose là toolkit native UI được Android khuyến nghị và có API Kotlin; vì vậy đây là hướng UI chính cho Android trong kế hoạch này. Kotlin là ngôn ngữ cho cả logic và UI, còn Compose chỉ nằm ở lớp UI. [Android Compose](https://developer.android.com/compose).

SwiftUI là hướng UI chính cho iOS; Swift đảm nhiệm logic và adapter. SDK cung cấp component để app ghép vào kiến trúc đang dùng. [Apple SwiftUI](https://developer.apple.com/swiftui/).

Khả năng nhúng từng phần cho phép app dùng Views/UIKit thử SDK dần: [Compose trong Views](https://developer.android.com/develop/ui/compose/migrate/interoperability-apis/compose-in-views), [UIHostingController](https://developer.apple.com/documentation/swiftui/uihostingcontroller).

### Ranh giới hỗ trợ ban đầu

- Android ưu tiên Kotlin + Compose. App dùng Java/Views có thể tích hợp qua Kotlin và ComposeView; chưa cam kết API Java đầy đủ hoặc một UI Kit XML riêng.
- iOS ưu tiên Swift + SwiftUI. UIKit được hỗ trợ bằng hướng dẫn và ví dụ nhúng; chưa cam kết Objective-C API hay bộ component UIKit tương đương toàn bộ.
- Logic thuần phải dùng được mà không kéo Compose, SwiftUI, Firebase hoặc DevTool vào app.
- Host app sở hữu navigation, dependency injection, branding, localization, credential, consent và business flow. SDK không bắt host thay kiến trúc app.
- Flutter tiếp tục được duy trì theo package hiện có. Native có sample app riêng, không cần khôi phục runner native của các demo Flutter đã bỏ.

### Chia sẻ giữa các nền tảng

Giai đoạn đầu dùng implementation Dart/Kotlin/Swift riêng, chia sẻ **đặc tả hành vi, dữ liệu test và quy ước thiết kế**. Không đưa Flutter engine vào app native để chạy các hàm logic nhỏ.

Kotlin Multiplatform hoặc core dùng FFI là hướng đánh giá sau nếu chi phí duy trì logic trùng lặp trở thành vấn đề đo được. Quyết định lại cần một thử nghiệm so sánh: API Swift, cancellation, debug, dependency, kích thước app và quy trình release. Thử nghiệm đó không chặn các mốc đầu.

## 2. Hiện trạng và phạm vi chuyển đổi

Căn cứ vào source trong checkout tại thời điểm lập kế hoạch:

| Capability | Hiện trạng | Hướng native | Ưu tiên |
| --- | --- | --- | --- |
| Update policy | Dart thuần; host cung cấp config và version | Chuyển logic và kiểm chứng bằng cùng fixture | Đầu tiên |
| Typed config | Dart thuần; schema, decoder, snapshot và fake | API theo từng ngôn ngữ, cùng quy tắc validation | Sau update |
| Telemetry | Contract và fake; chưa phải một bộ provider hoàn chỉnh | Contract/fake trước, adapter theo nhu cầu | Sau update |
| Đọc tiền thành chữ | Entry point Dart thuần, có BigInt | Thêm riêng khi có consumer; thống nhất miền số được hỗ trợ | Theo nhu cầu |
| Firebase lifecycle / Remote Config | Adapter qua FlutterFire | Adapter gọi SDK native của provider | Sau core |
| UI Kit | Widget và state của Flutter | Xây từng component Compose/SwiftUI theo nhu cầu | Thử sau logic |
| DevTool | Controller và panel gắn với Flutter | Bắt đầu từ logging/debug panel riêng cho native nếu cần | Để sau |
| Fuzz / Screen Draw | Dựa vào Semantics, overlay và canvas Flutter | Cần thiết kế và thử nghiệm riêng cho nền tảng | Chưa cam kết |

Nguồn nội bộ: [tổ chức package](package-organization.md), [core](../mobile_sdk_core/README.md), [update](../mobile_update/README.md), [quy trình release](release-workflow.md).

Tên API có thể theo quy ước Kotlin/Swift. Tính tương đương được xét trên input, output, lỗi và vòng đời; không yêu cầu tên class hay chữ ký hàm giống Dart.

## 3. Cấu trúc repo và dependency dự kiến

Giữ đường dẫn package Flutter hiện có. Chỉ tạo thư mục native khi bắt đầu mốc implementation tương ứng.

```text
contracts/
  update/                  # Đặc tả và JSON fixture có version
  config/
  telemetry/
native/
  android/
    sdk-core/              # Kotlin/JVM; tạo ở mốc core
    sdk-update/            # Kotlin/JVM
    sdk-ui-compose/        # Android library, opt-in
    adapters/              # Module Android riêng theo provider
    samples/               # App Compose; ví dụ Views khi làm UI
  ios/
    Sources/
      MobileSDKCore/
      MobileSDKUpdate/
      MobileSDKUI/
    Tests/
    Samples/               # App SwiftUI; ví dụ UIKit khi làm UI
Package.swift              # Manifest dự kiến ở root cho SwiftPM qua URL Git
docs/
  PLAN-native-sdk.md
  native-validation/       # Bằng chứng cho từng mốc khi bắt đầu test
```

Đây là layout đích; chưa tạo các module rỗng để báo là đã hỗ trợ native.

Quan hệ dependency dự kiến:

- Update policy chạy độc lập; chỉ phụ thuộc core nếu có contract thực sự cần dùng chung.
- Core không phụ thuộc UI, provider hoặc developer tools.
- UI phụ thuộc framework UI của nền tảng; app có thể chỉ cài UI mà không cài Firebase/update.
- Adapter phụ thuộc contract cần dùng và SDK provider tương ứng.
- Sample app ghép các module. Developer tools chỉ nằm trong cấu hình phát triển.

**Lưu ý SwiftPM:** package qua URL Git cần manifest ở root của repo phân phối. Product riêng trong cùng manifest không đủ để bảo đảm resolver không tải dependency provider. Base package phải giữ manifest không có Firebase; khi đến mốc adapter, thử nghiệm package phân phối riêng cho provider (có thể mirror từ monorepo). Kiểm tra bằng consumer sạch trước khi chốt. Một manifest có thể cung cấp nhiều product core/update/UI với version theo release của package SwiftPM; không hứa version product độc lập trong cùng manifest.

Android dùng Maven publication kèm metadata để consumer nhận dependency đúng; thử bằng repository local trước khi mở registry nội bộ. [Android library publication](https://developer.android.com/build/publish-library/upload-library).

## 4. Lộ trình theo mốc nhỏ

Mỗi mốc đi theo vòng lặp: chọn phạm vi nhỏ → implementation → test → sample/pilot → ghi bằng chứng và phản hồi → sửa → quyết định phạm vi tiếp theo. Không gắn toàn bộ lộ trình với một ngày phát hành chung.

### P0 — Chốt contract và nền tảng thử nghiệm

Đầu ra:

- [ ] Chọn host pilot Android và iOS; ghi người phụ trách SDK và consumer cho từng nền tảng. Nếu chưa có host thực tế, sample chỉ chứng minh tích hợp kỹ thuật.
- [ ] Ghi ADR cho hướng Kotlin/Compose và Swift/SwiftUI, dependency boundary và cơ chế phân phối thử.
- [ ] Kiểm kê hành vi update trong Dart, viết đặc tả và fixture có ID ổn định; test Dart đọc fixture làm đường đối chiếu.
- [ ] Chốt các trường hợp parser chưa rõ: version rút gọn, số âm, khoảng trắng, hậu tố prerelease/build, số vượt miền hỗ trợ. Parser hiện tại là parser số, chưa phải một implementation SemVer đầy đủ.
- [ ] Mọi thay đổi hành vi Dart được tách thành thay đổi có migration; không tiện tay chuẩn hóa parser trong lúc port.
- [ ] Ghi ma trận Kotlin/JDK/Gradle/AGP/Compose và Swift/Xcode/SDK iOS, cùng phiên bản minimum và phiên bản kiểm tra chính. Pin phiên bản cụ thể khi bắt đầu implementation.
- [ ] Điểm xuất phát để đánh giá: Android minSdk 23 và iOS deployment target 16. Đây là đề xuất sản phẩm, chưa phải minimum đã kiểm chứng; đối chiếu với host pilot và dependency trước khi chốt. compileSdk/targetSdk được ghi riêng, không suy ra từ minSdk.
- [ ] Chốt tên package/module, Maven coordinates và cách pin revision SwiftPM; không dùng placeholder làm namespace phát hành.

Điều kiện hoàn thành: đặc tả update, fixture Dart và ma trận toolchain được review; ghi rõ các quyết định còn mở. Chưa đánh dấu Kotlin/Swift đã hỗ trợ ở mốc này.

### P1 — Android thử nghiệm với update policy

Phạm vi: module Kotlin/JVM cho config update, parser, quyết định `none/soft/force` và checker nhận loader từ host. Không cần UI SDK hoặc Firebase.

- [ ] Chạy cùng fixture update với Dart; đối chiếu mọi kết quả thuộc contract.
- [ ] Unit test checker: config disabled không gọi version loader; lỗi loader và cancellation có hành vi được mô tả.
- [ ] Sample Android tối thiểu hiển thị kết quả bằng UI của host và tự xử lý mở store.
- [ ] Publish vào Maven local, rồi một consumer sạch resolve bằng coordinates và build release; kiểm tra dependency graph và chạy smoke test bản release.
- [ ] Đo phần tăng kích thước/build time so với sample nền, ghi số liệu thay vì đặt mục tiêu tùy ý.

Điều kiện hoàn thành: contract test xanh, sample chạy được trên emulator, consumer dùng artifact thay vì chỉ project dependency. Trạng thái tối đa lúc này là Android experimental.

### P2 — iOS thử nghiệm với cùng update policy

Phạm vi tương ứng P1 bằng Swift, dùng SwiftPM; UI và mở store vẫn do host.

- [ ] Dùng lại fixture P0; so sánh output Dart/Kotlin/Swift theo ID của test case.
- [ ] Unit test checker, error propagation và cancellation; không ép tương đương cancellation giữa các runtime nếu contract chưa quy định.
- [ ] Sample SwiftUI, build và test bằng xcodebuild trên iOS Simulator; kiểm tra deployment target đã chọn.
- [ ] Consumer sạch resolve SwiftPM qua Git revision, build bản release và chạy smoke test; không chỉ kiểm tra local path package.
- [ ] Ghi dependency graph, kích thước và thời gian build theo cách đo đã dùng ở P1.

Điều kiện hoàn thành: update có bằng chứng trên cả ba implementation. SwiftPM package có thể thử bằng revision của nhánh trước khi có release tag; quy tắc tag/range sẽ được kiểm chứng ở mốc phát hành.

**Mốc thử nghiệm native đầu tiên kết thúc ở P2:** hai app native dùng được update policy mà không cần Flutter engine, Firebase hoặc UI Kit của SDK.

### P3 — Core theo từng capability

Chia thành các đợt riêng, không port toàn bộ core trong một PR:

1. Typed config cơ bản: bool/int/double/string, default, range và snapshot bất biến.
2. Enum/JSON/custom decoder theo nhu cầu; mỗi ngôn ngữ cung cấp callback riêng, không chia sẻ executable decoder qua JSON.
3. ConfigSource và fake: load, subscription, dispose/cancel; chốt rõ subscription nhận giá trị hiện tại hay chỉ thay đổi mới.
4. Telemetry contract và fake: event validation, allow-list, trace/error propagation; chưa tự bật gửi dữ liệu cho provider.
5. Tiện ích đọc tiền chỉ bổ sung khi có host dùng; Swift cần quyết định riêng cho miền số lớn trước khi nhận cam kết tương đương BigInt của Dart.

Điều kiện cho từng đợt: fixture dùng chung, unit test failure mode, ví dụ tích hợp và changelog. Ghi rõ capability nào đã có trên nền tảng nào, capability nào chưa hỗ trợ.

### P4 — Adapter native đầu tiên

Ưu tiên Firebase Remote Config nếu host pilot cần; nếu không, chọn adapter theo nhu cầu được ghi nhận.

- [ ] Host khởi tạo provider và truyền instance/dependency vào SDK; core vẫn dùng fake mà không cần provider.
- [ ] Kiểm tra default, cache/offline, fetch thành công, candidate sai schema, giữ snapshot tốt gần nhất và concurrent load.
- [ ] Kiểm tra timeout, dispose/cancel và completion đến muộn. Phân biệt ngừng chờ với thực sự hủy request của SDK provider.
- [ ] Tách test với fake transport và integration test với project thử nghiệm của provider; không dùng credential production.
- [ ] Kiểm tra consumer core-only không resolve provider ngoài ý muốn; đặc biệt kiểm tra package-level dependency của SwiftPM.
- [ ] Sample và host pilot kiểm tra luồng restart/background/foreground trên thiết bị thực trước khi nâng khỏi experimental.

Điều kiện hoàn thành: có báo cáo integration và giới hạn hành vi theo nền tảng; dependency và minimum OS được cập nhật nếu provider đặt yêu cầu cao hơn.

### P5 — UI Kit native theo nhóm component

Không chuyển toàn bộ danh mục Flutter cùng lúc. Nhóm thử nghiệm đầu: Button, TextField, Loading và Alert. Chỉ mở rộng sang Select, Dialog/Sheet, Toast, OTP hoặc component khác sau khi nhóm đầu có phản hồi sử dụng.

- [ ] Trích quy ước màu, typography, spacing, shape và state thành đặc tả token có version; host có thể override. Không yêu cầu dựng hệ thống sinh code token ở đợt đầu.
- [ ] Android triển khai Compose; iOS triển khai SwiftUI. Chia sẻ ý nghĩa trạng thái và nội dung, cho phép khác biệt layout/interaction hợp lý theo nền tảng.
- [ ] Dùng state do host quản lý khi phù hợp; tránh mỗi component tự tạo một kho state hoặc navigation riêng.
- [ ] Test enabled/disabled/loading/error, focus, keyboard, font lớn, dark mode, accessibility label và hành vi đọc màn hình.
- [ ] Test Compose recomposition và Activity recreation; test SwiftUI identity, task cancellation và cập nhật UI trên MainActor.
- [ ] Có sample ComposeView trong Views và UIHostingController trong UIKit; kiểm tra lifecycle, safe area/insets và đóng màn hình không để lại task/subscription.
- [ ] Đặt screenshot baseline riêng cho mỗi nền tảng ở cấu hình đã pin; snapshot hỗ trợ bắt lỗi giao diện, không thay thế test tương tác/accessibility.

Điều kiện cho từng nhóm: component chạy trên app sample và host pilot, có bằng chứng UI test cùng kiểm tra accessibility trên thiết bị. Không yêu cầu hai nền tảng giống từng pixel.

### P6 — Developer tools và mở rộng sau pilot

Chỉ bắt đầu khi có consumer và người duy trì. Thứ tự đề xuất: structured logging và debug panel → screen annotation → nghiên cứu fuzz riêng.

Fuzz dựa trên Flutter Semantics không chuyển thẳng thành khả năng thao tác UI native. Cần đánh giá riêng API kiểm thử, giới hạn runtime và phạm vi môi trường cho phép trước khi thiết kế. Tool phải tách khỏi dependency/binary production. Mỗi tool có kế hoạch test riêng trước khi nhận implementation.

## 5. Chiến lược kiểm thử và CI tăng dần

### Bộ dữ liệu hành vi dùng chung

JSON fixture chứa `contract_version`, `case_id`, input và expected output/error code. Mỗi runtime đọc cùng file; expected output được review theo đặc tả, không tự sinh từ implementation mới rồi coi là đúng.

Các nhóm bắt buộc khi capability tương ứng được triển khai:

| Nhóm | Trường hợp cần kiểm tra |
| --- | --- |
| Update | Disabled; dưới/bằng/trên min/latest; thiếu hoặc sai trường; URL không hợp lệ; version lỗi; thứ tự min/latest; parser boundary |
| URL | Quy tắc scheme/authority giống contract; URI parser của Dart/JVM/Foundation có thể khác. Việc host có mở được URL là integration test riêng |
| Kiểu số | Int overflow; finite double; sai kiểu bool/string; quy tắc biểu diễn số trong fixture, tránh mất chính xác do JSON reader |
| Chuỗi | Unicode/emoji và đơn vị tính độ dài. Không mặc định Swift grapheme count tương đương UTF-16 length của Dart/Kotlin |
| Config | Default, duplicate/unknown key, decode lỗi, range, enum/JSON sai; không lộ một phần candidate chưa validate xong |
| Bất đồng bộ | Error, timeout, concurrent call, cancel/dispose, subscription cleanup và late completion theo contract từng API |
| Telemetry | Event/key sai, primitive value, allow-list, trace success/error/cancellation; fake không âm thầm che lỗi |

### Các lớp test

| Lớp | Android | iOS | Khi bắt buộc |
| --- | --- | --- | --- |
| Logic/contract | JVM unit test, coroutine test khi có async | Swift Testing hoặc XCTest theo toolchain đã pin | Mỗi PR thay đổi logic |
| Native integration | Instrumented test trên emulator | XCTest trên iOS Simulator | Khi thêm/thay đổi adapter hay API nền tảng |
| UI interaction | Compose UI test | XCTest/XCUITest trong sample host | Khi thêm/thay đổi component UI |
| Consumer packaging | Resolve Maven artifact + release build/smoke | Resolve SwiftPM revision/tag + release build/smoke | Mỗi candidate và thay đổi đóng gói |
| Thiết bị thực | Lifecycle, release build, TalkBack, provider | Lifecycle, release build, VoiceOver, provider | Trước khi nâng capability khỏi experimental |

Tham khảo API kiểm thử chính thức: [Compose testing](https://developer.android.com/develop/ui/compose/testing), [Swift Testing](https://developer.apple.com/documentation/testing/). UI test iOS cần sample app host; unit test Swift package không chứng minh UI đã hoạt động.

### Mở rộng CI theo mốc

- Giữ kiểm tra Flutter hiện có; PR chỉ đổi tài liệu không cần chạy lại toàn bộ bộ test native chưa tồn tại.
- P0: thêm kiểm tra fixture/schema và Dart contract test.
- P1: thêm job Android/JVM, lint/build và consumer smoke; pin JDK/Gradle/toolchain.
- P2: thêm job macOS cho Swift/iOS Simulator và consumer SwiftPM. `swift test` trên macOS không thay thế build/test target iOS.
- P4: fake transport test chạy mỗi PR liên quan; provider integration chạy ở workflow có cấu hình sandbox, đồng thời bắt buộc khi chuẩn bị candidate adapter.
- P5: thêm emulator/simulator UI test và screenshot cho nhóm component đang phát triển.
- PR thường chạy một cấu hình chính đã pin; candidate chạy minimum OS/toolchain được hỗ trợ và cấu hình hiện hành đã chọn. Ghi cụ thể vào support matrix, không dùng chữ “latest” như một cam kết không giới hạn.
- Path filter phải gồm contract dùng chung và dependency liên quan; fixture thay đổi phải chạy cả Dart/Kotlin/Swift đã được triển khai.
- Có script/lệnh tái hiện từng job và lưu test result. Job chưa chạy hoặc bị skip không được ghi là pass.

Mọi thao tác sử dụng CLI, filesystem, API hoặc test runner trong môi trường cô lập. Không dùng Computer Use, AppleScript hay điều khiển cửa sổ desktop. Kiểm tra thủ công trên thiết bị do người phụ trách pilot thực hiện và ghi kết quả.

## 6. Pilot, phát hành và rollback

Mỗi capability đi qua experimental → candidate → stable theo từng nền tảng. Android có thể đi trước iOS hoặc ngược lại; bảng support ghi rõ mức hỗ trợ, không tự coi mọi nền tảng đã tương đương.

Để lên candidate cần contract test, sample, consumer packaging và hướng dẫn tích hợp/rollback. Để lên stable cần thêm ít nhất một host thực tế của nền tảng đó qua hai vòng tích hợp → phản hồi → sửa → xác nhận, cùng người chịu trách nhiệm hỗ trợ. Sample tự viết không thay thế bằng chứng consumer thực tế.

Release ghi rõ version package/artifact, revision, contract version, OS/toolchain đã test, dependency provider, known issues và breaking change. Không đồng bộ version Dart/Kotlin/Swift chỉ vì nằm trong một repo.

- Android version theo artifact; P0 chốt quy tắc phối hợp version giữa các module có dependency.
- iOS base SwiftPM version theo package. Nếu dùng tag riêng như `native-ios/v…`, phải xác minh khả năng resolve tag/range; trước đó pin revision. Chưa hứa cú pháp version range hoạt động với tag tùy ý.
- Chưa công bố tag, đẩy registry hoặc tạo repo phân phối adapter trong bước lập PLAN này. Các mốc triển khai chuẩn bị artifact và hướng dẫn consumer trước khi có thao tác phát hành.
- Rollback bằng artifact version/Git revision đã kiểm chứng. Giữ nguyên artifact/tag cũ; thay đổi config contract phải nêu khả năng đọc của bản SDK trước. Với update, có kịch bản tắt policy bằng config và kiểm tra tình huống offline/cache để tránh khóa app.

## 7. Cách cập nhật PLAN sau mỗi đợt

Sau một đợt nhỏ, cập nhật checkbox và thêm bản ghi ở bảng dưới. Bằng chứng chi tiết lưu tại `docs/native-validation/` với revision, lệnh chạy, thiết bị/OS, kết quả, known issues và việc cần làm tiếp. Nếu chưa có thiết bị hoặc host pilot, giữ mốc tương ứng ở trạng thái chờ kiểm chứng.

| Ngày | Mốc/capability | Nền tảng | Kết quả và bằng chứng | Việc tiếp theo |
| --- | --- | --- | --- | --- |
| 2026-11-16 | Lập PLAN | Android/iOS | Đã xác định hướng công nghệ, scope và điều kiện kiểm thử; chưa chạy test native | P0: review update contract, chọn pilot và chốt toolchain |

Đợt làm tiếp theo chỉ cần thực hiện P0 cho update: đặc tả hành vi, fixture dùng chung, Dart contract test và ADR/toolchain. Sau khi có bằng chứng mới quyết định bắt đầu implementation Kotlin ở P1; không mở đồng thời toàn bộ core, UI và adapter.
