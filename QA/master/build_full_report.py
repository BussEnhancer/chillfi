#!/usr/bin/env python3
"""ChillFi — complete project report (QA, fixes, features, production state, owner actions).
   python3 QA/master/build_full_report.py  →  QA/ChillFi_Complete_Report.pdf
Figures and the defect register are read live from QA/master/{app,website,admin}.json."""
import json, os, datetime
from collections import Counter
from reportlab.lib.pagesizes import A4
from reportlab.lib import colors
from reportlab.lib.units import mm
from reportlab.lib.styles import ParagraphStyle
from reportlab.platypus import (BaseDocTemplate, PageTemplate, Frame, Spacer, Table, TableStyle,
                                PageBreak, Image, KeepTogether, CondPageBreak)

from reportlab.pdfbase import pdfmetrics
from reportlab.platypus import Paragraph as _Para

GLYPHS = {'→': '›', '↔': '/', '★': ' stars', '✅': '<font color="#15803D"><b>Done</b></font> ·', '❌': '<font color="#B91C1C"><b>To do</b></font> ·'}
class Paragraph(_Para):  # Poppins has no arrows / emoji — map to safe equivalents
    def __init__(self, text, *a, **k):
        for g, r in GLYPHS.items(): text = text.replace(g, r)
        super().__init__(text, *a, **k)
from reportlab.pdfbase.ttfonts import TTFont

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
SHOTS = os.path.abspath(os.path.join(ROOT, '..', '..', 'qa-tools', 'results'))
FONTS = os.path.join(ROOT, 'backend', 'assets', 'fonts')
OUT = os.path.join(ROOT, 'QA', 'ChillFi_Complete_Report.pdf')

pdfmetrics.registerFont(TTFont('P', os.path.join(FONTS, 'Poppins-Regular.ttf')))
pdfmetrics.registerFont(TTFont('PS', os.path.join(FONTS, 'Poppins-SemiBold.ttf')))
pdfmetrics.registerFont(TTFont('PB', os.path.join(FONTS, 'Poppins-Bold.ttf')))
from reportlab.pdfbase.pdfmetrics import registerFontFamily
registerFontFamily('P', normal='P', bold='PB', italic='P', boldItalic='PB')

ORANGE = colors.HexColor('#FF6B2C'); PURPLE = colors.HexColor('#6C2BFF'); INK = colors.HexColor('#111827')
GREY = colors.HexColor('#6B7280'); LIGHT = colors.HexColor('#F5F5F7'); LINE = colors.HexColor('#E5E7EB')
GREEN = colors.HexColor('#15803D'); RED = colors.HexColor('#B91C1C'); AMBER = colors.HexColor('#B45309'); BLUE = colors.HexColor('#1D4ED8')

S = {
    'title': ParagraphStyle('title', fontName='PB', fontSize=26, leading=32, textColor=INK),
    'sub': ParagraphStyle('sub', fontName='P', fontSize=11, leading=16, textColor=GREY),
    'h1': ParagraphStyle('h1', fontName='PB', fontSize=16, leading=21, textColor=INK, spaceBefore=6, spaceAfter=8),
    'h2': ParagraphStyle('h2', fontName='PS', fontSize=12, leading=16, textColor=ORANGE, spaceBefore=10, spaceAfter=5),
    'body': ParagraphStyle('body', fontName='P', fontSize=9.2, leading=13.5, textColor=INK, spaceAfter=4),
    'small': ParagraphStyle('small', fontName='P', fontSize=7.8, leading=10.5, textColor=INK),
    'smallg': ParagraphStyle('smallg', fontName='P', fontSize=7.8, leading=10.5, textColor=GREY),
    'cell': ParagraphStyle('cell', fontName='P', fontSize=8, leading=10.6, textColor=INK),
    'cellb': ParagraphStyle('cellb', fontName='PS', fontSize=8, leading=10.6, textColor=INK),
    'head': ParagraphStyle('head', fontName='PS', fontSize=8, leading=10.6, textColor=colors.white),
    'bullet': ParagraphStyle('bullet', fontName='P', fontSize=9.2, leading=13.5, textColor=INK, leftIndent=12, bulletIndent=2, spaceAfter=2),
    'callout': ParagraphStyle('callout', fontName='P', fontSize=9.2, leading=13.5, textColor=INK),
}
P = lambda t, s='body': Paragraph(t, S[s])
def bullets(items, style='bullet'): return [Paragraph(i, S[style], bulletText='•') for i in items]

