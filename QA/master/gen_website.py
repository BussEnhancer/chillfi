#!/usr/bin/env python3
"""Generates QA/master/website.json (Website Master QA) from the real route inventory (src/App.tsx).
Existing results are preserved on re-run."""
import json, os
HERE = os.path.dirname(os.path.abspath(__file__))
S = []
def sec(name, loc, pre, cases, notes=''):
    S.append(dict(name=name, location=loc, pre=pre, notes=notes, cases=cases))
RESP = lambda page: ('Responsive: mobile / tablet / desktop', f'Automated audit of {page} at 320–430, 600–1100, 1280–1920 px + visual check at 375/768', 'No horizontal scroll, no clipped/overlapping controls, readable text, usable touch targets at every width')
GUEST = 'Guest (logged out)'; LOGGED = 'Logged in as DLV-TEST customer'

sec('Global: Header, Navigation, Footer', 'components/navigation/*', GUEST, [
 ('Logo', 'Click logo', 'Goes to Home'),
 ('Search bar + category selector', 'Type query, optionally choose category, submit', 'Searches (within category if chosen) — no dead "All Categories" control'),
 ('Wishlist / Cart / Account icons', 'Click each', 'Correct page; badges show real counts'),
 ('Mobile hamburger drawer', 'At 375px open menu', 'Search, 6 links, account & wishlist; closes after navigation'),
 ('Category nav links', 'Click Home, Categories, Deals, New Arrivals, Best Sellers, Brands, Track Order', 'Each opens the right content (Brands shows brands, not all products)'),
 ('TopBar', 'View ≥1024px', 'Trust texts; no dead link presented as link'),
 ('Footer links', 'Click every enabled link', 'All open existing pages; "Soon" items not clickable'),
 ('Breadcrumbs', 'Click a breadcrumb', 'Navigates (SPA, no full reload)'),
 ('Maintenance gate', 'Admin enables maintenance_mode', 'Customer pages show Maintenance; admin can still reach /login + /admin'),
 ('404', 'Open unknown URL', '404 page with Go Back / Home / Shop'),
 RESP('header/footer on every page'),
])
sec('Home', 'pages/Home/index.tsx', GUEST, [
 ('Hero banners', 'Load home', 'Admin banners from /home; auto-rotate; arrows/dots work; Shop Now follows banner link'),
 ('Trust bar', 'View', '4 cards render'),
 ('Shop by Category', 'Click category', 'Listing filtered by category'),
 ('Flash sale', 'View', 'Flash products with real countdown (or none); Shop All Deals works'),
 ('Trending', 'View / View All', 'Products; View All opens listing'),
 ('Promo banners', 'Admin promo banners active', 'Shown with working links'),
 ('Top brands', 'Click brand', 'Listing filtered by brand'),
 ('Testimonials', 'Admin testimonials active', 'Shown'),
 ('Newsletter', 'Submit email', 'Real subscription or honest message (no fake success)'),
 ('Product card actions', 'Hover (desktop) / tap (touch) wishlist & cart', 'Actions reachable on touch devices; feedback shown'),
 RESP('/'),
])
sec('Product Listing', 'pages/ProductListing/index.tsx', GUEST, [
 ('Load & count', 'Open /products', 'Products with "Showing X–Y of N"'),
 ('Sort', 'Each option', 'Order changes correctly'),
 ('Category filter', 'Pick category', 'Filtered; chip shown; Clear All resets'),
 ('Brand filter', 'Pick brand', 'Filtered'),
 ('Price filter', 'Drag slider', 'Filtered without request storm'),
 ('Filters on mobile/tablet', 'At 375 / 768px', 'Filters reachable (drawer/panel)'),
 ('Pagination', '>20 products', 'Pages work; fits on mobile'),
 ('Card: add to cart / wishlist', 'Click', 'Works with feedback'),
 ('Hero banner CTA', 'Click Shop Now', 'Does something meaningful (no dead button)'),
 ('Error state', 'Backend down', 'Error message, not "No products found"'),
 RESP('/products'),
])
sec('Search', 'pages/Search/index.tsx', GUEST, [
 ('Search results', 'Search "boat"', 'Matching products'),
 ('Empty query / no results', 'Blank; "zzqq"', 'Guidance + Browse button'),
 ('New search from header while on page', 'Search again', 'Input text and results both update'),
 RESP('/search'),
])
sec('Product Details', 'pages/ProductDetails/index.tsx', GUEST, [
 ('Load', 'Open product', 'Name, images, price, MRP, discount, stock from API'),
 ('Gallery', 'Click thumbnails/arrows', 'Images switch; arrows usable on touch'),
 ('Add to cart / Go to cart', 'Click', 'Added; button becomes Go to Cart'),
 ('Wishlist as guest', 'Click heart logged out', 'Prompt/redirect to login with context (not silent hard reload)'),
 ('Wishlist logged in', 'Toggle', 'Persisted; header badge updates'),
 ('Tabs', 'Description, Specifications, Reviews, FAQs, Delivery', 'Each shows content'),
 ('Write review', 'Logged in, submit', 'Validation; review saved'),
 ('Offers / seller card', 'View', 'Real or clearly informational; no dead T&C buttons'),
 ('Related products', 'Scroll', 'Same-category products'),
 ('Not found', 'Bad id', '"Product not found"'),
 RESP('/product/:id'),
])
sec('Categories & Offers', 'pages/Categories, pages/Offers', GUEST, [
 ('Category cards', 'Click', 'Listing filtered'),
 ('Mobile category sheet', 'At 375 tap Filter Categories', 'Sheet lists categories'),
 ('Popular brands', 'Click', 'Works or not styled as links'),
 ('Coupons list', 'Open /offers', 'Active coupons from API; copy works'),
 ('How to use coupons modal', 'Open/close', 'Works'),
 ('Offer tabs / hero CTA / sidebar CTAs', 'Click', 'No dead controls or fake counters'),
 RESP('/categories, /offers'),
])
sec('Login / Register', 'pages/Login/index.tsx', GUEST, [
 ('Tabs', 'Switch Login/Register', 'Register shows name/email'),
 ('Phone validation', 'Enter 5 digits / 1234567890', 'Error for invalid Indian mobile'),
 ('Send OTP', 'Valid number', 'Firebase OTP (requires real phone / test number)'),
 ('OTP boxes', 'Type/paste/backspace', 'Works; fits at 320px'),
 ('Verify & login', 'Correct OTP', 'Tokens saved; redirected to intended page'),
 ('Email validation (register)', 'Invalid email', 'Rejected'),
 RESP('/login'),
])
sec('Cart', 'pages/Cart/index.tsx', LOGGED + '; item in cart', [
 ('Items', 'Open /cart', 'Items with qty, price, line total'),
 ('Qty +/−', 'Click', 'Updates; + capped at stock'),
 ('Remove', 'Click trash', 'Removed'),
 ('Delivery line', 'Cart below ₹499', 'Shows the same delivery fee checkout will charge'),
 ('Proceed to checkout', 'Click', 'Checkout'),
 ('Empty cart', 'Remove all', 'Empty state'),
 RESP('/cart'),
])
sec('Checkout', 'pages/Checkout/index.tsx', LOGGED + '; item in cart', [
 ('Addresses', 'Open', 'Saved addresses selectable'),
 ('Add address validation', 'Invalid phone / pincode / empty', 'Field errors; nothing saved'),
 ('Pincode serviceability', 'Address with non-serviceable pincode', 'Customer told before paying (per Shipping Policy)'),
 ('Delivery options', 'Choose Express', 'Price shown equals price charged'),
 ('Coupon', 'Apply valid / invalid code', 'Discount / error'),
 ('Order summary', 'Compare with backend', 'Subtotal, delivery, GST, coupon, total = order total'),
 ('Place COD order', 'Choose COD, place', 'Order created; success page; Delhivery shipment attempted'),
 ('Place online (test payment)', 'Choose UPI, place', 'Dev payment → /order-success; order Paid; shipment created'),
 ('Failure handling', 'Payment/confirm fails', 'User sees error; cart not lost'),
 ('Summary load failure', '/cart fails', 'Error message instead of endless "Calculating"'),
 RESP('/checkout'),
])
sec('Order Success / Failed', 'pages/OrderSuccess, pages/OrderFailed', LOGGED, [
 ('Success content', 'After COD / online order', 'Order ID, total; COD says Pay on Delivery (not Payment Confirmed)'),
 ('Track My Order', 'Click', 'Opens that order'),
 ('Failed reason', 'Backend redirects with ?reason=', 'Reason displayed'),
 ('Failed: Try Again', 'Click', 'Leads to a working retry (cart/items not lost)'),
 RESP('/order-success, /order-failed'),
])
sec('My Account', 'pages/MyAccount/index.tsx', LOGGED, [
 ('Profile card', 'Open /account', 'Name, phone, email from API'),
 ('Quick actions', 'Click each', 'Correct destinations'),
 ('Recent orders', 'View', 'Latest 3 orders; Details opens that order'),
 ('Account navigation on mobile', 'At 375/768', 'All account pages reachable'),
 ('Placeholder widgets (wallet, coins, refer, premium)', 'View/click', 'No dead buttons presented as working features'),
 ('Logout', 'Click', 'Session cleared; redirected'),
 RESP('/account'),
])
sec('My Orders', 'pages/Orders/index.tsx', LOGGED, [
 ('List & tabs', 'Open /account/orders', 'Orders, status tabs filter'),
 ('Order card', 'View', 'Real item count; status badge'),
 ('View Details', 'Click', 'Opens tracking page'),
 ('Search', 'Search order id', 'Finds orders'),
 ('Pagination', 'Many orders', 'Pages work; fits on mobile'),
 ('Right-column CTAs', 'Find My Order, Buy Again, Invoices, Return', 'No dead/misleading buttons'),
 RESP('/account/orders'),
])
sec('Order Tracking / Details', 'pages/Tracking/index.tsx', LOGGED + '; order with AWB', [
 ('Header & status card', 'Open order', 'Order id, date, status + Delhivery stage'),
 ('Progress tracker', 'View at 375 & desktop', 'Stages readable, correct stage highlighted'),
 ('Delivery info', 'View', 'Address, courier Delhivery, AWB, expected date'),
 ('Delivery timeline', 'View', 'Real Delhivery scans, newest first'),
 ('Cancel order', 'Processing order → cancel', 'Modal; cancels; Delhivery shipment cancelled'),
 ('Refund/Return request', 'Delivered/Cancelled order', 'Modal validates; submitted; status pill'),
 ('Rate & Review', 'Delivered order', 'Works or removed'),
 RESP('/account/orders/:id/track'),
])
sec('Wishlist, Addresses, Settings, Notifications, Reviews', 'pages/Wishlist, SavedAddresses, EditProfile, Notifications, MyReviews', LOGGED, [
 ('Wishlist list/remove/move to bag', 'Use each', 'Works; header badge in sync'),
 ('Wishlist dead CTAs', 'Share, suggestions, promo', 'No dead controls / fake products'),
 ('Addresses CRUD + default', 'Add/edit/delete/default', 'Works with validation and error feedback'),
 ('Edit profile', 'Change name/email', 'Validated and saved; visible in app'),
 ('Notifications list', 'Open', 'Order/shipping notifications from API'),
 ('My reviews', 'Open', 'Reviews listed; images load'),
 RESP('account sub-pages'),
])
sec('Support, About, Contact, Policies, Delete Account', 'pages/Support, AboutUs, ContactUs, *Policy, DeleteAccount', GUEST, [
 ('Contact form', 'Submit valid / invalid email', 'Validates; POST /contact succeeds; appears in Admin → Messages'),
 ('Contact details', 'View', 'Real business phone/email/address'),
 ('Support page controls', 'Click search, topics, chat/call/whatsapp/email', 'Working links (tel:/mailto:/wa.me) — no dead buttons'),
 ('FAQ accordion', 'Expand/collapse', 'Works'),
 ('About page CTA & stats', 'Click Explore; read stats', 'CTA works; no invented stats'),
 ('Policy pages', 'Open all 5', 'Content renders; cross-links work'),
 ('Delete account page', 'Find link; run flow with OTP', 'Reachable; OTP required; session cleared after deletion'),
 RESP('static pages'),
])
sec('Delhivery — Website Order Lifecycle', 'website + backend + Delhivery staging', LOGGED, [
 ('Order → shipment', 'Place online test order on website', 'Real staging AWB stored'),
 ('Tracking page shows Delhivery data', 'Open order', 'Courier, AWB, real scan'),
 ('Status updates reach website', 'In transit → Out for delivery → Delivered events', 'Status card, tracker, timeline update'),
 ('Notifications list', 'After events', 'One notification per stage'),
 ('Cancel before pickup', 'Cancel on website', 'Delhivery cancellation accepted'),
 ('Web ⇄ App ⇄ Admin agree', 'Compare', 'Same state everywhere'),
])

