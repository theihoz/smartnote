# KỊCH BẢN VIDEO BÁO CÁO DỰ ÁN SMARTNOTE

## 1. Thông tin chung

- **Tên dự án:** SmartNote
- **Thời lượng đề xuất:** 8–10 phút
- **Nền tảng:** Flutter Android
- **Thành viên:**
  - Diệp Yến Khoa
  - Nguyễn Trường Diễm Quỳnh
  - Trần Thái Hòa
- **Mục tiêu video:** Giới thiệu bài toán, giao diện, chức năng, cách lưu dữ
  liệu offline và hoạt động của REST API trong môi trường Docker.

## 2. Chuẩn bị trước khi quay

1. Cài APK mới nhất trên điện thoại hoặc Android Emulator.
2. Xóa dữ liệu ứng dụng để mô phỏng lần sử dụng đầu tiên.
3. Chuẩn bị một tài khoản demo, ví dụ `demo@smartnote.local`.
4. Chuẩn bị hai ghi chú mẫu:
   - “Kế hoạch báo cáo SmartNote”.
   - “Danh sách công việc tuần này”.
5. Nếu quay phần máy chủ, chạy:

   ```powershell
   npm run docker:up
   ```

6. Mở sẵn terminal log Docker, Postman Collection và cấu trúc thư mục dự án.
7. Tắt thông báo cá nhân trên máy quay và không để lộ token hoặc mật khẩu thật.

## 3. Kịch bản chi tiết

### 00:00–00:35 — Mở đầu

**Hình ảnh cần quay**

- Logo hoặc màn hình đăng nhập SmartNote.
- Hiển thị tên ba thành viên.

**Lời thuyết minh**

> Xin chào thầy cô và các bạn. Nhóm chúng em xin giới thiệu SmartNote, một ứng
> dụng ghi chú dành cho Android được phát triển bằng Flutter. Ứng dụng hỗ trợ
> ghi chú văn bản, danh sách công việc, nhãn, nhắc việc, khóa PIN, thùng rác và
> xuất tài liệu. Điểm chính của SmartNote là người dùng vẫn có thể đăng ký,
> đăng nhập và sử dụng ứng dụng khi không có Wi-Fi nhờ cơ sở dữ liệu SQLite
> được lưu trực tiếp trên thiết bị.

**Kết quả cần thể hiện**

- Người xem biết tên dự án, thành viên và giá trị chính của ứng dụng.

---

### 00:35–01:20 — Bài toán và giải pháp

**Hình ảnh cần quay**

- Chuyển nhanh qua màn hình trang chủ, tìm kiếm, yêu thích và cài đặt.
- Có thể chèn sơ đồ đơn giản: `Người dùng → SmartNote → SQLite / REST API`.

**Lời thuyết minh**

> Các ứng dụng ghi chú thường phụ thuộc vào kết nối mạng hoặc làm mất thay đổi
> khi đồng bộ thất bại. SmartNote giải quyết vấn đề này theo hướng ưu tiên
> offline. Mọi thao tác được lưu trên thiết bị trước. Khi phiên bản ứng dụng có
> cấu hình máy chủ, dữ liệu mới được gửi lên REST API. Nhờ đó, phiên bản APK
> mặc định vẫn hoạt động độc lập, còn phiên bản kết nối Docker có thể mô phỏng
> hệ thống đồng bộ nhiều thiết bị.

**Kết quả cần thể hiện**

- Giải thích được hai chế độ hoạt động:
  - SQLite local không cần mạng.
  - SQLite cache kết hợp REST API khi có cấu hình máy chủ.

---

### 01:20–02:15 — Đăng ký, đăng nhập và Guest

**Hình ảnh cần quay**

1. Chuyển sang màn hình đăng ký.
2. Nhập email sai để minh họa kiểm tra dữ liệu.
3. Nhập email và mật khẩu hợp lệ, sau đó đăng ký.
4. Đăng xuất rồi đăng nhập lại.
5. Quay lại và chọn “Tiếp tục với Guest”.

**Lời thuyết minh**

