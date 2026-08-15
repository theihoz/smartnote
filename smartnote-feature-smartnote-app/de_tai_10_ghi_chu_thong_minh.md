**ĐỀ TÀI 10**

**Ứng dụng Ghi chú Thông minh**

Mô tả: Ứng dụng giúp người dùng lưu trữ ghi chú, hình ảnh và quản lý công việc cá nhân.

# Chức năng chính

- Tạo ghi chú
- Chỉnh sửa
- Xóa ghi chú
- Gắn hình ảnh
- Phân loại bằng Tag
- Tìm kiếm
- Đánh dấu yêu thích

# Yêu cầu kỹ thuật bắt buộc

Mỗi đề tài phải đáp ứng đầy đủ các tiêu chí sau:

| Tiêu chí | Mô tả yêu cầu | Điểm |
|---|---|---|
| 1. Giao diện người dùng (UI/UX) | Thiết kế hiện đại, bố cục hợp lý, sử dụng Material Design 3, hỗ trợ nhiều kích thước màn hình. | 1.5 |
| 2. Điều hướng ứng dụng | Có tối thiểu 5 màn hình, sử dụng Navigator hoặc GoRouter để chuyển màn hình hợp lý. | 0.5 |
| 3. Quản lý trạng thái | Sử dụng Provider (hoặc Riverpod/BLoC nếu muốn nâng cao) để quản lý dữ liệu và trạng thái ứng dụng. | 1.0 |
| 4. Biểu mẫu và kiểm tra dữ liệu | Có ít nhất một biểu mẫu nhập liệu với kiểm tra dữ liệu (Validation) đầy đủ. | 0.5 |
| 5. Cơ sở dữ liệu cục bộ | Sử dụng SQLite hoặc Hive để lưu trữ dữ liệu và thực hiện đầy đủ các thao tác CRUD. | 1.5 |
| 6. Kết nối REST API | Kết nối tối thiểu một API công khai, xử lý dữ liệu JSON và hiển thị lên giao diện; cần có xử lý trạng thái tải và lỗi kết nối. | 1.0 |
| 7. Tính năng thiết bị | Tích hợp ít nhất một tính năng của thiết bị như Camera, Thư viện ảnh, GPS, Quét QR/Barcode hoặc Thông báo cục bộ (Local Notification). | 1.0 |
| 8. Trải nghiệm người dùng | Có chức năng tìm kiếm, lọc dữ liệu hoặc sắp xếp; bổ sung ít nhất một hiệu ứng chuyển động (Animation). | 1.0 |
| 9. Kiến trúc và chất lượng mã nguồn | Tổ chức dự án theo mô hình MVVM hoặc Clean Architecture (mức cơ bản), mã nguồn rõ ràng, dễ bảo trì. | 1.0 |
| 10. Báo cáo và Demo | Báo cáo mô tả phân tích, thiết kế, triển khai; sử dụng Git để quản lý mã nguồn và trình bày demo sản phẩm hoạt động. | 1.0 |

**Tổng điểm: 10 điểm**

## Yêu cầu nộp bài

Sinh viên cần nộp đầy đủ các thành phần sau:

- Mã nguồn dự án Flutter.
- File APK hoặc AAB có thể cài đặt trên thiết bị Android.
- Báo cáo (PDF) từ 15-20 trang, trình bày quá trình phân tích, thiết kế và triển khai ứng dụng.
- Slide thuyết trình (PowerPoint hoặc PDF).
- Video demo từ 5-10 phút giới thiệu các chức năng chính của ứng dụng.
- Liên kết kho mã nguồn GitHub (khuyến khích công khai hoặc chia sẻ quyền truy cập cho giảng viên).

# Khuyến khích nâng cao (cộng điểm)

Sinh viên có thể được xem xét cộng điểm nếu tích hợp thêm các tính năng như:

- Đăng nhập bằng Firebase Authentication.
- Đồng bộ dữ liệu với Firebase hoặc Supabase.
- Hỗ trợ chế độ sáng/tối (Light/Dark Mode).
- Đa ngôn ngữ (Tiếng Việt/Tiếng Anh).
- Quản lý trạng thái bằng Riverpod hoặc BLoC.
- Kiểm thử (Unit Test hoặc Widget Test).
- Tối ưu hiệu năng và trải nghiệm người dùng.
