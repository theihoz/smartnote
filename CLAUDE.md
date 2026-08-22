# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

Flutter app:

```bash
flutter pub get
flutter analyze                       # must stay at "No issues found!"
flutter test
flutter test test/features/sync/outbox_sync_service_test.dart   # single file
flutter test --plain-name "restores the deleted note"           # single test
flutter run                                  # offline-only, on-device SQLite
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8787     # against Docker API from an emulator
flutter build apk --release
```

Express API (npm scripts in [package.json](package.json)):

```bash
npm run api:start                     # node api/src/server.js, port 8787 (PORT env)
npm run api:test                      # node --test api/test/*.test.js
node --test api/test/auth.test.js     # single API test file
npm run docker:up                     # docker compose up --build -d --wait
npm run docker:test                   # compose up + Postman collection run
npm run postman:lint                  # lint postman/specs/smartnote-api.openapi.yaml
```

Regenerate localizations after editing `lib/l10n/*.arb`: `flutter gen-l10n` (config in
[l10n.yaml](l10n.yaml); `app_vi.arb` is the template, so every key must exist there first).

## Architecture

Each feature under [lib/features/](lib/features/) splits into four roles —
`presentation` (widgets) → `application` (controllers) → `domain` (models +
abstract repositories, no Flutter/HTTP imports) ← `data` (SQLite / REST
adapters). Add new code in the matching layer rather than at the feature root.

**`main.dart` is the composition root, not `providers.dart`.**
[lib/app/providers.dart](lib/app/providers.dart) declares providers that
deliberately throw (`noteRepositoryProvider`) or return `null`
(`pinLockServiceProvider`, `reminderRepositoryProvider`, …).
[lib/app/smartnote_app.dart](lib/app/smartnote_app.dart) overrides them from
constructor arguments, and [lib/main.dart](lib/main.dart) supplies the real
implementations. Consequence: widget tests construct `SmartNoteApp(...)` with
fakes and never touch a real database, and a feature that reads a `null`
provider must degrade gracefully instead of asserting.

**`API_BASE_URL` is a compile-time switch, not runtime config.**
`ApiConfig.fromEnvironment()` reads `String.fromEnvironment('API_BASE_URL')`
([api_config.dart](lib/features/sync/data/api_config.dart)). Absent → auth runs
through `LocalAuthGateway` on a local SQLite database and nothing syncs;
present → `AuthApiClient` + `RestCloudNoteStore` talk to the Express API.
Both paths must keep working; changing the URL requires a rebuild.

**Per-profile databases.** `openSmartNoteProfileDatabase(profileKey)` opens a
separate SQLite file per profile, where the key is the account `profileId` or
`guest:<deviceId>`. `_switchSession` in `main.dart` pushes the outbox for the
old session, calls `claimGuest` when a guest signs into an account, opens the
new profile database, then closes the old one. Schema version is 5 with
`onUpgrade` migrations in
[smartnote_database.dart](lib/features/notes/data/smartnote_database.dart) —
adding a column means bumping the version and adding a migration step.

**Offline-first sync.** Writes hit SQLite and append to `sync_outbox` first.
`OutboxSyncService.syncPending()` pushes the outbox then pulls; conflicts
resolve by newer UTC `updatedAt`, deletes use tombstones, and outbox rows are
only removed on success so failures retry. `ResumeSyncCoordinator` re-runs it on
app resume.

**Backend.** [api/src/app.js](api/src/app.js) is a single-file Express 5 app
over SQLite WAL (`createApp({databasePath, log})` is exported so tests can point
at a temp file). `principals` unifies guests and accounts; notes are keyed by
`(owner_id, note_id)`. Bearer sessions store only a token hash; passwords use
PBKDF2-HMAC-SHA256. Responses are always `{data, meta.requestId}` or
`{error: {code, message, requestId}}`. Docker Compose mounts `api/data` on
tmpfs, so server-side data is wiped when the container is recreated.

## Conventions

- Two locales, `vi` (default) and `en`. Reusable strings go in the ARB files and
  are read via `AppLocalizations.of(context)`; one-off feature strings use
  `featureText(context, vi: '…', en: '…')`
  ([feature_text.dart](lib/l10n/feature_text.dart)). Do not leave a
  user-visible string hardcoded in either language.
- Widget tests find elements through inline `Key('save-reminder-button')` /
  `Key('search-filter-button')` style keys — keep them stable when refactoring.
  [lib/app/app_keys.dart](lib/app/app_keys.dart) holds only the global
  `scaffoldMessengerKey`, used to show snackbars from outside a widget context.
- Repository tests use `sqflite_common_ffi`: `setUpAll(sqfliteFfiInit)` and pass
  `factory: databaseFactoryFfi` plus an in-memory path to the `open*Database`
  helpers.
- Release APKs are signed with the debug key
  ([android/app/build.gradle.kts](android/app/build.gradle.kts)) — demo only,
  not publishable to Google Play.
- Repo language is Vietnamese: README, `docs/`, seed data and user-facing error
  strings are written in Vietnamese; commit messages are English Conventional
  Commits.
