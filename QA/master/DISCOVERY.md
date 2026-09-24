# ChillFi — Phase 1 Discovery (fresh, 24 Sep 2026)

Source of truth = the code as it is today (not previous QA). Classifications are from reading the
implementation; every item is re-verified at runtime in Phases 4–8 before being marked PASS/FAIL.

## System map
| Layer | Tech | Where |
|---|---|---|
| Mobile app | Flutter (Android built/tested on Pixel 9 emulator) | `lib/` — 42 reachable screens, 11 unreachable screens |
| Website + Admin | React/Vite SPA (admin = `/admin/*`) | `web/website` — 29 customer routes, 17 admin pages |
| Backend | Node/Express | `backend/src` — 148 endpoints (34 public, 42 customer, 71 staff/admin, 1 optional-auth) |
| Database | PostgreSQL | 29 tables |
| Shipping | Delhivery B2C (staging verified), Shiprocket (legacy code path) | `backend/src/utils/delhivery.js`, `services/shipmentService.js` |
| Payments | PhonePe v1 (UAT on prod), dev fake payment locally | `utils/phonepe.js`, `controllers/paymentController.js` |
| Notifications | In-app (DB) + FCM push | `utils/notify.js`, `utils/firebase.js` |
| Hosting | EC2 (pm2 cluster ×2, nginx), https://chillfi.in | `deploy_backend.sh` |

## Public endpoint security review (34)
All public endpoints are catalogue/auth/webhook/callback by design. Checked: `POST /profile/request-delete`
requires a valid OTP for that phone; `/payment/dev-success` is not registered in production (prod → 401).

## Candidate defects found by code inspection (to confirm at runtime)
Severity: C = critical (money/data/security/blocked core flow), H = high, M = medium, L = low/cosmetic.

### Backend / cross-cutting
- H: Public product lists & home only show `status='Active'` → products marked "Low Stock"/"Out of Stock" vanish from storefront; deleted (Inactive) product still reachable by direct URL.
- H: Admin category/brand/product lists hide inactive items → cannot re-enable after deactivating.
- M: Coupon re-check at order creation ignores expiry/min-order; Free-Shipping coupon shows hard-coded ₹49 at apply time.
- M: Dashboard revenue (Paid only) vs Analytics revenue (all orders incl. cancelled) disagree.
- M: `/app-config` maintenance gate blocks website `/login` for admins.
- M: Admin settings Cloudinary keys not used (upload reads env only).

### Admin panel
- C: Refunds page calls non-existent endpoints (`/orders/admin/refunds`) → page empty; correct `/admin/refund-requests` unused.
- C: Add Product likely crashes page (response shape misread); brand/category never saved (UI sends names, API expects ids).
- M: Users "Remove" is a fake block; staff see admin-only order buttons (403); role cache not cleared on logout.
- M: Orders list Qty always 1; only first 200 rows loaded; status changes unrestricted.
- M: Banners `background_color` dropped; brand logo URL only (no upload); coupon/shipping-rule fields cannot be cleared.
- L: Many Settings toggles/fields not read anywhere (store info, feature toggles, payment toggles, security, SEO, express/COD toggles) — placeholders.
- L: Header bell static; Analytics "Top Regions" placeholder; message replies not emailed (no mailer).

### Website
- H: Mobile/tablet (<1024px) have no product filters and no account navigation (sidebars `hidden lg:block`).
- H: ProductCard wishlist/cart buttons hover-only → unusable on touch.
- H: Cart shows delivery "Free" but checkout charges ₹49; Express ₹79 shown but never charged (displayed total ≠ order total).
- H: Checkout clears cart before cod-confirm/initiate finish; failure lands user on empty cart; order-failed page never shows reason (reads state, backend sends query) and wrongly says cart is saved.
- M: Checkout/address forms: no phone/pincode format validation; save errors swallowed.
- M: Related products use wrong param (`category_id`) → not same-category.
- M: Guest wishlist click hard-redirects to /login; header wishlist badge desyncs.
- M: Order success page shows "Payment Confirmed" even for COD / direct URL; order list "(1 Item)" and delivery date "—" always.
- M: Dead CTAs: Support page (almost all), PLP hero "Shop Now", Offers tabs/hero, bank offers T&C, Refer Now, Premium, Buy Again, Find Order, Share Wishlist, Rate & Review, Help Center, map zoom, About "Explore", brands "View All", search-bar "All Categories".
- M: Newsletter shows fake "subscribed" (no API).
- L: Dummy contact details (+91 98765 43210, Bengaluru address, support@chillfi.com vs .in) — needs real business info (manual).
- L: `/delete-account` page not linked anywhere; placeholder image service (via.placeholder.com) dead.
- Responsive (to measure): login OTP row, PLP pagination, cart rows, tracking header buttons, contact grid, address form grid-cols-2, static hero art.

### Mobile app
- C: Orders tab back button pops the only route → blank screen.
- H: Checkout address sheet: no validation, silent failure; address delete without confirmation.
- H: Cancel order can send an empty reason (UI shows first reason selected, state empty).
- H: Force-update compares against hard-coded `appVersion='1.0.0'` (build is 1.0.2+3) → setting min version 1.0.1+ locks out current users.
- H: Maintenance screen buttons do nothing (user stuck).
- M: Product image gallery is entirely dummy (6 phone icons, iPhone specs).
- M: Home hero banner ignores its link; Home mic result discarded; listing search box dead; "Filter" only a snackbar.
- M: Reviews: filter chips, sort, helpful thumbs, bottom "Add to Cart" are no-ops.
- M: Discovery screens: category chips/"View All"/Notify/Shop Now no-ops; several highlight the wrong bottom-nav tab.
- M: Location/Notification permission screens don't request OS permissions.
- M: Saved Addresses / Recently Viewed screens exist but unreachable from profile.
- M: Signup password field unused; "Reset via Email" sends nothing; reset password confirm not compared; strength meter static.
- L: About "Version 2.5.0", hard-coded stats; Privacy policy only 1 of 9 sections; Help "Connect" no-op; tel link missing "+".
- L: No connectivity handling (NoInternetScreen unreachable).

## Delhivery (already verified on real staging 24 Sep; re-tested in Phase 8)
Create/AWB, duplicate recovery, tracking (single/batch/ref), pickup, label, cancel, webhook lifecycle, notifications.
Staging account has COD disabled (Delhivery-side).
