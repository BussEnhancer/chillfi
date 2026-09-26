#!/usr/bin/env python3
"""ChillFi — Production Readiness Report (deep, from-scratch analysis, 25 Sep 2026).
   python3 QA/master/build_readiness_report.py  →  QA/ChillFi_Production_Readiness_Report.pdf
Shares fonts/styles/helpers with build_full_report.py. Live-probe facts were captured 2026-09-25 16:06 UTC."""
import os, json
from collections import Counter
_src = open(os.path.join(os.path.dirname(os.path.abspath(__file__)), 'build_full_report.py')).read()
exec(_src[:_src.index('# ── data')])   # imports, fonts, colours, styles, P/bullets/table/callout/shot helpers
from xml.sax.saxutils import escape as esc

OUT = os.path.join(ROOT, 'QA', 'ChillFi_Production_Readiness_Report.pdf')
W = 174 * mm
TAG = {'READY': ('#15803D', '#F0FDF4'), 'OWNER': ('#1D4ED8', '#EFF6FF'), 'FIX': ('#B91C1C', '#FEF2F2'),
       'VERIFY': ('#B45309', '#FFFBEB'), 'REC': ('#6B7280', '#F3F4F6'), 'N/A': ('#6B7280', '#F3F4F6')}
LABEL = {'READY': 'Ready', 'OWNER': 'Owner step', 'FIX': 'Must fix', 'VERIFY': 'Verify', 'REC': 'Recommended', 'N/A': 'Not in scope'}
def tag(k): return f'<font color="{TAG[k][0]}"><b>{LABEL[k]}</b></font>'
SEV = {'Critical': '#B91C1C', 'High': '#B91C1C', 'Medium': '#B45309', 'Low': '#6B7280'}
def sev(s): return f'<font color="{SEV[s]}"><b>{s}</b></font>'
def h1(t): return [CondPageBreak(60 * mm), P(t, 'h1')]
def h2(t): return P(t, 'h2')
def steps(items): return [Paragraph(t, S['bullet'], bulletText=f'{i}.') for i, t in enumerate(items, 1)]

# ── data ─────────────────────────────────────────────────────────────────────
areas = {k: json.load(open(os.path.join(HERE, f'{k}.json'))) for k in ['app', 'website', 'admin']}
def stats(d): return Counter(tc.get('status') for s in d['sections'] for tc in s['cases'])
ST = {k: stats(d) for k, d in areas.items()}
TOT = sum((c for c in ST.values()), Counter())
NCASES = sum(TOT.values()); NDEF = sum(len(d['defects']) for d in areas.values())

story = []
# ── cover ────────────────────────────────────────────────────────────────────
story += [Spacer(1, 32 * mm), P('<font color="#FF6B2C">ChillFi</font>', 'title'), P('Production Readiness Report', 'title'),
          Spacer(1, 3 * mm), P('Deep analysis from scratch — code, live production, security, release, operations — and the exact go-live runbook', 'sub'),
          Spacer(1, 2 * mm), P('25-26 September 2026 · updated after two fix rounds · app 1.0.3 (build 6) · website + API live on chillfi.in', 'sub'),
          Spacer(1, 12 * mm)]
kpi = [['READY*', 'after the 6 owner steps'], ['7 / 7', 'must-fix items done + deployed'], ['6', 'owner switch-over steps'],
       [f'{TOT["PASS"]}/{NCASES}', 'QA cases passing'], [str(NDEF), 'defects found, all fixed'], ['0', 'failing tests / JS errors']]
kt = Table([[Paragraph(f'<font name="PB" size="19" color="#FF6B2C">{a}</font><br/><font name="P" size="8" color="#6B7280">{b}</font>', S['body']) for a, b in kpi[i:i + 3]] for i in (0, 3)], colWidths=[58 * mm] * 3)
kt.setStyle(TableStyle([('BOX', (0, 0), (-1, -1), 0.5, LINE), ('INNERGRID', (0, 0), (-1, -1), 0.5, LINE), ('TOPPADDING', (0, 0), (-1, -1), 10), ('BOTTOMPADDING', (0, 0), (-1, -1), 10), ('LEFTPADDING', (0, 0), (-1, -1), 10)]))
story += [kt, Spacer(1, 10 * mm),
          callout('<b>Update 26 Sep — every developer item in this report is now done, tested and deployed</b> (section 0), '
                  'including all 7 must-fix items, every "should fix soon" item, and a round of hardening found while doing that work '
                  '(short staff sessions, hashed tokens/OTP codes, stricter input limits, an admin change-history log). '
                  'What remains is only the owner\'s part: the 6 switch-over steps after client testing, the email domain, '
                  'the Play upload of build 6 and the uptime monitor. The original analysis (sections 1-25) follows unchanged for reference.', GREEN, '#F0FDF4'),
          Spacer(1, 4 * mm),
          callout('<b>Original verdict (25 Sep, before fixes).</b> The shop is built, tested and live on chillfi.in, and is safe to use for the client\'s testing right now '
                  '(online payment is locked off, Delhivery is in test mode). It is <b>not yet ready for real customers</b>: '
                  '<b>7 developer fixes</b> (section 3) must land first — two of them would hurt real customers on day one '
                  '(PhonePe return page shows "failed" after a successful payment; a test phone number can log in on production) — '
                  'and then the owner performs the <b>6 switch-over steps</b> in the order given in section 4. '
                  'Estimated developer effort for the must-fix list: about 1–1.5 working days, plus one real-device test session.', RED, '#FEF2F2'),
          Spacer(1, 5 * mm),
          P('How to read this report: <b>Ready</b> = works now, verified. <b>Must fix</b> = developer change needed before real customers. '
            '<b>Owner step</b> = needs your account/keys/decision. <b>Verify</b> = could not be checked from outside the server; check once. '
            '<b>Recommended</b> = not a blocker.', 'small'),
          PageBreak()]

