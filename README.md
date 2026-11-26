# Blood Donation App

A Flutter application for coordinating blood requests and helping donors and people in need of blood connect. The Android app uses Firebase Authentication and Cloud Firestore, with Riverpod for state management.

![Blood Donation App icon](assets/icon/app_icon.png)

## Features

- Sign in and account flows, including email verification.
- Create, browse, respond to, manage, and close blood requests.
- Maintain a donor profile with blood group and donation-related details.
- Search the donor directory.
- Surface loading, empty, and error states explicitly, with unexpected errors reported through Firebase Crashlytics.

## Technology

- Flutter and Dart
- Riverpod for application state and dependency wiring
- Firebase Authentication and Cloud Firestore
- Firebase Crashlytics
- Firestore Security Rules, tested with the Firebase Emulator Suite

## Project structure

```text
lib/
  bootstrap/       App startup and failure handling
  core/            Shared Firebase, error, geo, time, and UI utilities
  features/
    auth/          Authentication and session flows
    blood_request/ Blood request and response flows
    donor_profile/ Donor profile and eligibility data
    donor_search/  Donor directory search
  home/            Main four-tab application shell
rules_test/        Firestore Security Rules emulator tests
test/              Flutter unit and widget tests
```

The feature folders keep presentation, domain logic, and data access separated. Generated Riverpod files are produced with `build_runner`.

## Requirements

- Flutter 3.38.x (the version line used by GitHub Actions)
- Dart SDK compatible with the constraint in `pubspec.yaml`
- Android Studio / Android SDK for Android builds
- Node.js 24 and Java 21 to run the Firestore rules emulator tests

## Run locally

1. Clone the repository and install Flutter dependencies:

   ```bash
   git clone https://github.com/tahatahirbutt-dev/BloodDonation_App.git
   cd BloodDonation_App
   flutter pub get
   ```

2. Configure Firebase for Android. Add the `google-services.json` file for the Android app (`com.tahabutt.blooddonation`) at:

   ```text
   android/app/google-services.json
   ```

   This file is intentionally ignored by Git. Obtain it from your Firebase project; do not add it to commits.

3. Generate the Riverpod source files and run the app:

   ```bash
   dart run build_runner build --delete-conflicting-outputs
   flutter run
   ```

## Tests and static analysis

Run the Flutter checks from the repository root:

```bash
flutter analyze
flutter test
```

To generate an LCOV coverage report:

```bash
flutter test --coverage
```

The report is written to `coverage/lcov.info`.

### Firestore Security Rules tests

Run the emulator-backed rules tests from the repository root:

```bash
cd rules_test
npm ci
npx -y firebase-tools emulators:exec --only firestore --project demo-bloodrules "node --test firestore_rules_test.mjs"
```

`npm ci` installs the exact versions recorded in `rules_test/package-lock.json`.

## Firebase configuration in CI

GitHub Actions restores `android/app/google-services.json` from the repository Actions secret named `GOOGLE_SERVICES_JSON_BASE64`. To create the base64 value in PowerShell:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("android\app\google-services.json")) | Set-Clipboard
```

Add the copied value as `GOOGLE_SERVICES_JSON_BASE64` under the repository's **Settings → Secrets and variables → Actions**. Without this secret, CI still runs analysis and tests; the APK build is skipped. Jenkins uses a Secret file credential with the ID `google-services-json`.

Firebase client API keys identify the Firebase project; they are not a substitute for access control. Protect Firestore data with Security Rules and App Check, and review the API restrictions on the project's Firebase-provisioned keys in Google Cloud Console.

## Screenshots

This repository currently contains the app icon but no captured UI screenshots. Add current screenshots under `docs/screenshots/` when available; useful screens to capture are the blood-request feed, post-request form, donor search, and donor profile.
