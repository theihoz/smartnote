# SmartNote Complete App Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Hoàn thiện SmartNote với UI/UX hướng Focus Inbox, undo một bước cho sửa/xóa, localization ARB đồng bộ, và lưu theme/locale qua lần mở app.

**Architecture:** Giữ Riverpod, GoRouter, SQLite và Supabase. Bổ sung repository settings dùng SharedPreferences, Flutter ARB localization, và undo entry trong NotesController; mọi thay đổi bắt đầu bằng regression test.

**Tech Stack:** Flutter/Dart 3.12, Riverpod, Material 3, flutter_localizations, SharedPreferences, SQLite, GoRouter.

## Global Constraints

- SQLite vẫn là nguồn dữ liệu offline chính.
- Supabase lỗi hoặc thiếu cấu hình không được chặn app local.
- Tiếng Việt là mặc định; tiếng Anh phải thay thế toàn bộ chuỗi UI người dùng thấy.
- Theme system/light/dark phải được lưu cục bộ.
- Undo chỉ giữ một thao tác gần nhất trong phiên, hết hạn sau 5 giây.
- Không để chuỗi tiếng Việt bị lỗi encoding trong source hoặc giao diện.

---

### Task 1: Regression tests và audit hiện trạng

**Files:**
- Create/modify: `test/app/smartnote_app_test.dart`
- Create: `test/app/settings_controller_test.dart`
- Create/modify: `test/features/notes/application/notes_controller_test.dart`

**Interfaces:**
- Test settings load/save, locale/theme restart behavior, edit/delete/undo behavior, and English labels.

- [ ] Viết test đỏ cho persistence, undo sửa/xóa, và các màn hình chính ở English.
- [ ] Chạy test riêng để xác nhận fail vì behavior chưa có.
- [ ] Giữ lại test hiện tại và bổ sung assertions cho empty/error/snackbar copy.

### Task 2: Persistent app settings

**Files:**
- Create: `lib/features/settings/data/app_settings_repository.dart`
- Modify: `lib/app/providers.dart`
- Modify: `lib/main.dart`
- Modify: `lib/app/smartnote_app.dart`

**Interfaces:**
- `AppSettingsRepository.loadThemeMode() -> ThemeMode`
- `AppSettingsRepository.saveThemeMode(ThemeMode mode) -> Future<void>`
- `AppSettingsRepository.loadLocale() -> Locale`
- `AppSettingsRepository.saveLocale(Locale locale) -> Future<void>`

- [ ] Implement defaults `ThemeMode.system` and `Locale('vi')`.
- [ ] Hydrate SharedPreferences before `runApp` and override providers.
- [ ] Persist every setting change without blocking UI updates.
- [ ] Run settings tests and full app tests.

### Task 3: ARB localization

**Files:**
- Create: `lib/l10n/app_vi.arb`, `lib/l10n/app_en.arb`
- Modify: `pubspec.yaml`, `lib/app/smartnote_app.dart`
- Modify: all presentation files under `lib/features/**/presentation/`

**Interfaces:**
- Generated `AppLocalizations` is the only source for user-facing strings.

- [ ] Enable Flutter l10n generation and define Vietnamese/English message keys.
- [ ] Replace hard-coded labels, tooltips, validation, dates, empty states, status text, dialogs, and SnackBars.
- [ ] Remove ternary language branching from `AppShell` and settings.
- [ ] Add widget tests proving a locale switch updates navigation and screen copy.

### Task 4: One-step undo for edits and deletes

**Files:**
- Modify: `lib/features/notes/application/notes_controller.dart`
- Modify: `lib/features/notes/presentation/note_detail_screen.dart`
- Modify: `lib/features/notes/presentation/note_editor_screen.dart`

**Interfaces:**
- `NotesController.undo() -> Future<bool>`
- `NotesController.canUndo -> bool`
- Internal `UndoEntry` stores operation type, note id, previous snapshot, and expiry.

- [ ] Capture previous note before save/update and delete.
- [ ] Replace prior entry on each mutation; expire after 5 seconds.
- [ ] Undo edit by restoring the previous snapshot; undo delete by saving the deleted snapshot.
- [ ] Show localized SnackBar feedback and keep route/context valid after navigation.
- [ ] Add tests for expiry, replacement, edit restore, delete restore, and missing-note safety.

### Task 5: Focus Inbox redesign and encoding cleanup

**Files:**
- Modify: `lib/app/app_theme.dart`
- Modify: `lib/app/smartnote_app.dart`
- Modify: `lib/features/notes/presentation/home_screen.dart`
- Modify: `library_screens.dart`, `note_widgets.dart`, `note_detail_screen.dart`, `note_editor_screen.dart`, `settings_screen.dart`

- [ ] Apply focused hierarchy: compact header, prominent search/list affordance, predictable cards, clear primary FAB, and consistent responsive navigation.
- [ ] Make light/dark surfaces, typography, spacing, focus/pressed states, and empty/error states consistent.
- [ ] Ensure settings communicates saved theme/language and sync status clearly.
- [ ] Replace mojibake strings with valid UTF-8 source and localized messages.
- [ ] Preserve existing note, image, search, favorite, and sync behavior.

### Task 6: Verification and release checks

- [ ] Run `flutter analyze`.
- [ ] Run `flutter test`.
- [ ] Run `flutter build apk --debug`.
- [ ] Exercise Vietnamese/English, system/light/dark restart, edit undo, delete undo, search, favorites, and offline fallback.
- [ ] Inspect `git diff` and report any remaining limitations instead of claiming completion.

