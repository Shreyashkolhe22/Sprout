# Sprout

A playful habit tracker built with Flutter. Add the habits you really want to
keep, tick them off each day, and watch real streaks build. Pip, a friendly
ghost, reacts to how your day is going.

## Run

```bash
flutter pub get
flutter run
flutter test
flutter analyze
```

## What's real

- **No sample data.** A new user starts with an empty app.
- **Saved on the device** (`shared_preferences`), one habit list per user name.
  Logging out keeps it; logging back in with the same name restores it.
- **Streaks are computed from the days you actually ticked.** A streak stays
  alive until the end of today and resets after a missed day.
- **Can't fake history.** Future days can't be ticked, and days before a habit
  was created don't count as missed.
- **"Today" follows the clock**, including when the app is left open past
  midnight.

## Notes

A Notes tab for writing, reading and editing notes, with image and PDF
attachments.

- New notes open in edit mode; saved notes open in read mode with Edit and
  Delete. Leaving with unsaved edits asks before discarding.
- Attach with the paperclip: images from the photo picker, PDFs from the
  system file picker. Each file is **copied into app-private storage** per user
  (max 15 MB), so notes keep working if the original is moved or deleted.
- Images open full-screen with pinch-to-zoom. PDFs open in an in-app viewer
  (`pdfx`) with a page counter.
- Search covers titles, text and attachment names.
- Notes and attachments are saved per user name, like habits. Deleting a
  note deletes its files.
- Attachments need real files, so they are Android/iOS only (the web build
  shows a friendly "not supported" message).

## Building on Android

`android/gradle.properties` makes Gradle's downloads more tolerant (TLS 1.2,
longer timeouts, more retries). Some networks drop the TLS handshake to
`dl.google.com` intermittently, which showed up as
"Remote host terminated the handshake" when plugins were first added.

## Release signing

The app ID is `in.shreyashkole.sprout` and release builds are signed with the
Sprout release keystore:

| File | Purpose |
|---|---|
| `android/app/sprout-release.jks` | the signing key (alias `sprout`) |
| `android/key.properties` | keystore path + passwords read by Gradle |

Both are git-ignored. **Back them up somewhere safe (outside this folder).**
If the keystore or its password is lost, existing users can no longer receive
updates: Android only installs an update signed with the same key.

```bash
flutter build apk --release        # -> build/app/outputs/flutter-apk/app-release.apk
```

A release build refuses to run without `android/key.properties`, so it can
never be silently signed with the debug key. Debug builds (`flutter run`) are
unaffected.

Check who signed an APK:

```bash
apksigner verify --print-certs app-release.apk   # expect: CN=Sprout
```

Before each new release, raise `version:` in `pubspec.yaml` (for example
`1.0.1+2`). The number after `+` must go up every time.

## Project structure

Feature-first, with layers inside each feature. No state-management package:
a `ChangeNotifier` controller plus `ListenableBuilder`.

```
lib/
  main.dart                      entry point (wires real storage)
  app.dart                       MaterialApp, login/logout root
  core/
    constants/app_assets.dart    illustration catalogue (asset + aspect)
    theme/                       colours, text, decorations, ThemeData
    utils/dates.dart             date helpers
    widgets/                     chunky button, progress ring, illustration card
  features/
    auth/data/                   SessionRepository (who is signed in)
    onboarding/presentation/     4 intro pages + name capture
    habits/
      domain/                    Habit entity (streaks, JSON), icon catalogue
      data/                      HabitRepository interface, in-memory + prefs impls
      application/               HabitController (state + commands)
      presentation/              HomeShell, Today & Stats, profile/new-habit sheets
    notes/
      domain/                    Note, Attachment (immutable, JSON)
      data/                      NoteRepository, AttachmentStorage, AttachmentPicker
      application/               NotesController (CRUD, search, delete files)
      presentation/              NotesView, NoteScreen, image/PDF viewers
    focus/presentation/          countdown timer screen
assets/
  images/                        bundled artwork (logo tile, Pip illustrations)
  source/                        original sheets (NOT bundled in the app)
test/                            unit, storage and widget-flow tests
```

## Artwork

`assets/source/grid.png` is the original 7-illustration sheet and
`assets/source/logo.png` the original logo. The bundled tiles in
`assets/images/ghosts/` were cropped from the sheet with transparent rounded
corners. Add new pictures to `AppAssets` with their width/height ratio.

## Native branding

App name, launcher icons (all Android densities), the Android splash and the
web icons/manifest all use the Sprout logo. iOS/desktop platforms aren't
present in this project.