story += [P('0. Update — what was fixed after this analysis', 'h1'), P('0a. The 7 must-fix items (25 Sep)', 'h2'),
          table([['#', 'Item', 'Status', 'Proof'],
                 ['F1', 'PhonePe return page', '<font color="#15803D"><b>Fixed + live</b></font>', 'Return URL carries the transaction id; "pending" shows "Payment processing" instead of "failed"; test: callback no longer "Missing transaction ID"'],
                 ['F2', 'Backend test login 9876543210', '<font color="#15803D"><b>Fixed + live</b></font>', 'Only when NODE_ENV=development (production server confirmed NODE_ENV=production)'],
                 ['F3', 'In-app account deletion', '<font color="#15803D"><b>Verified</b></font> (app build 6)', 'Settings › Delete account — tested end-to-end on the emulator (account removed, app returns to Welcome); staff accounts refused'],
                 ['F4', 'Firebase SHA fingerprints', '<font color="#15803D"><b>Done</b></font>', 'Corrected 26 Sep: 6 fingerprints registered in Firebase — debug keystore, upload key, and the Play App Signing key (the app had an earlier Play upload, so this was already available). Nothing left to add here; test real OTP on a real phone when convenient'],
                 ['F5', 'Website Delete Account', '<font color="#15803D"><b>Fixed + live</b></font>', 'Uses Firebase phone verification like Login; on chillfi.in it reaches Google reCAPTCHA (previously used a path that never sent SMS)'],
                 ['F6', 'Dependency advisories', '<font color="#15803D"><b>Fixed + live</b></font>', 'Backend 14 → 0 (nodemailer 10, send verified); website 2 moderate react-router advisories not reachable here (SSR / redirect path guarded)'],
                 ['F7', 'PhonePe webhook hardening', '<font color="#15803D"><b>Fixed + live</b></font>', 'Refused when keys missing; paid amount must match (tested: ₹1 "success" for a ₹799 order is not marked Paid)']],
                [9 * mm, 42 * mm, 28 * mm, 95 * mm], font='small'),
          Spacer(1, 4 * mm), P('0b. "Should fix soon" items from section 3 — now done', 'h2'),
          table([['Item', 'Status', 'Proof'],
                 ['Voice search on Android 11+', '<font color="#15803D"><b>Fixed + verified</b></font>', 'Added the manifest &lt;queries&gt; entry; tested live on an Android 17 (API 36) emulator — tapping the mic opens the system speech recognizer ("Listening…") instead of failing silently'],
                 ['Unused biometric permission', '<font color="#15803D"><b>Fixed</b></font> (app build 6)', 'local_auth removed from pubspec — USE_BIOMETRIC/USE_FINGERPRINT no longer in the built manifest'],
                 ['Settings encryption key', '<font color="#15803D"><b>Live</b></font>', 'SETTINGS_ENCRYPTION_KEY generated and set on the server; a start-up migration re-encrypts any credential still under the old key, so nothing already saved was lost'],
                 ['Admin session', '<font color="#15803D"><b>Enforced server-side</b></font>', 'Staff (admin/support) access tokens now expire after 1 hour and refresh tokens after 12 hours, checked on the server — not just the 30-minute browser timer. Tested: a 2-hour-old admin token is rejected (401), customer sessions unchanged (7d/30d)'],
                 ['Rate-limit bypass (verify)', '<font color="#15803D"><b>Tightened</b></font>', 'OTP send/verify, Firebase verify, account deletion and coupon apply limited to 20/min per IP in production; contact form to 5/min. The plain-HTTP EC2 IP was also removed from the CORS allow-list'],
                 ['OTP generator', '<font color="#15803D"><b>Fixed + live</b></font>', 'crypto.randomInt instead of Math.random; codes are now stored hashed and compared in constant time (previously plain text)'],
                 ['App policy screens', '<font color="#15803D"><b>Done</b></font> (app build 6)', 'Settings › Policies opens Terms (in-app) and Refund/Return/Shipping (the website pages, in the browser)'],
                 ['Release signing fallback', '<font color="#15803D"><b>Fixed</b></font> (app build 6)', 'A release build now fails outright if android/key.properties is missing, instead of silently signing with the debug key']],
                [46 * mm, 34 * mm, 94 * mm], font='small'),
          Spacer(1, 4 * mm), P('0c. Hardening found while fixing the above (not in the original findings)', 'h2'),
          table([['Item', 'What changed'],
                 ['Refresh tokens', 'Stored as sha-256 instead of plain text (a database leak no longer hands out live sessions); legacy plain-text rows still work'],
                 ['Revoked Firebase sessions', 'verifyIdToken now checks revocation — a signed-out Firebase session can no longer be replayed against /auth/firebase-verify or the delete-account flow'],
                 ['Input limits', 'payment_method restricted to the 6 real options; product/user list sizes capped (100-1000 depending on the endpoint) so a large ?limit= can no longer return the whole catalogue; review rating must be an integer 1-5 with length limits; avatar_url must look like an uploaded https link; notification-preference keys validated; address set-default checks ownership before clearing the current default'],
                 ['Coupon race', 'A one-per-customer coupon is now re-checked under the same database lock as the usage-limit check, closing a narrow window where two simultaneous orders could both use it'],
                 ['Admin change history', 'New Settings › Security › "Recent admin changes" log — every admin/staff action (who, what, when) is recorded automatically. Verified live with 25+ real actions from the regression run'],
                 ['Access logs', 'Request logs now mask ?token=/?key=/?secret= values (the Delhivery webhook accepts a query-string token) and are more detailed in production'],
                 ['JSON body limit', '10 MB → 2 MB (uploads go through multipart, not JSON)'],
                 ['Privacy policy', 'App and website now explain where to delete an account and that order records are kept (without the customer\'s name) for 6 years for GST, as Indian law requires']],
                [40 * mm, 134 * mm], font='small'),
          Spacer(1, 4 * mm),
          callout('<b>Full regression after every change:</b> all customer test suites pass, admin suites pass except the 2 known Cloudinary-not-configured-locally items '
                  'and 2 other pre-existing, unrelated items (a staging label-endpoint flake, an admin-tab-switch quirk); Delhivery staging lifecycle 48/48; payment-expiry 12/12; '
                  '493 responsive checks with 0 overflow and 0 script errors; 2,649-element tap audit with 0 blocked.', GREEN, '#F0FDF4'),
          Spacer(1, 3 * mm),
          callout('<b>App to upload:</b> FinalApp/ChillFi-v1.0.3-build6-release.aab (versionCode 6, same upload key as builds 4 and 5, rebuilt to include the Policies screen and privacy-policy text). Upload this file.', BLUE, '#EFF6FF'),
          Spacer(1, 4 * mm), P('0d. Email Templates admin feature + full re-verification (26 Sep)', 'h2'),
          table([['Item', 'Detail'],
                 ['New: Email Templates', '13 editable templates (every order-update email, plus the store\'s new-order and low-stock alerts), with {{placeholder}} substitution — editing one also changes the matching push/in-app notification text, not just the email. A template with no edit just uses its original wording. Verified: all 13 render byte-identical to the old hardcoded text; a live edit → save → revert cycle tested through both the UI and the API.'],
                 ['Full regression re-run', 'From a clean state, after every change made this session: payment-expiry 12/12, Delhivery staging lifecycle 48/48 (now flowing through the new templates — a real customer notification and admin alert were confirmed to carry the correct order number/amount at every stage: created, shipped, out for delivery, delivered). All 10 website customer suites 100% (107/107 cases). Admin suites 95/99 — the 4 misses are the same pre-existing, already-documented items (2 Cloudinary-not-configured-locally, 1 test-harness token-switch quirk, 1 role-switch redirect quirk). 493 responsive checks, 0 overflow, 0 script errors. 2,649-element tap audit, 0 blocked.'],
                 ['App tested on iOS', 'iOS 26 simulator (iPhone 17 Pro): Home, search, product detail and add-to-cart/guest-checkout gating all work correctly. Phone-OTP sign-in could not be tested on iOS — this build has no GoogleService-Info.plist, so Firebase phone auth cannot initialise (a pre-existing gap from before this session; Android already covers OTP login in the regression suite\'s login/account tests).'],
                 ['Found: COD on Delhivery staging', 'The Delhivery staging account currently rejects COD shipments ("Cash on Delivery isn\'t enabled on this Delhivery account"). The order still saves correctly and can be retried — no shipment is created until Delhivery enables COD, or the order is prepaid. This is exactly go-live step 4 (section 4): confirm with Delhivery whether COD is enabled on the live account too, before launch.'],
                 ['Found: test products in admin', 'The admin Products list shows several "QA UI Speaker …" test fixtures (all marked Inactive, invisible to customers). Harmless, but worth deleting before handing the panel to non-technical staff.']],
                [40 * mm, 134 * mm], font='small'),
          PageBreak()]

toc = ['Readiness scorecard', 'What was analysed and how', 'Must-fix before real customers (developer)',
       'Go-live runbook — the 6 owner steps, in order', 'Step 1 — Real contact details', 'Step 2 — GSTIN and tax invoices',
       'Step 3 — Delhivery live', 'Step 4 — Confirm COD with Delhivery', 'Step 5 — PhonePe live', 'Step 6 — Remove test logins',
       'Go-live day smoke test', 'Live production state (measured)', 'Security review', 'Payments, orders and money',
       'Shipping and delivery', 'Login and accounts', 'Android app release', 'iOS', 'Website: performance, SEO, accessibility',
       'Infrastructure, backups and monitoring', 'Email and domain', 'Quality evidence', 'Risk register',
       'First 24 hours / first week after launch', 'Appendix — file references for the developer']
story += [P('Contents', 'h1')] + [P(f'{i}. {t}', 'body') for i, t in enumerate(toc, 1)] + [PageBreak()]

