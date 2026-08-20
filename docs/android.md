# Build và cài APK Android

```powershell
flutter clean
flutter pub get
flutter build apk --debug --dart-define=API_BASE_URL=http://192.168.1.10:8787
flutter build apk --release --dart-define=API_BASE_URL=http://192.168.1.10:8787
```

APK nằm tại:

- Debug: `build/app/outputs/flutter-apk/app-debug.apk`
- Release: `build/app/outputs/flutter-apk/app-release.apk`

Nếu build trực tiếp bằng Gradle, release nằm tại
`build/app/outputs/apk/release/app-release.apk`.

1. Bật quyền cài ứng dụng không rõ nguồn trên thiết bị.
2. Chép APK sang thiết bị và mở file.
3. Cấp quyền notification/camera khi được hỏi.
4. Đảm bảo thiết bị truy cập được URL API đã nhúng khi build.

Ứng dụng hỗ trợ Android 7.0/API 24 trở lên. Build type `release` hiện vẫn ký
bằng debug key để chia sẻ bản demo; cần keystore riêng trước khi phát hành qua
Google Play. Không commit keystore hoặc `key.properties`.

## GitHub Release

Phiên bản hiện tại là `v1.0.0`. Đổi tên APK thành `SmartNote-v1.0.0.apk`, tải
lên [GitHub Releases](https://github.com/theihoz/smartnote/releases) và ghi rõ
URL API được nhúng, loại signing key và checksum SHA-256 trong release notes.
