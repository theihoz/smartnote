# SmartNote Design Specification

SmartNote is a Vietnamese/English Android note and personal-task application.
It uses Material Design 3, the approved warm-paper Superdesign direction,
SQLite for reliable offline CRUD, and Supabase for optional per-user cloud
sync. A small Vercel landing page distributes the generated APK.

The application contains Home, Search, Favorites, Note Detail, Note Editor,
Settings, and onboarding routes. Notes support text, checklists, tags, colors,
favorites, and images selected from the camera or gallery. Home also displays a
public REST quote with explicit loading, error, and retry states.

SQLite remains the local source of truth required by the assignment. Cloud
operations are queued after local writes and use last-write-wins timestamps.
Missing Supabase configuration must never prevent local use. Supabase URL and
publishable key are supplied with `--dart-define`.

The approved visual baseline is the Superdesign "Compact Student Productivity
Dashboard": cream canvas, indigo primary, coral/sage/lavender accents, rounded
20dp cards, restrained shadows, mobile NavigationBar, and tablet
NavigationRail. The UI ships with light/dark themes and Vietnamese/English
localization.

Acceptance requires analyzer success, unit/widget tests, an installable Android
APK, and a Vercel download page whose button targets the uploaded APK.
