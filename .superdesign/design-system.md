# SmartNote Design System

## Product context

SmartNote is a bilingual Vietnamese/English Android note and personal-task app.
It is offline-first with SQLite, optionally syncs to Supabase, and supports text
notes, checklists, tags, favorites, attached images, search, filtering, and
sorting. The primary users are students and young professionals who need a calm,
fast place to capture ideas and small tasks.

Key screens:

- Welcome/onboarding
- Home with recent notes, tag filters, and a daily inspiration card
- Search and advanced filters
- Favorites
- Note detail
- Create/edit note and checklist
- Settings for theme, language, and cloud sync

## Visual direction

Use a warm "digital paper desk" interpretation of Material Design 3. The app
must feel tactile and calm, not childish. Keep surfaces spacious, typography
highly legible, and interaction targets at least 48x48 logical pixels.

Primary style source: Softly Digital Wellness App.

### Color tokens — light

- Canvas: `#FDFCF8`
- Surface: `#FFFFFF`
- Surface variant: `#F6F2EA`
- Primary indigo: `#5A5791`
- Primary container lavender: `#EFEDF4`
- Secondary coral: `#E58F89`
- Secondary container peach: `#FFE2DE`
- Tertiary sage: `#DCE9DE`
- Text primary: `#292524`
- Text muted: `#78716C`
- Outline: `#D8D1C7`
- Error: `#BA1A1A`

### Color tokens — dark

- Canvas: `#1E1C1A`
- Surface: `#292624`
- Surface variant: `#34302D`
- Primary: `#C8C3F2`
- Primary container: `#403D70`
- Secondary: `#FFB7B2`
- Secondary container: `#6B3C3A`
- Tertiary: `#BFD8C3`
- Text primary: `#F2ECE5`
- Text muted: `#C9C0B7`
- Outline: `#746C65`
- Error: `#FFB4AB`

Tag colors are limited to lavender, peach, sage, pale yellow, and powder blue.
All text/tag combinations must meet WCAG AA contrast. Do not introduce neon,
gradients, glassmorphism, or unrelated colors.

## Typography

- Primary family: Outfit, with Roboto/system sans-serif fallback.
- Display/title: sentence case, weight 600–700, tight but readable tracking.
- Body: weight 400–500, 14–17sp, line height 1.35–1.5.
- Labels: 12–14sp, weight 500–600.
- Vietnamese diacritics must render cleanly at every size.
- Do not use cursive or decorative fonts inside the mobile application.

## Shape, spacing, and elevation

- Spacing scale: 4, 8, 12, 16, 20, 24, 32 logical pixels.
- Note cards: 20px radius; controls and chips: 12–18px radius.
- Primary floating action button: Material 3 large FAB with 20px radius.
- Shadows are soft and restrained: `0 4px 20px rgba(41,37,36,0.07)`.
- Use a very subtle paper grain only on large empty backgrounds; never over text.
- Cards may use at most one-degree visual tilt in decorative empty/onboarding
  compositions. Functional note grids remain aligned.

## Responsive layout

- Mobile (<600dp): NavigationBar, one-column list or two-column masonry-like
  grid where width permits, 16px page padding.
- Tablet (>=600dp): NavigationRail, 24px page padding, two-pane note
  list/detail when practical, two or three card columns.
- Editor content width is capped for readability on large screens.
- Respect system insets, text scaling, landscape, and keyboard visibility.

## Core components

- NoteCard: title, two-line preview or checklist progress, tag chips, optional
  image thumbnail, updated time, favorite affordance.
- TagChip: compact pastel container with selected outline/check.
- InspirationCard: lavender surface with quote, author, loading skeleton, error
  message, and retry action.
- EmptyState: simple line icon, friendly bilingual copy, single clear action.
- EditorToolbar: image, camera, checklist, tag, and color actions.
- SearchFilterSheet: note type, tag, favorite state, and sort order.
- SyncStatus: offline, syncing, synced, and failed states without blocking local
  editing.

## Motion

- Hero transition from NoteCard to note detail: 240–300ms.
- AnimatedSwitcher for loading, empty, data, and error states: 180–240ms.
- Checklist insert/remove: size + fade, 180ms.
- Favorite toggle: subtle scale 0.92→1.0, 160ms.
- Respect reduced-motion settings; motion must communicate state, not decorate.

## Screen requirements

### Home

Top app bar contains SmartNote wordmark, sync status, and profile/settings
entry. Greeting and daily inspiration appear above recent notes. A horizontal
tag row filters content. Note cards prioritize scanning and never hide the
create action. The FAB creates a new note.

### Search

Persistent search field at top, filter action, active-filter chips, clear empty
and no-results states. Results reuse NoteCard.

### Favorites

Uses the same card system and responsive layout as Home, with concise empty
guidance.

### Note detail

Readable content, image gallery, tags, checklist progress, favorite/edit/delete
actions. Delete requires confirmation and supports undo.

### Editor

Title then content/checklist area, autosave/saved status, and bottom toolbar.
Validation errors appear beside the affected field. Photo source selection is a
Material bottom sheet.

### Settings

Grouped Material list sections for language, theme, Supabase account/sync, data
status, and app information.

## Content and accessibility

- Initial visual content is Vietnamese with realistic student notes; the
  implementation also ships equivalent English strings.
- Never use lorem ipsum in generated screens.
- Icons require semantic labels; color is never the only status indicator.
- Support large text without clipping and maintain 48dp touch targets.
