# REST API, Postman và log

OpenAPI nằm tại `postman/specs/smartnote-api.openapi.yaml`.

| Method | Path | Mô tả |
|---|---|---|
| GET | `/health` | Trạng thái API |
| POST | `/v1/auth/guest` | Tạo/mở phiên Guest |
| POST | `/v1/auth/register` | Đăng ký và đăng nhập ngay |
| POST | `/v1/auth/login` | Đăng nhập |
| POST | `/v1/auth/logout` | Đăng xuất |
| GET | `/v1/auth/me` | Danh tính hiện tại |
| PUT | `/v1/auth/password` | Đổi mật khẩu |
| POST | `/v1/auth/claim-guest` | Gộp Guest vào tài khoản |
| GET | `/v1/notes` | Danh sách ghi chú/tombstone |
| GET | `/v1/notes/:id` | Một ghi chú |
| PUT | `/v1/notes/:id` | Upsert idempotent |
| DELETE | `/v1/notes/:id` | Soft-delete |
| GET | `/v1/quotes/random` | Quote ngẫu nhiên |

Endpoint ghi chú yêu cầu `Authorization: Bearer <token>`. Response thành công
có `data` và `meta.requestId`; lỗi có `error.code`, `error.message`,
`error.requestId`. Bản demo chỉ kiểm tra định dạng email, không xác minh quyền
sở hữu email. Mật khẩu dài 8–72 ký tự và được băm bằng PBKDF2-HMAC-SHA256.

```powershell
npm run postman:lint
npm run postman:test
npm run postman:push
```

Cloud workspace: `scara's Workspace`
(`127bdead-d8a5-48fd-81fd-41eff9c03ae8`). Collection Cloud ID:
`50368433-73918b79-021a-43f9-bb21-24444fa82349`. Lệnh push không dùng
`force-sync`. Không commit Postman API key.

Flutter log bằng tên `smartnote.api`; backend ghi JSON line. Cả hai chỉ ghi
method, path, status, duration, owner rút gọn và request ID; không ghi nội dung
ghi chú, PIN, mật khẩu hoặc token.
