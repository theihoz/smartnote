# Cài đặt và chạy dự án

## Backend

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
API qua firewall nếu thiết bị không kết nối được.

Flutter tự tạo `smartnote.db`. Backend tự tạo `smartnote-api.db`, bật WAL và
busy timeout. Không sửa database bằng tay khi process API đang chạy.
