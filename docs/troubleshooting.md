# Khắc phục sự cố

## Không kết nối API

- Emulator dùng `10.0.2.2`, không dùng `127.0.0.1`.
- Thiết bị thật dùng IP LAN của máy chạy API.
- Kiểm tra `/health`, firewall và hai thiết bị cùng mạng.
- Đối chiếu `requestId` trong log `smartnote.api` và JSON log backend.
- `API_BASE_URL` được gắn vào APK khi build; sửa IP yêu cầu build và cài lại.

Ví dụ kiểm tra từ điện thoại thật:

```text
http://192.168.1.10:8787/health
```

Nếu URL này không mở được, lỗi nằm ở Docker, IP LAN hoặc Windows Firewall;
ứng dụng không thể tự chuyển từ API hỏng sang tài khoản SQLite vì hai nguồn có
danh sách tài khoản riêng.

## App chạy nhưng chưa đồng bộ

APK mặc định chạy local bằng SQLite nên đăng ký, đăng nhập và Guest không cần
API. Bản APK được build với `API_BASE_URL` mới gửi tài khoản và ghi chú tới máy
chủ Docker.

## Notification không xuất hiện

Kiểm tra quyền notification Android 13+, tiết kiệm pin và thời gian hệ thống.

## Build Android lỗi

Chạy `flutter doctor`, xác nhận Android SDK/JDK 17, rồi chạy `flutter clean` và
`flutter pub get`. Nếu release báo thiếu `IntegrationTestPlugin`, bảo đảm
`integration_test` không nằm trong `pubspec.yaml` khi dự án không có integration
test. Không commit keystore hoặc `.env`.