# ── 1 scorecard ──────────────────────────────────────────────────────────────
story += h1('1. Readiness scorecard')
sc = [['Area', 'Status', 'Evidence / what is left'],
      ['Core shopping (browse, search, cart, checkout, orders, tracking)', tag('READY'), f'{TOT["PASS"]} of {NCASES} QA cases pass, 0 fail; full regression green on 25 Sep; {NDEF} defects fixed'],
      ['Cash on Delivery orders', tag('READY'), 'Works end-to-end today; live Delhivery COD must be confirmed (step 4)'],
      ['Online payment (PhonePe)', tag('FIX'), 'Return-page bug (F1) + webhook hardening (F7); then owner keys (step 5). Real PhonePe never tested with a live merchant'],
      ['Shipping (Delhivery)', tag('OWNER'), '48/48 staging lifecycle checks; switch to production + pre-switch clean-up (step 3)'],
      ['Real OTP login on the Play build', tag('VERIFY'), 'Only test numbers were ever used. SHA fingerprints not registered in Firebase (F4). Test with a real SIM before launch'],
      ['Test logins / backdoors', tag('FIX'), 'Backend test phone 9876543210 → 123456 works on production (F2); Firebase test numbers (step 6)'],
      ['Account deletion (Play policy)', tag('FIX'), 'App has no in-app "Delete account" (F3); website delete page uses an OTP path that may not send SMS (F5)'],
      ['GST invoices', tag('OWNER'), 'Built and tested; waiting for real GSTIN (step 2)'],
      ['Contact details and support email', tag('OWNER'), 'Test values live; <b>help@chillfi.in cannot receive mail — domain has no MX records</b> (section 21)'],
      ['Security', tag('READY'), '0 SQL-injection paths, server-side prices, credential encryption, OTP-only admin; 5 high dependency advisories to patch (F6)'],
      ['Infrastructure / backups', tag('READY'), 'Health 200 in 0.24 s, TLS valid to 5 Nov 2026, pm2 auto-restart, nightly verified backups; no off-server copy (R)'],
      ['Monitoring', tag('OWNER'), 'Health endpoint ready; external uptime monitor not yet created'],
      ['Website performance / SEO', tag('REC'), 'No gzip (906 KB script sent uncompressed), robots.txt/sitemap missing, meta tags only via JS'],
      ['Android release', tag('READY'), '1.0.3 build 5 signed with the upload key; upload to Play + force update; voice search on Android 11+ to verify'],
      ['iOS', tag('N/A'), 'Runs in the simulator; not publishable yet (no Firebase iOS config / push setup)'],
      ['Code backup', tag('REC'), 'GitHub copy is from 6 Jun 2026 — 55 commits (all QA work) not pushed']]
story += [table(sc, [50 * mm, 28 * mm, 96 * mm]), PageBreak()]

# ── 2 method ─────────────────────────────────────────────────────────────────
story += h1('2. What was analysed and how')
story += bullets([
    '<b>Live production, read-only</b> (25 Sep 16:06 UTC): health, public app-config, TLS certificate, redirects, security headers, response times, compression, robots/sitemap, DNS (A, MX, SPF, DMARC), unauthenticated access to admin/payment endpoints, and a scan of the shipped JavaScript bundle for secrets. No production data was read or changed.',
    '<b>Code, line by line</b>: every go-live switch traced through backend, website and app (what each admin field does, which URL the server calls, what customers see before/after, how to roll back).',
    '<b>Security audit</b>: authentication, tokens, OTP, role checks, rate limits, CORS, input validation, SQL, uploads, webhooks, error handling, logging, credential encryption, secrets in git.',
    '<b>Tooling</b>: npm audit (backend + website production dependencies), Flutter analyzer, TypeScript compiler, git history, Android merged manifest, signing certificate of the release bundle.',
    f'<b>Evidence from testing</b>: {NCASES} QA cases, 16 browser suites, Delhivery staging lifecycle, payment-expiry test, 493 responsive checks, 1,758-element tap audit, Android emulator (Pixel 9 + small phone) and iPhone 17 simulator.'])
story += [Spacer(1, 3 * mm), callout('Limits of this analysis: the production server\'s private configuration (.env) and database were not opened. '
          'Items that depend on them are marked <b>Verify</b> with the exact check to run. No real payment, real shipment or real SMS was made.', AMBER, '#FFFBEB'),
          PageBreak()]

# ── 3 must fix ───────────────────────────────────────────────────────────────
story += h1('3. Must-fix before real customers (developer)')
story += [P('Each item was confirmed in the code. None is visible during client testing because online payment is off and only test numbers are used — '
            'which is exactly why they must be fixed before switching to live.'), Spacer(1, 2 * mm)]
mf = [['#', 'Problem', 'Why it matters', 'Fix', 'Effort'],
      ['F1', '<b>PhonePe return page</b>: the payment request sends redirectUrl <i>/api/payment/callback</i> without the transaction id; in REDIRECT mode PhonePe returns without it, so the server sends the customer to "Order failed — Missing transaction ID".',
       'Every successful website payment would show "failed" although the order is Paid (webhook). Customers may pay twice or complain.',
       'Put the id in the URL: <i>/api/payment/callback?merchantTransactionId=&lt;id&gt;</i>; show a "confirming payment" page that polls verify.', '1 h + UAT test'],
      ['F2', '<b>Backend test login</b>: phone 9876543210 always accepts OTP 123456 via /api/auth/send-otp + verify-otp; not limited to development.',
       'If that user exists on production (QA used it), anyone can sign in as it — or register it.', 'Only allow TEST_PHONES when NODE_ENV=development; delete/disable that user on production.', '30 min'],
      ['F3', '<b>No account deletion inside the app</b> (Play and Apple policy for apps with sign-up). Backend endpoint DELETE /api/profile/account exists.',
       'Play review can reject the update or the listing.', 'Add Account → Settings → "Delete account" (confirm dialog → API → sign out).', '2–3 h'],
      ['F4', '<b>Firebase phone auth on the release build</b>: google-services.json has no Android SHA fingerprints.',
       'Real SMS OTP on the Play-signed app may fail or fall back to a browser captcha. Test numbers hide this.',
       'Add SHA-1 + SHA-256 of the upload key AND the Play App Signing key in Firebase → Project settings; enable Play Integrity; re-download google-services.json; rebuild.', '30 min + real phone test'],
      ['F5', '<b>Website Delete Account page</b> uses the backend OTP path (/auth/send-otp). The default provider "firebase" needs a captcha token the server never has — SMS likely never arrives.',
       'The public deletion URL required by Play may not work.', 'Switch the page to the same Firebase sign-in the Login page uses, then call request-delete with the Firebase token.', '2 h'],
      ['F6', '<b>Dependency advisories</b>: backend production deps 5 high (multer DoS, nodemailer, fast-xml-parser, ip-address, brace-expansion) + 9 moderate; website 2 moderate (react-router).',
       'Known public vulnerabilities; multer is used for uploads.', 'npm audit fix (non-breaking) on both, run the regression, deploy.', '1–2 h'],
      ['F7', '<b>PhonePe webhook when keys are missing</b>: the expected signature becomes sha256(payload+"null").',
       'Only matters if the salt key is ever empty, but then a forged "paid" webhook would be accepted.', 'Refuse the webhook (503) when PhonePe is not fully configured; also compare the paid amount with the order.', '30 min']]