sec('Error Handling & Universal Error Dialog', 'utils/api.ts, components/feedback/ErrorDialog.tsx', GUEST, [
 ('Offline submit (Contact)', 'Network down, submit', 'Dialog "No internet connection"; no "Failed to fetch"'),
 ('HTML 502 from proxy', 'Gateway returns HTML', 'Friendly server message; no JSON parse error'),
 ('500 with internal text', 'API returns SQL text', 'Friendly server message only'),
 ('Business 4xx message', 'API returns valid user message', 'Message shown as-is in dialog'),
 ('Dialog on phone & desktop', '375 and 1440', 'Centered, readable, OK closes, Esc closes'),
 ('Load failure (Orders)', 'Orders API offline', 'Inline friendly message; no technical text'),
 ('Checkout place-order failure', 'Fail /orders', 'Dialog "Couldn\'t place your order"'),
 ('Tracking cancel/refund failure', 'Fail request', 'Dialog + inline friendly text'),
])

def build():
    path = os.path.join(HERE, 'website.json'); old = {}
    if os.path.exists(path):
        for s in json.load(open(path))['sections']:
            for c in s['cases']: old[c['id']] = c
    sections = []
    for si, s in enumerate(S, 1):
        cases = []
        for ci, (el, steps, exp) in enumerate(s['cases'], 1):
            cid = f'WEB-{si:02d}-{ci:02d}'
            base = dict(id=cid, element=el, pre=s['pre'], steps=steps, expected=exp, actual='', status='NOT TESTED', evidence='', defect='', retest='')
            if cid in old:
                for k in ('actual', 'status', 'evidence', 'defect', 'retest'): base[k] = old[cid].get(k, base[k])
            cases.append(base)
        sections.append(dict(id=f'WEB-{si:02d}', name=s['name'], location=s['location'], notes=s['notes'], cases=cases))
    prev = json.load(open(path)) if os.path.exists(path) else {}
    data = dict(title='ChillFi Website — Master QA Testing Report', filename='ChillFi_Website_Master_QA.pdf',
                subtitle='Every customer route in src/App.tsx, derived from the actual implementation, incl. responsive checks at 17 viewports.',
                scope='Customer website (React/Vite). Admin panel is covered in its own report.',
                environment='Local build :5200 → backend :5000 · headless Chrome (Playwright) + Chrome · Delhivery STAGING',
                sections=sections, defects=prev.get('defects', []), blockers=prev.get('blockers', []))
    json.dump(data, open(path, 'w'), indent=1, ensure_ascii=False)
    print(path, sum(len(s['cases']) for s in sections), 'cases in', len(sections), 'sections')
build()
