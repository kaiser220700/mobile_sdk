# Chính sách truy cập và sử dụng source Mobile SDK

Cập nhật: 2026-11-16. Chủ sở hữu dùng tên KAISER. Điều khoản về quyền sử dụng
nằm trong [LICENSE](../LICENSE); thông báo chủ sở hữu nằm trong
[COPYRIGHT](../COPYRIGHT.md). Chính sách này không mở rộng quyền đã được cấp.

## 1. Phân phối chỉ qua GitHub

Source được quản lý qua GitHub. App được cho phép dùng Git revision đã chốt
hoặc tag package có sẵn. Không có yêu cầu hoặc kế hoạch đưa SDK lên pub.dev,
Maven Central hay hosted package registry khác; `publish_to: none` được giữ.
Tag/GitHub Release là cách ghi nhận snapshot tùy chọn trong GitHub.

Build, cache dependency và kiểm tra artifact trong Maven local trên máy/CI
phải nằm trong phạm vi sử dụng được phép; không đồng nghĩa được phân phối
artifact cho bên khác.

## 2. Quyền truy cập và quyền dùng SDK

Quyền xem repo, quyền clone và quyền dùng SDK trong sản phẩm là các quyền khác
nhau. Repo không cấp license open source. Ngoài quyền theo luật, điều khoản
nền tảng hoặc license/thỏa thuận hợp lệ khác, việc sử dụng phải có chấp thuận
bằng văn bản của KAISER.

Chấp thuận cần ghi dự án/đơn vị được dùng, revision hoặc phạm vi version,
quyền sửa/build/tích hợp, bên được nhận source và phạm vi phân phối ứng dụng
đã biên dịch. Có quyền tích hợp cho một app không tự cho phép đưa SDK sang
app, khách hàng hoặc tổ chức khác.

Đặc biệt, quyền dùng trong app không mặc định cho phép bán SDK, đăng lại source,
đưa source/artifact SDK ra ngoài GitHub hoặc cấp lại quyền cho bên khác. Giữ
copyright/license trong các bản sao được phép và trong hồ sơ phân phối theo
thỏa thuận tương ứng.

## 3. Quyền riêng tư của repo và giới hạn bảo vệ

Với mục tiêu hạn chế người ngoài lấy source, ưu tiên repo private và chỉ cấp
quyền cho người cần tham gia. Không coi đây là xác nhận repo hiện đã private;
visibility phải được kiểm tra trong cài đặt GitHub bởi người có quyền.

Repo public cho phép người khác xem/fork theo điều khoản GitHub. LICENSE này
không phủ nhận những quyền nền tảng đó. Chuyển sang private không thu hồi được
các bản sao đã tồn tại. Người có source vẫn có thể tạo bản sao; policy và
copyright không phải cơ chế ngăn copy tuyệt đối.

Nguồn: [GitHub licensing](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/licensing-a-repository)
và [GitHub Terms, mục D/E](https://docs.github.com/en/site-policy/github-terms/github-terms-of-service).

## 4. Dependency, đóng góp và quyền đã cấp

Giữ license/notice của dependency và code/asset bên thứ ba. Chỉ tuyên bố quyền
đối với phần thực sự do KAISER nắm giữ; không đổi license của upstream bằng
thông báo copyright ở root repo.

Trước khi nhận đóng góp từ người khác, xác định quyền của người đóng góp và
thỏa thuận sử dụng đóng góp đó. Quyền truy cập GitHub không tự chuyển quyền
sở hữu mọi đóng góp cho KAISER.

Policy không thu hồi quyền đã được cấp hợp lệ theo license/thỏa thuận trước
đó. Muốn thay đổi phạm vi sử dụng phải dựa trên thỏa thuận và quyền thực tế,
không chỉ sửa nội dung LICENSE ở một commit mới.
