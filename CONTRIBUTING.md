# Contributing to GhostBuster

Thanks for helping improve GhostBuster. This guide describes how the project is
organized and the workflow we follow so changes stay reviewable and the
teammate-built UI is preserved.

## Project at a glance

GhostBuster is an offline-first Flutter app that simulates an incoming phone
call so a user can leave an awkward situation. It does **not** place a real
call. The repository has three parts:

| Path | What it is |
|---|---|
| `frontend-client/` | The Flutter app (the product). |
| `backend-tools/` | Local Python developer tools for preparing audio. Not a server. |
| `backend-server/` | An optional FastAPI + SQLite service. The app runs fully without it. |

See [`README.md`](README.md) and the [`docs/`](docs/) hub for details.

## Development setup

Follow [`docs/01-getting-started.md`](docs/01-getting-started.md). In short, from
`frontend-client/`:

```bash
flutter pub get
flutter run        # on an Android emulator or device
```

## Branching workflow

The integration branch is **`development`**; `main` is the stable branch. Work on
short-lived branches off `development`:

- `feature/<short-name>` for new work (e.g. `feature/voice-preview`)
- `fix/<short-name>` for bug fixes (e.g. `fix/ringtone-overlap`)
- `docs/<short-name>`, `ci/<short-name>`, `test/<short-name>` as appropriate

Keep each branch to one logical change. Do not rename or delete shared branches.

## Commit messages (Conventional Commits)

Use `type(scope): summary`. Valid scopes mirror the project structure: `mobile`,
`audio`, `recording`, `assets`, `state`, `l10n`, `docs`, `ci`, `test`,
`security`, `deps`.

Examples:

- `feat(mobile): add local voice recording`
- `fix(audio): stop ringtone before voice playback`
- `docs(readme): document Android setup`
- `test(state): cover countdown cancellation`
- `ci(github): verify Flutter tests and build`

## Required checks before a pull request

Run these from `frontend-client/` and make sure they pass:

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug   # when you touch native/Android or dependencies
```

Do not weaken checks to make them pass (no `--no-fatal-infos`, no disabling lint
rules, no deleting tests). If you change behavior, add or update tests.

## Pull requests

1. Push your branch and open a PR targeting `development`.
2. Fill in the PR template; reference any related issue (e.g. `Closes #12`).
3. Wait for CI (format, analyze, test, Android build, Python checks) to pass.
4. Request a teammate review, especially for changes to shared UI, localization
   ARBs, audio, assets, or platform configuration.
5. Resolve feedback and merge only after required checks pass and a reviewer
   approves.

## Protecting teammate work

- Review `git diff` before committing; don't sweep up unrelated changes.
- Resolve merge conflicts deliberately, file by file. Never blanket-accept one
  side.
- Preserve the existing visual design; redesign only to fix a concrete defect.

## Documentation-as-code

A change isn't finished until the docs it affects are updated in the same change
set. Use this table:

| Change | Documentation to update |
|---|---|
| Project features or user workflow | [`README.md`](README.md) and relevant feature doc |
| Flutter setup or dependencies | [`frontend-client/README.md`](frontend-client/README.md), [`docs/01-getting-started.md`](docs/01-getting-started.md), [`docs/03-tech-stack.md`](docs/03-tech-stack.md) |
| State transitions or audio behavior | [`docs/02-architecture.md`](docs/02-architecture.md), [`docs/08-state-machine-and-audio.md`](docs/08-state-machine-and-audio.md) |
| Voice recording or scenario behavior | [`docs/09-voice-recording-and-assets.md`](docs/09-voice-recording-and-assets.md), [`docs/07-security.md`](docs/07-security.md) |
| Python voice tools | [`backend-tools/README.md`](backend-tools/README.md), [`docs/09-voice-recording-and-assets.md`](docs/09-voice-recording-and-assets.md) |
| Localization | [`frontend-client/README.md`](frontend-client/README.md), [`docs/02-architecture.md`](docs/02-architecture.md) |
| CI workflow | [`docs/10-testing-and-ci.md`](docs/10-testing-and-ci.md) |
| Security or data handling | [`SECURITY.md`](SECURITY.md), [`docs/07-security.md`](docs/07-security.md) |
| Platform support or release process | [`docs/04-setup-and-deployment.md`](docs/04-setup-and-deployment.md), [`docs/11-platform-limitations.md`](docs/11-platform-limitations.md), [`docs/13-release-checklist.md`](docs/13-release-checklist.md) |
| Major milestone or plan status | [`docs/06-roadmap.md`](docs/06-roadmap.md) and the relevant phase report |

## Code of conduct and security

By contributing you agree to the [Code of Conduct](CODE_OF_CONDUCT.md). Report
security issues following [`SECURITY.md`](SECURITY.md) — do not open a public
issue for a vulnerability.
