#!/usr/bin/env python3
"""Generates QA/master/app.json (Mobile App Master QA) from the real screen inventory (lib/).
Only (re)creates cases that don't exist yet — existing results are preserved on re-run."""
import json, os
HERE = os.path.dirname(os.path.abspath(__file__))

S = []
def sec(name, loc, pre, cases, notes=''):
    S.append(dict(name=name, location=loc, pre=pre, notes=notes, cases=cases))

LOGGED = 'Logged in as DLV-TEST customer; backend reachable'
GUEST = 'Fresh install / guest'

sec('Splash Screen', 'features/intro/splash_screen.dart', GUEST, [
 ('Logo & branding', 'Launch app', 'ChillFi logo, wave background and 3 badges (Trusted Quality, Fast Delivery, Best Deals) render centred without overflow'),
 ('Remote config fetch', 'Launch with backend up', 'GET /app-config called; app continues after ~3s'),
 ('Maintenance routing', 'Admin enables maintenance_mode; relaunch', 'App routes to Maintenance screen with admin message'),
 ('Force update routing', 'Admin sets force_update_enabled + min_app_version above installed version; relaunch', 'App routes to Force Update screen; current version must NOT be blocked when min version ≤ installed'),
 ('Logged-in routing', 'Launch with valid session', 'Goes straight to Home'),
 ('First-launch routing', 'Fresh install', 'Goes to Onboarding One'),
 ('Returning guest routing', 'Onboarding already seen, logged out', 'Goes to Welcome screen'),
 ('Offline launch', 'Launch with network off', 'App does not hang on splash; shows usable state / message'),
])
sec('Maintenance Screen', 'core/widgets/maintenance_screen.dart', 'maintenance_mode on', [
 ('Content', 'Open via maintenance mode', '"We\'re Under Maintenance" + server message shown'),
 ('"Notify Me When It\'s Back" button', 'Tap', 'Button performs an action (feedback) — not a dead control'),
 ('"Go to Home"/retry button', 'Tap after admin disables maintenance', 'User can leave the screen / retry without reinstalling'),
])
sec('Force Update Screen', 'core/widgets/force_update_screen.dart', 'force update active', [
 ('Content', 'Open via force update', '"Update Required" + server message'),
 ('"Update Now"', 'Tap', 'Opens Play Store listing for the app'),
 ('Version comparison uses real build version', 'Compare AppConfig.appVersion with pubspec version', 'App reports its real installed version (1.0.2) so users on the latest build are never blocked'),
])
for i, (title, nxt) in enumerate([('Onboarding One', 'Onboarding Two'), ('Onboarding Two', 'Onboarding Three')], 1):
    sec(title, f'features/onboarding/onboarding_screen_{["one","two"][i-1]}.dart', GUEST, [
     ('Illustration, headings, badges', 'Open screen', 'All text/images render, no clipping on 1080×2400'),
     ('"Skip"', 'Tap Skip', 'Marks onboarding seen; goes to Welcome'),
     ('"Next"', 'Tap Next', f'Goes to {nxt}'),
    ])