> SmartNote cung cấp ba lựa chọn: đăng ký tài khoản, đăng nhập hoặc tiếp tục với
> Guest. Trong APK mặc định, các chức năng này sử dụng SQLite trên điện thoại
> và không cần kết nối Internet. Email được chuẩn hóa, mật khẩu phải có từ tám
> đến bảy mươi hai ký tự và không được lưu ở dạng văn bản. Hệ thống sử dụng
> PBKDF2-HMAC-SHA256 cùng salt riêng để bảo vệ mật khẩu. Mỗi tài khoản và hồ sơ
> Guest có vùng dữ liệu ghi chú riêng.

**Kết quả cần thể hiện**

- Không còn thông báo yêu cầu `API_BASE_URL` trong APK mặc định.
- Đăng ký và đăng nhập thành công khi tắt Wi-Fi.
- Guest mở được ứng dụng mà không cần tài khoản.

---

### 02:15–03:25 — Trang chủ và tạo ghi chú

**Hình ảnh cần quay**

1. Giới thiệu trang chủ và thanh điều hướng.
2. Nhấn nút tạo ghi chú.
3. Nhập tiêu đề, nội dung, nhãn và chọn loại ghi chú.
4. Tạo một danh sách công việc và đánh dấu một mục hoàn thành.
5. Lưu ghi chú rồi mở lại.

**Lời thuyết minh**

> Trang chủ hiển thị các ghi chú gần đây và hỗ trợ cả ghi chú văn bản lẫn danh
> sách công việc. Người dùng có thể thêm tiêu đề, nội dung, ảnh, nhãn, màu và
> trạng thái yêu thích. Trong khi nhập, SmartNote tự lưu bản nháp để hạn chế
> mất dữ liệu. Mỗi lần lưu cũng tạo một phiên bản lịch sử; hệ thống giữ tối đa
> hai mươi phiên bản cho mỗi ghi chú.

**Kết quả cần thể hiện**

- Ghi chú được tạo và mở lại thành công.
- Danh sách công việc lưu đúng trạng thái.
- Có thể mở lịch sử phiên bản và khôi phục một bản cũ.

---

### 03:25–04:15 — Tìm kiếm, nhãn, lọc và yêu thích

**Hình ảnh cần quay**

1. Gõ từ khóa trong màn hình tìm kiếm.
2. Mở bộ lọc.
3. Chọn nhãn, trạng thái yêu thích hoặc loại ghi chú.
4. Chuyển cách sắp xếp mới nhất, cũ nhất hoặc theo tiêu đề.

**Lời thuyết minh**

> Khi số lượng ghi chú tăng lên, người dùng có thể tìm theo tiêu đề hoặc nội
> dung. Bộ lọc hỗ trợ kết hợp nhãn, ghi chú yêu thích, loại ghi chú và thứ tự
> sắp xếp. Các điều kiện này hoạt động trực tiếp trên dữ liệu local nên phản
> hồi nhanh và không phụ thuộc vào mạng.

**Kết quả cần thể hiện**

- Danh sách thay đổi đúng theo nhiều điều kiện kết hợp.

---

### 04:15–05:20 — Các chức năng hỗ trợ

**Hình ảnh cần quay**

1. Tạo lịch nhắc cho một ghi chú.
2. Khóa ghi chú bằng PIN và thử mở lại.
3. Xóa ghi chú, sử dụng nút hoàn tác rồi mở Thùng rác.
4. Chọn nhiều ghi chú và mở màn hình xuất dữ liệu.

**Lời thuyết minh**

> SmartNote hỗ trợ nhắc việc theo ngày giờ bằng thông báo cục bộ. Nếu thiết bị
> chưa cấp quyền, ứng dụng hiển thị hướng dẫn thay vì báo lỗi kỹ thuật. Với ghi
> chú riêng tư, người dùng có thể đặt PIN từ bốn đến sáu số. Sau năm lần nhập
> sai, ứng dụng tạm khóa trong ba mươi giây. Ghi chú bị xóa được chuyển vào
> Thùng rác trong ba mươi ngày và có thể hoàn tác hoặc khôi phục. Ngoài ra,
> người dùng có thể chọn nhiều ghi chú để xuất thành PDF hoặc Markdown.

