# SmartNote Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use
> `superpowers:executing-plans` and `superpowers:test-driven-development`.

**Goal:** Build and package the SmartNote Android application and its APK
download page.

**Architecture:** Feature-first Flutter application. Riverpod presentation
controllers depend on repository interfaces; SQLite implements offline storage
and Supabase is an optional synchronization adapter. GoRouter owns navigation.

**Tech Stack:** Flutter, Riverpod, GoRouter, sqflite, Supabase Flutter,
image_picker, HTTP, SharedPreferences, Flutter localization, Vercel.

## Global Constraints

- Android application ID is `vn.edu.smartnote`; minimum Android SDK is 24.
- Every hand-written behavior starts with a failing test.
- SQLite is always available; Supabase configuration is optional.
- UI follows `.superdesign/design-system.md`.
- Vietnamese is the default language and English is available in Settings.

---

### Task 1: Domain model and validation

- [ ] Add failing tests for note validation, checklist progress, filtering, and
  sorting.
- [ ] Implement immutable note/tag/checklist/filter models and validators.
- [ ] Run focused tests and commit.

### Task 2: SQLite repository and optional Supabase sync

- [ ] Add failing repository contract tests using an in-memory database.
- [ ] Implement schema and transactional CRUD for notes, tags, checklist items,
  and image paths.
- [ ] Add failing tests for sync payloads and local-only fallback.
- [ ] Implement Supabase initialization from dart-defines and an outbox-style
  sync service.
- [ ] Run repository tests and commit.

### Task 3: Application state, routing, settings, and REST quote

- [ ] Add failing controller tests for CRUD, search/filter, quote loading/error,
  locale, theme, and sync status.
- [ ] Implement Riverpod providers/controllers, GoRouter routes,
  SharedPreferences settings, and DummyJSON quote repository.
- [ ] Run controller tests and commit.

### Task 4: Material 3 user interface

- [ ] Add failing widget tests for Home, Editor validation, Search, Favorites,
  Detail, Settings, responsive navigation, and localization.
- [ ] Implement the approved warm-paper theme and all seven routes.
- [ ] Integrate camera/gallery with recoverable lost-data handling.
- [ ] Run widget tests and commit.

### Task 5: Packaging and Vercel distribution

- [ ] Add runtime configuration documentation and Supabase SQL migration.
- [ ] Run formatter, analyzer, unit/widget tests, and build the APK.
- [ ] Create a responsive static download page and verify its links.
- [ ] Upload the APK to public Vercel Blob and deploy the page to Vercel.
- [ ] Record production URL, APK location, and verification evidence.
