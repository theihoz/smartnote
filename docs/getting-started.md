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
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8787
```

Thiết bị thật cần cùng mạng với máy API và dùng IP LAN của máy. Cho phép cổng
API qua firewall nếu thiết bị không kết nối được. Bản cài mới cần kết nối API
để tạo Guest hoặc tài khoản; sau đó ghi chú vẫn dùng được offline từ cache.

Flutter tạo một file SQLite riêng cho từng profile. Backend tự tạo
`smartnote-api.db`, bật WAL và busy timeout. Không sửa database bằng tay khi
process API đang chạy.
