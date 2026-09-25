# ChillFi — Master QA, Responsive Audit, Delhivery Staging & Production Readiness
**Final report · 25 Sep 2026** · Source of truth: `QA/master/{app,website,admin}.json` → the three Master QA PDFs in this folder.
All work is on local branch `delhivery-integration` (committed, **not pushed, not deployed**). Delhivery was used in **staging only**; no production shipment, no real payment.

> **Update — 25 Sep 2026, after owner decisions (asked one by one)**
> - **Deployed to production (twice):**
>   1. all security, money and QA fixes;
>   2. GST-inclusive pricing plus contact details editable in Admin → Settings.
>
>   Health and smoke checks passed; Delhivery is still on staging and PhonePe on UAT.
> - **Read-only production check:** the negative-quantity exploit was **never used** (0 bad order lines, 0 zero/negative orders out of 22).
> - **Ratings:** recalculated on production (9 products; fake seeded ratings removed).
> - **GST:** prices are now GST-inclusive everywhere; the charged total equals the displayed price. Verified on the website, the app and the staging lifecycle (48/48).
> - **Contact details:** single-sourced from Admin → Settings → Store Info (phone, support email, WhatsApp); still the test values, as requested.
> - **Fonts:** Poppins is bundled (SIL OFL), with no runtime downloads.
> - **App release:** `FinalApp/ChillFi-v1.0.3-build4-release.aab` is built and signed with the same upload key as v1.0.2. **You upload it to Play.** Then turn on force update to 1.0.3, because v1.0.2 still shows GST added on top.
> - **Still open:**
>   - COD on the live Delhivery account (you're checking);
>   - the Firebase test number and PhonePe UAT keys (you're providing);
>   - Cloudinary keys.

---

## 1. Executive summary
The whole ChillFi system (Flutter app, React website, admin panel, Node/Express backend, Delhivery staging, PhonePe flow) was inventoried and tested against three project-specific checklists (463 cases). Every achievable case has been executed: **428 PASS, 1 FAIL, 19 BLOCKED (external credentials), 15 N/A, 0 NOT TESTED.**

The core business flow was proven end-to-end against **real Delhivery staging**: product → cart → checkout → order → backend → staging shipment (AWB) → scan events → customer notifications → Delivered. App, website, admin and database all show the same final state (order CF4688283969, AWB 86406910000302).

QA found and fixed **111 defects**, **10 of them Critical**. The most serious:
- a cart negative-quantity price exploit;
- Settings save echoing stored credentials to the browser;
- a coupon bypass at order time;
- payment dev-shortcuts reachable outside development;
- abandoned payments holding stock forever, and late payments on cancelled orders keeping the money.

**These fixes are not yet in production.** Production currently still has the critical issues listed in §11 until the backend is deployed.

**Verdict:** not production-ready until (1) the fixes are deployed and (2) the external blockers in §15 are cleared. After that, all critical acceptance-gate items that can be tested are met.

## 2. Mobile app QA
| Total | Pass | Fail | Blocked | N/A |
|---|---|---|---|---|
| 231 | 203 | 0 | 13 | 15 |

- **Critical issues found (all fixed):** coupon bypass, logout data leak, PhonePe initiate/verify mismatch, negative-quantity exploit, and others (6 in total).
- **Blocked:**
  - 8 cases need the Firebase test phone number (BLK-01: OTP, sign-up, notification permission, push).
  - 4 cases need PhonePe UAT credentials (BLK-02).
  - 1 case needs Cloudinary keys (BLK-03, avatar).
- **N/A:** includes the fake location-permission screen, which was removed.
- **Open:** ADEF-53. Fonts are fetched at runtime; bundling them needs your OK to download the Poppins files.

## 3. Website QA
| Total | Pass | Fail | Blocked | N/A |
|---|---|---|---|---|
| 136 | 131 | 1 | 4 | 0 |

- **Fail:** WEB-15-02, contact details (+91 98765 43210 vs the app's +91 90562 24993; `.in` vs `.com`). This waits on your real details.
- **Blocked:** the OTP boxes need BLK-01; PhonePe UAT is blocked by BLK-02.
- **Critical found (fixed):** 1, the checkout total not matching the amount actually charged.

## 4. Admin panel QA
| Total | Pass | Fail | Blocked | N/A |
|---|---|---|---|---|
| 96 | 94 | 0 | 2 | 0 |

- **Blocked:** image and promo uploads need real Cloudinary keys (BLK-03). Missing keys now give a clear message.
- **Critical found (fixed):**
  - the Settings save response exposed credentials;
  - the Refunds page never loaded;
  - the staff role default was unsafe.

## 5. Responsive testing
Final signed-in run: **510 checks** (30 pages × 17 viewports, 320–1920 px, including account pages and order tracking), with **0 horizontal overflow and 0 JS errors**. The tap audit checked **2,755 interactive elements; 0 were blocked**.

| Device class | Result |
|---|---|
| Mobile | PASS |
| Tablet | PASS |
| Desktop | PASS |

## 6. Admin → App synchronisation — **PASS** (live on emulator)
Each change was made in the admin and then observed in the app:
- **Banner created:** shown first on Home.
- **Coupon deleted:** the offer card switched to the next real coupon.
- **Price edited:** the new price (₹1777) showed in search.
- **Product deactivated:** search returns "No results", the wishlist shows "No longer available", and the product page shows "Product unavailable".
- **COD master switch:** the payment screen toggled "Currently unavailable" ↔ available, live, with no restart.
- **Maintenance mode:** the app showed the maintenance screen with the admin's message; "Check Again" resumed the app.

## 7. Admin → Website synchronisation — **PASS**
Covered by admin suites A–F and the sync probes:
- products, categories, brands, banners, promo banners, testimonials, coupons, shipping rules;
- GST, free-shipping threshold and fee, maintenance (the admin can still sign in), COD switch;
- refunds, order status, reviews.

## 8. Backend / database synchronisation — **PASS**
- **Same order everywhere:** app, website and admin read the same API and show identical order, payment and shipment state (CF4688283969).
- **Revenue:** one definition (Paid and not cancelled) is used by both the dashboard and analytics.
- **Money checks:**
  - stock and coupon usage are consistent after orders, cancels and expiry;
  - the charged total always equals the shown total.

## 9. Delhivery staging result — **48/48 PASS**, final run (real `staging-express.delhivery.com`)
| Area | Result |
|---|---|
| Order creation | ✅ app and website UI, plus the API |
| Shipment creation | ✅ automatic: COD immediately, prepaid once paid |
| Duplicate / parallel re-ship | ✅ refused |
| AWB | ✅ stored, shown in app, website and admin |
| Pickup | ✅ auto-booked; label available |
| Tracking | ✅ customer and admin tracking match |
| Intermediate statuses | ✅ In Transit, at hub, Out for Delivery, failed attempt, RTO |
| Out-of-order / duplicate / unknown events | ✅ ignored or recorded without corrupting the order |
| Delivered | ✅ order Delivered, COD marked Paid, cannot regress |
| Notifications | ✅ placed, manifested, in transit, out for delivery, attempt failed, delivered; no duplicates |
| Cancellation | ✅ before pickup cancels the shipment; after pickup refused; RTO never shown as Delivered |
| Webhook security | ✅ bad/no token → 401, invalid payload → 400 |
| Error handling | ✅ rejections now show an actionable reason, e.g. "COD isn't enabled on this Delhivery account" |

Staging caveat: the staging account has **COD disabled**, so prepaid orders were used (paid through the local dev payment, no money moved). Please confirm COD is enabled on the live Delhivery account.

## 10. Regression result (final, after all fixes)
**Website and admin:** all 17 suites pass, except the expected Cloudinary upload blocks and one harness limitation.

| Suite | Result |
|---|---|
| browse | 17/17 |
| rest1 | 30/30 |
| rest1b | 6/6 |
| rest2 | 22/22 |
| login | 8/8 |
| addr | 3/3 |
| account | 10/10 |
| checkout | 7/7 |
| serviceability | 3/3 |
| maint | 1/1 |
| adminA | 12/13 (ADM-01-04 is a harness limitation, verified in code) |
| adminB | 11/11 |
| adminC | 16/16 |
| adminD | 22/22 |
| adminE | 26/28 (both failures are Cloudinary uploads, BLK-03) |
| adminF | 9/9 |

**Backend:** Delhivery lifecycle 48/48; payment-expiry test 13/13.

**App:** on the emulator, re-verified after the final builds:
- core flows (checkout, COD order, success screen, orders, tracking);
- sync;
- expired session;
- guest prompts.

The analyzer shows only 2 pre-existing lint notes.

Test failures during regression were diagnosed individually. Where it was a test issue (stale selector, leftover data, uppercase CSS text), the suite was made self-contained. Product bugs were fixed: maintenance login lock-out, session sign-out on refresh failure, and account-menu links.

## 11. Security findings (all fixed locally — **production still vulnerable until deployed**)
| ID | Severity | Finding |
|---|---|---|
| ADEF-51 | Critical | Cart accepted negative/zero/huge quantities, so a negative line cut the price (e.g. pay ₹1,000 for ₹5,000) and increased stock |
| ADEF-A9 | Critical | Admin Settings save returned every stored credential (Delhivery/PhonePe secrets) to the browser |
| earlier | Critical | Coupon re-validation missing at order time (expiry, min order, per-user use) |
| earlier | Critical | PhonePe/dev payment shortcuts active whenever NODE_ENV≠production; now require an explicit dev flag |
| earlier | High | Logout didn't clear cart/wishlist (shared device leak); staff role defaulted permissively |
| ADEF-57 / WDEF-29 | High | Any token-refresh hiccup signed users out; parallel refresh race |
| ADEF-A18 | Low | Support staff could open admin-only pages |

Also verified:
- Credentials are masked in the admin UI and encrypted at rest.
- The webhook uses a timing-safe token check.
- 5xx responses never leak internals (a reference ID is logged instead).
- `trust proxy` is set, so the rate limit applies per real client IP.

## 12. Performance / reliability findings
- **Abandoned online payments:** they used to hold stock and coupons forever. They now auto-expire after 2 hours, only when the gateway confirms no payment; a late payment triggers an automatic refund.
- **Admin analytics and refunds:** a stale-response race could show the wrong period; fixed.
- **App search:** repeated identical searches returned stale results; fixed.
- **Fonts:** fetched at runtime (ADEF-53, open), so offline first launch uses fallback fonts.
- **Rate limit:** 200/min per IP in production, configurable upwards for local QA only.

## 13. Fixes implemented
111 defects were fixed across the app (56 logged), website (32) and admin (23). Each has a root cause, fix and retest record in the JSON/PDFs. Highlights beyond §11:
- money correctness: shown total = charged total, GST applied after coupon, auto-refund on paid cancellations, Refunds admin page;
- pincode serviceability and COD rules (store switch, pincode rules, courier) with the reason shown to customers;
- universal friendly error dialogs on app, website and admin;
- removal of fake or placeholder UI (fake ratings, stats, "CHILLFI Cash", location permission, dead buttons and toggles, marked "Not active yet");
- real admin notification bell and top regions;
- local-time dates in the app;
- deactivated products handled everywhere.

## 14. Unresolved issues
| ID | Reason unresolved |
|---|---|
| WEB-15-02 / WDEF-12 contact details | Needs your real phone, email and address (not guessed) |
| ADEF-18 fake seeded ratings on production | Fixed locally; the production recalculation (`scripts/recalc-ratings.js --apply`) needs your permission |
| ADEF-53 runtime fonts | Needs permission to download and bundle the Poppins font files (OFL licence) |
| WDEF-25 FREESHIP banner copy on production | Fixed in seed/local; the production banner text is an admin content edit |
| Store identity (sample GSTIN / address / phone in Settings) | Business identity; you must supply it (nothing customer-facing uses it today) |

## 15. Manual actions remaining
1. **Approve deployment** of backend + website (and later an app release). This is urgent for the security fixes.
2. **Approve one read-only production query** to check for past negative-quantity orders (`order_items.quantity < 1`).
3. **BLK-01:** a Firebase test phone number for OTP, sign-up, push and permission flows.
4. **BLK-02:** PhonePe UAT merchant ID and salt key in the local admin.
5. **BLK-03:** real Cloudinary keys (Admin → API Keys → Media / CDN), and confirm production has them.
6. **COD:** confirm COD is enabled on the live Delhivery account.
7. **GST:** decide whether prices shown are GST-inclusive or GST is added on top (legal requirement).
8. Real contact details and store identity.

## 16. Mobile app production readiness — **Conditionally ready**
Browsing, cart, checkout, COD orders, tracking, sync and error handling all pass. Before release:
- OTP login and PhonePe must be verified on a real device (BLK-01/02);
- bundle fonts (ADEF-53);
- ship a new build containing the fixes (current store build v1.0.2+3 predates them).

## 17. Website production readiness — **Ready after deploy + contact details**
All flows pass, and the responsive audit is clean. Remaining before launch:
- the contact-details fix;
- a PhonePe UAT verification.

## 18. Admin panel production readiness — **Ready after deploy**
All operational workflows pass, and there are no dead ends. Image upload needs Cloudinary keys.

## 19. Backend / integration readiness — **Ready after deploy + go-live checklist**
- Delhivery is proven on staging (48/48).
- Go-live runbook: `QA/DELHIVERY_GO_LIVE.md`.
- Production must stay on staging until you approve the switch; the switch has a confirmation dialog.
- PhonePe production is not activated.

## 20. Final production blockers
1. Critical security fixes not yet deployed (§11).
2. Real-device verification of OTP login and PhonePe payment (BLK-01/02).
3. COD availability on the live Delhivery account.
4. GST display decision and real contact / store-identity details.

## 21. Next actions
1. You approve deploy → run `deploy_backend.sh --apply --web` (dry run first), then smoke-test production.
2. Run the read-only production exploit check. If approved, apply the ratings recalculation.
3. Provide the Firebase test number, PhonePe UAT and Cloudinary keys → I resume the 19 blocked cases.
4. Bundle fonts, then build and upload a new app release.
5. Delhivery go-live per the runbook, only on your explicit instruction.
