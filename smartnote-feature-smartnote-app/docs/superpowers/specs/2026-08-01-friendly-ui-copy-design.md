# SmartNote Friendly UI Copy Design

**Date:** 2026-08-01

## Goal

Make every user-facing label in SmartNote feel close, natural, and easy to
understand. Technical implementation terms should not be the primary wording
shown to users. This change affects copy only; navigation, layout, behavior,
and data models remain unchanged.

## Voice and tone

- Use familiar Vietnamese words and short active sentences.
- Tell the user what an action does instead of naming the technology behind it.
- Keep errors calm and helpful, with a clear next action where possible.
- Avoid jargon such as `CRUD`, `SQLite`, `tag`, and `checklist` in primary UI.
- Product and service names may appear as secondary technical information.
- Keep English mode natural and prevent mixed Vietnamese-English screens.

## Terminology

| Current wording | New Vietnamese wording | English equivalent |
| --- | --- | --- |
| Checklist | Danh sách việc | Task list |
| Tag | Nhãn | Label |
| Thêm tag | Thêm nhãn | Add label |
| Thêm mục | Thêm việc | Add task |
| Nội dung việc | Việc cần làm | What needs doing? |
| SQLite cục bộ | Lưu trên thiết bị | Saved on this device |
| Dữ liệu và đồng bộ | Lưu trữ và đồng bộ | Storage and sync |
| Supabase | Đồng bộ đám mây | Cloud sync |
| Tự động lưu cục bộ | Tự động lưu trên thiết bị | Saved automatically on this device |
| CRUD ghi chú, tag, checklist và đường dẫn ảnh | Ghi chú và ảnh được lưu an toàn trên điện thoại | Notes and photos are stored safely on your phone |

The service name `Supabase` may remain in the secondary status text beneath
`Đồng bộ đám mây` so developers and advanced users can still identify the
configured provider.

## Screen copy

### Home

- Loading quote: `Đang tìm một chút cảm hứng...`
- Quote failure: `Chưa tải được câu nói. Thử lại nhé.`
- Empty title: `Bạn chưa có ghi chú nào`
- Empty guidance: `Nhấn nút + để ghi lại ý tưởng đầu tiên.`

### Search and favorites

- Search hint: `Tìm theo tiêu đề hoặc nội dung...`
- No search result: `Không tìm thấy ghi chú phù hợp.`
- Empty favorites copy should explain how to favorite a note rather than only
  state that the list is empty.

### Editor

- Note types: `Ghi chú` and `Danh sách việc`.
- Body hint: `Viết điều bạn đang nghĩ...`
- Image count: use natural Vietnamese, such as `Đã thêm 2 ảnh`.
- Camera tooltip: `Chụp ảnh`; gallery tooltip: `Chọn ảnh`.
- Label tooltip: `Thêm nhãn`; color tooltip: `Chọn màu`.
- Local save message: `Tự động lưu trên thiết bị`.

### Detail and destructive actions

- Keep actions short: `Yêu thích`, `Chia sẻ`, and `Xóa ghi chú`.
- Delete confirmation: `Bạn muốn xóa ghi chú này?`
- Supporting message: `Bạn vẫn có thể hoàn tác ngay sau khi xóa.`
- Success message: `Đã xóa ghi chú`; recovery action: `Hoàn tác`.

### Settings

- Section: `Lưu trữ và đồng bộ`.
- Primary cloud label: `Đồng bộ đám mây`.
- Cloud status explains whether sync is ready, unavailable, or needs setup
  without exposing configuration variable names.
- Local storage title: `Lưu trên thiết bị`.
- Local storage description: `Ghi chú và ảnh được lưu an toàn trên điện thoại`.

## Localization approach

The existing session-level language switch remains in place. User-facing copy
changed by this work must have both Vietnamese and English variants. This scope
does not introduce ARB generation or a new localization dependency; it keeps
the current lightweight approach and removes mixed-language labels from the
screens touched by the copy audit.

## Testing

- Add widget expectations for the most important Vietnamese labels.
- Verify switching to English replaces those labels with natural English.
- Keep navigation and interaction tests intact to prove the copy-only change
  does not alter behavior.
- Run `flutter analyze` and the complete `flutter test` suite before commit.

## Out of scope

- Layout, colors, typography, navigation, and animations.
- New features or changes to note storage and synchronization behavior.
- A full generated localization/ARB system.
