# Khắc phục sự cố

## Không kết nối API

- Emulator dùng `10.0.2.2`, không dùng `127.0.0.1`.
- Thiết bị thật dùng IP LAN của máy chạy API.
- Kiểm tra `/health`, firewall và hai thiết bị cùng mạng.
- Đối chiếu `requestId` trong log `smartnote.api` và JSON log backend.

## App chạy nhưng chưa đồng bộ

Nếu thiết bị đã có phiên, dữ liệu vẫn ở SQLite và outbox được giữ để thử lại
lần mở sau. Với bản cài mới, thiếu `API_BASE_URL` khiến đăng nhập, đăng ký và
Guest báo `API_BASE_URL chưa được cấu hình`; hãy build lại APK với URL API mà
thiết bị truy cập được.

## Notification không xuất hiện

Kiểm tra quyền notification Android 13+, tiết kiệm pin và thời gian hệ thống.

## Build Android lỗi

Chạy `flutter doctor`, xác nhận Android SDK/JDK 17, rồi chạy `flutter clean` và
`flutter pub get`. Nếu release báo thiếu `IntegrationTestPlugin`, bảo đảm
`integration_test` không nằm trong `pubspec.yaml` khi dự án không có integration
test. Không commit keystore hoặc `.env`.
