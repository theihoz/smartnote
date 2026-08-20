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
3. Sau frame đầu, app đẩy outbox rồi kéo dữ liệu API.
4. Với cùng ID, `updatedAt` UTC mới hơn thắng; xóa dùng tombstone.
5. Thành công mới xóa outbox và cập nhật `sync_state`; lỗi được giữ để thử lại.

Thiếu `API_BASE_URL` hoặc mất mạng không làm mất khả năng CRUD local.

## Backend

Backend là một process Express dùng SQLite WAL. Khóa `(device_id, note_id)`
tách dữ liệu giữa thiết bị. Thiết kế phù hợp khoảng 100 người dùng trên một
instance có persistent disk; không chạy nhiều instance cùng ghi một file.