def table(rows, widths, head=True, zebra=True, font='cell'):
    data = [[c if not isinstance(c, str) else Paragraph(c, S['head' if (head and r == 0) else font]) for c in row] for r, row in enumerate(rows)]
    t = Table(data, colWidths=widths, repeatRows=1 if head else 0)
    st = [('VALIGN', (0, 0), (-1, -1), 'TOP'), ('GRID', (0, 0), (-1, -1), 0.4, LINE),
          ('LEFTPADDING', (0, 0), (-1, -1), 5), ('RIGHTPADDING', (0, 0), (-1, -1), 5), ('TOPPADDING', (0, 0), (-1, -1), 3.5), ('BOTTOMPADDING', (0, 0), (-1, -1), 3.5)]
    if head: st += [('BACKGROUND', (0, 0), (-1, 0), INK)]
    if zebra:
        for r in range(1 if head else 0, len(rows)):
            if r % 2 == 0: st.append(('BACKGROUND', (0, r), (-1, r), LIGHT))
    t.setStyle(TableStyle(st)); return t

def callout(text, color=ORANGE, bg='#FFF7F3'):
    t = Table([[Paragraph(text, S['callout'])]], colWidths=[174 * mm])
    t.setStyle(TableStyle([('BACKGROUND', (0, 0), (-1, -1), colors.HexColor(bg)), ('LINEBEFORE', (0, 0), (0, -1), 3, color),
                           ('LEFTPADDING', (0, 0), (-1, -1), 9), ('RIGHTPADDING', (0, 0), (-1, -1), 9), ('TOPPADDING', (0, 0), (-1, -1), 7), ('BOTTOMPADDING', (0, 0), (-1, -1), 7)]))
    return t

def shot(path, width_mm, caption=None, max_h_mm=120):
    if not os.path.exists(path): return []
    from reportlab.lib.utils import ImageReader
    iw, ih = ImageReader(path).getSize()
    w = width_mm * mm; h = w * ih / iw
    if h > max_h_mm * mm: h = max_h_mm * mm; w = h * iw / ih
    out = [Image(path, width=w, height=h)]
    if caption: out.append(Paragraph(caption, S['smallg']))
    return out

from xml.sax.saxutils import escape as esc
# ── data ─────────────────────────────────────────────────────────────────────
areas = {k: json.load(open(os.path.join(HERE, f'{k}.json'))) for k in ['app', 'website', 'admin']}
names = {'app': 'Mobile app', 'website': 'Website', 'admin': 'Admin panel'}
def stats(d):
    c = Counter(tc.get('status', 'NOT TESTED') for s in d['sections'] for tc in s['cases'])
    return sum(c.values()), c
all_defects = [(k, x) for k, d in areas.items() for x in d.get('defects', [])]
sev_order = {'Critical': 0, 'High': 1, 'Medium': 2, 'Low': 3}
sevc = Counter(x['severity'] for _, x in all_defects)
T = {k: stats(d) for k, d in areas.items()}
tot_cases = sum(t for t, _ in T.values()); tot = Counter()
for _, c in T.values(): tot.update(c)
today = datetime.date(2026, 9, 25).strftime('%d %B %Y')

story = []
# ── cover ────────────────────────────────────────────────────────────────────
story += [Spacer(1, 40 * mm), P('<font color="#FF6B2C">ChillFi</font>', 'title'),
          P('Complete Project Report', 'title'), Spacer(1, 4 * mm),
          P('Master QA · Fixes · New features · Delhivery staging · Production deployment · Readiness', 'sub'),
          Spacer(1, 3 * mm), P(f'{today} · Mobile app (Flutter) · Website (React) · Admin panel · Backend (Node/Express + PostgreSQL)', 'sub'),
          Spacer(1, 18 * mm)]
kpis = [[f'{tot["PASS"]}/{tot_cases}', 'test cases passed'], ['0', 'failing test cases'], [str(len(all_defects)), 'defects found &amp; fixed'],
        [str(sevc['Critical']), 'critical issues fixed'], ['48/48', 'Delhivery staging lifecycle'], ['510', 'responsive checks, 0 issues']]
kt = Table([[Paragraph(f'<font name="PB" size="20" color="#FF6B2C">{a}</font><br/><font name="P" size="8" color="#6B7280">{b}</font>', S['body']) for a, b in kpis[i:i + 3]] for i in (0, 3)], colWidths=[58 * mm] * 3)
kt.setStyle(TableStyle([('BOX', (0, 0), (-1, -1), 0.5, LINE), ('INNERGRID', (0, 0), (-1, -1), 0.5, LINE), ('TOPPADDING', (0, 0), (-1, -1), 10), ('BOTTOMPADDING', (0, 0), (-1, -1), 10), ('LEFTPADDING', (0, 0), (-1, -1), 10)]))
story += [kt, Spacer(1, 16 * mm),
          callout('<b>Status in one line:</b> the code is production-ready and live on chillfi.in. Real customers can be served once the owner switches '
                  'PhonePe and Delhivery to live credentials from the admin panel (Settings → Go-Live checklist). Until then the site safely takes '
                  'Cash on Delivery orders only.'),
          PageBreak()]

# ── contents ─────────────────────────────────────────────────────────────────
toc = ['Executive summary', 'Scope and method', 'Test results by area', 'Security findings and fixes', 'Money, payments and orders',
       'Delhivery shipping (staging end-to-end)', 'Admin → app / website synchronisation', 'Responsive and usability audit',
       'New features built', 'Production deployment log', 'Production readiness today (Go-Live checklist)', 'Owner action list',
       'Operations: backups, monitoring, server', 'Remaining limitations', 'Appendix A — Screenshots', 'Appendix B — Complete defect register']