sec('Onboarding Three', 'features/onboarding/onboarding_screen_three.dart', GUEST, [
 ('Illustration, headings, badges', 'Open screen', 'All content renders'),
 ('"Skip"', 'Tap', 'Goes to Welcome'),
 ('"Get Started"', 'Tap', 'Marks onboarding seen; goes to Welcome; relaunch skips onboarding'),
])
sec('Welcome Screen', 'features/auth/welcome_screen.dart', GUEST, [
 ('Branding & feature cards', 'Open', 'Logo, "Welcome to CHILLFI", 3 feature cards render'),
 ('"Get Started"', 'Tap', 'Opens Login'),
 ('"Login / Signup"', 'Tap', 'Opens Login'),
 ('"Continue as Guest"', 'Tap', 'Opens Home as guest'),
])
sec('Login Screen', 'features/auth/login_screen.dart', GUEST, [
 ('Header, logo, texts', 'Open', '"Welcome Back!" and subtitle render'),
 ('Language selector', 'Tap "English ▾"', 'Either works or is not presented as interactive (no dead control)'),
 ('Phone input', 'Type digits', '+91 prefix, numeric keyboard, max 10 digits'),
 ('Phone validation', 'Tap Send OTP with 9 digits / letters', 'Error "Enter a valid 10-digit mobile number"'),
 ('Send OTP', 'Valid number, tap Send OTP', 'Firebase OTP sent; navigates to OTP screen (requires real phone/Firebase test number)'),
 ('"Forgot Password?"', 'Tap', 'Opens Forgot Password'),
 ('"Sign Up"', 'Tap', 'Opens Sign Up'),
 ('Back button', 'Tap back (incl. after logout)', 'Never leaves a blank screen'),
])
sec('Sign Up Screen', 'features/auth/signup_screen.dart', GUEST, [
 ('Form fields', 'Open', 'Full name, mobile, email, password, terms checkbox render'),
 ('Phone validation', 'Submit with invalid phone', 'Rejected with clear message (10-digit rule)'),
 ('Email validation', 'Enter invalid email', 'Rejected or ignored gracefully'),
 ('Terms required', 'Submit without ticking terms', 'Blocked with message'),
 ('Terms / Privacy links', 'Tap each', 'Opens readable terms/privacy content'),
 ('Password field', 'Enter password', 'Password is either used by the flow or not shown (no dead field)'),
 ('Sign Up', 'Valid form', 'Firebase OTP → OTP screen (needs real phone)'),
 ('"Login" link', 'Tap', 'Returns to Login'),
])
sec('OTP Verification Screen', 'features/auth/otp_verification_screen.dart', 'OTP sent', [
 ('Phone display & edit', 'Open', 'Shows the number entered; edit returns to previous screen'),
 ('6-box OTP input', 'Type/paste 6 digits', 'Auto-advances, auto-verifies'),
 ('Countdown & resend', 'Wait 60s', 'Resend enabled after countdown'),
 ('Wrong OTP', 'Enter wrong OTP', 'Clear error, stays on screen'),
 ('Correct OTP', 'Enter right OTP', 'POST /auth/firebase-verify → session saved → Location permission screen'),
])
sec('Forgot / Reset Password', 'features/auth/forgot_password_screen.dart, reset_password_screen.dart', GUEST, [
 ('Forgot: validation', 'Submit invalid number', 'Error shown'),
 ('Forgot: "Send Reset Link"', 'Valid registered number', 'POST /auth/forgot-password → OTP screen'),
 ('Forgot: "Reset via Email"', 'Tap', 'Performs a real action or is not offered (no fake flow)'),
 ('Reset: password rules', 'Enter <6 chars', 'Rejected'),
 ('Reset: confirm must match', 'Enter mismatched confirm', 'Rejected with message'),
 ('Reset: strength meter', 'Type weak/strong passwords', 'Indicator reflects actual strength'),
 ('Reset: submit', 'Valid', 'POST /auth/reset-password → Login'),
])
sec('Location & Notification Permission Screens', 'features/auth/location_permission_screen.dart, notification_permission_screen.dart', 'Just logged in', [
 ('Location: content', 'Open', 'Benefits list renders'),
 ('Location: "Allow" buttons', 'Tap', 'OS permission prompt appears (or honest skip), then continues'),
 ('Location: "Not Now"', 'Tap', 'Continues without permission'),
 ('Notification: "Allow Notifications"', 'Tap', 'OS notification permission requested (Android 13+), then Home'),
 ('Notification: "Not Now"', 'Tap', 'Continues to Home'),
])
sec('Home Dashboard', 'features/home/home_dashboard_screen.dart', LOGGED, [
 ('Header: delivery address', 'Open Home', 'Shows selected/default address label + pincode (not stuck on "Select Address")'),
 ('Header: notification bell + unread badge', 'Have unread notifications', 'Badge shows unread count; tap opens Notifications inbox'),
 ('Header: cart icon + badge', 'Items in cart', 'Badge = cart count; tap opens Cart'),
 ('Search bar', 'Tap', 'Opens Search screen'),
 ('Mic (voice search)', 'Tap mic, speak', 'Recognised query is searched (result not discarded)'),
 ('Hero banners', 'Admin has active banners', 'Banners from /home show image/title/subtitle; carousel works'),
 ('Hero banner tap', 'Tap a banner with a link', 'Navigates to the banner target (not always all-products)'),
 ('Quick features', 'Tap each of 6 tiles', 'Each navigates/acts as labelled'),
 ('Offer cards: greeting', 'Logged in', '"Hey, {name}!"'),
 ('Offer cards: coupon copy', 'Tap Code: CHILL10', 'Copies a coupon that actually exists and works at checkout'),
 ('Categories row', 'Tap a category', 'Opens listing filtered by that category'),
 ('Discover: New / Trending / For You', 'Tap each', 'Opens the matching screen with data'),
 ('Deal of the Day', 'Flash-sale products exist', 'Cards show real data; Add adds to cart with feedback'),
 ('Pull to refresh', 'Pull down', 'Home reloads'),
 ('Bottom nav', 'Tap each tab', 'Correct screen opens; correct tab highlighted'),
])
sec('Search & Voice Search', 'features/search/*', LOGGED, [
 ('Trending & suggestions', 'Open, type 2+ letters', 'Suggestions appear from API'),
 ('Search results', 'Submit "boat"', 'Results list with image, name, price, discount'),
 ('Result tap', 'Tap a result', 'Opens Product Details'),
 ('No results', 'Search "zzzzqq"', '"No results found" empty state'),
 ('Clear / back', 'Tap ✕ / back', 'Clears query / returns'),
 ('Voice search screen', 'Open mic', 'Mic permission requested; recognised text used; popular chips work'),
])
sec('Categories (Tab)', 'features/categories/categories_screen.dart', LOGGED, [
 ('Sidebar & grid', 'Open tab', 'Categories from API render in sidebar and grid'),
 ('Category tap', 'Tap one', 'Opens listing filtered by category'),
 ('Error/empty state', 'Backend down / no categories', 'Shows message + retry, not an endless spinner'),
])
sec('Product Listing', 'features/product_listing/*', LOGGED, [
 ('Header', 'Open from a category', 'Title = category name; search/cart icons work'),
 ('In-page search box', 'Type + submit', 'Filters the listing (not a dead input)'),
 ('Brand chips', 'Tap a brand', 'List filtered to that brand'),
 ('Sort', 'Choose each option', 'List reorders correctly'),
 ('Filter button', 'Tap', 'Provides a real filter (or is removed)'),
 ('Grid/List toggle', 'Tap', 'Layout switches'),
 ('Product card', 'Tap', 'Opens details'),
 ('Wishlist heart', 'Tap', 'Toggles wishlist (server) with visible state'),
 ('Add to cart', 'Tap Add', 'Item added with visible feedback'),
 ('Infinite scroll', 'Scroll to end with >1 page', 'Next page loads with same filters'),
 ('Empty state', 'Category with no products', '"No products found"'),
])
sec('Product Details', 'features/product_details/product_details_screen.dart', LOGGED, [
 ('Load', 'Open a product', 'Name, images, price, MRP, % off, description, highlights from API'),
 ('Gallery', 'Swipe / tap image', 'Real product images; full-screen gallery shows the same product'),
 ('Wishlist', 'Tap heart', 'Toggles, persists after reopen'),
 ('Share', 'Tap share icon', 'Share sheet opens (or icon removed)'),
 ('Rating row', 'Tap', 'Opens Reviews'),
 ('Offer cards (EMI/Bank/Exchange)', 'View', 'Reflect real offers or are clearly informational'),
 ('Stock display', 'Product with stock N', 'Shows availability; out-of-stock disables add'),
 ('Similar products', 'Scroll', 'Same-category products; tap opens them'),
 ('Add to Cart', 'Tap', 'POST /cart/add, "Added to cart!", cart badge updates'),
 ('Buy Now', 'Tap', 'Adds and opens Cart'),
 ('Recently viewed tracking', 'Open product', 'POST /products/:id/recently-viewed recorded'),
 ('Not found', 'Open deleted product id', '"Product not found" state'),
])
sec('Product Reviews', 'features/product_details/product_reviews_screen.dart', LOGGED, [
 ('Summary & list', 'Open', 'Stats and reviews from API; empty state if none'),
 ('Filter chips', 'Tap a star filter', 'List filtered (or chips removed)'),
 ('Sort "Most Helpful"', 'Tap', 'Sorts (or not shown as control)'),
 ('Write a review validation', 'Submit without stars / body', 'Validation messages'),
 ('Submit review', 'Valid review', 'POST succeeds; appears in list; product rating updates'),
 ('Helpful thumbs', 'Tap', 'Works or not presented as control'),
 ('Bottom "Add to Cart"', 'Tap', 'Adds product to cart'),
])
sec('Cart', 'features/cart/cart_screen.dart', LOGGED + '; 1+ items in cart', [
 ('Items load', 'Open cart', 'GET /cart items with image, name, price'),
 ('Address strip', 'Has addresses', 'Shows default address; Change opens checkout'),
 ('Quantity +/−', 'Tap + and −', 'Qty updates server-side; + capped at stock; − at 1 removes'),
 ('Remove item', 'Tap delete', 'Item removed'),
 ('Apply coupon', 'Open Apply Coupon, apply valid code', 'Discount shown; totals recalc'),
 ('Price details', 'Compare with backend /cart summary', 'Subtotal, discount, delivery (₹49 under threshold / FREE), GST, total correct'),
 ('Empty cart', 'Remove all', 'Empty state + Shop Now'),
 ('Checkout', 'Tap Checkout', 'Opens Checkout'),
])
sec('Apply Coupon', 'features/cart/apply_coupon_screen.dart', LOGGED, [
 ('Available coupons', 'Open', 'Active coupons from GET /cart/coupons'),
 ('Invalid code', 'Enter "NOPE"', 'Inline error'),
 ('Valid code', 'Apply existing coupon', 'Returns to cart with discount'),
 ('Min order not met', 'Apply coupon above cart value', 'Clear error'),
])
sec('Checkout', 'features/checkout/checkout_screen.dart', LOGGED, [
 ('Address list', 'Open', 'Saved addresses; tap selects'),
 ('Add address validation', 'Save with empty/invalid phone/pincode', 'Field errors shown; nothing saved'),
 ('Add address', 'Valid address', 'Saved and selected'),
 ('Edit address', 'Edit, save', 'Updated'),
 ('Delete address', 'Tap delete', 'Asks confirmation, then deletes'),
 ('Order summary', 'Compare with cart', 'Same totals as Cart (incl. coupon/GST)'),
 ('Proceed to Payment', 'With address selected', 'Opens Payment'),
])
sec('Payment Method', 'features/payment/payment_method_screen.dart', LOGGED, [
 ('Options', 'Open', 'COD and PhonePe/UPI shown with totals'),
 ('Place COD order', 'Select COD, place', 'Order created; OrderSuccess; Delhivery shipment attempted'),
 ('PhonePe order (test)', 'Select PhonePe, Pay', 'Order created; payment page opens; verification leads to success'),
 ('Payment initiation failure', 'Force initiate failure', 'Order cancelled, cart restored, message shown'),
])
sec('PhonePe Payment', 'features/payment/phonepe_payment_screen.dart', 'PhonePe order started', [
 ('"I\'ve Completed Payment"', 'Tap after test payment', 'Verifies → OrderSuccess'),
 ('Auto-verify on resume', 'Return to app', 'Verification runs automatically'),
 ('"Reopen PhonePe"', 'Tap', 'Opens payment URL again'),
 ('Failed payment', 'Verification fails', 'OrderFailed with reason; retry path works'),
])
sec('Order Success / Failed', 'features/orders/order_success_screen.dart, order_failed_screen.dart', 'Order just placed', [
 ('Success details', 'After order', 'Order number, total, payment, status correct'),
 ('"View My Orders"', 'Tap', 'Opens My Orders with the new order on top'),
 ('"Continue Shopping"', 'Tap', 'Back to Home'),
 ('Failed: reason & retry', 'After failed payment', 'Reason shown; Try Again lets the user pay again for that order or re-order'),
])
sec('My Orders (Tab)', 'features/orders/my_orders_screen.dart', LOGGED, [
 ('List', 'Open Orders tab', 'Orders newest first with status pill, items, total, date'),
 ('Status tabs', 'Tap each tab', 'Filtered correctly'),
 ('Order tap', 'Tap card', 'Opens Order Details'),
 ('Back button on tab', 'Open via bottom nav, press back', 'Never leaves a blank screen'),
 ('Bottom navigation present', 'Open via bottom nav', 'Bottom nav visible like other tabs'),
 ('Pull to refresh / empty', 'Pull; new user', 'Refreshes; "No orders yet"'),
])
sec('Order Details', 'features/orders/order_details_screen.dart', LOGGED, [
 ('Details', 'Open an order', 'Number, status, payment, date, AWB, shipment label, items, totals'),
 ('Track Order', 'Order with AWB', 'Opens tracking timeline'),
 ('Cancel (Processing only)', 'Open Processing order', 'Cancel button shown; not for Shipped/Delivered'),
 ('Refund/Return request', 'Delivered/Cancelled order', 'Sheet validates reason; POST succeeds; status pill shown'),
 ('Auto-refresh on resume', 'Status changes while app backgrounded', 'Screen shows new status on return'),
 ('Error state', 'Invalid order id / network error', 'Error message (not endless spinner)'),
])
sec('Cancel Order', 'features/orders/cancel_order_screen.dart', 'Processing order', [
 ('Order card', 'Open', 'Shows THIS order\'s id/date/amount'),
 ('Reason required', 'Submit without choosing', 'A reason is always sent (default selection matches state)'),
 ('Cancel', 'Choose reason, confirm', 'Order Cancelled; Delhivery shipment cancelled; stock restored'),
 ('Support / Track / Contact buttons', 'Tap each', 'Navigate somewhere useful (not dead)'),
])
sec('Tracking Timeline', 'features/orders/delhivery_tracking_screen.dart', 'Order with AWB', [
 ('Header', 'Open', 'Delhivery branding, AWB (copyable), status'),
 ('Live scans', 'Order with scans', 'Real Delhivery scans with location/time'),
 ('No scans yet', 'Fresh shipment', 'Honest "Order placed" row, no invented dates'),
 ('Refresh', 'Tap Refresh', 'Reloads tracking'),
 ('Error', 'Backend down', 'Error + Retry'),
])
sec('Wishlist (Tab)', 'features/wishlist/wishlist_screen.dart', LOGGED, [
 ('List', 'Open', 'Saved products with price, stock'),
 ('Remove', 'Tap ✕', 'Removed server-side'),
 ('Clear All', 'Tap', 'Confirms, then clears'),
 ('Add to Cart', 'Tap', 'Added with feedback'),
 ('Empty state', 'No items', 'Empty message'),
])
sec('My Profile (Tab)', 'features/profile/my_profile_screen.dart', LOGGED, [
 ('Header', 'Open', 'Name, email, phone from API'),
 ('Bag icon', 'Tap', 'Badge and destination consistent'),
 ('Menu items', 'Tap Edit Profile, My Orders, Wishlist, My Reviews, Notifications, Settings', 'Each opens its screen'),
 ('Saved Addresses entry', 'Look for addresses', 'User can manage saved addresses from profile'),
 ('Guest view', 'Open as guest', 'Prompts login instead of fake profile/logout'),
 ('Logout', 'Confirm logout', 'Session cleared; Login shown; back does not return to account'),
])
sec('Edit Profile', 'features/profile/edit_profile_screen.dart', LOGGED, [
 ('Load', 'Open', 'Current name/email; phone read-only'),
 ('Email validation', 'Invalid email', 'Rejected with message'),
 ('Save', 'Change name', 'PUT /profile; "Profile updated!"; reflected on web too'),
 ('Avatar upload', 'Pick image', 'Uploaded and shown'),
])
sec('My Reviews', 'features/profile/my_reviews_screen.dart', LOGGED, [
 ('List / empty', 'Open', 'Loading then reviews or empty state'),
 ('Delete review', 'Delete one', 'Confirm → removed'),
])
sec('Notifications Inbox', 'features/profile/notifications_screen.dart', LOGGED, [
 ('List', 'Open from bell', 'Notifications newest first with icons'),
 ('Order notification tap', 'Tap one', 'Opens that order'),
 ('Unread count clears', 'Open inbox, return', 'Bell badge resets'),
 ('Push notification', 'Order status changes (Delhivery event)', 'Push received on device, deduplicated'),
])
sec('Notification Settings', 'features/profile/notification_settings_screen.dart', LOGGED, [
 ('Load toggles', 'Open', 'Current preferences loaded'),
 ('Toggle persists', 'Toggle, reopen', 'Saved via PUT'),
 ('Order updates off', 'Disable order updates', 'Order pushes stop (in-app record kept)'),
])
sec('Settings, Help & Support, About, Privacy', 'features/profile/*', LOGGED, [
 ('Settings links', 'Tap each of 5', 'Each opens its screen'),
 ('Help: category tiles', 'Tap each', 'Sensible destination (no odd pop)'),
 ('Help: call / WhatsApp / email', 'Tap each', 'Opens dialer (with +91) / WhatsApp / mail with real contact'),
 ('Help: dead items', 'Tap search, My Tickets, View All, Connect', 'No dead controls'),
 ('About: links & version', 'Open About', 'Links work; version shows real app version'),
 ('Privacy policy', 'Open', 'Complete policy content; index items navigate'),
 ('Terms & Conditions', 'Find from About/Settings', 'Terms screen reachable'),
])
sec('Discovery Screens (Brands, Offers, Flash, New, Trending, Recommended)', 'features/brands, offers, deals, new_arrivals, trending, recommended', LOGGED, [
 ('Brands list & search', 'Open Top Brands', 'Brands from API; search filters; tap opens brand products'),
 ('Offers products', 'Open Best Deals', 'Discounted products listed'),
 ('Flash deals', 'Open Deal of the Day → View All', 'Flash-sale products; chips filter'),
 ('New / Trending / Recommended', 'Open each', 'Products from respective API'),
 ('Chips & "View All" & CTA banners', 'Tap each', 'Each works or is not interactive (no dead controls)'),
 ('Bottom nav highlight', 'Open each screen', 'Correct tab highlighted'),
])
sec('Unreachable / Orphan Screens', 'address/*, recently_viewed, sub_categories, empty_cart, cod_confirmation, push/offer notifications, terms, no_internet', '-', [
 ('Saved Addresses reachable', 'From profile', 'Reachable, list/add/edit/delete/default work'),
 ('Recently Viewed reachable', 'From profile', 'Reachable, shows real history'),
 ('No-internet handling', 'Turn network off mid-use', 'User gets a clear offline message / retry'),
 ('Dead orphan screens', 'Code review', 'Unused dummy screens (SubCategories, COD confirmation, EmptyCart) not reachable by users'),
], notes='Screens that exist in code but nothing navigates to them.')
sec('Delhivery — App Order Lifecycle', 'app + backend + Delhivery staging', LOGGED, [
 ('Order → Delhivery shipment', 'Place prepaid order in app', 'Real staging AWB stored; "Shipment created" shown'),
 ('Pickup booked', 'After shipment', 'Pickup request exists for the warehouse'),
 ('In transit', 'Delhivery In Transit event', 'App shows Shipped / In transit; push received'),
 ('Out for delivery', 'Dispatched event', 'App shows Out for delivery; push'),
 ('Delivered', 'Delivered event', 'App shows Delivered; COD marked Paid; push'),
 ('Cancel before pickup', 'Cancel in app', 'Delhivery shipment cancelled'),
 ('App ⇄ Web ⇄ Admin agree', 'Compare same order everywhere', 'Identical status/AWB/history'),
])
sec('Regression & Non-functional', 'whole app', LOGGED, [
 ('Session persistence', 'Kill and relaunch app', 'Still logged in'),
 ('Token refresh / expiry', 'Expired access token', 'Refreshed silently or sent to login cleanly'),
 ('Android back behaviour', 'Press back across screens', 'No blank screens, no loops'),
 ('Release build', 'Install signed release APK', 'Launches, talks to https://chillfi.in/api, no debug hooks'),
 ('Layout on 1080×2400', 'Visit key screens', 'No yellow/black overflow stripes'),
])

