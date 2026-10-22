# GhostBuster — Phase 10: GitHub Actions CI and Team Workflow

Date: 2026-10-22 · Branch: `development` · Only `.github/workflows/flutter-ci.yml` changed · Nothing committed or pushed.

## Summary

A CI workflow already existed at `.github/workflows/flutter-ci.yml`, so it was **repaired, not replaced**. The previous version had real gaps: no manual trigger, no format check, no Android build, a weakened `flutter analyze --no-fatal-infos`, and no permissions or concurrency controls. The repaired workflow runs the full required check sequence, keeps the existing Python job, and was validated by parsing the YAML and running every check locally against the current code.

CI itself was **not executed** from this environment: pushing to a branch or opening a PR is required, and I have not been asked to push. Section "How to run CI" explains how to trigger it. I have not invented a run status or URL.

## Repository facts (inspected)

- Remote: `git@github.com:donaldycottonacao/GhostBuster.git`. Default branch on origin: **`main`**.
- Branches present (local + origin): `main`, `development`, `develop`. Active work lands on `development` (latest commit `8ff87f4`).
- Flutter app lives in `frontend-client/`; Python tools in `backend-tools/`; a `backend-server/` also exists.
- `frontend-client/pubspec.yaml` pins only the Dart SDK (`>=3.0.0 <4.0.0`); it does **not** pin an exact Flutter version. The verified toolchain is **Flutter 3.47.7 / Dart 3.13.5**.
- `frontend-client/pubspec.lock` is tracked (so CI resolves the same dependency versions, including `record` 7.1.2 → `record_linux` → `jni`).
- `.env` files (`backend-tools/.env`, `backend-server/.env`) are git-ignored; no secrets are referenced by the workflow.
- Working tree was clean before this phase apart from the new workflow edit.

## Workflow configuration

File: `.github/workflows/flutter-ci.yml` (one workflow, three jobs).

**Triggers**
- `push` to `main, master, development, develop`
- `pull_request` targeting those branches
- `workflow_dispatch` (manual)

`master`/`develop` are included defensively; the repo currently uses `main` and `development`. Extra branch names are harmless.

**Top-level safety**
- `permissions: contents: read` — least privilege; CI only reads the repo.
- `concurrency` with `cancel-in-progress: true` — a newer run on the same ref cancels the older one, saving runner minutes.
- `FLUTTER_VERSION: 3.47.7` in `env`, used by both Flutter jobs.

**Flutter SDK version and rationale.** Pinned to **3.47.7** because that is the exact version used to develop and verify the project locally (Phases 2–9 and the voice feature). A floating `channel: stable` would silently track new Flutter releases and could break the build without a code change; an explicit pin keeps CI reproducible. `pubspec.yaml` has no exact `flutter:` line, so `flutter-version-file` could not be used; the version is pinned directly instead.

**Action versions (pinned to releases):**
- `actions/checkout@v4`
- `subosito/flutter-action@v2.23.0` (latest release at time of writing; was a floating `@v2`)
- `actions/setup-java@v4` (Temurin 17, for the Gradle/Android build)
- `actions/setup-python@v5`

### Job 1 — `flutter-verify` (format, analyze, test)
Runs from `frontend-client/`:
1. Checkout
2. Set up Flutter 3.47.7 (`cache: true`)
3. `flutter --version` (shows Flutter and Dart versions)
4. `flutter pub get`
5. `dart format --output=none --set-exit-if-changed lib test`
6. `flutter analyze` (no `--no-fatal-infos`; infos now fail the job as the prompt requires)
7. `flutter test`

### Job 2 — `android-build` (debug APK)
`needs: flutter-verify`, so the APK is built only after the code checks pass. Runs from `frontend-client/`: checkout → set up Java 17 → set up Flutter → `flutter pub get` → `flutter build apk --debug`. The APK is not signed and not uploaded (no artifact upload, to avoid publishing build output).

Splitting the build into its own job means an infrastructure/native-build failure is distinguishable from a code failure, and both still gate a PR.

### Job 3 — `python-verify` (backend-tools)
Runs from `backend-tools/`: checkout → Python 3.11 → `pip install -r requirements.txt` (currently installs nothing; the file declares no third-party packages) → `python -m compileall scripts tests` → `python -m unittest discover -s tests -v`.

Change from the old workflow: it ran only `test_cli.py`; it now runs the whole `tests/` suite, which includes `test_tools.py`. The optional real-SAPI test is Windows-only and skips itself on the Linux runner.