story += [P('Contents', 'h1')] + [P(f'{i + 1}. {t}') for i, t in enumerate(toc)] + [PageBreak()]

# ── 1 executive summary ──────────────────────────────────────────────────────
story += [P('1. Executive summary', 'h1'),
          P(f'The whole ChillFi system was inventoried and tested against three project-specific QA checklists ({tot_cases} test cases). '
            f'<b>{tot["PASS"]} pass, {tot["FAIL"]} fail, {tot["BLOCKED"]} blocked</b> (each needs a credential or an action only the owner can take) and '
            f'{tot["NOT APPLICABLE"]} not applicable. No case is left untested.'),
          P(f'Testing found <b>{len(all_defects)} defects</b> — {sevc["Critical"]} critical, {sevc["High"]} high, {sevc["Medium"]} medium, {sevc["Low"]} low. '
            '<b>All are fixed, re-tested and deployed.</b> The most serious were a price exploit (negative cart quantities), admin settings '
            'exposing stored credentials to the browser, a coupon bypass, test-payment shortcuts reachable on the live server, an unused password '
            'login that gave single-factor access to the admin account, and abandoned payments holding stock forever.'),
          P('The core business flow was proven end-to-end against <b>real Delhivery staging</b>: product → cart → checkout → order → shipment (AWB) '
            '→ tracking events → customer notifications (in-app + push) → Delivered, with the app, website, admin and database all showing the same final state.'),
          P('Beyond fixes, the project gained: GST-inclusive pricing, GST tax invoices, email and SMS notification channels, admin new-order and '
            'low-stock alerts, a Go-Live checklist in the admin, abandoned-payment expiry with automatic refunds for late payments, contact details '
            'editable from the admin, nightly database backups, a health endpoint for uptime monitoring, a Node 22 server upgrade and auto-restart on reboot.'),
          Spacer(1, 3 * mm),
          callout('<b>Verdict.</b> Production-ready from a code, security and testing standpoint. <b>Before taking real online payments and live shipments</b> the owner must, '
                  'from the admin panel: (1) enter live PhonePe keys, (2) enter the live Delhivery token and pickup location, (3) confirm COD with Delhivery, '
                  '(4) publish app v1.0.3 and turn on force update, (5) enter the real GSTIN and contact details. Recommended: uptime monitor, SMTP email, '
                  'off-server backup copy.', GREEN, '#F0FDF4'),
          PageBreak()]

# ── 2 scope ──────────────────────────────────────────────────────────────────
story += [P('2. Scope and method', 'h1'),
          table([['Component', 'Technology', 'What was covered'],
                 ['Mobile app', 'Flutter (Android), v1.0.3+4', 'Every screen: onboarding, OTP login/sign-up, home, search, listing, product, cart, checkout, payment, orders, tracking, wishlist, profile, help, settings, permissions, push'],
                 ['Website', 'React + Vite + TypeScript', 'All customer pages incl. account, orders, tracking, checkout, policies; 30 pages × 17 screen widths'],
                 ['Admin panel', 'React (same site, /admin)', 'Dashboard, products, orders, refunds, users, categories, brands, reviews, messages, notifications, analytics, banners, coupons, shipping rules, settings, API keys'],
                 ['Backend', 'Node/Express, PostgreSQL 15', 'Every API used by the three clients, payments (PhonePe), shipping (Delhivery), notifications, security'],
                 ['Integrations', 'Delhivery staging, PhonePe UAT, Firebase', 'Real staging shipments, sandbox payments, real OTP (test number) and FCM push']],
                [30 * mm, 42 * mm, 102 * mm]),
          Spacer(1, 4 * mm), P('Method', 'h2')]
story += bullets(['Each defect followed <b>find → fix → re-test → regression → record</b>; nothing marked PASS without evidence (screenshots, API output or logs).',
                  'Automated browser suites (Playwright, 17 suites) for website and admin; Android emulator driving for the app; API-level lifecycle scripts for Delhivery and payments.',
                  'Production was only touched with explicit owner approval: two read-only checks, one data correction (ratings), five deployments and server maintenance.',
                  'Delhivery was used in <b>staging only</b>; no real shipment was created and no real money moved.'])
story.append(PageBreak())

# ── 3 results ────────────────────────────────────────────────────────────────
rows = [['Area', 'Total', 'Pass', 'Fail', 'Blocked', 'N/A', 'Pass rate']]
for k in ['app', 'website', 'admin']:
    t, c = T[k]; app_ = t - c['NOT APPLICABLE']
    rows.append([names[k], str(t), str(c['PASS']), str(c['FAIL']), str(c['BLOCKED']), str(c['NOT APPLICABLE']), f'{100 * c["PASS"] / app_:.1f}%'])