sec('Error Handling & Universal Error Dialog', 'core/widgets/app_error_dialog.dart, cart_feedback.dart, api_service.dart', LOGGED, [
 ('Offline: Add to Cart (product details)', 'Disable network, tap Add to Cart', 'Universal dialog "No internet connection"; no raw error'),
 ('Offline: Buy Now', 'Disable network, tap Buy Now', 'Universal dialog; stays on screen'),
 ('Offline: listing card cart button', 'Disable network, tap card cart icon', 'Universal dialog (previously silent)'),
 ('Dialog dismiss', 'Tap OK', 'Dialog closes; screen usable'),
 ('Online add feedback', 'Tap card cart icon online', 'Green "<product> added to cart"; badge increments'),
 ('Similar product add failure', 'Fail add from similar products', 'Error dialog, not a false "Added to cart"'),
 ('5xx from backend', 'Backend returns 500 with internal text', 'Friendly server message + errorRef; no SQL/stack text'),
 ('OTP send failure (Firebase)', 'Invalid number / quota', 'Friendly mapped text, never raw Firebase message'),
 ('Order placement failure', 'Fail /orders', 'Dialog "Couldn\'t place your order"'),
 ('Cancel order failure', 'Fail cancel', 'Dialog "Couldn\'t cancel order"'),
 ('Profile save failure', 'Fail update', 'Dialog "Couldn\'t save changes"'),
 ('Voice search error', 'Speech error', 'Friendly status text, no "Error: <code>"'),
])

