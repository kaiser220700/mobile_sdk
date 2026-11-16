# Chốt đợt 0.7.x — GitHub-only

Ngày: 2026-11-16. Branch: `release/0.7.0`.
Trạng thái: hoàn tất trong repo theo phạm vi đã thống nhất; pilot app thật được miễn.
Source nền: `f5e6d2c`; các thay đổi guard/CI và tài liệu được chốt cùng báo cáo
này. Đây là mốc công việc trên branch, không phải phát hành lại version/tag
`v0.7.0` đã tồn tại.

## Phạm vi và quyết định

- GitHub là kênh quản lý/phân phối source duy nhất; không publish registry.
- Version từng package và `stage` trong catalog giữ nguyên: UI Kit candidate,
  các thư viện còn lại development, Fuzz/Screen Draw experimental.
- Theo yêu cầu chủ sở hữu ngày 2026-11-16, bỏ qua pilot/test/build trên app
  thật bên ngoài để hoàn thành 0.7.x. Không ghi bước này là pass.
- Native chưa triển khai; PLAN P0–P6 là công việc riêng, không chặn mốc này.
- Không thay đổi visibility/quyền GitHub; không tạo tag mới hoặc di chuyển tag cũ.

## Thay đổi trong đợt chốt

- Guard chấp nhận riêng integration branch `release/0.7.0`, vẫn kiểm tra
  metadata của toàn bộ package và giữ yêu cầu ref/note cho package release.
- CI workspace/portal chạy cả push develop và release/**; metadata job giữ
  kiểm tra trên đúng ref được yêu cầu.
- Chốt ROADMAP Flutter/native và phạm vi GitHub-only.
- Bổ sung LICENSE độc quyền, COPYRIGHT và source usage policy của KAISER.
- Changelog, hướng dẫn Flutter 3.50/`material_ui` và rollback được liên kết.

## Kiểm tra trong repo

| Kiểm tra | Kết quả |
| --- | --- |
| `python3 -m unittest discover -s tool -p 'test_*.py'` | Qua: 9 test policy, gồm 3 test mới cho integration branch |
| `./tool/verify_release_metadata.sh` | Qua trên `release/0.7.0` |
| `npm run test:web` | Qua: 6 test |
| `./tool/verify_workspace.sh` | Qua: resolve/format/analyze 14 package/example, 142 test Dart/Flutter trong 13 nhóm; boundaries và 9 test policy |
| `npm run build` | Qua: portal tĩnh và Flutter Web release; Wasm dry run qua |
| Liên kết tài liệu, version/maturity, `publish_to: none`, cấu hình CI | Qua; workflow có branch filters main/develop/release/** |
| `git diff --check` | Qua |
| App thật bên ngoài | Bỏ qua theo yêu cầu; không có kết quả nghiệm thu |
| GitHub Actions hosted | Chưa chạy trong lượt local này |
| Native build/device/Firebase project thật | Không thực hiện |

## Sử dụng và rollback

App được phép sử dụng pin full Git revision của snapshot cần dùng và giữ
lockfile. Có thể lấy revision chứa báo cáo bằng lệnh sau trên checkout có
commit chốt:

```sh
git log -1 --format=%H -- docs/validation-0.7.x.md
```

Không giả định branch di động là pin bất biến và không bắt buộc tạo tag.

Migration Flutter 3.50: [hướng dẫn](flutter-3.50-migration.md). Quyền sử dụng:
[LICENSE](../LICENSE), [COPYRIGHT](../COPYRIGHT.md),
[source usage policy](source-usage-policy.md).

Rollback bằng revision SDK và lockfile trước đó trong app, resolve dependency
và build lại môi trường app. Nếu app đã migration Flutter/Material, cần khôi
phục cả source/toolchain app phù hợp; không di chuyển tag đã tồn tại.

Lượt xác nhận trong repo không chứng minh tương thích mọi app/thiết bị hoặc
mọi Firebase project và không tự nâng bất kỳ package nào lên stable.