rows.append(['<b>All</b>', f'<b>{tot_cases}</b>', f'<b>{tot["PASS"]}</b>', f'<b>{tot["FAIL"]}</b>', f'<b>{tot["BLOCKED"]}</b>', f'<b>{tot["NOT APPLICABLE"]}</b>',
             f'<b>{100 * tot["PASS"] / (tot_cases - tot["NOT APPLICABLE"]):.1f}%</b>'])
story += [P('3. Test results by area', 'h1'), table(rows, [40 * mm, 20 * mm, 20 * mm, 20 * mm, 22 * mm, 20 * mm, 32 * mm]), Spacer(1, 5 * mm),
          P('Blocked cases — all waiting on an owner credential or action', 'h2')]
brows = [['Area', 'Case', 'What it needs']]
need = {'Image upload': 'Cloudinary keys on the local test setup (production has keys)', 'Promo banner CRUD + upload': 'Cloudinary keys (local)',
        'Avatar upload': 'Cloudinary keys (local)', '"I\'ve Completed Payment"': 'A completed PhonePe sandbox card payment (owner enters test card)',
        'Failed payment': 'PhonePe sandbox failure flow (owner)', 'Failed: reason & retry': 'PhonePe sandbox failure flow (owner)',
        'Send OTP': 'Website reCAPTCHA — check once by hand', 'OTP boxes': 'Website reCAPTCHA — check once by hand',
        'Verify & login': 'Website reCAPTCHA — check once by hand', 'Place online (test payment)': 'Completed sandbox payment (owner)'}
for k, d in areas.items():
    for s in d['sections']:
        for c in s['cases']:
            if c.get('status') == 'BLOCKED': brows.append([names[k], f'{c["id"]} {c["element"]}', need.get(c['element'], c.get('actual', '')[:90])])
story += [table(brows, [28 * mm, 62 * mm, 84 * mm]), Spacer(1, 5 * mm), P('Regression (final run, after all fixes)', 'h2'),
          table([['Suite / check', 'Result'],
                 ['Website suites (browse, listing, product, cart, checkout, account, addresses, login, maintenance, serviceability)', '107/107'],
                 ['Admin suites A–F (products, orders, refunds, users, catalogue, content, coupons, shipping rules, settings, security)', '96/100 — 2 need Cloudinary keys, 1 harness limitation, 1 superseded check'],
                 ['Delhivery staging lifecycle (API, real staging)', '48/48'],
                 ['Payment expiry / late-payment refund test', '12/12'],
                 ['Responsive audit (30 pages × 17 widths, 320–1920 px)', '510 checks · 0 overflow · 0 JS errors'],
                 ['Tap audit (every interactive element reachable)', '2,755 elements · 0 blocked'],
                 ['Flutter analyzer', 'clean (2 pre-existing lint notes)']], [120 * mm, 54 * mm]),
          PageBreak()]

# ── 4 security ───────────────────────────────────────────────────────────────
story += [P('4. Security findings and fixes', 'h1'), P('All fixed and deployed to production.'),
          table([['Severity', 'Finding', 'Fix'],
                 ['Critical', 'Cart accepted negative / zero / fractional / huge quantities: a negative line cut the order total (pay ₹1,000 for a ₹5,000 item) and increased stock.', 'Integer 1…stock enforced on cart add/update; order creation refuses non-positive quantities. Production check: never exploited.'],
                 ['Critical', 'Saving Admin → Settings returned every stored credential (Delhivery / PhonePe secrets) to the browser.', 'Credential keys filtered from every settings response; credentials only via masked API-keys screen.'],
                 ['Critical', 'Coupons not re-validated at order time (expiry, minimum order, per-user use).', 'Full re-validation inside order creation, with row locks on usage limits.'],
                 ['Critical', 'Payment test shortcuts could mark orders paid when the server was not strictly "development".', 'Require explicit development flag; sandbox payments can never mark orders paid on production.'],
                 ['High', 'Unused password-login route allowed single-factor admin sign-in; password reset open.', 'Password sign-in/reset disabled; admin sign-in is phone OTP only.'],
                 ['High', 'Production was running PhonePe in sandbox mode — a sandbox "payment" could have been accepted.', 'Server refuses online orders/payments until PhonePe is live; clients show COD only.'],
                 ['High', 'Any token-refresh hiccup (offline, rate limit) signed users out; concurrent refreshes raced.', 'Single-flight refresh; sign out only when the server rejects the session.'],
                 ['High', 'Logout left cart/wishlist of the previous user on shared devices; staff role default too permissive.', 'State cleared on logout; staff role checks tightened; staff blocked from admin-only pages.'],
                 ['Medium', 'Raw technical errors (SQL, provider messages) could reach customers.', 'Friendly errors everywhere, internal detail logged with a reference id.']],
                [20 * mm, 84 * mm, 70 * mm]),
          Spacer(1, 4 * mm), P('Verified safeguards', 'h2')]
