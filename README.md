# Excelerate Connect

A cross-platform Flutter app that helps **learners** discover and register for
Excelerate programs/events and gives **admins** a channel to publish
announcements and collect feedback.

## Project Vision

Excelerate runs many programs, workshops, and events, but learners often miss
announcements and admins have no simple way to gauge engagement. Excelerate
Connect closes that gap with a single mobile app where learners can browse
programs, register in a tap, and leave feedback afterward — giving admins a
lightweight feedback loop to improve future sessions.

## Objectives

- Give learners one place to see upcoming programs and announcements.
- Make registering for a program a two-tap action (view details → register).
- Collect structured feedback (star rating + comment) right after a program.
- Keep the codebase simple enough for a small team to extend weekly
  (new screens/features are added as isolated widgets under `lib/screens`).

## Target Users

| User    | Goals                                                              |
|---------|---------------------------------------------------------------------|
| Learner | Browse programs, register for events, view announcements, give feedback |
| Admin   | Publish announcements, track participation, review feedback (Week 2+)   |

## Core Features (Week 1 scope)

- **Login & Profile** — email/password form with validation (`login_screen.dart`)
- **Home Dashboard** — announcements + upcoming program preview (`home_screen.dart`)
- **Program Listing** — search + category filter over all programs (`program_listing_screen.dart`)
- **Program Details** — full info, one-tap registration, star-rating feedback form (`program_details_screen.dart`)

## Navigation Flow

```
Login
  └──▶ Home
         ├──▶ Program Listing ──▶ Program Details ──▶ (Feedback Form)
         └──▶ Program Details (from Home preview) ──▶ (Feedback Form)
```

Every screen below Home is reachable from the bottom navigation bar or a
back arrow, so there are no dead ends.

## Project Structure

```
lib/
  main.dart                        # App entry point, theme, route table
  models/
    program.dart                   # Program model + in-memory repository
  screens/
    login_screen.dart              # Screen 1 — Login
    home_screen.dart               # Screen 2 — Home Dashboard
    program_listing_screen.dart    # Screen 3 — Program Listing
    program_details_screen.dart    # Screen 4 — Program Details / Feedback
  widgets/                         # (reserved for shared components)
android/  ios/                     # Platform-specific project folders
pubspec.yaml                       # Dependencies, metadata
```

## Getting Started

```bash
flutter pub get
flutter run
```

Requires Flutter SDK `>=3.3.0`. No backend is wired up yet — `ProgramRepository`
in `lib/models/program.dart` uses in-memory mock data and is the intended
integration point for a real API/Firebase backend in a later sprint.

## Roadmap (beyond Week 1)

- Admin console (create/edit programs, view feedback analytics)
- Real authentication + persistent storage
- Push notifications for announcements
