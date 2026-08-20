# Kiến trúc SmartNote

## Flutter

Mỗi feature chia theo bốn vai trò: `presentation` hiển thị UI, `application`
điều phối use case, `domain` chứa model/interface không phụ thuộc framework và
`data` chứa adapter SQLite/REST.

`NoteRepository` là seam của ghi chú. SQLite lưu cache local; REST adapter
chuyển payload giữa sync domain và HTTP camelCase.

## Luồng đồng bộ

1. App hiển thị cache SQLite ngay.
2. CRUD ghi SQLite trước và thêm `sync_outbox`.
3. Khi có phiên hợp lệ, app đẩy outbox rồi kéo dữ liệu API.
4. Với cùng ID, `updatedAt` UTC mới hơn thắng; xóa dùng tombstone.
5. Thành công mới xóa outbox và cập nhật `sync_state`; lỗi được giữ để thử lại.

Mỗi profile dùng file SQLite riêng. Đăng xuất khóa cache tài khoản; mất mạng
không làm mất khả năng CRUD local. Khi Guest đăng nhập, outbox được đẩy trước,
API gộp dữ liệu theo `updatedAt`, rồi app tải cache tài khoản.

## Backend

Backend là một process Express dùng SQLite WAL. `principals` thống nhất Guest
và tài khoản; ghi chú khóa theo `(owner_id, note_id)`. Session dùng Bearer token,
mật khẩu dùng PBKDF2-HMAC-SHA256. Bản demo chỉ kiểm tra định dạng email và cấp
phiên ngay sau khi đăng ký.
Thiết kế phù hợp khoảng 100 người dùng trên một instance.