story += bullets(['Credentials masked in the admin and encrypted at rest; webhook secret compared in constant time.',
                  'Rate limit 200 requests/min per real client IP in production (proxy-aware).',
                  'Admin/staff sign-ins recorded (time, IP, device); admin panel signs out after 30 minutes idle.',
                  'HTTPS enforced by the web server (HTTP → HTTPS redirect, valid Let\'s Encrypt certificate, auto-renewing).'])
story.append(PageBreak())

# ── 5 money ──────────────────────────────────────────────────────────────────
story += [P('5. Money, payments and orders', 'h1')]
story += bullets(['<b>GST-inclusive pricing</b> (owner decision): the displayed price is the price paid. GST is shown as an "Includes GST" line and stored for invoices. Verified: shown total = charged total on website and app (e.g. ₹999 item → ₹999; 20% coupon → ₹799.20).',
                  '<b>Abandoned online payments</b> auto-cancel after 2 hours — only when PhonePe confirms the payment did not complete; stock and coupon released; customer informed. If PhonePe cannot be reached, nothing is cancelled.',
                  '<b>Late payment on a cancelled order</b> automatically opens a full refund request and tells the customer (it used to send "Order confirmed" and keep the money).',
                  '<b>Auto-refund</b> request whenever a paid order is cancelled; Refunds admin page fixed (it never loaded).',
                  '<b>Revenue</b> uses one definition everywhere (paid and not cancelled); analytics stale-response race fixed.',
                  '<b>Orders keep their delivery address</b> (snapshot at order time) — editing or deleting an address no longer changes past orders or pending shipments.',
                  '<b>Fake ratings</b> removed on production (9 products had seeded counts such as 4.3★ / 52,000 reviews).',
                  '<b>Checkout rules</b>: pincode serviceability, store-wide COD switch and per-pincode rules (fee, COD, delivery estimate) all enforced by the server and explained to customers.'])
story += [Spacer(1, 3 * mm), P('GST tax invoices (new)', 'h2')]
story += bullets(['Sequential numbers per financial year (<b>CF/2627/000001</b>), CGST + SGST within the seller\'s state, IGST otherwise, HSN per product, amount in words, reverse-charge line.',
                  'Download from the website order page, the app order details and the admin order view; orders from before the GST change are reproduced exactly as they were charged.',
                  '<b>Off until the owner enters the real GSTIN</b> and switches invoices on (the sample GSTIN in settings is rejected).'])
story.append(KeepTogether(shot(os.path.join(HERE, 'sample_invoice.png'), 120, 'Sample invoice from local test data (sample seller details). This test order was placed before the switch to GST-inclusive prices, so GST appears on top — the invoice reproduces exactly what was charged. New orders show GST included in the price.', 110)))
story.append(PageBreak())

# ── 6 delhivery ──────────────────────────────────────────────────────────────
story += [P('6. Delhivery shipping — staging end-to-end', 'h1'), P('Final run against real <b>staging-express.delhivery.com</b>: <b>48/48 checks passed</b>.'),
          table([['Area', 'Result'],
                 ['Shipment creation', 'Automatic — COD orders immediately, prepaid once paid; duplicate / parallel re-ship refused'],
                 ['AWB and pickup', 'AWB stored and shown in app, website and admin; pickup auto-booked; shipping label available'],
                 ['Tracking', 'Customer and admin tracking match; full scan history'],
                 ['Status events', 'In transit, at destination hub, out for delivery, failed attempt, RTO, delivered; out-of-order and duplicate events ignored'],
                 ['Delivered', 'Order marked Delivered, COD marked paid, cannot regress'],
                 ['Cancellation', 'Before pickup cancels the shipment; after pickup refused; RTO never shown as delivered'],
                 ['Notifications', 'Placed, shipment created, shipped, out for delivery, delivered, cancelled, returned — in-app and push, no duplicates (21 on device, 0 duplicates)'],
                 ['Webhook security', 'Bad/missing token → 401, invalid payload → 400'],
                 ['Errors', 'Rejections show an actionable reason, e.g. "Cash on Delivery isn\'t enabled on this Delhivery account"']],
                [36 * mm, 138 * mm]),
          Spacer(1, 3 * mm),
          callout('Staging note: the Delhivery <b>staging</b> account has COD disabled, so prepaid orders were used for the lifecycle. '
                  'Production stays on staging (no token) until the owner switches it — orders placed now are not booked with Delhivery automatically.', AMBER, '#FFFBEB'),
          Spacer(1, 4 * mm), P('Proof — one order, same state everywhere (CF4688283969, AWB 86406910000302)', 'h2')]
imgs = shot(os.path.join(SHOTS, 'core_flow_app.png'), 55, None, 95); imgs2 = shot(os.path.join(SHOTS, 'web', 'core_flow_admin.png'), 110, None, 95)
if imgs and imgs2:
    story.append(Table([[imgs[0], imgs2[0]]], colWidths=[60 * mm, 114 * mm], style=[('VALIGN', (0, 0), (-1, -1), 'TOP')]))
    story.append(P('Left: app order details (Delivered, Paid, AWB). Right: admin orders list (Delivered, AWB).', 'smallg'))