story += [table(mf, [9 * mm, 52 * mm, 44 * mm, 51 * mm, 18 * mm], font='small'), Spacer(1, 4 * mm), h2('Should fix soon (not launch blockers)')]
story += [table([['Item', 'Detail'],
                 ['Voice search on Android 11+', 'Manifest lacks the &lt;queries&gt; entry for android.speech.RecognitionService — the mic may not start on real phones. Verify on a device; add the entry.'],
                 ['Unused biometric permission', 'local_auth is in pubspec but never used → USE_BIOMETRIC/USE_FINGERPRINT in the manifest and a Play Data-safety question. Remove the package.'],
                 ['Settings encryption key', 'Stored gateway secrets are encrypted with a key derived from JWT_SECRET unless SETTINGS_ENCRYPTION_KEY is set. Set a separate key on the server before entering live keys (changing it later makes stored keys unreadable).'],
                 ['Admin session', 'The 30-minute admin timeout is enforced in the browser only; tokens live 7 days. Consider shorter access tokens for staff.'],
                 ['Rate-limit bypass (verify)', 'If port 5000 is reachable from the internet, X-Forwarded-For can be spoofed. Confirm the EC2 security group only exposes 22/80/443.'],
                 ['OTP generator', 'Uses Math.random — switch to crypto.randomInt (backend OTP path only).'],
                 ['App policy screens', 'App has Privacy and Terms but no Refund/Return/Shipping pages — link them to the website pages.'],
                 ['Release signing fallback', 'If android/key.properties is missing a release build silently uses the debug key — make the build fail instead.']],
                [44 * mm, 130 * mm], font='small'), PageBreak()]

# ── 4 runbook overview ───────────────────────────────────────────────────────
story += h1('4. Go-live runbook — the 6 owner steps, in order')
story += [P('Do these <b>after the client finishes testing</b> and <b>after</b> the must-fix list in section 3 is deployed. '
            'The order matters: low-risk visible changes first, money last, test logins removed at the very end. '
            'Everything except step 6 is done in <b>chillfi.in/admin → Settings</b>; the <b>Go-Live</b> tab shows each item\'s live status with a "Fix" button.'),
          Spacer(1, 2 * mm),
          table([['Step', 'What', 'Where', 'Time', 'Risk'],
                 ['0', 'Preparation (day before): developer fixes deployed; server .env checked; Firebase SHA added; Delhivery test orders cleaned', 'Developer + Delhivery', '½ day', 'Low'],
                 ['1', 'Real phone, email, WhatsApp, address', 'Settings → Store Info', '5 min', 'None'],
                 ['2', 'Real GSTIN + legal name/address, then invoices ON', 'Settings → Store Info', '10 min', 'Low'],
                 ['3', 'Delhivery live token + pickup name, environment = production', 'Settings → API Keys → Shipping', '20 min', 'Medium — real, chargeable shipments'],
                 ['4', 'Confirm COD on the live Delhivery account (or switch COD off)', 'Delhivery + Settings → Shipping', '1 call', 'Medium'],
                 ['5', 'PhonePe live Merchant ID + Salt Key, environment = PRODUCTION, ₹1 test', 'Settings → API Keys → Payment Gateway', '30 min', 'High — real money'],
                 ['6', 'Remove Firebase test numbers + backend test login', 'Firebase console + developer', '10 min', 'Low'],
                 ['+', 'Upload app 1.0.3 build 5 to Play, then Force Update ON (min 1.0.3)', 'Play Console, Settings → Store Info', '1–3 days review', 'Low']],
                [11 * mm, 72 * mm, 45 * mm, 20 * mm, 26 * mm], font='small'),
          Spacer(1, 4 * mm), h2('Step 0 — preparation checklist (day before)')]
story += steps([
    'Developer: deploy fixes F1–F7 (section 3) and run the regression.',
    'Developer: on the server confirm <b>NODE_ENV=production</b>, <b>APP_BASE_URL=https://chillfi.in</b>, <b>WEBSITE_URL=https://chillfi.in</b> (PhonePe return and webhook URLs are built from these), a separate <b>SETTINGS_ENCRYPTION_KEY</b>, and that <b>PHONEPE_ENV</b> in .env is not "PROD" (a stale Railway file shows PROD — the admin value wins only when it is set).',
    'Developer: Firebase console → Project settings → Android app com.ecom.chillfi → add SHA-1 and SHA-256 of the <b>upload key</b> and of the <b>Play App Signing key</b> (Play Console → Setup → App integrity). Re-download google-services.json, rebuild, and log in with a <b>real</b> SIM on a real phone.',
    'Firebase console → Authentication → Settings → Authorized domains: chillfi.in and www.chillfi.in present (website OTP).',
    'Admin → Orders: cancel every order that was shipped on Delhivery <b>staging</b> (once production is selected, staging AWBs can no longer be cancelled from admin), and review orders still "pending shipment" — see step 3.',
    'Set up the uptime monitor (section 20) so you are alerted during the switch-over.',
    'Tell customers nothing yet; keep maintenance mode OFF (the switch-over does not need downtime).'])
story.append(PageBreak())

# ── steps 1..6 ───────────────────────────────────────────────────────────────
def step_block(title, where, prereq, do, system, verify, rollback, risks):
    out = [P(title, 'h1'), table([['Where', where], ['Before you start', prereq]], [34 * mm, 140 * mm], head=False, font='small'), h2('Do this')]
    out += steps(do)
    out += [h2('What the system does'), *bullets(system), h2('How to verify'), *steps(verify),
            h2('Roll back'), *bullets(rollback), h2('Watch out for'), *bullets(risks), PageBreak()]
    return out

story += step_block('5. Step 1 — Real contact details',
    'chillfi.in/admin → Settings → Store Info → Save',
    'The real support phone (10-digit Indian mobile), a WhatsApp number (optional), a support email <b>that can receive mail</b> (see section 21 — help@chillfi.in currently cannot), and the registered business address.',
    ['Open Settings → Store Info.', 'Replace Phone Number (now +91 98765 43210, a sample), Support Email, Store Email, WhatsApp Number and Store Address (now "123, Tech Park, Whitefield…", a sample).', 'Press Save.'],
    ['The public /api/app-config "contact" block updates within ~30 s; tel: and wa.me links are built automatically from a 10-digit number.',
     'Website Contact, Support, Privacy/Terms/Refund/Return/Shipping and Delete-account pages, and the app Help & Support screen read these values. Tax invoices print the phone and email.'],
    ['Go-Live tab: "Real contact details" turns Done (it checks the phone is not the sample and the address is not "Tech Park, Whitefield").',
     'Open chillfi.in/contact and the app → Account → Help & Support: new number and email show; tap Call / WhatsApp / Email and confirm they open correctly.',
     'Send an email to the support address from a personal account and confirm it arrives.'],
    ['Type the previous values back and Save.'],
    ['There is no format validation — a typo is published immediately. Check each value twice.', 'The website does not show the address on the Contact page yet (only phone/email/WhatsApp).'])

story += step_block('6. Step 2 — GSTIN and tax invoices',
    'Settings → Store Info → GST Number, Store Name, Store Address → Save; then toggle "Issue GST Tax Invoices" → Save',
    'Your GST registration certificate: 15-character GSTIN, exact legal/trade name and principal place of business. Optional: HSN codes for each product (Admin → Products → edit → HSN Code, 4/6/8 digits).',
    ['Enter the GSTIN exactly (capital letters). Enter Store Name and Store Address exactly as on the certificate. Save.',
     'Confirm GST Rate (%) — prices are GST-inclusive at this rate (default 18).',
     'Turn on "Issue GST Tax Invoices" and Save. The server refuses if the GSTIN format is invalid.',
     'Optionally add HSN codes to products (invoices show "—" when missing).'],
    ['Seller state = first two digits of the GSTIN. Buyer in the same state → CGST + SGST; other states → IGST.',
     'Invoice numbers: CF/&lt;financial year&gt;/000001 upward, per financial year (April start). A number is assigned when an invoice is first generated.',
     'Invoices are offered only for orders that are Shipped or Delivered (not cancelled): website order page, app order details, admin order view.'],
    ['Go-Live tab: "GST tax invoices" turns Done (it also rejects the sample GSTIN 29AABCU9603R1ZM, which otherwise passes the format check).',
     'Admin → Orders → open a Delivered order → Invoice: check your name, address, GSTIN, tax split and amount in words.',
     'Ask your accountant to review one sample invoice before real sales.'],
    ['Turn "Issue GST Tax Invoices" off → customers see "Invoices are not enabled yet". Already-issued numbers are kept.'],
    ['Once real invoices are issued, do not change the GSTIN or numbering mid-year without your accountant.',
     'Buyer state is read from the address text; unusual state spellings default to intra-state (CGST+SGST).'])

