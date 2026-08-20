# Build và cài APK Android

```powershell
flutter clean
flutter pub get
flutter build apk --debug --dart-define=API_BASE_URL=http://192.168.1.10:8787
```

APK nằm tại `build/app/outputs/flutter-apk/app-debug.apk`.

1. Bật quyền cài ứng dụng không rõ nguồn trên thiết bị.
2. Chép APK sang thiết bị và mở file.
3. Cấp quyền notification/camera khi được hỏi.
4. Đảm bảo thiết bị truy cập được URL API đã nhúng khi build.

Debug APK dùng cho kiểm thử/chia sẻ nội bộ, không dùng phát hành Google Play.
Dự án hỗ trợ Android 7.0/API 24 trở lên.
