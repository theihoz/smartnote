# Cài đặt và chạy dự án

## Backend

### Docker

```powershell
npm install
npm run docker:up
```

API chạy tại `http://localhost:8787`. Database Docker nằm trong `tmpfs`, nên
dữ liệu mất khi container bị dừng hoặc tạo lại.

### Chạy trực tiếp

```powershell
npm install
npm run api:start
```

API mặc định chạy tại `http://127.0.0.1:8787`. Biến `PORT` thay đổi cổng.
Database runtime nằm trong `api/data/` .

## Flutter

```powershell
flutter pub get
flutter run
```

Lệnh trên chạy đăng ký, đăng nhập, Guest và ghi chú hoàn toàn bằng SQLite.
Muốn thử máy chủ, truyền thêm `--dart-define=API_BASE_URL=<địa chỉ API>`; thiết
bị thật phải dùng IP LAN của máy chạy Docker và cùng mạng Wi-Fi.

### Chọn nguồn dữ liệu

| Cách chạy | Lệnh | Nơi lưu tài khoản và ghi chú |
|---|---|---|
| APK offline mặc định | `flutter run` | SQLite trên thiết bị |
| Emulator + Docker | `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8787` | Express/SQLite trong Docker, có cache thiết bị |
| Điện thoại thật + Docker | `flutter run --dart-define=API_BASE_URL=http://<IP-LAN>:8787` | Express/SQLite trong Docker, có cache thiết bị |

`API_BASE_URL` là cấu hình tại thời điểm build, không phải ô nhập trong ứng
dụng. Dùng `ipconfig` để tìm IPv4 LAN của máy tính. Không dùng `localhost`,
`127.0.0.1` hoặc `10.0.2.2` trên điện thoại thật.

Flutter tạo một file SQLite riêng cho từng profile. Backend tự tạo
`smartnote-api.db`, bật WAL và busy timeout. Không sửa database bằng tay khi
process API đang chạy.