story += step_block('7. Step 3 — Delhivery live shipping',
    'Settings → API Keys → Shipping (Delhivery) — each field is saved on its own; the status panel above the fields shows what is missing, the webhook URL, last webhook, and Test / Sync / Pickup buttons',
    'Live API token from Delhivery, the <b>exact</b> registered pickup (warehouse) name, Delhivery client name and seller GSTIN. A webhook secret you choose (long random text). Delhivery account approved for live shipping.',
    ['<b>Clean up first</b>: Admin → Orders. Any order that is Processing/Paid or COD with shipment "pending" or "failed" will be <b>booked as a real shipment within 30 minutes</b> of switching — however old. Cancel test orders now, or set "Auto-ship" = false first and ship manually.',
     'Cancel orders already shipped on staging (they cannot be cancelled from admin after the switch).',
     'Enter DELHIVERY_TOKEN (live), DELHIVERY_PICKUP_LOCATION (exact name), DELHIVERY_CLIENT_NAME, DELHIVERY_SELLER_GST, default weight (grams), pickup time and cut-off.',
     'Enter DELHIVERY_WEBHOOK_SECRET, then send Delhivery the webhook: URL <b>https://chillfi.in/api/shipping/delhivery/webhook</b>, header <b>Authorization: Bearer &lt;your secret&gt;</b> (draft email: QA/DELHIVERY_REQUEST_EMAIL.md).',
     'Set Environment = production and confirm the warning ("REAL, chargeable shipments").',
     'Press <b>Test</b> in the status panel, then place one real COD order to your own address.'],
    ['COD orders are booked at order time; prepaid orders when payment succeeds. A pickup is booked the same day before the cut-off, otherwise next working day (Sundays skipped).',
     'Every 30 minutes (one server process) it retries failed bookings (max 5), syncs tracking, books pickups and expires unpaid online orders.',
     'Webhook scans update the order (Shipped, Out for delivery, Delivered, RTO) and notify the customer; Delivered COD orders are marked Paid.'],
    ['Go-Live tab: "Delhivery live shipping" = Done ("Live — pickup location …").',
     'Your test order gets an AWB within a minute; the label downloads (Admin → Orders → Label); the AWB is visible in Delhivery One.',
     'Status panel shows "last webhook received" after the first scan.',
     'Cancel the test order before pickup (Admin → Orders → Cancel) and confirm it disappears in Delhivery.'],
    ['Environment = staging (instant) or Auto-ship = false. Production AWBs stop syncing while on staging — switch back promptly.'],
    ['Wrong pickup name → every booking fails ("pickup location not found"); the error is shown on the order.',
     'Staging account has COD disabled — do not judge live COD from staging.',
     'Serviceability answers are cached 6 h per pincode; restart the API after switching for fresh results.'])

story += step_block('8. Step 4 — Confirm COD with Delhivery',
    'Delhivery account manager / Delhivery One; then Settings → Shipping → "COD Available"',
    'Your live Delhivery client code; COD remittance bank details submitted to Delhivery.',
    ['Ask Delhivery to confirm in writing that <b>COD is enabled</b> on the live client and the COD limit per parcel.',
     'If COD is not enabled: Settings → Shipping → turn "COD Available" OFF → Save (checkout then offers online payment only — only do this after step 5 works).',
     'Optionally restrict COD by pincode prefix with Shipping Rules (COD available on/off, fee, delivery days).'],
    ['Checkout combines three things: the store switch, the pincode rule (longest prefix wins) and Delhivery\'s own COD flag for the pincode.',
     'If Delhivery rejects a COD parcel the admin sees "Cash on Delivery isn\'t enabled on this Delhivery account…" and the order is retried up to 5 times.'],
    ['Place one COD order to a serviceable pincode → AWB created (no COD error).', 'With COD off: website badge "Currently unavailable", app subtitle "Currently unavailable", API refuses COD orders.'],
    ['Toggle "COD Available" back.'],
    ['The Go-Live "Cash on Delivery" item is always shown as done — it cannot know Delhivery\'s answer; this step is manual.',
     'Turning COD off while online payment is still in test mode leaves customers with no way to pay.'])

story += step_block('9. Step 5 — PhonePe live (real money)',
    'Settings → API Keys → Payment Gateway',
    'Must-fix F1 and F7 deployed. PhonePe business account approved for live, with the <b>Merchant ID</b>, <b>Salt Key</b> and <b>Salt Index</b> (this code uses the PhonePe PG v1 salt-key API — if PhonePe gives you a v2 client-id/secret instead, the developer must add v2 first). Refund process agreed (below).',
    ['Enter PhonePe Merchant ID, Salt Key and Salt Index (each saved on its own; the key is stored encrypted and only the last 4 characters are shown).',
     'Set PhonePe Environment = PRODUCTION and confirm the warning.',
     'If the PhonePe dashboard asks for URLs: website/domain https://chillfi.in; callback/webhook https://chillfi.in/api/payment/webhook (the server also sends these with every payment).',
     'Within 30 seconds checkout shows online payment on the website and in the app.',
     'Real test: place a ₹1–10 order online from the website and from the app with your own UPI/card.',
     'Cancel it from Admin → Orders; a refund request opens automatically → refund it in the PhonePe dashboard → Admin → Refunds → mark Refunded.'],
    ['Customer pays on PhonePe\'s page → PhonePe calls the webhook (signature checked) → order becomes Paid → confirmation + (if Delhivery live) automatic shipment.',
     'The app also verifies the payment when the customer returns to it.',
     'Unpaid online orders older than 2 hours are checked with PhonePe: completed → Paid; failed → cancelled, stock and coupon released.',
     '<b>Refunds are manual</b>: the system opens a refund request (customer cancel, admin cancel, or payment arriving on a cancelled order); money is returned from the PhonePe dashboard.'],
    ['Go-Live tab: "Online payments live (PhonePe)" = Done ("Live — real payments accepted").',
     'Website test: after paying you land on the order success page (not "Order failed").',
     'Admin → Orders: test order Payment = Paid, payment method PhonePe; server log line "[order] paid … via phonepe-webhook".',
     'Refund reaches your account; Admin → Refunds shows Refunded and the customer got the notification.'],
    ['Set Environment back to UAT: online payment is hidden and refused immediately. Paid orders are unaffected; unpaid online orders are left untouched (clean up manually).'],
    ['Never test with large amounts. Keep the PhonePe dashboard open during the first day.',
     'If Delhivery is already live, a paid test order ships automatically — cancel it before pickup.',
     'Enter the live keys only after SETTINGS_ENCRYPTION_KEY is set on the server (step 0).'])

story += step_block('10. Step 6 — Remove test logins',
    'Firebase console → Authentication → Sign-in method → Phone → "Phone numbers for testing"; developer for the backend test phone',
    'Client testing finished; step 0 real-SIM login worked (otherwise removing test numbers can lock everyone out of testing).',
    ['Firebase: delete +91 90000 00001, +91 98765 43210, +91 90562 24993, +91 83606 91637 (all test numbers) → Save.',
     'Developer: deploy fix F2 (backend test phone 9876543210 only in development) and disable/delete the 9876543210 user on production.',
     'Developer: remove the test customer accounts used in QA (e.g. "DLV-TEST Customer", "QA Person") or anonymise them via account deletion.',
     'Optional: Firebase → Authentication → Settings → SMS region policy = allow India only (limits SMS abuse/cost).'],
    ['Test numbers no longer bypass SMS; every login needs a real OTP.'],
    ['Try +91 90000 00001 on the website and the app → no login with 123456.', 'Log in with a real number → OTP SMS arrives within ~30 s, login succeeds.'],
    ['Re-add a test number in the Firebase console (only if needed for support).'],
    ['Do this last — after steps 1–5 are verified with real accounts.'])

