# Manual Actions Required

| Feature | Required Action | Reason | Status |
|---------|-----------------|--------|--------|
| OTP verification (signup/login) | Real phone number to receive MSG91 SMS OTP | No sandbox OTP bypass found in code | PENDING |
| PhonePe payment | UAT/sandbox merchant credentials in backend/.env (PHONEPE_MERCHANT_ID etc.) + test flow | Cannot use live credentials; sandbox not yet configured/confirmed | PENDING |
| Firebase push notifications | Physical/emulator device with Google Play services + FCM token | Needs device-level push delivery, not just code check | PENDING |
| Voice search | Real device microphone | Emulator mic support is unreliable | PENDING |
| Google/Apple/Facebook sign-in (if implemented) | Real account sign-in in emulator | Needs interactive OAuth | PENDING — to confirm if implemented |
| Location permission flow | Device/emulator location services | Needs OS permission dialog interaction | PENDING |
| Delhivery staging validation | Paste Delhivery STAGING token + staging pickup name in Admin → API Keys → Shipping, then run `backend/scripts/test-delhivery-lifecycle.js` (see QA/DELHIVERY_GO_LIVE.md §A) | Integration verified only against local simulator; Delhivery staging token not obtainable from dashboard | PENDING — token from Delhivery |
| Deploy Delhivery/PhonePe changes to EC2 | `./deploy_backend.sh <key> --apply --web`, then set APP_BASE_URL/WEBSITE_URL on server (QA/DELHIVERY_GO_LIVE.md §B) | Production change needs owner approval | PENDING — approval |
| Delhivery webhook enablement | Send QA/DELHIVERY_REQUEST_EMAIL.md to Delhivery | Delhivery One dashboard has no webhook UI; push is enabled by Delhivery | PENDING — owner to send |
| Delhivery / PhonePe production switch | Config-only, per QA/DELHIVERY_GO_LIVE.md §C/§D | Real charges | PENDING — explicit owner go-ahead |

| iOS Firebase configuration | Add `ios/Runner/GoogleService-Info.plist` from the Firebase console (or run `flutterfire configure`) | BUG-010: no iOS Firebase config exists at all — app used to crash on launch (now fixed to degrade gracefully), but push notifications AND the mobile app's phone/OTP login (which uses Firebase Phone Auth, not the backend's OTP endpoint) cannot work without this | PENDING — needs your Firebase project access |

Nothing here has been skipped automatically — all are flagged per Phase 20/21 rules and await your explicit go-ahead ("Done" / "Skip this for now").
