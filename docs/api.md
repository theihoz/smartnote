# REST API, Postman và log

OpenAPI nằm tại `postman/specs/smartnote-api.openapi.yaml`.

| Method | Path | Mô tả |
|---|---|---|
| GET | `/health` | Trạng thái API |
| GET | `/v1/notes` | Danh sách ghi chú/tombstone |
| GET | `/v1/notes/:id` | Một ghi chú |
| PUT | `/v1/notes/:id` | Upsert idempotent |
| DELETE | `/v1/notes/:id` | Soft-delete |
| GET | `/v1/quotes/random` | Quote ngẫu nhiên |

Endpoint ghi chú yêu cầu `X-Device-Id` là UUID. Response thành công có `data`
và `meta.requestId`; lỗi có `error.code`, `error.message`, `error.requestId`.

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
method, path, status, duration và request ID, không ghi nội dung ghi chú/PIN.