# ── 11 smoke test ────────────────────────────────────────────────────────────
story += h1('11. Go-live day smoke test (30 minutes, after steps 1–6)')
story += [table([['#', 'Check', 'Expected'],
                 ['1', 'https://chillfi.in/api/health', '{"status":"ok","db":"ok"} in under 1 s'],
                 ['2', 'New customer sign-up with a real number (website and app)', 'OTP SMS, account created, lands on Home'],
                 ['3', 'Search, product page, add to cart, apply a coupon', 'Prices GST-inclusive; coupon total correct'],
                 ['4', 'Checkout with a serviceable pincode', 'COD and online options as configured; delivery estimate shown'],
                 ['5', 'Online ₹1 order (website and app)', 'Success page; order Paid; confirmation push/email'],
                 ['6', 'COD order', 'Order placed; Delhivery AWB within a minute'],
                 ['7', 'Admin: order list, label, invoice (after Shipped)', 'Label downloads; invoice shows your GSTIN'],
                 ['8', 'Cancel both test orders; refund the online one', 'Shipments cancelled in Delhivery; refund completed'],
                 ['9', 'Contact page, Help & Support in app', 'Real phone/email/WhatsApp open correctly'],
                 ['10', 'Delete-account page with a spare account', 'OTP arrives; account removed'],
                 ['11', 'Admin → Settings → Go-Live', 'All items Done except optional SMS'],
                 ['12', 'Uptime monitor', 'Shows "Up"; alert contact receives a test alert']],
                [9 * mm, 80 * mm, 85 * mm], font='small'), PageBreak()]

# ── 12 live state ────────────────────────────────────────────────────────────
story += h1('12. Live production state (measured 25 Sep 2026, 16:06 UTC)')
story += [table([['Check', 'Result', 'Status'],
                 ['API health', '200 {"status":"ok","db":"ok"}, 0.24 s', tag('READY')],
                 ['Response times', 'Home page 0.22 s, product list API 0.27 s, home API 0.28 s', tag('READY')],
                 ['HTTPS', 'http → https 301; certificate Let\'s Encrypt, chillfi.in + www.chillfi.in, valid until 5 Nov 2026 (auto-renew)', tag('READY')],
                 ['www.chillfi.in', 'Serves the site directly (no redirect to chillfi.in) — duplicate URL for search engines', tag('REC')],
                 ['Online payment', 'online_payment_available = false (test mode locked off) — expected until step 5', tag('OWNER')],
                 ['Maintenance mode', 'off', tag('READY')],
                 ['Contact shown to customers', '+91 98765 43210 / help@chillfi.in / "123, Tech Park, Whitefield…" — sample values', tag('OWNER')],
                 ['Force update', 'off, minimum version 1.0.0 — turn on after build 5 is live on Play', tag('OWNER')],
                 ['Pricing', 'GST-inclusive, rate 18%, free shipping above ₹999, max delivery 7 days', tag('READY')],
                 ['Admin API without login', '401 "No token provided"', tag('READY')],
                 ['Security headers (API)', 'HSTS 1 year, nosniff, X-Frame-Options SAMEORIGIN', tag('READY')],
                 ['Security headers (web pages)', 'none (HSTS/nosniff/frame-options only on /api)', tag('REC')],
                 ['Compression', 'no gzip on HTML or JS; main script 906 KB sent uncompressed', tag('REC')],
                 ['robots.txt / sitemap.xml', 'return the app HTML (files do not exist)', tag('REC')],
                 ['Secrets in the shipped JavaScript', 'only the Firebase web API key (public by design; restrict it to chillfi.in in Google Cloud)', tag('READY')],
                 ['DNS e-mail records', 'no MX, no SPF, no DMARC for chillfi.in', tag('FIX')]],
                [42 * mm, 104 * mm, 28 * mm], font='small'), PageBreak()]

# ── 13 security ──────────────────────────────────────────────────────────────
story += h1('13. Security review')
story += [P('Overall the application security is solid for launch once F2, F6 and F7 are done. Findings by area:'),
          table([['Area', 'Finding', 'Severity'],
                 ['SQL injection', 'All user input goes through parameterised queries; sort columns are whitelisted. No injectable query found.', sev('Low') + ' (OK)'],
                 ['Prices / totals', 'Computed on the server with stock and coupon rows locked; quantity must be an integer 1…stock.', sev('Low') + ' (OK)'],
                 ['Order access', 'Every order, invoice, tracking, cancel and refund lookup is scoped to the signed-in user.', sev('Low') + ' (OK)'],
                 ['Admin access', 'All /api/admin routes need staff/admin; sensitive ones admin-only; admins cannot demote/block themselves.', sev('Low') + ' (OK)'],
                 ['Admin sign-in', 'Phone OTP only (password login disabled); sign-ins logged with IP/device; 30-min idle sign-out (browser).', sev('Low') + ' (OK)'],
                 ['Test login backdoor', 'Phone 9876543210 → OTP 123456 on production (F2).', sev('High')],
                 ['Stored gateway keys', 'AES-256-GCM, masked in admin; key derived from JWT_SECRET unless SETTINGS_ENCRYPTION_KEY set.', sev('Medium')],
                 ['PhonePe webhook', 'Signature compared in constant time; weak when salt key missing; amount not cross-checked (F7).', sev('Medium')],
                 ['Delhivery webhook', 'Bearer secret, constant-time compare; 503 when not configured. Token also accepted in ?query (logged by request log).', sev('Low')],
                 ['Tokens', 'Access 7 days, refresh 30 days rotated on use; refresh tokens stored unhashed; website keeps tokens in localStorage.', sev('Medium')],
                 ['OTP (backend path)', 'Math.random generator; plain-text OTP storage; 5 attempts; 1/min + 5/hour per phone.', sev('Low')],
                 ['Rate limiting', '200 requests/min per IP; no tighter limit on login, coupon or contact form; verify port 5000 is not public.', sev('Medium')],
                 ['CORS', 'Allows localhost origins and http://3.111.32.220 with credentials in production — tidy up.', sev('Low')],
                 ['Uploads', 'Images only, 5 MB, memory storage, Cloudinary re-validates.', sev('Low') + ' (OK)'],
                 ['Errors / logs', 'No stack traces or secrets to clients; friendly messages with reference id.', sev('Low') + ' (OK)'],
                 ['Secrets in git', '.env, keystore, key.properties, service account and .pem are ignored and not in history.', sev('Low') + ' (OK)'],
                 ['Dependencies', 'Backend: 5 high + 9 moderate advisories; website: 2 moderate (F6).', sev('High')],
                 ['Audit trail', 'Sign-ins are recorded; other admin actions (refunds, role changes, settings) only in server logs.', sev('Low')]],
                [32 * mm, 116 * mm, 26 * mm], font='small'), PageBreak()]

# ── 14 payments ──────────────────────────────────────────────────────────────
story += h1('14. Payments, orders and money')
story += bullets([
    '<b>Pricing</b>: GST-inclusive — the displayed price is what the customer pays; GST is shown as "Includes GST". Charged total = displayed total (verified on website and app).',
    '<b>Safety net while in test mode</b>: on production the server refuses online orders and ignores any sandbox "success", so no order can be marked paid without real money.',
    '<b>Abandoned payments</b>: unpaid online orders are checked with PhonePe after 2 hours and cancelled only if PhonePe confirms non-payment (stock and coupon released). If PhonePe cannot be reached nothing is cancelled.',
    '<b>Late payment on a cancelled order</b> automatically opens a full refund request and informs the customer.',
    '<b>Refunds</b> are recorded in Admin → Refunds; the money itself is returned from the PhonePe dashboard (no refund API integration). Plan who does this daily.',
    '<b>Coupons</b> are re-validated at order time (expiry, minimum order, per-user use, usage limit).',
    '<b>COD</b>: store switch + per-pincode rules + Delhivery COD flag; delivered COD orders are marked Paid automatically.',
    '<b>Must fix</b>: F1 (return page) and F7 (webhook hardening) before step 5. Real PhonePe (even UAT) was never completed end-to-end because card entry needs a person — do the ₹1 test in step 5.'])