**Kết quả cần thể hiện**

- Nhắc việc được lưu.
- Nội dung ghi chú khóa không hiển thị trước khi nhập đúng PIN.
- Hoàn tác và khôi phục Thùng rác hoạt động.
- Nút xuất PDF/Markdown chỉ bật sau khi chọn ghi chú.

---

### 05:20–06:00 — Giao diện, ngôn ngữ và lưu cài đặt

**Hình ảnh cần quay**

1. Mở Cài đặt.
2. Chuyển giao diện sáng sang tối.
3. Chuyển tiếng Việt sang tiếng Anh.
4. Đóng và mở lại ứng dụng.

**Lời thuyết minh**

> Phần cài đặt cho phép chuyển giao diện sáng, tối và thay đổi giữa tiếng Việt
> với tiếng Anh. Các lựa chọn được lưu trên thiết bị và áp dụng cho toàn bộ ứng
> dụng. Khi đóng rồi mở lại, giao diện và ngôn ngữ đã chọn vẫn được giữ nguyên.

**Kết quả cần thể hiện**

- Các màn hình đổi màu đồng bộ.
- Ngôn ngữ và giao diện không bị đặt lại sau khi mở ứng dụng.

---

### 06:00–06:50 — SQLite và kiến trúc Flutter

**Hình ảnh cần quay**

- Hiển thị cấu trúc các thư mục `presentation`, `application`, `domain`,
  `data`.
- Hiển thị tên các bảng chính hoặc sơ đồ dữ liệu, không cần mở dữ liệu nhạy cảm.

**Lời thuyết minh**

> Phần Flutter được tổ chức theo hướng Clean Architecture. Presentation phụ
> trách giao diện, Application điều phối nghiệp vụ, Domain chứa quy tắc và Data
> kết nối SQLite hoặc REST API. Trên thiết bị, SmartNote dùng một cơ sở dữ liệu
> xác thực local và các file SQLite riêng cho từng hồ sơ. SQLite lưu ghi chú,
> nhãn, danh sách công việc, ảnh, bản nháp, lịch sử phiên bản, nhắc việc, thùng
> rác và hàng đợi đồng bộ. Vì vậy APK vẫn sử dụng bình thường khi không có mạng.

**Kết quả cần thể hiện**

- Giải thích được trách nhiệm của từng tầng mà không đi quá sâu vào mã nguồn.

---

### 06:50–07:55 — Express API và Docker

**Hình ảnh cần quay**

1. Chạy `npm run docker:up`.
2. Mở `http://localhost:8787/health` trên máy tính.
3. Hiển thị log JSON của một request.
4. Có thể quay lệnh build ứng dụng với `API_BASE_URL`.

**Lời thuyết minh**

> Ngoài chế độ local, dự án có backend Express chạy trong Docker tại cổng
> 8787. Khi build ứng dụng với `API_BASE_URL`, các yêu cầu đăng ký, đăng nhập và
> đồng bộ sẽ được gửi tới backend. Android Emulator dùng địa chỉ 10.0.2.2, còn
> điện thoại thật phải dùng IP LAN của máy chạy Docker. Backend cung cấp API
> xác thực, CRUD ghi chú, soft-delete và quote. Mỗi response có request ID; log
> chỉ ghi phương thức, đường dẫn, trạng thái và thời gian xử lý, không ghi mật
> khẩu, token, PIN hoặc nội dung ghi chú.

> Trong bản demo, SQLite của Docker nằm trong bộ nhớ tạm. Khi container bị tạo
> lại, dữ liệu máy chủ có thể mất. Cách cấu hình này phù hợp để trình diễn và
> kiểm thử, chưa phải lưu trữ production.

**Lệnh minh họa**

```powershell
npm run docker:up
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8787
```

**Kết quả cần thể hiện**

- Endpoint `/health` trả về trạng thái hoạt động.
- Log có request ID nhưng không chứa dữ liệu nhạy cảm.

---

### 07:55–08:35 — Postman và kiểm thử

**Hình ảnh cần quay**

