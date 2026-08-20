# SmartNote

SmartNote là ứng dụng ghi chú Flutter dành cho Android, hỗ trợ văn bản,
checklist, ảnh, nhãn, nhắc việc, khóa PIN, thùng rác 30 ngày và xuất
PDF/Markdown. Ứng dụng hoạt động offline bằng SQLite và đồng bộ với REST API
khi có kết nối.

## Kiến trúc

- Flutter: `presentation → application → domain ← data`.
- SQLite là cache và hàng đợi thay đổi offline.
- REST API Express + SQLite là nguồn dữ liệu đồng bộ chính.
- Mỗi thiết bị có UUID trong `X-Device-Id`; không có đăng nhập/Supabase.

Chi tiết: [Kiến trúc](docs/architecture.md) và [API](docs/api.md).

Khám phá request/response bằng [API Playground](https://theihoz.github.io/smartnote/).

## Yêu cầu

- Flutter 3.44+ và Android SDK.
- Node.js 22+.
- Postman CLI để chạy collection hoặc đồng bộ Postman Cloud.

## Chạy nhanh

### Docker (khuyến nghị khi phát triển API)

```powershell
npm run docker:up
npm run docker:test
docker compose logs -f api
```

API chạy tại `http://localhost:8787`. SQLite nằm trong `tmpfs`, vì vậy dữ
liệu API sẽ mất khi container dừng hoặc được tạo lại. Dùng
`npm run docker:down` để dừng môi trường.

### Không dùng Docker

```powershell
npm install
npm run api:start
```

Mở terminal khác:

```powershell
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8787
```

`10.0.2.2` dùng cho Android Emulator. Thiết bị thật dùng IP LAN của máy chạy
API, ví dụ `http://192.168.1.10:8787`. Không truyền `API_BASE_URL` thì app chạy
local-only.

## Kiểm thử

```powershell
npm run api:test
npm run postman:lint
npm run postman:test
flutter analyze
flutter test
flutter build apk --debug
```

APK nằm tại `build/app/outputs/flutter-apk/app-debug.apk`, hỗ trợ Android
7.0/API 24 trở lên.

## Tài liệu

- [Cài đặt và SQLite](docs/getting-started.md)
- [Clean Architecture](docs/architecture.md)
- [REST API, Postman và logging](docs/api.md)
- [Build/cài APK](docs/android.md)
- [Khắc phục sự cố](docs/troubleshooting.md)

## Bảo mật

`X-Device-Id` chỉ phân tách dữ liệu, không phải xác thực. Không lưu dữ liệu
nhạy cảm trên Internet nếu chưa bổ sung HTTPS, auth, rate limit và backup.

## Giấy phép

MIT — xem [LICENSE](LICENSE).