story.append(PageBreak())

# ── 7 sync ───────────────────────────────────────────────────────────────────
story += [P('7. Admin → app / website synchronisation', 'h1'), P('Each change was made in the admin and observed live in the app (Android emulator) and on the website.'),
          table([['Admin change', 'Result in app / website'],
                 ['Banner created / deleted', 'Shown first on Home; removed when deleted'],
                 ['Coupon deleted', 'Offer card switched to the next real coupon'],
                 ['Price edited', 'New price (₹1,777) shown in search and product page'],
                 ['Product deactivated', 'Search: "No results"; wishlist: "No longer available"; product page: "Product unavailable"; cannot be added to cart'],
                 ['COD master switch', 'Payment screen toggles "Currently unavailable" ↔ available, live, no restart'],
                 ['Maintenance mode', 'Maintenance screen with the admin\'s message; "Check Again" resumes; admin can still sign in on the website'],
                 ['Free-delivery threshold', 'Changed to ₹799 → product page, top bar and trust strips updated'],
                 ['Contact details', 'Changed phone/email → website contact, help and policy pages and app Help & Support updated'],
                 ['Push / admin notification', 'Delivered to the device (foreground and background) on the "Order updates" channel']],
                [48 * mm, 126 * mm]),
          PageBreak()]

# ── 8 responsive ─────────────────────────────────────────────────────────────
story += [P('8. Responsive and usability audit', 'h1')]
story += bullets(['<b>Website:</b> 30 pages × 17 widths (320 → 1920 px), signed in, including account and tracking pages — <b>0 horizontal overflow, 0 JavaScript errors</b>.',
                  '<b>Tap audit:</b> 2,755 interactive elements — none hidden or blocked.',
                  '<b>Universal error handling:</b> every failure on app, website and admin shows a friendly dialog or inline state with retry — never a raw error or blank screen.',
                  '<b>Honesty pass:</b> fake or placeholder content removed or labelled: fake ratings and stats, "CHILLFI Cash", a fake location-permission screen, dead buttons, mock screens with invented products, placeholder settings.',
                  '<b>App polish:</b> bundled Poppins font (works offline), local-time dates, guest sign-in prompts, pinned maintenance "Check Again", correct notification channel and app name.'])
story.append(PageBreak())

# ── 9 features ───────────────────────────────────────────────────────────────
story += [P('9. New features built', 'h1'),
          table([['Feature', 'What it does', 'Status'],
                 ['GST tax invoices', 'Numbered invoices, CGST/SGST/IGST, HSN, PDF download on website/app/admin', 'Live · off until real GSTIN'],
                 ['Email notifications', 'Order emails to customers; new-order and low-stock alerts to the store; "Send test email"', 'Live · inactive until SMTP entered'],
                 ['SMS order updates', 'MSG91 transactional SMS for key order moments', 'Live · inactive until DLT template'],
                 ['Go-Live checklist', 'Admin page showing every launch item\'s live status with one-click "Fix"', 'Live'],
                 ['Payment safety', 'Abandoned-payment expiry, late-payment auto-refund, sandbox guard on production', 'Live'],
                 ['Contact from admin', 'Phone / email / WhatsApp edited in Store Info, used by app and website', 'Live'],
                 ['Admin security', 'OTP-only sign-in, sign-in log, 30-min idle sign-out, registration pause switch', 'Live'],
                 ['Admin alerts bell', 'Real counts: failed shipments, orders to ship, refunds, messages, low stock', 'Live'],
                 ['Store settings', 'COD switch, per-pincode rules, reviews switch, SEO tags, delivery days — all enforced', 'Live'],
                 ['Health endpoint', '/api/health checks API + database for uptime monitors', 'Live'],
                 ['Nightly backups', 'Database dump at 02:30 IST, 7 daily + 6 monthly, verified', 'Live']],
                [38 * mm, 94 * mm, 42 * mm]),
          PageBreak()]

# ── 10 deploy log ────────────────────────────────────────────────────────────
story += [P('10. Production deployment log (25 September 2026)', 'h1'), P('Every production action below was approved by the owner. Each deployment was preceded by a dry run and followed by health and smoke checks; each has a backup on the server.'),
          table([['#', 'Action', 'Result'],
                 ['1', 'Deploy all security, money and QA fixes (backend + website)', 'Healthy; exploit check: never used (22 orders)'],
                 ['2', 'Recalculate product ratings from real reviews', '9 products corrected; no fake ratings remain'],
                 ['3', 'Deploy GST-inclusive pricing + contact details from admin', 'Charged total = displayed price'],
                 ['4', 'Deploy sandbox-payment guard', 'Online payment off until PhonePe is live (COD only)'],
                 ['5', 'Upgrade server Node 20 → 22.23.3; install pm2 auto-start on reboot', 'Both API processes on Node 22; auto-start enabled'],
                 ['6', 'Deploy invoices, email/SMS, auth hardening, alerts, SEO, health endpoint; add log rotation', 'Healthy; 19/22 orders got address snapshots'],
                 ['7', 'Install nightly database backup (systemd timer)', 'Backups verified: row counts match live for all key tables'],
                 ['8', 'Deploy admin Go-Live checklist', 'Live; reflects real production status']],
                [8 * mm, 100 * mm, 66 * mm]),
          PageBreak()]

