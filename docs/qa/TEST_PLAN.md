# Test plan: Blood Donor ISB

| | |
|---|---|
| **Product** | Blood Donor ISB, Android, Flutter and Firebase |
| **Author** | Taha Butt |
| **Scope of this plan** | Blood-request loop, donor search, donor profile, authentication, Firestore security rules |

## 1. Goals

1. A requester can post a request and a compatible donor can answer it.
2. A donor's phone number is visible only to the donor and to the requester of the request they chose to help, and only after they confirm.
3. A bad network call or bad data in one screen never crashes the app. Every screen shows a loading, empty or error state.
4. Security rules enforce the privacy promise even if the app is bypassed.

## 2. In scope and out of scope

**In scope**: sign-up and email verification, profile and eligibility, privacy switches, posting, listing, responding, withdrawing, fulfilling and cancelling requests, donor search, error handling and offline behaviour, Firestore rules, Android only.

**Out of scope**: push notifications (not built), payments, iOS and web, performance and load testing, accessibility audit with assistive technology, penetration testing.

## 3. Approach: risk-based, in layers

| Layer | What it checks | Tool | Where |
|---|---|---|---|
| Unit | Use-case rules (validation, expiry, 3-open-request cap, compatibility, eligibility, distance sorting), mappers on corrupt data, geohash maths | `flutter_test` | `test/**/domain`, `test/core` |
| Data contract | The Firestore data source and the in-memory data source behave identically (filters, limits, ordering, failures) | `flutter_test` with `fake_cloud_firestore` | `test/**/data` |
| Widget and flow | Whole-app journeys on in-memory data: post, respond, withdraw, fulfil, search, sign-out mid-flow, error and Try again states | `flutter_test` | `test/**/presentation` |
| Security rules | Who may read, write and delete each document and query | Firebase Emulator and `@firebase/rules-unit-testing` | `rules_test/` |
| Static analysis | Lint and type errors | `flutter analyze` | CI |
| Manual | Real device, real Firebase, two accounts | [Test cases](TEST_CASES.md) | `docs/qa/` |

**Highest risks, tested most deeply**
1. Phone number exposure (rules tests, response and directory tests, manual cases TC-PRV-*).
2. Wrong blood-group matching (64 donor and recipient pairs checked against an independent antigen model).
3. A donor offering help too early (90-day interval) or to their own request.
4. Slow or failed network: every call has a timeout and a typed failure.
5. Backend data that is malformed: unreadable documents are skipped and reported, not crashed on.

## 4. Test environments

- Automated: GitHub Actions on Ubuntu, Flutter 3.38.x, Node 24, JDK 21 (Firestore emulator).
- Manual: a physical Android phone, debug build, Firebase project on the Spark plan, two test accounts.

## 5. Entry and exit criteria

**Entry**: `flutter analyze` reports no issues and `flutter test` passes.

**Exit (ready to demo)**: all CI jobs green; every manual case with priority P1 passed on a real device; no open defect with severity Critical or High; all open defects listed in the [defect log](DEFECT_LOG.md).

## 6. Test data

Fictional names and numbers only (for example "Test Donor A", `+92300 0000001`). Never use real people's data in tests, screenshots or demos.

## 7. Defect handling

Severity: **Critical** (data exposure, crash on launch, data loss), **High** (core flow blocked), **Medium** (feature wrong, workaround exists), **Low** (cosmetic). Each defect is logged with root cause, fix and the test that now guards it. See [DEFECT_LOG.md](DEFECT_LOG.md).

## 8. Known gaps (honest list)

- No automated test runs on a real device or emulator UI (widget tests use a simulated app).
- Coverage percentage has not been measured as a gate. Run `flutter test --coverage` for the number.
- Rules and indexes are tested against the emulator; behaviour on production Firestore is checked manually.
- App Check and server-side rate limiting do not exist, so abuse of the public API is not mitigated.
