# Khắc phục sự cố

## Không kết nối API

- Emulator dùng `10.0.2.2`, không dùng `127.0.0.1`.
- Thiết bị thật dùng IP LAN của máy chạy API.
- Kiểm tra `/health`, firewall và hai thiết bị cùng mạng.
- Đối chiếu `requestId` trong log `smartnote.api` và JSON log backend.

## App chạy nhưng chưa đồng bộ

Đây là fallback khi thiếu `API_BASE_URL` hoặc API lỗi. Dữ liệu vẫn ở SQLite và
outbox được giữ để thử lại lần mở sau.

## Notification không xuất hiện

Kiểm tra quyền notification Android 13+, tiết kiệm pin và thời gian hệ thống.

## Build Android lỗi

Chạy `flutter doctor`, xác nhận Android SDK/JDK 17, rồi chạy `flutter clean` và
`flutter pub get`. Không commit keystore hoặc `.env`.