def build():
    path = os.path.join(HERE, 'app.json')
    old = {}
    if os.path.exists(path):
        for s in json.load(open(path))['sections']:
            for c in s['cases']: old[c['id']] = c
    sections = []
    for si, s in enumerate(S, 1):
        cases = []
        for ci, (el, steps, exp) in enumerate(s['cases'], 1):
            cid = f'APP-{si:02d}-{ci:02d}'
            base = dict(id=cid, element=el, pre=s['pre'], steps=steps, expected=exp, actual='', status='NOT TESTED', evidence='', defect='', retest='')
            if cid in old:
                for k in ('actual', 'status', 'evidence', 'defect', 'retest'): base[k] = old[cid].get(k, base[k])
            cases.append(base)
        sections.append(dict(id=f'APP-{si:02d}', name=s['name'], location=s['location'], notes=s['notes'], cases=cases))
    prev = json.load(open(path)) if os.path.exists(path) else {}
    data = dict(title='ChillFi Mobile App — Master QA Testing Report', filename='ChillFi_Mobile_App_Master_QA.pdf',
                subtitle='Every reachable screen of the Flutter app (lib/), in user-journey order, derived from the actual implementation.',
                scope='Android app (debug build against local backend + Delhivery staging; release build against https://chillfi.in/api).',
                environment='Pixel 9 emulator 1080×2400 · backend local :5000 · Delhivery STAGING · PhonePe dev/UAT',
                sections=sections, defects=prev.get('defects', []), blockers=prev.get('blockers', []))
    json.dump(data, open(path, 'w'), indent=1, ensure_ascii=False)
    print(path, sum(len(s['cases']) for s in sections), 'cases in', len(sections), 'sections')

build()
