#!/usr/bin/env python3
"""Generates QA/master/admin.json (Admin Panel Master QA) from the real admin inventory (/admin/*).
Existing results are preserved on re-run."""
import json, os
HERE = os.path.dirname(os.path.abspath(__file__))
S = []
def sec(name, loc, pre, cases, notes=''):
    S.append(dict(name=name, location=loc, pre=pre, notes=notes, cases=cases))
ADMIN = 'Logged in as admin'

sec('Access Control & Layout', 'components/auth/AdminRoute.tsx, components/admin/*', '-', [
 ('Guest blocked', 'Open /admin logged out', 'Redirect to login'),
 ('Customer blocked', 'Open /admin as customer', 'Access denied; API returns 403'),
 ('Support staff scope', 'Login as support_staff', 'Only Orders/Reviews/Messages; admin-only actions hidden'),
 ('Role cache', 'Logout admin, login customer in same tab', 'Customer does not inherit admin UI'),
 ('Sidebar navigation', 'Click every item', 'Each page loads'),
 ('Header search', 'Search twice from Products page', 'Filters each time'),
 ('Header bell', 'Click', 'Real notifications or not presented as feature'),
 ('Logout', 'Click', 'Session cleared'),
 ('Maintenance lockout', 'Maintenance on, admin logged out', 'Admin can still log in'),
])
sec('Dashboard', 'pages/Admin/Dashboard', ADMIN, [
 ('Stat cards', 'Open', 'Revenue (paid), orders, products, users match DB'),
 ('Revenue chart', 'View', 'Real monthly data (no mock bars)'),
 ('Top products / Recent orders', 'View', 'Real data; View All links work'),
 ('API failure', 'Backend error', 'Error shown, not silent mock data'),
])
sec('Products', 'pages/Admin/Products', ADMIN, [
 ('List & stats', 'Open', 'All products incl. inactive/out-of-stock; stat chips correct'),
 ('Search & category filter', 'Use', 'Filters'),
 ('Add product', 'Fill form incl. brand, category, image; save', 'Created with brand+category saved; page does not crash'),
 ('Add validation', 'Save without price / name', 'Clear errors'),
 ('Edit product', 'Change name/price/brand/category', 'Saved and shown'),
 ('Inline stock edit', 'Change stock', 'Saved'),
 ('Inline status', 'Set Inactive / Out of Stock / Active', 'Saved; product still visible in admin; can be re-activated'),
 ('Featured / Flash sale toggles', 'Toggle', 'Saved'),
 ('Image upload', 'Upload image', 'Stored (Cloudinary) and shown'),
 ('Delete', 'Delete product', 'Confirm; soft-deleted; restorable or clearly removed'),
 ('Propagation: price/name/image → app & website', 'Edit then check storefronts', 'Both storefronts show the change'),
 ('Propagation: status → storefront', 'Set Low Stock / Out of Stock', 'Storefront behaviour correct (low stock still sellable; out of stock not purchasable)'),
])
sec('Orders', 'pages/Admin/Orders', ADMIN, [
 ('List, tabs, search', 'Open', 'Orders with real qty, customer, amount, payment, status, AWB, shipping stage'),
 ('Export CSV', 'Click', 'CSV downloads with rows'),
 ('Order detail modal', 'Open order', 'Items, customer, address, payment, Delhivery section'),
 ('Status update', 'Change status', 'Saved; customer notified; invalid backward moves prevented'),
 ('Create / Retry shipment', 'Processing COD/Paid order', 'AWB created on Delhivery staging'),
 ('Live track + Sync', 'Open tracking', 'Real scans; Sync pulls latest'),
 ('Print label', 'Click', 'Delhivery label PDF opens'),
 ('Cancel → Delhivery', 'Set Cancelled', 'Shipment cancelled at Delhivery'),
 ('Staff restrictions', 'As support staff', 'Status/ship buttons hidden'),
])
sec('Refunds', 'pages/Admin/Refunds', ADMIN, [
 ('List loads', 'Open /admin/refunds', 'Customer refund/return requests listed'),
 ('Filters', 'Use status chips', 'Filters'),
 ('Approve / Reject', 'Act on a request', 'Saved; customer sees new status in app & web'),
 ('Mark Refunded', 'Approved request', 'Order payment_status Refunded'),
])
sec('Users', 'pages/Admin/Users', ADMIN, [
 ('List & stats & search', 'Open', 'Users with orders/spend; search works'),
 ('Block / Unblock', 'Block test user', 'User session rejected on app & web; unblock restores'),
 ('Role toggle support staff', 'Toggle', 'Role saved; access changes'),
 ('Remove', 'Click remove', 'Honest behaviour (no fake delete)'),
 ('Self-protection', 'Try to block own admin account', 'Prevented'),
])
sec('Categories', 'pages/Admin/Categories', ADMIN, [
 ('List incl. inactive', 'Open', 'Active and inactive shown'),
 ('Create / Edit', 'Save', 'Saved'),
 ('Deactivate & reactivate', 'Toggle off then on', 'Can be re-enabled'),
 ('Delete', 'Delete', 'Confirm; removed from storefront'),
 ('Propagation', 'Rename / deactivate', 'App & website category lists update'),
])
sec('Brands', 'pages/Admin/Brands', ADMIN, [
 ('List incl. inactive', 'Open', 'All brands'),
 ('Create / Edit / logo', 'Save', 'Saved; duplicate name gives clear error'),
 ('Deactivate & reactivate', 'Toggle', 'Can be re-enabled'),
 ('Delete', 'Delete', 'Removed; products keep working'),
 ('Propagation', 'Change', 'App brands screen & website update'),
])
sec('Reviews', 'pages/Admin/Reviews', ADMIN, [
 ('List & rating filter', 'Open', 'Reviews listed; filter works'),
 ('Verify toggle', 'Toggle', 'Saved; verified badge on website'),
 ('Delete', 'Delete', 'Removed; product rating recalculated on app & web'),
])
sec('Messages', 'pages/Admin/Messages', ADMIN, [
 ('List from Contact form', 'Submit contact form on website', 'Message appears'),
 ('Read toggle / filter', 'Use', 'Works'),
 ('Reply', 'Send reply', 'Stored; honest note if email delivery not configured'),
 ('Delete', 'Delete', 'Removed'),
])
sec('Notifications (Push)', 'pages/Admin/Notifications', ADMIN, [
 ('Validation', 'Empty title/body', 'Send disabled'),
 ('Send to one user', 'Search user, send', 'In-app notification + push received on device'),
 ('Broadcast', 'Send to all', 'All customers get in-app notification; counts shown'),
])
sec('Analytics', 'pages/Admin/Analytics', ADMIN, [
 ('Period tabs', 'Switch 7/30/90/365', 'Data changes'),
 ('KPIs consistent with dashboard', 'Compare revenue', 'Same definition of revenue'),
 ('Placeholder panels', 'View', 'No fake panels presented as data'),
])
sec('Banners, Promo Banners, Testimonials', 'pages/Admin/Banners, PromoBanners, Testimonials', ADMIN, [
 ('Banner CRUD', 'Create/edit/toggle/delete', 'Saved'),
 ('Banner → app & website home', 'Activate a banner', 'Shows on both home screens with working link'),
 ('Promo banner CRUD + upload', 'Create with image', 'Saved; shows on website home'),
 ('Promo banners in app', 'Check app home', 'Shown or documented as website-only'),
 ('Testimonials CRUD + avatar', 'Create', 'Shows on website home'),
])
sec('Coupons', 'pages/Admin/Coupons', ADMIN, [
 ('Create / edit / toggle / delete', 'Use', 'Saved'),
 ('Validation', 'Percentage >100, value ≤0', 'Rejected'),
 ('Coupon at checkout (app & web)', 'Apply new coupon', 'Discount applied correctly'),
 ('Expiry / min order / usage limit enforced at order', 'Expired or under-min coupon', 'Rejected at order creation too'),
 ('Clear expiry/limit', 'Remove expiry', 'Saved as no-expiry'),
])
sec('Shipping Rules', 'pages/Admin/ShippingRules', ADMIN, [
 ('CRUD', 'Create prefix rule', 'Saved'),
 ('Fee applied at checkout', 'Order to matching pincode', 'App & website charge the rule fee'),
 ('COD / ETA fields', 'Set COD off for prefix', 'Honoured at checkout or not offered'),
])
sec('Settings', 'pages/Admin/Settings', ADMIN, [
 ('Store info fields', 'Change store email/phone', 'Used by storefront or clearly marked'),
 ('GST rate', 'Change 18→12', 'Cart/checkout tax updates on app & web; restore'),
 ('Free-shipping threshold & fee', 'Change', 'Checkout fee updates on app & web; restore'),
 ('Maintenance mode', 'Enable/disable', 'App splash + website gate respond'),
 ('Force update / min version', 'Set min = current version', 'Current app not blocked; higher min blocks'),
 ('Order notification toggles', 'Disable shipped notifications', 'Pushes suppressed'),
 ('Feature/payment/security/SEO toggles', 'Toggle', 'Honoured or clearly marked not active'),
 ('API Keys: secrets masked', 'View credentials', 'Only last 4 chars; never full secret'),
 ('API Keys: Delhivery panel', 'Test connection / Sync / Request pickup', 'Works against staging'),
 ('API Keys: env switch confirmation', 'Choose production', 'Confirmation dialog shown'),
])
sec('Delhivery — Admin Operations', 'Orders + Settings', ADMIN, [
 ('Order shows shipment state', 'Open shipped order', 'AWB, stage, env, history'),
 ('Failed shipment visible + retry', 'Shipment rejected', 'Reason shown; retry works'),
 ('Delivered reflected', 'After Delivered event', 'Admin shows Delivered, payment Paid'),
 ('No operational dead end', 'Walk order from placed to delivered', 'Every step actionable from admin'),
])

