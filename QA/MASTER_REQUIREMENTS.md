# ChillFi — Master Requirement Matrix

Source of truth found in project (no separate quotation/requirement PDF exists):
- Approved UI screens: `Screens/App/*` (Auth, Home Feed, Product Module, Cart & Checkout, Order Module, Profile Module, Notification Module, Website, Extra)
- Flutter app code: `FinalApp/chillfi/lib/features/*` (24 feature modules)
- Backend code: `FinalApp/chillfi/backend/src/*` (Express + PostgreSQL)
- `.env.example` reveals integrated third-party services (source of truth for integrations since no separate integration doc exists)

> NOTE FOR CLIENT/DEV: No quotation, SOW, or written requirement doc was found in the project directories. This matrix is derived from approved UI screens + implemented code. If a quotation/requirement document exists elsewhere, provide it so this matrix can be corrected against it — until then, "requirement source" = screens/code, not a signed scope.

Status legend: NOT VERIFIED | PASS | FAIL | BLOCKED | UNTESTED — MANUAL ACTION REQUIRED | UNTESTED — REAL DEVICE REQUIRED | NOT APPLICABLE

| ID | Module | Feature | Requirement Source | Verification Method | Status |
|----|--------|---------|--------------------|--------------------|--------|
| R-001 | Auth | Splash screen | Screens/App/Auth/1 | iOS Simulator (live) | PASS after BUG-010 fix (was a P0 total-launch-failure blank screen before the fix) |
| R-002 | Auth | Onboarding (3 screens) | Screens/App/Auth/2-4 | iOS Simulator (live) | PASS — all 3 screens render correctly, dots indicator correct, "Skip" present, first-launch-only (correctly not re-shown on relaunch) |
| R-003 | Auth | Welcome screen | Screens/App/Auth/5 | iOS Simulator (live) | PASS — Login/Signup + Continue as Guest both present and functional |
| R-004 | Auth | Login (password + OTP) | Screens/App/Auth/6, lib/features/auth | API + DB (backend live-tested) + iOS Simulator (mobile UI) | PASS (backend). Mobile Login screen (`lib/features/auth/login_screen.dart`) confirmed live: renders correctly, phone field takes focus and accepts input correctly. Note: mobile login calls Firebase Phone Auth (`auth.verifyPhoneFirebase`), NOT the backend's `/api/auth/send-otp` — so it depends on real iOS Firebase config, which doesn't exist yet (see BUG-010). Could not conclusively verify the "Send OTP" tap itself in this session due to iOS Simulator instability (repeated crashes/disconnects) in this environment during final testing — re-verify once Firebase iOS config (`GoogleService-Info.plist`) is added, since the button is expected to fail until then regardless of UI responsiveness. |
| R-005 | Auth | OTP verification (send/verify/replay/rate-limit) | Screens/App/Auth/7, backend/utils/otp.js | API + DB — used TEST_PHONES sandbox number (9876543210, no real SMS needed) | PASS (backend logic, 2 bugs found & fixed: BUG-001, BUG-002). Mobile app's OTP send path is Firebase-based, not this backend endpoint — see R-004 note. |
| R-006 | Auth | Signup | Screens/App/Auth/8 | API + DB | PASS |
| R-007 | Auth | Forgot / Reset password | Screens/App/Auth/9-10 | API + DB | PASS |
| R-008 | Auth | Location permission | Screens/App/Auth/11 | Emulator | NOT VERIFIED |
| R-009 | Auth | Notification permission | Screens/App/Auth/12 | Emulator | NOT VERIFIED |
| R-010 | Auth | Firebase Auth (google/phone?) | pubspec firebase_auth, local_auth | Emulator | NOT VERIFIED |
| R-011 | Home | Home dashboard | Screens/Home Feed/13 | iOS Simulator (live) | PASS — banners, quick-action tiles, category icons, welcome/rewards card, exclusive-offer coupon card all render with live backend data; BUG-011 (banner text clipping) found & fixed. Categories/Flash Deals sections below the fold not yet scrolled-to and checked. |
| R-060 | Account | Guest vs logged-in account screen | Screens/profile module | iOS Simulator (live) | BUG-012 (P3, documented, not auto-fixed) — guest sees a "Logout" button and identical empty states to a real zero-orders account, no login-required messaging |
| R-012 | Home | Search + voice search | Screens/Home Feed/14,15; speech_to_text dep | Emulator (mic = real device) | UNTESTED — REAL DEVICE REQUIRED (voice) |
| R-013 | Home | Categories / sub-categories | Screens/Home Feed/16-17 | API + DB | PASS (list); subcategories/products-by-category not yet exercised |
| R-014 | Home | Brand listing | Screens/Home Feed/18 | API + DB | PASS |
| R-015 | Home | Flash deals | Screens/Home Feed/19 | API | NOT VERIFIED yet (route exists, not called) |
| R-016 | Home | Trending products | Screens/Home Feed/20 | API | NOT VERIFIED yet (route exists, not called) |
| R-017 | Home | Offer products | Screens/Home Feed/22 | API | NOT VERIFIED yet |
| R-018 | Home | New arrivals | Screens/Home Feed/21 | API | NOT VERIFIED yet (route exists, not called) |
| R-019 | Home | Recently viewed | Screens/Home Feed/23 | API + DB | NOT VERIFIED yet (route exists, not called) |
| R-020 | Home | Recommended products | Screens/Home Feed/24 | API | NOT VERIFIED yet (route exists, not called) |
| R-021 | Product | Product listing | Screens/PRODUCT MODULE | API + DB | PASS (BUG-003 found & fixed) |
| R-022 | Product | Product details + gallery | Screens/PRODUCT MODULE | API | NOT VERIFIED yet (GET /:id not called directly) |
| R-023 | Product | Product reviews | Screens/PRODUCT MODULE | API + DB | NOT VERIFIED yet |
| R-024 | Product | Similar products | Screens/PRODUCT MODULE | API | NOT VERIFIED yet |
| R-025 | Cart | Cart screen / empty cart | Screens/Cart & checkout, extra | API (backend live-tested) | PASS (BUG-004 found & fixed) |
| R-026 | Cart | Wishlist (toggle/list/check) | Screens/extra, lib/features/wishlist | API + DB | PASS |
| R-027 | Checkout | Address (add/list/validation) | Screens/Cart & checkout | API + DB | PASS (backend); frontend UI screen not yet checked on emulator |
| R-028 | Checkout | Apply coupon (preview) + order-time coupon lock | Screens/Cart & checkout | API + DB | PASS |
| R-029 | Checkout | Payment method selection (COD/PhonePe) | Screens/Cart & checkout | API | PASS (backend accepts both; UI selector not yet checked on emulator) |
| R-030 | Payment | PhonePe payment flow (dev-mode mock) | backend paymentController.js | API — tested via dev-mode mock (NODE_ENV=development); real UAT/sandbox PhonePe credentials not configured | PASS (dev mock only) — UNTESTED — MANUAL ACTION REQUIRED for real PhonePe sandbox |
| R-031 | Payment | COD confirmation | Screens/Cart & checkout | API | PASS (order created with COD, payment_status Pending as expected) |
| R-032 | Payment | Order success / failed screens (backend state) | Screens/Cart & checkout | API | PASS (Paid after mock success); failure-path not yet tested |
| R-033 | Orders | My orders list | Screens/order module | API + DB | PASS |
| R-034 | Orders | Order details | Screens/order module | API + DB | PASS (BUG-005 found & fixed — was a P1 production-breaking crash) |
| R-035 | Orders | Cancel order | Screens/order module | API + DB | PASS |
| R-036 | Orders | Shipment tracking (Delhivery/Shiprocket) | backend utils/delhivery.js, shiprocket.js | Needs a real/sandbox carrier account | NOT VERIFIED — no tracking_id present on test orders yet |
| R-037 | Profile | My profile / edit profile | Screens/profile module | API + DB | PASS |
| R-038 | Profile | Saved addresses | Screens/profile module | API + DB | PASS |
| R-039 | Profile | Notification settings | Screens/profile module | Emulator | NOT VERIFIED |
| R-040 | Profile | Terms, Privacy, About, Help & Support | Screens/profile module | Emulator (content review) | NOT VERIFIED |
| R-041 | Profile | Logout | Screens/profile module | Emulator + session check | NOT VERIFIED |
| R-042 | Notifications | Push notifications (Firebase) | firebase_messaging, flutter_local_notifications | Real device (FCM) | UNTESTED — REAL DEVICE REQUIRED |
| R-043 | Notifications | Offer notifications | Screens/notification module | Real device | UNTESTED — REAL DEVICE REQUIRED |
| R-044 | Extra | No internet / offline state | Screens/extra, connectivity_plus dep | Emulator (airplane mode) | NOT VERIFIED |
| R-045 | Extra | Maintenance screen | Screens/extra | API confirmed (`/api/app-config` returns maintenance_mode/message); app-side gating not yet checked on emulator | PARTIAL PASS |
| R-046 | Admin | Admin panel (dashboard/users/orders/banners/coupons/testimonials/promo-banners/shipping-rules/reviews/messages/settings) | backend adminController.js | API (backend live-tested, RBAC verified) | PASS (backend) — no admin UI found in this Flutter app; admin is API-only or a separate web app not present in this repo |
| R-047 | Website | Parallel web storefront (Home, PLP, PDP, Cart, Checkout, Account, Orders, Tracking, Wishlist, CMS pages) | Screens/App/Website (15 pages); code at `FinalApp/chillfi/web/website` (React + Vite + TS + Tailwind, deployed via Firebase Hosting, hits the same backend API) | Local dev server + browser (live-tested) | PASS — Home, PLP, PDP, Cart, Checkout→Order flow, My Orders, Order Tracking, Wishlist, Contact form, Privacy Policy all verified live with real backend data. 2 real bugs found & fixed (BUG-008 price formatting, BUG-009 checkout total race/staleness — P1). Phone/OTP login itself is UNTESTED — MANUAL ACTION REQUIRED (real Firebase reCAPTCHA, not automatable); tested authenticated pages by injecting a legitimately-issued JWT instead of the UI login. Admin UI (`/admin/*`) not yet clicked through (backend admin API already verified). Terms/About/FAQ pages not yet opened (same low-risk static-content pattern as Privacy Policy).
| R-048 | Backend | Auth API (JWT) | backend routes/auth.js, middleware/auth.js | API test | PASS |
| R-049 | Backend | Cart/Orders/Payment/Address/Wishlist/Search/Brands/Categories/Contact/AppConfig APIs | backend routes/*.js | API test | PASS |
| R-050 | Integration | Cloudinary image upload | backend middleware/upload.js | Needs real Cloudinary credentials | NOT VERIFIED — credentials not exercised |
| R-051 | Integration | MSG91/2Factor OTP delivery to a real phone | backend utils/otp.js | Real phone | UNTESTED — MANUAL ACTION REQUIRED (backend OTP *logic* fully verified via TEST_PHONES sandbox number; only the actual SMS delivery to a real handset is unverified) |
| R-052 | Integration | Firebase push (server → device) | backend utils/firebase.js | Real device | UNTESTED — REAL DEVICE REQUIRED |
| R-053 | Non-func | Localization / multi-language | Flutter lib | Code check | NOT APPLICABLE — no `.arb`/l10n infrastructure, no `generate: true` in pubspec, no `Locale()` usage anywhere in `lib/`. The app is English-only; multi-language was never implemented. Flagging for client: if the quotation/screens implied Hindi/English toggle, this is a scope gap, not a bug. |
| R-054 | Non-func | Security (.env secrets, exposed keys) | backend config | Static review | IN PROGRESS — see BUGS.md; `.env`/`firebase-service-account.json` present locally (not committed to git, gitignore confirmed) |
| R-055 | Non-func | Build validation (Android/iOS) | build config | `flutter pub get` + `flutter analyze` | PASS — clean pub get, analyzer reports only 2 trivial lint infos, no errors |

This table will be expanded/corrected as each module is opened (sub-buttons, sub-states, exact fields) — this is the entry-level matrix from discovery, not the final granular checklist.