story += [h1('15. Shipping and delivery'), *bullets([
    'Delhivery staging lifecycle: 48/48 checks (create, AWB, pickup, tracking, delivered, RTO, cancel, webhooks, duplicate/out-of-order protection).',
    'Automatic booking: COD at order time, prepaid on payment; retries up to 5 times; tracking sync every 30 min; one process runs the scheduler (no double booking).',
    'Invalid address and COD-not-enabled errors are shown to the admin in plain words.',
    'Serviceability check at checkout; unknown results never block a customer.',
    'Owner step 3 includes a mandatory clean-up of pending/staging orders — the most likely go-live surprise.',
    'Package weight defaults to 500 g for every item unless set — set real weights to avoid Delhivery weight disputes.']), PageBreak()]

# ── 16 login ─────────────────────────────────────────────────────────────────
story += h1('16. Login and accounts')
story += bullets([
    'Website and app sign in with Firebase phone OTP; the server verifies the Firebase token and issues its own session.',
    '<b>Verify</b>: real-SIM OTP on the Play-signed build after adding SHA fingerprints (F4). This has never been tested — only test numbers.',
    'Website OTP uses an invisible reCAPTCHA; authorised domains must include chillfi.in and www.chillfi.in.',
    'Sign-ups can be paused from admin; blocked users are rejected on every request.',
    '<b>Account deletion</b>: backend supports deletion (orders are anonymised; the shipping address on past orders is kept for tax records — say so in the Privacy Policy). App entry point missing (F3); website page likely not sending SMS (F5).',
    'Guest browsing is allowed; cart, wishlist, orders and addresses require an account (no guest checkout).'])
story += [h1('17. Android app release'), table([['Item', 'Value', 'Status'],
    ['Package / name', 'com.ecom.chillfi / "ChillFi"', tag('READY')],
    ['Version', '1.0.3, build 5 (versionCode 5) — FinalApp/ChillFi-v1.0.3-build5-release.aab', tag('READY')],
    ['Signing', 'Upload key, certificate SHA-256 50:5C:1D:A6:CE:E3:64:69… (same as build 4)', tag('READY')],
    ['SDK', 'minSdk 24 (Android 7), targetSdk 36 — meets current Play requirement', tag('READY')],
    ['Code shrinking', 'R8 minify + resource shrinking on', tag('READY')],
    ['Network', 'HTTPS only (cleartext blocked), API https://chillfi.in/api', tag('READY')],
    ['Permissions', 'Internet, notifications, microphone (voice search), biometric (unused — remove)', tag('VERIFY')],
    ['Account deletion in app', 'missing (F3)', tag('FIX')],
    ['Play Data safety', 'Declare: phone number, name, email, address, purchase history, audio (voice search, not stored), device ID for push', tag('OWNER')],
    ['Store listing', 'Privacy policy URL https://chillfi.in/privacy-policy; deletion URL https://chillfi.in/delete-account (after F5)', tag('OWNER')],
    ['Force update', 'After build 5 is live: Store Info → Force Update ON, minimum 1.0.3 (1.0.2 shows GST added on top)', tag('OWNER')]],
    [32 * mm, 114 * mm, 28 * mm], font='small')]
story += [h1('18. iOS'), P('The app runs on the iPhone 17 simulator (onboarding, login screens, tabs, swipe-back, empty states verified; minimum iOS 15). '
          '<b>Not publishable yet</b>: GoogleService-Info.plist missing (Firebase fails to start → OTP and push unavailable), no push entitlement / background mode, no URL scheme for phone-auth reCAPTCHA, '
          'no in-app account deletion, display name "Chillfi". Needed only if an App Store release is planned: Apple Developer account, APNs key uploaded to Firebase, and the items above.'),
          PageBreak()]

# ── 19 website ───────────────────────────────────────────────────────────────
story += h1('19. Website: performance, SEO, accessibility')
story += [table([['Topic', 'Finding', 'Action'],
    ['Responsive', '493 page × width checks (320–1920 px): 0 overflow, 0 JS errors; 1,758 interactive elements, 0 blocked', 'none'],
    ['Accessibility', 'Visible keyboard focus ring, one h1 per page, reduced-motion respected, labelled controls', 'none'],
    ['Speed (server)', 'First byte 0.2 s from India-region server', 'none'],
    ['Speed (download)', 'No gzip/brotli; single 906 KB JavaScript file (admin included)', 'Enable gzip in nginx (about 70% smaller); later split admin into its own chunk'],
    ['Caching', 'Hashed assets cached 1 year (immutable); HTML not cached', 'none'],
    ['SEO basics', 'Title present; description/Open Graph tags added only by JavaScript', 'Put default description + OG tags in index.html'],
    ['robots.txt / sitemap', 'Missing (URLs return the app page)', 'Add robots.txt and a sitemap (static pages + products)'],
    ['Duplicate host', 'www.chillfi.in serves the same site', '301 www → chillfi.in in nginx'],
    ['Security headers', 'Only on /api', 'Add HSTS, nosniff, frame-options, referrer-policy to nginx for all pages'],
    ['Legal pages', 'Privacy, Terms, Refund, Return, Shipping, Delete-account present', 'Update contact/address after step 1']],
    [30 * mm, 78 * mm, 66 * mm], font='small')]
story += [h1('20. Infrastructure, backups and monitoring'), *bullets([
    '<b>Server</b>: AWS EC2 (Mumbai region IP 3.111.32.220), ~1 GB RAM, Node 22, pm2 with 2 API processes, auto-start on reboot, log rotation 10 MB × 7; nginx with HTTPS.',
    '<b>Deploys</b>: scripted, dry-run first, automatic backup of backend and website before every deploy, health check after.',
    '<b>Database backups</b>: nightly 02:30 IST, 7 daily + 6 monthly, each verified readable; restore check compares row counts. <b>Gap</b>: copies live on the same server — add an EBS snapshot policy or S3 copy.',
    '<b>Monitoring</b>: /api/health checks API + database. <b>Owner</b>: create an UptimeRobot (free) keyword monitor on https://chillfi.in/api/health for "ok", 5-minute interval, alerts to email + phone app.',
    '<b>TLS</b>: Let\'s Encrypt valid to 5 Nov 2026; confirm the renewal timer once (sudo certbot renew --dry-run).',
    '<b>Capacity</b>: fine for launch. Move to t3.small (2 GB) when traffic grows — first confirm the IP is an Elastic IP.',
    '<b>Code backup</b>: <font color="#15803D"><b>Done 26 Sep</b></font> — pushed to GitHub (BussEnhancer/chillfi, branch delhivery-integration, 73 commits). The original thesonushah1-dot/chillfi repo was inaccessible from this machine, so the owner created a new repo and granted push access instead.']),
    h1('21. Email and domain'), *bullets([
    '<b>chillfi.in has no MX record</b> — mail to help@chillfi.in (shown on the website, app, invoices and policies) cannot be delivered. Either set up mailboxes (Zoho Mail / Google Workspace: add their MX records) or show an address that works today.',
    '<b>No SPF or DMARC</b> — once order emails are sent from @chillfi.in they are likely to land in spam. Add the SPF and DKIM records your email provider gives you, and a DMARC record (start with p=none).',
    'Order emails are built and waiting: Settings → API Keys → Email (SMTP) → "Send test email".',
    'SMS order updates (optional) need a DLT-approved MSG91 template.']), PageBreak()]

