# Blood-request loop + donor search

New: lib/features/blood_request, lib/features/donor_search, lib/home/home_shell.dart, core geo/id/data helpers, composite indexes, rules for bloodRequests + responses.
Deleted by this slice: lib/features/donor_profile/presentation/pages/home_page.dart, rules_test/firestore.rules.test.mjs.
Not included on purpose: .g.dart files (run build_runner), rules_test/package.json, location_catalog.dart, geohash.dart.
Known limits: no server-side spam limit on requests; feed capped at 50; geohash prefix query can truncate at 50 per cell; no call button yet (copy number only); App Check / Google sign-in / FCM / CI still pending.
