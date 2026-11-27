# Defect log

Defects found while building and checking this project. Only issues that actually occurred are listed. IDs are in the order found.

| ID | Severity | Found | Defect | Root cause | Found by | Fix | Guard |
|---|---|---|---|---|---|---|---|
| D-01 | Medium | Profile preferences | Build error: the notifier method `update` collided with Riverpod 3's own `update` on the generated notifier. | Name clash with a framework member. | `flutter analyze` on the first full run | Renamed to `updatePreferences` | `flutter analyze` in CI; profile tab widget tests |
| D-02 | Low | Test assumption | Test for the 90-day wait looked for a calendar date that the screen does not show. | The test asserted behaviour the UI never had (the screen says how many days remain). | `flutter test` | Assertion changed to the real text | `request_flow_test` |
| D-03 | Low | Test assumption | Search test expected a donor 11 km away inside the default 10 km radius. | Wrong test data, not an app bug; the radius cut-off is exact by design. | `flutter test` | Test selects the 25 km radius first | `donor_search_flow_test`, `search_donors_test` (exact cut-off for several radii) |
| D-04 | Medium | Build environment | Debug APK build failed after the package rename: "this and base files have different roots" (Kotlin incremental cache across drives D: and C:). | Project and pub cache on different drives. | `flutter build apk --debug` | `kotlin.incremental=false` in `android/gradle.properties` | CI builds the release APK on every push |
| D-05 | High | Repository hygiene | About 8,000 `node_modules` files and the Firebase config were committed to Git. | Dependencies installed in `rules_test/` before a `.gitignore` entry existed. | Reviewing `git ls-files` | Untracked in PR #1, `.gitignore` entries added, `npm ci` with the lock file in CI | CI; `.gitignore` |

## Open issues and risks

| ID | Severity | Item |
|---|---|---|
| R-01 | Medium | No server-side limit on how many requests one account can post; the 3-request cap is enforced in the client and checked only by use-case tests. |
| R-02 | Medium | App Check is not enabled, so the public API key can be used by other clients, though Security Rules still apply. |
| R-03 | Low | Feed and directory results are capped at 50; a busy area can hide some donors. The app marks results as possibly incomplete in the directory. |
| R-04 | Low | A request write that times out may still reach the server later and create a duplicate. |