def build():
    path = os.path.join(HERE, 'admin.json'); old = {}
    if os.path.exists(path):
        for s in json.load(open(path))['sections']:
            for c in s['cases']: old[c['id']] = c
    sections = []
    for si, s in enumerate(S, 1):
        cases = []
        for ci, (el, steps, exp) in enumerate(s['cases'], 1):
            cid = f'ADM-{si:02d}-{ci:02d}'
            base = dict(id=cid, element=el, pre=s['pre'], steps=steps, expected=exp, actual='', status='NOT TESTED', evidence='', defect='', retest='')
            if cid in old:
                for k in ('actual', 'status', 'evidence', 'defect', 'retest'): base[k] = old[cid].get(k, base[k])
            cases.append(base)
        sections.append(dict(id=f'ADM-{si:02d}', name=s['name'], location=s['location'], notes=s['notes'], cases=cases))
    prev = json.load(open(path)) if os.path.exists(path) else {}
    data = dict(title='ChillFi Admin Panel — Master QA Testing Report', filename='ChillFi_Admin_Panel_Master_QA.pdf',
                subtitle='Every /admin page in sidebar order, derived from the actual implementation, incl. admin → app/website propagation.',
                scope='Admin panel (React /admin/*) and the backend admin APIs it uses.',
                environment='Local :5200 → backend :5000 · Chrome · Delhivery STAGING',
                sections=sections, defects=prev.get('defects', []), blockers=prev.get('blockers', []))
    json.dump(data, open(path, 'w'), indent=1, ensure_ascii=False)
    print(path, sum(len(s['cases']) for s in sections), 'cases in', len(sections), 'sections')
build()
