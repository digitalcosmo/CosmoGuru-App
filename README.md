# CosmoGuru App

Flutter app for clients who buy CK Planner reports directly from CosmoGuru.
Sign in with mobile number + OTP (no Acharyaji code); planner data comes from
the `_Cosmo` endpoints on software.cosmokundli.com.

- `lib/` — app code (GetX). Sister project: digitalcosmo/myacharyaji-app.
- `branding/` — launcher icons copied into the generated platform folders by CI.
- CI (`.github/workflows/ci.yml`) generates android/ios/web, runs `flutter analyze`,
  builds release APKs (application ID `com.cosmo.guru`, same as the existing app)
  and publishes a report to the `ci-results` branch.
- iOS: push `main` to the `ios-build` branch to build an unsigned IPA.
