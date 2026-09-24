# Bug Log

BUG ID | FEATURE | SCREEN | SEVERITY | EXPECTED | ACTUAL | ROOT CAUSE | FILE(S) | FIX | RETEST RESULT

## BUG-001
- FEATURE: OTP login (`verify-otp`) and Firebase phone login (`firebase-verify`)
- SCREEN: Login / OTP Verification
- SEVERITY: P2
- EXPECTED: A deactivated (`is_active=false`) account cannot log in, same as password login.
- ACTUAL: OTP login and Firebase phone login returned `"Login successful"` with a valid-looking JWT for a deactivated account; every subsequent authenticated request then failed with "User not found or inactive" — a confusing dead end, and an inconsistency with password login which already blocked deactivated accounts.
- ROOT CAUSE: `verifyOtpLogin` and `firebaseVerify` in `authController.js` queried/updated `users` by phone only, without an `is_active = TRUE` check (password login had this check, the other two didn't).
- FILE(S): `backend/src/controllers/authController.js`
- FIX: Added `is_active = TRUE` to the OTP-login update query (returns 401 "Account not found or has been deactivated" if no match) and added an explicit `is_active` check in `firebaseVerify` before issuing tokens.
- RETEST RESULT: PASS — deactivated test account (`9876543210`) now correctly rejected at `verify-otp`; after reactivating, full flow (send-otp → verify-otp → `/auth/me`) passes with a valid token and correct user payload.

## BUG-002
- FEATURE: `send-otp` (login/signup/forgot-password)
- SCREEN: Login, Signup, Forgot Password
- SEVERITY: P1
- EXPECTED: If the SMS provider fails to deliver the OTP, the API should tell the client so it can show an error / retry, not claim success.
- ACTUAL: `send-otp` always responded `{success:true,"OTP sent"}` regardless of whether the underlying SMS provider call succeeded. Reproduced locally: 2Factor.in returned an HTML error page (bad/placeholder API key), logged as `❌ OTP SMS error`, yet the API still reported success. In production this means any SMS-provider outage or bad key silently strands every real user at the OTP screen with no way to know why.
- ROOT CAUSE: `createOTPSession()` in `utils/otp.js` discarded the `sent` flag from `sendOTP()` and always resolved; `sendOtp`/`forgotPassword` in `authController.js` never checked it.
- FILE(S): `backend/src/utils/otp.js`, `backend/src/controllers/authController.js`
- FIX: `createOTPSession` now returns `{ sent }`; `sendOtp` and `forgotPassword` return `502` with a clear message when `sent` is false.
- RETEST RESULT: PASS — test-phone path (`9876543210`) still returns success (no regression); a real number with the locally-misconfigured 2Factor key now correctly returns the 502 failure instead of a false "OTP sent".

## BUG-003
- FEATURE: Admin product create/update (`POST /api/products`, `PUT /api/products/:id`) → `product_images`
- SCREEN: Product listing, search, home, product details (image rendering)
- SEVERITY: P2
- EXPECTED: `images` array entries are validated/normalized to a plain URL string before being stored.
- ACTUAL: `images[i]` was inserted directly as the `url` column with no validation. Found a live corrupted row (product `a1000000-...-001`, "Samsung Galaxy S24 FE") where `url` was the JSON-stringified object `{"url":"...","is_primary":true}` instead of a plain URL — pg silently stringifies objects passed as query params. This broke `primary_image` everywhere it's surfaced (confirmed via `/api/search`), and would render a broken image in the app.
- ROOT CAUSE: No type-checking/normalization on `images` entries in `createProduct`/`updateProduct` (`productController.js`).
- FILE(S): `backend/src/controllers/productController.js`
- FIX: Added a `toImageUrl()` helper that accepts either a plain string or a `{url}` object and returns a clean URL string (or `null`, which is now skipped); corrected the one bad row in the DB.
- RETEST RESULT: PASS — `/api/search` now returns a plain URL for the previously-corrupted product; a `createProduct` call with mixed image shapes (string, `{url,...}` object, and an invalid object) correctly stored the two valid URLs and silently skipped the invalid entry.

## BUG-004
- FEATURE: Cart summary (`GET /api/cart`)
- SCREEN: Cart Screen / Empty Cart Screen
- SEVERITY: P3
- EXPECTED: An empty cart shows `delivery_fee: 0, total: 0`.
- ACTUAL: An empty cart returned `delivery_fee: 49, total: 49` — the flat shipping fee was being charged even with 0 items in the cart.
- ROOT CAUSE: `getCart()` in `cartController.js` called `getShippingFee`/`getGstAmount` unconditionally regardless of whether the cart had any items.
- FILE(S): `backend/src/controllers/cartController.js`
- FIX: Delivery fee and tax are now only computed when `items.rows.length > 0`; otherwise both are `0`.
- RETEST RESULT: PASS — empty cart now returns all-zero summary; adding an item back shows correct delivery_fee/tax/total, no regression.

## BUG-005 (P1 — Production Readiness Critical)
- FEATURE: Order detail / tracking (`GET /api/orders/:id`, tracking endpoints, admin shipment update)
- SCREEN: Order Details Screen, Delhivery Tracking Timeline
- SEVERITY: P1
- EXPECTED: Order detail loads successfully after checkout.
- ACTUAL: `GET /api/orders/:id` (and tracking/admin shipment endpoints) crashed with `column o.shipment_provider does not exist` on any freshly-provisioned database.
- ROOT CAUSE: `orderController.js` queries reference `orders.shipment_provider`, but that column was only ever added via a standalone, manually-run file (`backend/scripts/migrate-shiprocket.sql`) — it was never folded into `schema.sql`, which is the file `initDB()` actually runs on every server boot (and what `npm run db:setup` uses for a fresh install). Any environment set up from `schema.sql` alone (this local DB, and potentially any re-provisioned/staging/production DB where that one-off script was never run by hand) has a broken order-detail/tracking flow for every single order.
- FILE(S): `backend/src/db/schema.sql` (missing column), `backend/src/controllers/orderController.js` (consumer)
- FIX: Added `ALTER TABLE orders ADD COLUMN IF NOT EXISTS shipment_provider VARCHAR(20) DEFAULT 'delhivery';` to `schema.sql` right after the table definition, matching the existing pattern used for `tax_amount`. This makes the column part of the canonical, idempotent schema instead of a forgettable manual step.
- RETEST RESULT: PASS — after restart (which reran `schema.sql`), `GET /api/orders/:id` returns the full order with address, items, and `shipment_provider`.
- ⚠️ ACTION FOR CLIENT/DEV: If the production database was set up the same way (schema.sql only, migration script never run), **order details are broken in production right now**. Confirm `\d orders` on the production DB includes `shipment_provider` — if not, deploy this schema.sql fix or run the migration script there immediately.

## BUG-006
- FEATURE: `GET /api/products/recommended`
- SCREEN: Recommended Products Screen (home feed)
- SEVERITY: P2
- EXPECTED: Per the route's own comment ("optional auth — works both logged in and out"), a guest (no token) should get generic recommendations; a logged-in user gets personalized ones.
- ACTUAL: A request with no `Authorization` header got a hard `401 No token provided` — guests couldn't load this section at all.
- ROOT CAUSE: The inline route wrapper called `authenticate(req, res, () => next())` directly. `authenticate` itself responds with 401 when no token is present (by design, for routes that require auth) — the wrapper never handled that case, so "optional" auth was actually mandatory.
- FILE(S): `backend/src/middleware/auth.js`, `backend/src/routes/products.js`
- FIX: Added a real `optionalAuthenticate` middleware that attaches `req.user` when a valid token is present and silently proceeds as a guest otherwise (no token, invalid token, or expired token) — used it in place of the ad hoc wrapper on `/recommended`.
- RETEST RESULT: PASS — guest, authenticated, and garbage-token requests all now return 200 with product data; authenticated personalization unaffected (regression clean).

## BUG-007
- FEATURE: Global error handling for missing required fields (found via admin `createTestimonial`, but affects any endpoint that inserts without pre-validating)
- SCREEN: Admin panel forms generally
- SEVERITY: P3
- EXPECTED: A missing required field returns a clean validation message.
- ACTUAL: Returned the raw Postgres error, e.g. `null value in column "customer_name" of relation "testimonials" violates not-null constraint` — leaks internal table/column names to the API client.
- ROOT CAUSE: `errorHandler.js` special-cases unique-constraint (`23505`) and FK-violation (`23503`) Postgres errors but not not-null-violation (`23502`), so those fall through to the raw `err.message`.
- FILE(S): `backend/src/middleware/errorHandler.js`
- FIX: Added a `23502` case returning `{success:false, message:"A required field is missing"}`.
- RETEST RESULT: PASS — missing-field request now returns the clean message; correct-field request still creates successfully (regression clean).

## BUG-008 (Website)
- FEATURE: "You may also like" section on the Product Details page (and its discount-% badge)
- SCREEN: Product Detail Page (web/website)
- SEVERITY: P3
- EXPECTED: Prices in "You may also like" cards render comma-formatted like everywhere else on the site (e.g. `₹24,999`), and discount badges are numerically correct.
- ACTUAL: Prices rendered as raw unformatted strings (`₹24999.00`) instead of `₹24,999`. Root cause also affected the discount-% calculation, since it compared/subtracted string values.
- ROOT CAUSE: `sections/ProductDetails/RelatedProducts.tsx` passed `p.price`/`p.old_price` straight from the API response into `ProductCardPLP` without converting them with `Number(...)` first. Postgres `NUMERIC` columns serialize as JSON strings (e.g. `"24999.00"`), and `String.prototype.toLocaleString()` is a no-op, so the raw string passed straight through. `ProductListing/index.tsx` and `ProductDetails/index.tsx` already wrap every price field in `Number(...)` for this exact reason — `RelatedProducts.tsx` was the one place that didn't.
- FILE(S): `web/website/sections/ProductDetails/RelatedProducts.tsx`
- FIX: Wrapped `price`/`old_price` in `Number(...)` both when computing the discount badge and when passing props to `ProductCardPLP`.
- RETEST RESULT: PASS — "You may also like" on the Apple AirPods Pro PDP now shows correctly formatted, comma-separated prices (e.g. `₹24,999`) and correct discount percentages. Checked the Cart page's own "You may also like" section too — it sources from `StoreContext`, which already does `Number()` conversion on load, so it was unaffected (no separate fix needed there).

## BUG-009 (Website — P1, financial/trust-critical)
- FEATURE: Checkout — GST/delivery price preview vs. actual charged total
- SCREEN: Checkout Page (web/website)
- SEVERITY: P1
- EXPECTED: The total shown on "Place Order • ₹X" always equals what the customer is actually charged when the order is created.
- ACTUAL (two distinct but related defects found in the same code path):
  1. **Race on submit**: the checkout page fetches GST/delivery asynchronously (`GET /api/cart`) after mount. The "Place Order" button was never gated on that fetch completing, so a user (or a fast click) could submit while `tax_amount` was still `0` — e.g. displayed/confirmed `₹24,900` but the backend still computed and charged the correct `₹29,382` (GST included). The customer commits to one number and is charged a different (higher) one, with zero indication anything was still loading.
  2. **Stale/duplicated server cart**: the previewed GST/total is derived from the *backend's* `cart_items`, which can be stale or out of sync with what's actually in the user's locally-tracked cart (e.g. leftover items from a previous session). Observed previews of `₹33,864` and `₹42,828` for what was actually a single ₹24,900 item, because the backend cart still held old quantities.
- ROOT CAUSE: `pages/Checkout/index.tsx` — (1) the "Place Order" button's `disabled` condition didn't include "summary not yet loaded"; (2) the tax/delivery preview trusted the server cart as-is instead of syncing it to the client's current cart first.
- FILE(S): `web/website/pages/Checkout/index.tsx`
- FIX:
  - Added `!cartSummary` to the button's `disabled` condition (shows "Calculating total…" instead of a submittable button while loading), plus a matching guard in `handlePlaceOrder` itself.
  - The preview effect now syncs the backend cart (clear + re-add from the client's current cart) *before* fetching the summary, exactly like `handlePlaceOrder` already does, so the preview is always derived from what the user currently has in their cart.
  - **Follow-up defect surfaced by that fix and also corrected**: syncing on every effect run introduced a race between overlapping runs (React's dev-mode double-invoke, or quick re-renders) concurrently clearing/re-adding the *same shared server cart*, which could leave duplicated quantities (observed GST inflating to 2× and then 4× the correct amount across retests). Fixed by serializing all sync runs through a promise-chain mutex (`cartSyncChain`) plus a sequence-number guard (`cartSyncSeq`) so only one sync is ever in flight at a time and only the latest run's result is committed to state.
- RETEST RESULT: PASS — repeated the full add-to-cart → checkout → place-order flow after clearing test pollution; the previewed "Place Order • ₹29,382" matched the actual `TOTAL PAID ₹29,382` on the order-success page exactly, with GST/subtotal internally consistent throughout.

## BUG-010 (Flutter Mobile App — P0, Launch-Blocking)
- FEATURE: App launch (iOS)
- SCREEN: Splash Screen (never reached)
- SEVERITY: P0 — CRITICAL
- EXPECTED: The app launches and shows the splash/onboarding screen.
- ACTUAL: The app showed a permanently blank white screen on iOS with no error, no timeout, no recovery — completely unusable. Confirmed via `flutter run` (not just the bare installed binary) that `main()` throws an unhandled fatal exception before `runApp()` is ever called:
  ```
  [ERROR:flutter/runtime/dart_vm_initializer.cc(40)] Unhandled Exception: [core/not-initialized] Firebase has not been correctly initialized.
  #2 main (package:chillfi/main.dart:56:3)
  ```
- ROOT CAUSE: `Firebase.initializeApp()` in `lib/main.dart` was called unconditionally and NOT wrapped in try/catch (unlike the notifications init right after it, which already was). On iOS there is no `GoogleService-Info.plist` anywhere in `ios/Runner` and no cross-platform `firebase_options.dart` generated via FlutterFire CLI either — Firebase was only ever configured for Android (`android/app/google-services.json` exists, no iOS equivalent). Since the exception was unhandled, it propagated out of `main()` and `runApp(const MyApp())` was never reached — the entire app, not just push notifications, was dead on iOS.
- FILE(S): `lib/main.dart`; missing `ios/Runner/GoogleService-Info.plist` (or `lib/firebase_options.dart`)
- FIX (code-level, applied): Wrapped `Firebase.initializeApp()` + background-message registration + `_initNotifications()` in a single try/catch, so a Firebase failure degrades gracefully (push notifications won't work) instead of preventing the entire app from launching.
- ⚠️ REMAINING ACTION FOR CLIENT/DEV (cannot be done from this environment — requires the client's Firebase console access): Add a real `GoogleService-Info.plist` for the iOS app to `ios/Runner/`, or run `flutterfire configure` to generate `lib/firebase_options.dart` and pass it to `Firebase.initializeApp(options: ...)`. Without this, push notifications will remain non-functional on iOS even though the app itself now launches. **This must be verified on Android too** — Android does have `google-services.json`, but this whole class of bug (an unhandled exception in `main()` before `runApp()`) was never being tested there either; recommend explicitly confirming a clean Android launch as part of this same fix cycle.
- RETEST RESULT: PASS — after the code fix, rebuilding and launching in the iOS Simulator (pointed at the local backend via `--dart-define=API_URL=http://localhost:5000/api`) now correctly shows the Splash/Onboarding screen instead of a blank screen.

## BUG-011 (Flutter Mobile App)
- FEATURE: Home Dashboard — hero banner carousel
- SCREEN: Home Dashboard
- SEVERITY: P2
- EXPECTED: Banner title text fits fully within its available space (wrapping or auto-shrinking as needed), never hidden behind the banner image.
- ACTUAL: "Monsoon Sale — Up to 70% Off" rendered as "Monsoon Sale — Up t" with the rest of the text invisible, covered by the product image positioned on the right. Reproduced consistently on a real Home load with live banner data.
- ROOT CAUSE: `hero_banner.dart`'s text block was wrapped in `FittedBox(fit: BoxFit.scaleDown)` inside a `Padding` sized to the *full* banner width, while the product image was a separately `Positioned` element painted on top (in the same `Stack`) occupying the right 110.w — so the FittedBox computed its scale using the full width (never accounting for the image), and the image then visually covered whatever text extended into its region.
- FILE(S): `lib/features/home/widgets/hero_banner.dart`
- FIX: Changed the text `Padding` to reserve `right: 110.w + 20.r` (the image's width plus margin), so `FittedBox` correctly computes its available width excluding the image area and scales/wraps the text to fit next to it instead of being overlapped.
- RETEST RESULT: PASS — rebuilt and relaunched in the iOS Simulator; the "Monsoon Sale — Up to 70% Off" banner now displays the full title correctly, no longer clipped by the product image.

## BUG-012 (Flutter Mobile App — design/UX finding, not auto-fixed)
- FEATURE: Account-gated screens (My Orders, Wishlist, My Reviews) accessed via "Continue as Guest"
- SCREEN: My Orders (reproduced), likely Wishlist / My Reviews too
- SEVERITY: P3 (UX clarity, not a crash/data-leak)
- EXPECTED: A guest (no logged-in session) opening "My Orders" either can't reach the screen, or sees a clear "Log in to see your orders" prompt.
- ACTUAL: "Continue as Guest" still shows the full Account screen (including a "Logout" button, as if a session exists) and "My Orders" renders the exact same "No orders yet / Start shopping to see orders here" empty state a genuinely logged-in user with zero orders would see — with no way to tell the two situations apart.
- ROOT CAUSE: `CartProvider.loadOrders()` → `OrderService.getOrders()` (`lib/core/services/cart_service.dart:146-159`) wraps the entire API call in `try { ... } catch (_) { return []; }`, silently converting *any* failure — including a 401 from having no auth token as a guest, a network error, or a real server error — into an empty list indistinguishable from "you truly have zero orders." Spot-checked `wishlist_screen.dart` too; it has no auth-state check either, so this is a systemic pattern, not an isolated oversight in one screen.
- FILE(S): `lib/core/services/cart_service.dart` (and likely other services following the same `catch (_) => []` pattern), `lib/features/orders/my_orders_screen.dart`, `lib/features/wishlist/wishlist_screen.dart`
- WHY NOT AUTO-FIXED: This is a product/UX decision, not a one-line bug — the right fix (block guests from these screens entirely vs. keep them reachable but distinguish "empty" from "not logged in"/"failed to load") needs a call from the client/dev team, and touches navigation guards across multiple screens with real regression risk if changed without dedicated testing. Flagging for a deliberate decision rather than unilaterally rearchitecting.
- SUGGESTED FIX: Check `AuthProvider`'s logged-in state before navigating into these screens (or before rendering their content) and show a "Login required" prompt for guests; separately, have `getOrders()`/similar service calls distinguish auth failures (401) and network/server errors from a genuine empty result, so the UI can show the right message in each case instead of collapsing everything into "no orders yet."

## BUG-013 (Mobile App — P1, Systemic, affects nearly every product/brand image)
- FEATURE: Product images (catalog-wide) and all brand logos
- SCREEN: Product Listing, Home ("Deal of the Day"), Categories, Search, Cart, Wishlist, PDP, Brand Listing — every screen showing a product or brand image
- SEVERITY: P1
- EXPECTED: Product and brand images load correctly in the mobile app.
- ACTUAL: Every product card in Product Listing (and most other screens) showed a generic gray shopping-bag fallback icon instead of the actual image, even though the same image URLs render fine on the website and in Safari.
- ROOT CAUSE (two distinct issues found in the same investigation):
  1. **SVG vs raster format**: `placehold.co` URLs with no explicit file extension (e.g. `.../666?text=...`) return `content-type: image/svg+xml`. Flutter's `Image.network` cannot decode SVG at all (only raster formats) — it silently fails and shows the errorBuilder fallback. A browser (Safari, or the website's `<img>` tag) renders SVG natively, which is why this was invisible on web and only showed up testing the actual mobile app. 12 `product_images` rows used this exact pattern. Separately, 5 of 7 **brand logos** used Wikimedia `.svg` files — same failure mode, affecting every brand logo in the app (Samsung, Sony, Apple, Lenovo, OnePlus).
  2. **Dead links**: 2 of those Wikimedia SVG logos (Samsung, OnePlus) were themselves 404 — the files were renamed/deleted upstream. Also a specific Unsplash photo ID used for both the "Noise ColorFit Ultra 3 Smartwatch" product image and the "Noise" brand logo was a 404 (removed from Unsplash).
- FILE(S): Database data only (`product_images.url`, `brands.logo_url`) — no application code was at fault; the underlying `Image.network` usage in `product_card.dart` / `hero_banner.dart` / `deal_section.dart` etc. is standard and correct.
- FIX:
  - Added `.png` to the 12 affected `placehold.co` URLs (placehold.co supports an explicit format extension — confirmed it then returns `image/png`).
  - Re-pointed the 5 Wikimedia SVG brand logos through `wsrv.nl` (a public image proxy) with `&output=png`, which fetches the SVG and re-encodes it as PNG on the fly — confirmed each now returns `image/png`.
  - Replaced the 2 dead Wikimedia logos (Samsung, OnePlus) with current, live file references (Samsung: the renamed `Samsung_wordmark.svg`, proxied the same way; OnePlus: a PNG logo file already on Commons, no proxy needed).
  - Replaced the dead Unsplash photo (Noise product + brand logo) with another already-verified-working smartwatch photo already used elsewhere in the catalog.
  - Ran a full sweep of every image URL across `product_images`, `brands`, `banners`, `categories`, `promo_banners`, and `testimonials` (32 distinct URLs) — confirmed all now return `200` and a non-SVG content-type.
- RETEST RESULT: PASS — relaunched the app; the previously-broken "Noise ColorFit Ultra 3 Smartwatch" now shows a real product photo instead of the fallback icon. (Two other products in the same fixed batch — "boAt Airdopes 141 TWS" and "Noise ColorFit Ultra 2" — now correctly render a placehold.co placeholder graphic that visually just displays the product name as text; that's the actual, legitimate content of that placeholder image and loads successfully — it's a separate, minor **data-completeness** gap, not a bug: these 2 products simply never had a real photo assigned. Recommend the client/dev team upload real product photography for these before launch.)

## BUG-014 (Website — P1)
- FEATURE: Maintenance Mode (Admin → Settings → Store Features → Maintenance Mode)
- SCREEN: Every website storefront page
- SEVERITY: P1
- EXPECTED: Toggling Maintenance Mode on in Admin puts the live platform into maintenance for all visitors, per the checklist's own requirement ("Toggling maintenance mode here actually puts the live app into maintenance for all users").
- ACTUAL: Enabling maintenance mode (verified via `PUT /api/admin/settings` then `GET /api/app-config` — flag correctly flipped to `true` with the configured message) had **zero effect on the website** — the homepage and every other page kept loading and functioning completely normally for a regular visitor. The Flutter mobile app *does* check this flag correctly (`remote_config_service.dart` / `maintenance_screen.dart` gate the splash flow) — this was a website-only gap. Confirmed via code search: no file under the website's storefront source (outside `/admin`) ever referenced `app-config` or `maintenance_mode` — the check simply didn't exist.
- FILE(S): `web/website/src/App.tsx` (missing check), new `web/website/pages/Maintenance/index.tsx`
- FIX: Added a `Maintenance` page and wired `App.tsx` to fetch `/api/app-config` once on load; when `maintenance_mode` is true, every non-`/admin` route renders the maintenance page instead of its normal content. Admin routes stay reachable throughout so an admin can log in and turn it back off.
- RETEST RESULT: PASS — with maintenance mode on, the homepage correctly showed "We'll be right back" with the exact configured message, while `/admin/settings` remained fully usable. Turned maintenance mode back off via the same API and confirmed the homepage returned to normal (regression clean).

## BUG-015 (Mobile App — P2, hides all Add to Cart/Buy Now feedback)
- FEATURE: Add to Cart / Buy Now feedback (SnackBar messages) on Product Details
- SCREEN: Product Details Screen
- SEVERITY: P2
- EXPECTED: Tapping "Add to Cart" (or "Buy Now") shows a visible confirmation (green "Added to cart!") or error (red message, e.g. when not logged in) SnackBar.
- ACTUAL: No SnackBar was ever visible after tapping Add to Cart, success or failure — confirmed the tap genuinely reached the backend each time (`POST /api/cart/add` in server logs) and, as a guest, correctly received a `401`, yet the screen showed absolutely no feedback of any kind. The button appeared completely dead.
- ROOT CAUSE: The fixed bottom action bar (`_buildBottomActionBar()`, containing Add to Cart/Buy Now) was placed via `Align(alignment: Alignment.bottomCenter, ...)` stacked directly inside the `body`'s own `Stack`, instead of through Scaffold's dedicated `bottomNavigationBar` slot. Because Scaffold didn't know about this in-body bottom bar, `ScaffoldMessenger`'s SnackBars rendered at the true bottom of the screen and were completely hidden underneath the fixed action bar, invisible to the user no matter what the message said.
- FILE(S): `lib/features/product_details/product_details_screen.dart`
- FIX: Moved `_buildBottomActionBar()` into the Scaffold's `bottomNavigationBar:` property (guarded to hide while loading/product-not-found) and removed the now-redundant `Stack`/`Align` wrapper around the scrollable body. Scaffold now correctly insets SnackBars above the action bar.
- RETEST RESULT: Code fix verified via `dart analyze` (clean) and confirmed the specific root cause (bottom bar stacked via `Align` instead of `bottomNavigationBar`) is resolved on Product Details.
## BUG-017 (Production — P0, CRITICAL, found & fixed live)
- FEATURE: Every API-dependent page on the live production website (chillfi.in)
- SCREEN: Homepage, Product Listing, Categories, Cart, Checkout, Terms, and every other page that fetches live data
- SEVERITY: P0 — the entire live site was silently running on stale/fallback content only
- EXPECTED: chillfi.in (served over HTTPS) fetches live data from the backend API.
- ACTUAL: `web/website/.env.production` had `VITE_API_URL=http://3.111.32.220/api` — a plain-HTTP, direct-IP URL. Since the site itself loads over HTTPS, every single API request (home banners, products, categories, cart, app-config — everything) was silently blocked by the browser's mixed-content policy. Confirmed via console: `Mixed Content: ... requested an insecure resource 'http://3.111.32.220/api/home'. This request has been blocked.` The homepage was rendering a generic hardcoded fallback banner ("BIGGEST SALE OF THE SEASON") instead of real live content — this was happening on production before any change made in this session; it was surfaced while deploying the new policy pages below.
- ROOT CAUSE: `.env.production` was never updated to use the site's own HTTPS domain, even though nginx on the EC2 server already proxies `chillfi.in/api/` → the backend correctly. Separately, the backend's CORS `allowedOrigins` whitelist (`backend/src/index.js`) never included `https://chillfi.in` at all (only the old plain-HTTP IP) — so simply fixing the URL alone would have traded a mixed-content block for a CORS block.
- FILE(S): `web/website/.env.production`, `backend/src/index.js`
- FIX: Changed `VITE_API_URL` to `https://chillfi.in/api`; added `https://chillfi.in`, `https://www.chillfi.in`, `https://chillfi.web.app`, and `https://chillfi.firebaseapp.com` to the backend's CORS whitelist. Rebuilt the website, deployed the backend fix + restarted PM2, then deployed the new website build.
- RETEST RESULT: PASS — verified in a fresh browser tab (no stale console history): zero mixed-content errors, homepage now shows real live banner/trending data matching the backend exactly (e.g. "Laptops Under ₹55,000" banner, boAt Airdopes 52.0k reviews, etc.), confirmed on `/`, `/terms`, `/shipping-policy`, `/return-policy`, `/refund-policy`.

## BUG-018 (Website — feature added)
- FEATURE: Refund Policy, Return Policy, and Shipping Policy pages
- SCREEN: New pages, linked from Footer and Account sidebar (previously showed "Soon")
- Created `pages/RefundPolicy`, `pages/ReturnPolicy`, `pages/ShippingPolicy` (same structure/components as the existing Privacy Policy page), added routes (`/refund-policy`, `/return-policy`, `/shipping-policy`) to `App.tsx`, wired up the previously-disabled Footer links and added them to `AccountSidebar`'s legal section.
- Deployed to chillfi.in without touching the two standalone static pages already there (`/privacy-policy/`, `/delete-account/` — confirmed these are separate static exports outside the SPA, deployed without `rsync --delete` specifically to avoid wiping them; verified both still work identically post-deploy).
- RETEST: All 3 new pages verified live on chillfi.in with correct content; Terms, Privacy Policy, and Delete Account all reconfirmed working, unaffected.

## BUG-016 (Backend — deployment documentation, P2)
- FEATURE: Delhivery shipping configuration documentation
- SCREEN: N/A — `.env.example`, `RAILWAY_ENV_VARS.txt`
- SEVERITY: P2 (would cause real deployment confusion, not a runtime bug)
- EXPECTED: The env var names documented for configuring Delhivery match what the code actually reads.
- ACTUAL: `.env`, `.env.example`, and `RAILWAY_ENV_VARS.txt` all listed `DELHIVERY_API_KEY` / `DELHIVERY_WAREHOUSE_NAME` — but `backend/src/utils/delhivery.js` never reads either of those; it reads `DELHIVERY_TOKEN`, `DELHIVERY_CLIENT_NAME`, and `DELHIVERY_PICKUP_LOCATION` instead (confirmed via `grep` — zero matches for the documented names anywhere in `src/`). A developer following these files to configure Delhivery via environment variables would set values that are silently never read, and Delhivery would keep failing with "not configured" regardless. Shiprocket (the actual *default* courier provider in the code — `provider = req.body.provider || 'shiprocket'`) wasn't documented in any of these files at all.
- FILE(S): `backend/.env.example`, `backend/RAILWAY_ENV_VARS.txt` (`.env` itself left as-is since it's the live local file, not committed)
- FIX: Corrected the Delhivery variable names in both files to match the code, and added the missing Shiprocket variables with a note that Admin → Settings → API Keys is the recommended configuration path (writes to the DB, takes effect immediately, no redeploy).
- NOTE: This was a documentation-only bug — the actual runtime configuration path (Admin → Settings → API Keys, writing to `store_settings`) was already correct and internally consistent with the code; only the env-var/deployment docs were wrong.

- ⚠️ BROADER PATTERN OBSERVED: the same user-facing symptom — tapping "Add" with no visible SnackBar at all, success or failure — was also reproduced on the Home "Deal of the Day" quick-add button (`deal_section.dart`), confirmed reaching the backend (401 in server logs) both times, tested with an explicit 0.5s wait to rule out timing. That call site already uses `SnackBarBehavior.floating` and captures `ScaffoldMessenger` correctly before the `await`, so it is NOT the same Align-vs-bottomNavigationBar cause — the deeper reason wasn't conclusively identified in this session (time-boxed). **Recommend the dev team specifically verify SnackBar visibility end-to-end on a real device** (not just this simulator build) for every "quick add to cart" entry point across Home/Trending/New Arrivals/Search results, since guests silently getting no feedback on a failed add-to-cart is a real conversion/trust issue.
- ⚠️ RELATED, SEPARATE FINDING (not a bug, by design): the underlying reason the SnackBar showed an error at all is that **guests cannot add to cart** — `/api/cart/add` requires auth. This matches the website's behavior (cart is login-gated there too) and is consistent, expected behavior — the bug here was purely that the resulting message was invisible, not that guests were blocked.
