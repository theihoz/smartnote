# SmartNote

Ứng dụng ghi chú Flutter dành cho Android, thiết kế theo Figma SmartNote và
hoạt động theo hướng offline-first.

## Tính năng

- Ghi chú văn bản, checklist, thẻ và ảnh từ camera/thư viện.
- Tìm kiếm, yêu thích, chế độ sáng/tối và giao diện Việt/Anh.
- SQLite lưu dữ liệu cục bộ; outbox tự đồng bộ lên Supabase khi có cấu hình.
- Trích dẫn truyền cảm hứng từ REST API với trạng thái tải, lỗi và thử lại.
- Material 3 responsive bằng thanh điều hướng dưới hoặc NavigationRail.

## Chạy dự án

Yêu cầu Flutter 3.44 hoặc mới hơn và Android SDK (minSdk 24).

```powershell
flutter pub get
flutter run
```

Ứng dụng vẫn hoạt động đầy đủ bằng SQLite khi không có cấu hình cloud. Project
Supabase production đã được tạo tại `ijfiountpfumysfbwrqh`, migration và
Anonymous Sign-Ins đã được bật. Khi chạy hoặc build, truyền publishable key từ
Supabase Dashboard (không dùng secret/service-role key):

```powershell
flutter run `
  --dart-define=SUPABASE_URL=https://ijfiountpfumysfbwrqh.supabase.co `
  --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY
```

## Kiểm thử và build

```powershell
flutter analyze
flutter test
flutter build apk --debug
node .\download_site\test_site.mjs
```

APK được tạo tại `build/app/outputs/flutter-apk/app-debug.apk`.

## Tải APK

- Trang tải production: <https://smartnote-download.vercel.app>
- APK trực tiếp: <https://ei7nc9vnjb3m9ska.public.blob.vercel-storage.com/app-debug.apk>
- SHA-256: `068303290D8C874B62724B7DFE6F8732EE4FE127982D18E3D5227C4F52B29089`

Thư mục `download_site` là website tĩnh được triển khai bằng Vercel; APK được
lưu trong Vercel Blob.