1. Mở OpenAPI/Postman Collection của dự án.
2. Chạy kiểm thử API hoặc hiển thị kết quả đã chạy.
3. Hiển thị kết quả Flutter tests và analyze.

**Lời thuyết minh**

> Hợp đồng REST API được mô tả bằng OpenAPI và kiểm thử bằng Postman
> Collection. Bộ kiểm thử kiểm tra xác thực, CRUD, phân tách dữ liệu, tombstone
> và request ID. Postman trong dự án dùng để thiết kế và chạy bộ kiểm thử; thao
> tác từ ứng dụng không tự xuất hiện thành lịch sử trên Postman Cloud. Bên cạnh
> đó, dự án có kiểm thử Flutter cho nghiệp vụ, SQLite, đồng bộ, PIN, nhắc việc,
> xuất tài liệu và giao diện.

**Lệnh minh họa**

```powershell
npm run api:test
npm run postman:test
flutter analyze
flutter test
```

**Kết quả cần thể hiện**

- Không có lỗi phân tích mã nguồn.
- Bộ kiểm thử hiện tại chạy thành công.

---

### 08:35–09:10 — Kết luận

**Hình ảnh cần quay**

- Quay lại trang chủ SmartNote.
- Hiển thị tên ba thành viên và đường dẫn GitHub.

**Lời thuyết minh**

> Qua dự án SmartNote, nhóm chúng em đã xây dựng một ứng dụng Android có giao
> diện hoàn chỉnh, hoạt động offline bằng SQLite và có khả năng kết nối REST API
> khi cần. Hệ thống đáp ứng các chức năng chính của một ứng dụng ghi chú, có
> kiểm thử tự động, tài liệu hướng dẫn và môi trường Docker phục vụ phát triển.
> Trong tương lai, nhóm có thể thay cơ sở dữ liệu tạm bằng lưu trữ bền vững,
> bổ sung HTTPS, sao lưu và triển khai backend công khai. Cảm ơn thầy cô và các
> bạn đã theo dõi phần trình bày của nhóm.

## 4. Câu hỏi phản biện dự kiến

### Vì sao dùng SQLite trên điện thoại?

SQLite gọn nhẹ, không cần máy chủ, phù hợp lưu dữ liệu có cấu trúc và giúp ứng
dụng hoạt động khi mất mạng.

### Khi nào ứng dụng sử dụng Docker?

Chỉ khi APK được build với `API_BASE_URL`. APK mặc định dùng xác thực và dữ
liệu local trên điện thoại.

### Postman có phải là máy chủ không?

Không. Postman lưu hợp đồng và chạy bộ kiểm thử API. Máy chủ thực tế là Express
chạy trong Docker.

### Dữ liệu Docker có được lưu vĩnh viễn không?

Không trong cấu hình demo hiện tại. Thư mục dữ liệu được gắn vào `tmpfs`, nên
dữ liệu có thể mất khi container bị tạo lại.

### Mật khẩu được bảo vệ như thế nào?

Mật khẩu không được lưu trực tiếp. Hệ thống dùng PBKDF2-HMAC-SHA256 với salt
ngẫu nhiên riêng và không ghi mật khẩu vào log.

### Nếu không có mạng thì dữ liệu có mất không?

Không. Ghi chú được lưu vào SQLite trên thiết bị trước. Với bản có máy chủ,
thay đổi chưa gửi được sẽ nằm trong hàng đợi để thử lại sau.

## 5. Checklist sau khi quay

- [ ] Âm thanh rõ, không có tiếng thông báo chen vào.
- [ ] Không để lộ mật khẩu, token, API key hoặc dữ liệu cá nhân.
- [ ] Các thao tác chạm đủ chậm để người xem theo dõi.
- [ ] Có phụ đề cho tên chức năng và lệnh quan trọng.
- [ ] Phần Docker nói rõ dữ liệu máy chủ demo không lưu vĩnh viễn.
- [ ] Phần Postman nói rõ Postman không tự ghi lịch sử thao tác của ứng dụng.
- [ ] Video có tên dự án, thành viên, GitHub và phần kết luận.