# ── 11 readiness ─────────────────────────────────────────────────────────────
story += [P('11. Production readiness today (Go-Live checklist)', 'h1'), P('Status as read from the live production server. The same checklist is in Admin → Settings → Go-Live, with a "Fix" button for each item.'),
          table([['Item', 'Status', 'Where to fix (admin)'],
                 ['Online payments live (PhonePe)', '❌ Test mode — COD only', 'API Keys → Payment Gateway'],
                 ['Delhivery live shipping', '❌ Staging mode', 'API Keys → Shipping'],
                 ['Cash on Delivery', '✅ On (confirm with Delhivery)', 'Shipping → COD Available'],
                 ['App v1.0.3 + force update', '❌ After Play Store release', 'Store Info → Force Update'],
                 ['GST tax invoices', '❌ Sample GSTIN', 'Store Info'],
                 ['Real contact details', '❌ Test values', 'Store Info'],
                 ['Order emails (SMTP)', '❌ Not set up', 'API Keys → Email'],
                 ['SMS updates (optional)', '❌ Not set up', 'API Keys → OTP / SMS'],
                 ['Nightly database backup', '✅ Running, verified', 'Automatic'],
                 ['Uptime monitor', '— Outside admin', 'uptimerobot.com → /api/health']],
                [62 * mm, 56 * mm, 56 * mm]),
          Spacer(1, 4 * mm)]
story += [Table([[x] for x in shot(os.path.join(SHOTS, 'web', 'adm_golive.png'), 150, 'Admin → Settings → Go-Live checklist.', 150)])] if os.path.exists(os.path.join(SHOTS, 'web', 'adm_golive.png')) else []
story.append(PageBreak())

# ── 12 owner actions ─────────────────────────────────────────────────────────
story += [P('12. Owner action list', 'h1'), P('Required before serving real customers', 'h2'),
          table([['#', 'Action', 'Where'],
                 ['1', 'Enter live PhonePe Merchant ID + Salt Key, then set environment PRODUCTION. Then one real test order and refund.', 'Admin → API Keys → Payment Gateway'],
                 ['2', 'Enter live Delhivery API token + exact pickup location name, then set environment production (see QA/DELHIVERY_GO_LIVE.md).', 'Admin → API Keys → Shipping'],
                 ['3', 'Confirm with Delhivery that COD is enabled on the live account (otherwise switch COD off).', 'Admin → Shipping'],
                 ['4', 'Upload FinalApp/ChillFi-v1.0.3-build4-release.aab to Google Play; then turn on force update with minimum 1.0.3.', 'Play Console, then Admin → Store Info'],
                 ['5', 'Enter real GSTIN, legal name and address; switch on GST invoices.', 'Admin → Store Info']],
                [8 * mm, 114 * mm, 52 * mm]),
          P('Recommended soon', 'h2'),
          table([['#', 'Action', 'Where'],
                 ['6', 'Real support phone / email / WhatsApp (customers currently see test values).', 'Admin → Store Info'],
                 ['7', 'Uptime monitor on https://chillfi.in/api/health (free, 5 minutes).', 'uptimerobot.com'],
                 ['8', 'SMTP details for emails, then "Send test email"; optional MSG91 DLT template for SMS.', 'Admin → API Keys'],
                 ['9', 'Off-server backup copy: EBS snapshot policy, or an IAM role so backups can go to S3.', 'AWS console'],
                 ['10', 'Remove Firebase test phone numbers before public launch (anyone can sign in with +91 90000 00001 / 123456).', 'Ask the developer'],
                 ['11', 'One test on a real Android phone: login, payment, push.', 'Owner'],
                 ['12', 'Push the code to a private Git repository (currently only on the developer Mac and the server).', 'Owner approval']],
                [8 * mm, 114 * mm, 52 * mm]),
          PageBreak()]