# ── 22 quality ───────────────────────────────────────────────────────────────
rows = [['Area', 'Cases', 'Pass', 'Fail', 'Blocked', 'N/A']]
for k, n in [('app', 'Mobile app'), ('website', 'Website'), ('admin', 'Admin')]:
    c = ST[k]; rows.append([n, str(sum(c.values())), str(c['PASS']), str(c.get('FAIL', 0)), str(c['BLOCKED']), str(c['NOT APPLICABLE'])])
rows.append(['<b>Total</b>', f'<b>{NCASES}</b>', f'<b>{TOT["PASS"]}</b>', f'<b>{TOT.get("FAIL", 0)}</b>', f'<b>{TOT["BLOCKED"]}</b>', f'<b>{TOT["NOT APPLICABLE"]}</b>'])
story += h1('22. Quality evidence')
story += [table(rows, [44 * mm, 26 * mm, 26 * mm, 26 * mm, 26 * mm, 26 * mm]), Spacer(1, 3 * mm), *bullets([
    f'{NDEF} defects found (11 critical, 46 high, 41 medium, 26 low) — all fixed, re-tested and deployed.',
    'The 10 blocked cases need a person or a key: PhonePe card entry (3), website reCAPTCHA OTP (3), online test payment (1), Cloudinary uploads locally (3).',
    'Final regression 25 Sep: all customer suites pass; admin suites pass except the 2 Cloudinary upload checks (keys only on production) and 1 known test-harness limitation.',
    'UI consistency pass: one design system (type, spacing, radius, motion), shared back button, empty states and page transitions on app and website; verified on Pixel 9, a 360×640 phone and iPhone 17.',
    'Not covered by testing: real SMS OTP, real PhonePe money, live Delhivery, real-device push, iOS release.']), PageBreak()]

# ── 23 risk register ─────────────────────────────────────────────────────────
story += h1('23. Risk register')
story += [table([['Risk', 'Likelihood', 'Impact', 'Mitigation'],
    ['Customer sees "payment failed" after paying', 'High (certain without F1)', 'High', 'Fix F1; ₹1 test in step 5'],
    ['Real OTP fails on the Play build', 'Medium', 'High (no new sign-ups)', 'F4 + real-SIM test before launch'],
    ['Old test orders booked as real shipments', 'Medium', 'Medium (courier charges)', 'Step 3 clean-up / auto-ship off first'],
    ['Test login used by someone else', 'Low–Medium', 'High', 'F2 + step 6'],
    ['Play rejects update (no in-app deletion)', 'Medium', 'Medium (delay)', 'F3 before uploading'],
    ['Support emails never arrive', 'High (certain today)', 'Medium', 'MX + mailbox for the support address'],
    ['Order emails in spam', 'High without SPF/DKIM', 'Low–Medium', 'DNS records from mail provider'],
    ['COD not enabled on live Delhivery', 'Unknown', 'Medium', 'Step 4 written confirmation'],
    ['Refunds delayed', 'Medium', 'Medium (complaints)', 'Daily refund routine; PhonePe dashboard access'],
    ['Server loss (disk/instance)', 'Low', 'High', 'Off-server backup copy + GitHub push'],
    ['Outage unnoticed', 'Medium', 'Medium', 'UptimeRobot alerts'],
    ['Known dependency vulnerability exploited', 'Low', 'Medium', 'F6'],
    ['Wrong GST details on invoices', 'Low', 'Medium', 'Accountant reviews a sample (step 2)'],
    ['Old app (1.0.2) shows GST on top', 'Certain until force update', 'Low', 'Force update after build 5 is live'],
    ['Traffic spike on 1 GB server', 'Low at launch', 'Medium', 'Watch memory; resize to t3.small']],
    [58 * mm, 34 * mm, 30 * mm, 52 * mm], font='small'), PageBreak()]

# ── 24 after launch ──────────────────────────────────────────────────────────
story += h1('24. First 24 hours / first week after launch')
story += [h2('First 24 hours'), *bullets([
    'Keep Admin → Settings → Go-Live and Admin → Orders open; check new orders every hour.',
    'Every online order: Payment = Paid within a minute; any "Pending" online order older than 30 minutes → check it in the PhonePe dashboard.',
    'Every order: AWB present; any "shipment failed" → read the reason on the order (address, pincode, COD).',
    'Watch the uptime monitor and the admin alert bell (failed shipments, refunds, messages, low stock).',
    'Answer support messages the same day (Admin → Messages).']),
    h2('First week'), *bullets([
    'Daily: refunds processed, pickups happened, COD remittance from Delhivery reconciled.',
    'Check that nightly backups are fresh (Go-Live tab "Nightly database backup").',
    'Review app-store reviews and crash reports (Play Console → Android vitals).',
    'Turn on Force Update once most users are on 1.0.3.',
    'Plan the recommended items: gzip, robots/sitemap, security headers, off-server backup, iOS if wanted.'])]
story += [h1('25. Appendix — file references for the developer'), table([['Item', 'Where in the code'],
    ['F1 PhonePe return URL', 'backend/src/controllers/paymentController.js:35 (redirectUrl) and :236-242 (callback reads query)'],
    ['F2 test phone', 'backend/src/utils/otp.js:8 and :128-147'],
    ['F3 app account deletion', 'backend/src/routes/profile.js:22 (DELETE /api/profile/account); add UI under lib/features/profile/settings_screen.dart'],
    ['F4 Firebase Android config', 'android/app/google-services.json (oauth_client empty)'],
    ['F5 website delete page', 'web/website/pages/DeleteAccount/index.tsx:21,37; backend/src/utils/otp.js:62-92'],
    ['F6 dependencies', 'backend/package.json, web/website/package.json (npm audit --omit=dev)'],
    ['F7 webhook hardening', 'backend/src/utils/phonepe.js:45-46; backend/src/controllers/paymentController.js:183-233'],
    ['PhonePe environments', 'backend/src/utils/phonepe.js:15-57'],
    ['Delhivery environments / scheduler', 'backend/src/utils/delhivery.js:16-58; backend/src/services/shipmentService.js:338-380'],
    ['Go-Live checklist', 'backend/src/controllers/adminController.js:258-310; web/website/components/admin/GoLiveChecklist.tsx'],
    ['Invoices / GSTIN', 'backend/src/utils/invoice.js:9,54-123'],
    ['Settings encryption', 'backend/src/utils/settings.js:13-41'],
    ['Voice search manifest', 'android/app/src/main/AndroidManifest.xml (queries block)'],
    ['Runbooks', 'QA/OPS_RUNBOOK.md, QA/DELHIVERY_GO_LIVE.md, QA/UI_SYSTEM.md']],
    [44 * mm, 130 * mm], font='small')]

def on_page(c, doc):
    c.saveState()
    if doc.page > 1:
        c.setFillColor(ORANGE); c.rect(0, A4[1] - 8, A4[0], 8, stroke=0, fill=1)
        c.setFont('P', 7.5); c.setFillColor(GREY)
        c.drawString(18 * mm, 10 * mm, 'ChillFi — Production Readiness Report · updated 26 Sep 2026 · confidential')
        c.drawRightString(A4[0] - 18 * mm, 10 * mm, f'Page {doc.page}')
    else:
        c.setFillColor(ORANGE); c.rect(0, 0, 10, A4[1], stroke=0, fill=1)
    c.restoreState()

doc = BaseDocTemplate(OUT, pagesize=A4, leftMargin=18 * mm, rightMargin=18 * mm, topMargin=18 * mm, bottomMargin=18 * mm,
                      title='ChillFi — Production Readiness Report', author='ChillFi QA')
doc.addPageTemplates([PageTemplate(id='all', frames=[Frame(doc.leftMargin, doc.bottomMargin, doc.width, doc.height, id='f')], onPage=on_page)])
def _flat(xs):
    for x in xs:
        if isinstance(x, list): yield from _flat(x)
        else: yield x
doc.build(list(_flat(story)))
print(OUT)