## Working directory

Every Flutter command runs in `frontend-client/` and every Python command in `backend-tools/`, both via `defaults.run.working-directory`. No step runs Flutter from the repo root.

## Local verification results

Run from `frontend-client/` (and `backend-tools/` for Python), reproducing each CI step:

| Check | Command | Result |
|---|---|---|
| Dependencies | `flutter pub get` | PASS |
| Formatting | `dart format --output=none --set-exit-if-changed lib test` | PASS (42 files, 0 changed) |
| Analysis | `flutter analyze` | PASS (no issues) |
| Tests | `flutter test` | PASS (206/206) |
| Android build | `flutter build apk --debug` | PASS (`build/app/outputs/flutter-apk/app-debug.apk`) |
| Python compile | `python -m compileall scripts tests` | PASS |
| Python tests | `python -m unittest discover -s tests` | PASS (43 tests, 1 skipped) |

YAML was validated by parsing it with PyYAML: three jobs (`flutter-verify`, `android-build`, `python-verify`), triggers `push`/`pull_request`/`workflow_dispatch`, steps in the order above, no tab characters.

**CI caveat (honest):** the Android build needs a working Android NDK because `record` 7.x pulls `record_linux` → `jni`, which compiles native code via CMake/NDK. Locally this required repairing an incomplete NDK (see the voice-feature work). On the `ubuntu-latest` runner the Android SDK normally provisions the NDK automatically, but this exact build has not yet run on a GitHub runner, so the `android-build` job is the most likely to need a follow-up fix (for example pinning `ndkVersion` in `android/app/build.gradle`). It is included as required; if it fails on the first run, that is an infrastructure fix, not a code regression — `flutter-verify` and `python-verify` will still show the code is sound.

## How to run CI

CI cannot be triggered from this local environment; it runs on GitHub. To test it on an approved branch (nothing below is done without your go-ahead):

```powershell
# from the repo root, with the workflow change staged
git checkout -b ci/phase-10-github-actions
git add .github/workflows/flutter-ci.yml docs/phase-10-github-actions-ci.md
git commit -m "ci: run format, analyze, test and debug build on PRs"
git push -u origin ci/phase-10-github-actions
# then open a PR targeting development on GitHub
```

The push and the PR both trigger the workflow. Watch it under the repo's **Actions** tab, or open the PR's **Checks**. `workflow_dispatch` also lets you run it manually from the Actions tab once the workflow is on a branch GitHub can see.

## Team branch and review workflow

1. Update the integration branch: `git switch development && git pull`.
2. Branch per change: `git switch -c feature/<short-name>` (or `fix/<short-name>`).
3. One logical change per branch.
4. Before pushing, run locally from `frontend-client/`: `flutter pub get`, `dart format --output=none --set-exit-if-changed lib test`, `flutter analyze`, `flutter test`, and `flutter build apk --debug` when native/Android code is affected.
5. Review `git diff` for accidental changes to shared UI, localization ARBs, assets, or platform config.
6. Push the branch and open a PR targeting `development`.
7. Wait for CI; request a teammate review, especially for shared UI, localization, assets, and platform files.
8. Resolve feedback; merge only after required checks pass. Keep `development` as the integration branch and periodically merge it to `main` for releases.

Do not commit `.env`, secrets, personal voice recordings, model weights, or build output.

## Required status checks (recommendation — apply only after a green run)

Once the workflow has passed at least once on a branch, consider requiring these checks before merging to `development` (and `main`) in **Settings → Branches → Branch protection**:
- `Flutter format, analyze, test`
- `Android debug build`
- `Python backend-tools check`

I have **not** changed branch protection or merge settings; that needs your approval and the GitHub UI.

## Remaining issues and limitations

1. **CI has not run on GitHub yet** — needs a branch push / PR (see above).
2. **`android-build` is the fragile step** — native NDK build; may need an `ndkVersion` pin after the first runner attempt.
3. **A Gradle warning** ("applies the Kotlin Gradle Plugin…") appears on every build. It is non-fatal today but Flutter recommends migrating to built-in Kotlin eventually; out of scope here.
4. **No iOS or web job** — iOS needs macOS runners (extra cost/time) and the project targets Android; add later if those platforms become required.
5. **No caching beyond the Flutter SDK cache** — deliberately minimal until the basic workflow is proven green.

Phase 11 has not been started.