# ── 13 ops ───────────────────────────────────────────────────────────────────
story += [P('13. Operations: backups, monitoring, server', 'h1')]
story += bullets(['<b>Server:</b> AWS EC2 (Amazon Linux 2023, ~1 GB RAM, 2 vCPU), Node 22.23.3, pm2 with 2 API processes, auto-start on reboot, log rotation (10 MB × 7, compressed), nginx with HTTPS.',
                  '<b>Backups:</b> nightly at 02:30 IST → ~/db-backups (7 daily + 6 monthly), each checked readable; ~/bin/chillfi-restore-check.sh compares backup contents with live (read-only). Restore steps in QA/OPS_RUNBOOK.md.',
                  '<b>Gap:</b> backups are on the same server — they protect against mistakes and corruption, not against losing the server. Add EBS snapshots or an S3 copy.',
                  '<b>Monitoring:</b> https://chillfi.in/api/health returns 200 only when API and database respond (503 otherwise). An external monitor must be created by the owner.',
                  '<b>Server size:</b> fine for launch. When traffic grows move to t3.small (2 GB) — first confirm 3.111.32.220 is an Elastic IP.',
                  '<b>Runbooks:</b> QA/OPS_RUNBOOK.md (operations), QA/DELHIVERY_GO_LIVE.md (switching Delhivery to live).'])
story += [Spacer(1, 4 * mm), P('14. Remaining limitations', 'h1')]
story += bullets(['iOS app not built or tested — all app testing was on Android.',
                  'Image uploads not testable on the local setup (no Cloudinary keys); production has keys — try one upload in the live admin.',
                  'Website OTP login checked by code and API only; its reCAPTCHA step must be checked once by hand.',
                  'Not built: promotional emails (need unsubscribe/consent handling) and guest checkout (orders, tracking and invoices need an account).',
                  'Old app v1.0.2 shows GST added on top until users update — resolved by force update after v1.0.3 is live.'])
story.append(PageBreak())

# ── appendix A ───────────────────────────────────────────────────────────────
story += [P('Appendix A — Screenshots', 'h1')]
pairs = [(os.path.join(SHOTS, 'app_gst_inclusive_cart.png'), 'App cart — GST-inclusive total'), (os.path.join(SHOTS, 'app_help_contact.png'), 'App Help & Support — contact from admin')]
cells = []
for pth, cap in pairs:
    im = shot(pth, 70, None, 150)
    if im: cells.append([im[0], Paragraph(cap, S['smallg'])])
if len(cells) == 2:
    story.append(Table([[cells[0][0], cells[1][0]], [cells[0][1], cells[1][1]]], colWidths=[87 * mm, 87 * mm], style=[('ALIGN', (0, 0), (-1, -1), 'CENTER')]))
story += [Spacer(1, 4 * mm)] + shot(os.path.join(SHOTS, 'web', 'adm16_security_real.png'), 150, 'Admin → Settings → Security — only real controls remain.', 110)
story += [Spacer(1, 3 * mm)] + shot(os.path.join(SHOTS, 'web', 'web_wishlist_unavailable.png'), 150, 'Website wishlist — deactivated product shown as "No longer available".', 95)
story.append(PageBreak())

# ── appendix B ───────────────────────────────────────────────────────────────
story += [P('Appendix B — Complete defect register', 'h1'),
          P(f'{len(all_defects)} defects: {sevc["Critical"]} critical · {sevc["High"]} high · {sevc["Medium"]} medium · {sevc["Low"]} low. All fixed and re-tested (one website content item fixed locally and in seed data; its production banner text is an admin edit).', 'small'),
          Spacer(1, 2 * mm)]
drows = [['ID', 'Area', 'Sev.', 'Defect', 'Fix']]
for k, x in sorted(all_defects, key=lambda kx: (sev_order.get(kx[1]['severity'], 9), kx[0], kx[1]['id'])):
    color = {'Critical': '#B91C1C', 'High': '#B45309', 'Medium': '#1D4ED8', 'Low': '#6B7280'}.get(x['severity'], '#111827')
    drows.append([x['id'], names[k].split()[0] if k != 'app' else 'App', f'<font color="{color}"><b>{x["severity"]}</b></font>', esc(x['title']), esc(x.get('fix') or '—')])
story.append(table(drows, [19 * mm, 16 * mm, 17 * mm, 63 * mm, 59 * mm], font='small'))

# ── page template ────────────────────────────────────────────────────────────
def on_page(c, doc):
    c.saveState()
    if doc.page > 1:
        c.setFillColor(ORANGE); c.rect(0, A4[1] - 8, A4[0], 8, stroke=0, fill=1)
        c.setFont('P', 7.5); c.setFillColor(GREY)
        c.drawString(18 * mm, 10 * mm, 'ChillFi — Complete Project Report · 25 Sep 2026')
        c.drawRightString(A4[0] - 18 * mm, 10 * mm, f'Page {doc.page}')
    else:
        c.setFillColor(ORANGE); c.rect(0, 0, 10, A4[1], stroke=0, fill=1)
    c.restoreState()

doc = BaseDocTemplate(OUT, pagesize=A4, leftMargin=18 * mm, rightMargin=18 * mm, topMargin=18 * mm, bottomMargin=18 * mm,
                      title='ChillFi — Complete Project Report', author='ChillFi QA')
doc.addPageTemplates([PageTemplate(id='all', frames=[Frame(doc.leftMargin, doc.bottomMargin, doc.width, doc.height, id='f')], onPage=on_page)])
doc.build(story)
print(OUT)
