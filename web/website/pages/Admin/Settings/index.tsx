import React, { useState, useEffect } from 'react';
import AdminLayout from '../../../components/admin/AdminLayout';
import { Store, Truck, CreditCard, Bell, Shield, Globe, Save, Check, X, Loader2, Key, Eye, EyeOff, RefreshCw, Rocket } from 'lucide-react';
import { useSearchParams } from 'react-router-dom';
import GoLiveChecklist from '../../../components/admin/GoLiveChecklist';
import { useStore } from '../../../context/StoreContext';
import { apiGet, apiPost, apiPut } from '../../../utils/api';
import { showErrorDialog } from '../../../components/feedback/ErrorDialog';
import DelhiveryStatusPanel from '../../../components/admin/DelhiveryStatusPanel';

const tabs = [
  { id: 'golive', label: 'Go-Live', icon: <Rocket size={16} /> },
  { id: 'store', label: 'Store Info', icon: <Store size={16} /> },
  { id: 'shipping', label: 'Shipping', icon: <Truck size={16} /> },
  { id: 'payment', label: 'Payment', icon: <CreditCard size={16} /> },
  { id: 'notifications', label: 'Notifications', icon: <Bell size={16} /> },
  { id: 'security', label: 'Security', icon: <Shield size={16} /> },
  { id: 'seo', label: 'SEO', icon: <Globe size={16} /> },
  { id: 'apikeys', label: 'API Keys', icon: <Key size={16} /> },
];

const Toast: React.FC<{ msg: string; onClose: () => void }> = ({ msg, onClose }) => (
  <div className="fixed bottom-6 right-6 z-[100] flex items-center gap-3 bg-[#121212] text-white px-5 py-3.5 rounded-2xl shadow-2xl">
    <div className="w-6 h-6 bg-green-500 rounded-full flex items-center justify-center shrink-0"><Check size={13} /></div>
    <span className="text-sm font-bold">{msg}</span>
    <button onClick={onClose} className="ml-2 text-white/50 hover:text-white"><X size={14} /></button>
  </div>
);

// inactive = the setting is stored but nothing in the store/app reads it yet → shown disabled so admins aren't misled.
const NotActive: React.FC = () => (
  <span className="ml-2 align-middle text-[9px] font-black uppercase tracking-wider bg-gray-100 text-gray-500 px-2 py-0.5 rounded-full">Not active yet</span>
);
const LoginActivity: React.FC = () => {
  const [rows, setRows] = useState<{ created_at: string; method: string; ip: string; user_agent: string; name: string; role: string }[] | null>(null);
  useEffect(() => { apiGet<{ data: any[] }>('/admin/login-activity').then(r => setRows(r.data)).catch(() => setRows([])); }, []);
  return (
    <div className="mt-5">
      <p className="text-[11px] font-black text-gray-400 uppercase tracking-wider mb-2">Recent admin / staff sign-ins</p>
      {rows === null ? <p className="text-xs font-bold text-gray-400">Loading…</p>
        : rows.length === 0 ? <p className="text-xs font-bold text-gray-400">No sign-ins recorded yet.</p>
        : (
          <div className="max-h-64 overflow-y-auto border border-[#F3F4F6] rounded-xl divide-y divide-[#F3F4F6]">
            {rows.map((r, i) => (
              <div key={i} className="px-3 py-2 flex items-center justify-between gap-3 text-xs font-bold">
                <span className="text-[#111827]">{r.name || '—'} <span className="text-gray-400">({r.role === 'support_staff' ? 'staff' : r.role})</span></span>
                <span className="text-gray-500 truncate">{r.ip} · {/Mobile|Android|iPhone/i.test(r.user_agent) ? 'Mobile' : 'Desktop'}</span>
                <span className="text-gray-400 shrink-0">{new Date(r.created_at).toLocaleString('en-IN', { day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' })}</span>
              </div>
            ))}
          </div>
        )}
    </div>
  );
};

const Toggle: React.FC<{ value: boolean; onChange: (v: boolean) => void; label: string; desc?: string; inactive?: boolean }> = ({ value, onChange, label, desc, inactive }) => (
  <div className={`flex items-center justify-between py-4 border-b border-[#F8F7FC] last:border-0 ${inactive ? 'opacity-60' : ''}`}>
    <div>
      <p className="text-sm font-black text-[#111827]">{label}{inactive && <NotActive />}</p>
      {desc && <p className="text-[11px] font-bold text-gray-400 mt-0.5">{desc}</p>}
    </div>
    <button type="button" role="switch" aria-checked={value} aria-label={label} disabled={inactive} onClick={() => onChange(!value)} className={`relative w-11 h-6 rounded-full transition-colors disabled:cursor-not-allowed ${value ? 'bg-[#FF6B2C]' : 'bg-gray-200'}`}>
      <span className={`absolute top-1 w-4 h-4 bg-white rounded-full shadow transition-all ${value ? 'left-6' : 'left-1'}`} />
    </button>
  </div>
);

interface ApiSettings {
  store_name?: string; store_email?: string; store_phone?: string; whatsapp_number?: string;
  gst_number?: string; gst_rate?: string; website_url?: string; support_email?: string;
  store_address?: string; free_shipping_threshold?: string;
  standard_shipping_fee?: string; express_shipping_fee?: string;
  max_delivery_days?: string; free_shipping_enabled?: string;
  express_enabled?: string; cod_enabled?: string;
  [key: string]: string | undefined;
}

const asBool = (v: string | undefined, fallback: boolean) => v === undefined ? fallback : v === 'true';

const AdminSettings: React.FC = () => {
  const { settings, setSettings } = useStore();
  const [searchParams, setSearchParams] = useSearchParams();
  const [activeTab, setActiveTabState] = useState(() => (tabs.some(t => t.id === searchParams.get('tab')) ? searchParams.get('tab')! : 'golive'));
  // Tab lives in the URL (?tab=apikeys) so the checklist / dashboard can deep-link to it.
  const setActiveTab = (id: string) => { setActiveTabState(id); setSearchParams({ tab: id }, { replace: true }); };
  const [toast, setToast] = useState('');
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);

  const [store, setStore] = useState({
    name: settings.name, email: settings.email, phone: settings.phone,
    gst: settings.gst, gstRate: '18', url: settings.url, supportEmail: settings.supportEmail,
    address: settings.address, whatsapp: '',
  });

  const [shipping, setShipping] = useState({
    freeThreshold: settings.freeThreshold, standardFee: settings.standardFee,
    expressFee: settings.expressFee, maxDays: settings.maxDays,
    freeShipping: settings.freeShipping, express: settings.express, cod: settings.cod,
  });

  const [features, setFeatures] = useState({ maintenanceMode: false, userRegistration: true, guestCheckout: true, productReviews: true, invoices: false });
  const [appControl, setAppControl] = useState({ maintenanceMessage: "We're making some improvements to serve you better. We'll be back soon!", forceUpdate: false, minAppVersion: '1.0.0', forceUpdateMessage: 'A new version of the app is available with important fixes. Please update to continue.' });
  const [payment, setPayment] = useState({ upi: true, cards: true, netBanking: true, emi: true, cod: false, wallets: true });
  const [notif, setNotif] = useState({ orderPlaced: true, orderShipped: true, orderDelivered: true, orderCancelled: true, promo: false, adminAlerts: true, lowStock: true });
  const [security, setSecurity] = useState({ twoFactor: true, loginLog: true, forceHttps: false, sessionTimeout: true });
  const [seo, setSeo] = useState({ title: 'chillFi — Premium Electronics at Best Prices', description: 'Shop the latest smartphones, laptops, audio & more at chillFi. Best deals on Samsung, Apple, Sony, boAt and more.', keywords: 'electronics, smartphones, laptops, earphones, India, online shopping', ogImage: 'https://chillfi.web.app/og-image.jpg' });

  interface CredentialMeta { key: string; label: string; group: string; secret: boolean; value: string; isSet: boolean; options?: string[] }
  const [credentials, setCredentials] = useState<CredentialMeta[]>([]);
  const [credEdit, setCredEdit] = useState<Record<string, string>>({});
  const [showSecret, setShowSecret] = useState<Record<string, boolean>>({});
  const [credSaving, setCredSaving] = useState<Record<string, boolean>>({});
  const [credLoading, setCredLoading] = useState(false);
  const [loadFailed, setLoadFailed] = useState(false);

  const showToast = (msg: string) => { setToast(msg); setTimeout(() => setToast(''), 3000); };

  const loadCredentials = () => {
    setCredLoading(true);
    apiGet<{ success: boolean; data: CredentialMeta[] }>('/admin/credentials')
      .then(res => { if (res.data) setCredentials(res.data); })
      .catch((e) => showErrorDialog({ title: "Couldn't load API keys", error: e }))
      .finally(() => setCredLoading(false));
  };

  // Load settings from API on mount
  useEffect(() => {
    loadCredentials();
    setLoading(true);
    apiGet<{ success: boolean; data: ApiSettings }>('/admin/settings')
      .then(res => {
        if (res.data) {
          const d = res.data;
          const loaded = {
            name: (d.store_name || settings.name) as string,
            email: (d.store_email || settings.email) as string,
            phone: (d.store_phone || settings.phone) as string,
            gst: (d.gst_number || settings.gst) as string,
            gstRate: String(d.gst_rate ?? 18),
            url: (d.website_url || settings.url) as string,
            supportEmail: (d.support_email || settings.supportEmail) as string,
            address: (d.store_address || settings.address) as string,
            whatsapp: (d.whatsapp_number || '') as string,
          };
          setStore(loaded);

          const loadedShipping = {
            freeThreshold: String(d.free_shipping_threshold ?? settings.freeThreshold),
            standardFee: String(d.standard_shipping_fee ?? settings.standardFee),
            expressFee: String(d.express_shipping_fee ?? settings.expressFee),
            maxDays: String(d.max_delivery_days ?? settings.maxDays),
            freeShipping: asBool(d.free_shipping_enabled, settings.freeShipping),
            express: asBool(d.express_enabled, settings.express),
            cod: asBool(d.cod_enabled, settings.cod),
          };
          setShipping(loadedShipping);
          setSettings(s => ({ ...s, ...loaded, ...loadedShipping }));

          setFeatures(f => ({
            maintenanceMode: asBool(d.maintenance_mode, f.maintenanceMode),
            invoices: asBool(d.invoices_enabled, f.invoices),
            userRegistration: asBool(d.user_registration_enabled, f.userRegistration),
            guestCheckout: asBool(d.guest_checkout_enabled, f.guestCheckout),
            productReviews: asBool(d.product_reviews_enabled, f.productReviews),
          }));
          setAppControl(a => ({
            maintenanceMessage: d.maintenance_message || a.maintenanceMessage,
            forceUpdate: asBool(d.force_update_enabled, a.forceUpdate),
            minAppVersion: d.min_app_version || a.minAppVersion,
            forceUpdateMessage: d.force_update_message || a.forceUpdateMessage,
          }));
          setPayment(p => ({
            upi: asBool(d.payment_upi_enabled, p.upi),
            cards: asBool(d.payment_cards_enabled, p.cards),
            netBanking: asBool(d.payment_netbanking_enabled, p.netBanking),
            emi: asBool(d.payment_emi_enabled, p.emi),
            cod: asBool(d.payment_cod_enabled, p.cod),
            wallets: asBool(d.payment_wallets_enabled, p.wallets),
          }));
          setNotif(n => ({
            orderPlaced: asBool(d.notify_order_placed, n.orderPlaced),
            orderShipped: asBool(d.notify_order_shipped, n.orderShipped),
            orderDelivered: asBool(d.notify_order_delivered, n.orderDelivered),
            orderCancelled: asBool(d.notify_order_cancelled, n.orderCancelled),
            promo: asBool(d.notify_promo, n.promo),
            adminAlerts: asBool(d.notify_admin_alerts, n.adminAlerts),
            lowStock: asBool(d.notify_low_stock, n.lowStock),
          }));
          setSecurity(s => ({
            twoFactor: asBool(d.security_two_factor, s.twoFactor),
            loginLog: asBool(d.security_login_log, s.loginLog),
            forceHttps: asBool(d.security_force_https, s.forceHttps),
            sessionTimeout: asBool(d.security_session_timeout, s.sessionTimeout),
          }));
          setSeo(s => ({
            title: d.seo_title || s.title,
            description: d.seo_description || s.description,
            keywords: d.seo_keywords || s.keywords,
            ogImage: d.seo_og_image || s.ogImage,
          }));
        }
      })
      .catch((e) => { setLoadFailed(true); showErrorDialog({ title: "Couldn't load settings", error: e }); })
      .finally(() => setLoading(false));
  }, []);

  const handleSave = async () => {
    // Never save while the real values failed to load — that would overwrite them with the defaults on screen.
    if (loadFailed) { showErrorDialog({ title: "Can't save yet", message: 'Settings could not be loaded, so saving is disabled to protect your current configuration. Please reload the page.' }); return; }
    setSaving(true);
    try {
      await apiPut('/admin/settings', {
        store_name: store.name,
        store_email: store.email,
        store_phone: store.phone,
        gst_number: store.gst,
        gst_rate: Number(store.gstRate),
        website_url: store.url,
        support_email: store.supportEmail,
        whatsapp_number: store.whatsapp,
        store_address: store.address,
        free_shipping_threshold: Number(shipping.freeThreshold),
        standard_shipping_fee: Number(shipping.standardFee),
        express_shipping_fee: Number(shipping.expressFee),
        max_delivery_days: Number(shipping.maxDays),
        free_shipping_enabled: shipping.freeShipping,
        express_enabled: shipping.express,
        cod_enabled: shipping.cod,
        maintenance_mode: features.maintenanceMode,
        invoices_enabled: features.invoices,
        user_registration_enabled: features.userRegistration,
        guest_checkout_enabled: features.guestCheckout,
        product_reviews_enabled: features.productReviews,
        maintenance_message: appControl.maintenanceMessage,
        force_update_enabled: appControl.forceUpdate,
        min_app_version: appControl.minAppVersion,
        force_update_message: appControl.forceUpdateMessage,
        payment_upi_enabled: payment.upi,
        payment_cards_enabled: payment.cards,
        payment_netbanking_enabled: payment.netBanking,
        payment_emi_enabled: payment.emi,
        payment_cod_enabled: payment.cod,
        payment_wallets_enabled: payment.wallets,
        notify_order_placed: notif.orderPlaced,
        notify_order_shipped: notif.orderShipped,
        notify_order_delivered: notif.orderDelivered,
        notify_order_cancelled: notif.orderCancelled,
        notify_promo: notif.promo,
        notify_admin_alerts: notif.adminAlerts,
        notify_low_stock: notif.lowStock,
        security_two_factor: security.twoFactor,
        security_login_log: security.loginLog,
        security_force_https: security.forceHttps,
        security_session_timeout: security.sessionTimeout,
        seo_title: seo.title,
        seo_description: seo.description,
        seo_keywords: seo.keywords,
        seo_og_image: seo.ogImage,
      });
      setSettings(s => ({ ...s, ...store, ...shipping }));
      showToast('Settings saved successfully!');
    } catch (e: any) {
      showErrorDialog({ title: "Couldn't save settings", error: e });
    } finally {
      setSaving(false);
    }
  };

  return (
    <AdminLayout title="Settings" subtitle="Manage your store configuration">
      <div className="flex flex-col lg:flex-row gap-6">
        <div className="lg:w-56 shrink-0">
          <div className="bg-white rounded-2xl border border-[#ECECEC] shadow-sm p-3 space-y-1">
            {tabs.map(t => (
              <button key={t.id} onClick={() => setActiveTab(t.id)}
                className={`w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-bold transition-all ${activeTab === t.id ? 'bg-[#FF6B2C] text-white' : 'text-gray-500 hover:bg-[#FFF8F5] hover:text-[#FF6B2C]'}`}>
                {t.icon}{t.label}
              </button>
            ))}
          </div>
        </div>

        <div className="flex-1 space-y-5">
          {loading && (
            <div className="flex items-center gap-2 text-gray-400 py-4">
              <Loader2 size={16} className="animate-spin" />
              <span className="text-sm font-bold">Loading settings...</span>
            </div>
          )}

          {/* Store Info */}
          {loadFailed && (
            <div role="alert" className="mb-5 flex items-center justify-between gap-4 bg-red-50 border border-red-200 text-red-700 rounded-2xl px-5 py-4">
              <p className="text-sm font-bold">Your saved settings couldn't be loaded. The values below are defaults, not your configuration — saving is disabled until the page reloads successfully.</p>
              <button onClick={() => window.location.reload()} className="shrink-0 px-4 py-2 rounded-xl bg-red-600 text-white text-xs font-black">Reload</button>
            </div>
          )}
          {activeTab === 'golive' && <GoLiveChecklist onGo={setActiveTab} />}
          {activeTab === 'store' && (
            <>
              <div className="bg-white rounded-2xl border border-[#ECECEC] shadow-sm p-6">
                <h3 className="text-sm font-black text-[#111827] mb-1">Store Information</h3>
                <p className="text-[11px] font-bold text-gray-400 mb-5">Phone Number, Support Email and WhatsApp are shown to customers on the website (Contact, Help, policies) and in the app (Help &amp; Support). WhatsApp defaults to the phone number.</p>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  {([['Store Name', 'name'], ['Store Email', 'email'], ['Phone Number', 'phone'], ['GST Number', 'gst'], ['GST Rate (%)', 'gstRate'], ['Website URL', 'url'], ['Support Email', 'supportEmail'], ['WhatsApp Number (optional)', 'whatsapp']] as [string, keyof typeof store][]).map(([label, key]) => (
                    <div key={key}>
                      <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">{label}</label>
                      <input value={store[key]} onChange={e => setStore(s => ({ ...s, [key]: e.target.value }))} className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold text-[#111827] outline-none focus:border-[#FF6B2C] transition-colors" />
                    </div>
                  ))}
                </div>
                <div className="mt-4">
                  <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Store Address</label>
                  <textarea rows={2} value={store.address} onChange={e => setStore(s => ({ ...s, address: e.target.value }))} className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold text-[#111827] outline-none focus:border-[#FF6B2C] resize-none" />
                </div>
              </div>
              <div className="bg-white rounded-2xl border border-[#ECECEC] shadow-sm p-6">
                <h3 className="text-sm font-black text-[#111827] mb-4">Store Features</h3>
                <Toggle value={features.maintenanceMode} onChange={v => setFeatures(f => ({ ...f, maintenanceMode: v }))} label="Maintenance Mode" desc="Put the store in maintenance mode for visitors" />
                <Toggle value={features.invoices} onChange={v => setFeatures(f => ({ ...f, invoices: v }))} label="Issue GST Tax Invoices" desc="Customers can download a tax invoice once an order ships. Needs your real 15-character GSTIN in Store Information." />
                <Toggle value={features.userRegistration} onChange={v => setFeatures(f => ({ ...f, userRegistration: v }))} label="User Registration" desc="When off, new sign-ups are paused (existing customers can still log in)" />
                <Toggle value={features.productReviews} onChange={v => setFeatures(f => ({ ...f, productReviews: v }))} label="Product Reviews" desc="When off, new reviews are refused (existing reviews stay visible)" />
              </div>
              <div className="bg-white rounded-2xl border border-[#ECECEC] shadow-sm p-6">
                <h3 className="text-sm font-black text-[#111827] mb-4">App Control</h3>
                <div className="mb-4">
                  <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Maintenance Message</label>
                  <textarea rows={2} value={appControl.maintenanceMessage} onChange={e => setAppControl(a => ({ ...a, maintenanceMessage: e.target.value }))} placeholder="Shown to users while maintenance mode is on" className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold text-[#111827] outline-none focus:border-[#FF6B2C] resize-none" />
                </div>
                <Toggle value={appControl.forceUpdate} onChange={v => setAppControl(a => ({ ...a, forceUpdate: v }))} label="Force Update" desc="Block app access below the minimum version until updated" />
                <div className="grid grid-cols-2 gap-4 mt-4">
                  <div>
                    <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Minimum App Version</label>
                    <input value={appControl.minAppVersion} onChange={e => setAppControl(a => ({ ...a, minAppVersion: e.target.value }))} placeholder="1.0.0" className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold text-[#111827] outline-none focus:border-[#FF6B2C]" />
                  </div>
                </div>
                <div className="mt-4">
                  <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Force Update Message</label>
                  <textarea rows={2} value={appControl.forceUpdateMessage} onChange={e => setAppControl(a => ({ ...a, forceUpdateMessage: e.target.value }))} placeholder="Shown when a user must update to continue" className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold text-[#111827] outline-none focus:border-[#FF6B2C] resize-none" />
                </div>
              </div>
            </>
          )}

          {/* Shipping */}
          {activeTab === 'shipping' && (
            <div className="bg-white rounded-2xl border border-[#ECECEC] shadow-sm p-6">
              <h3 className="text-sm font-black text-[#111827] mb-5">Shipping Configuration</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
                {([['Free Shipping Threshold (₹)', 'freeThreshold'], ['Standard Shipping Fee (₹)', 'standardFee'], ['Max Delivery Days (shown on product pages)', 'maxDays']] as [string, keyof typeof shipping, boolean?][]).map(([label, key, inactive]) => (
                  <div key={key} className={inactive ? 'opacity-60' : ''}>
                    <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">{label}{inactive && <NotActive />}</label>
                    <input type="number" min={0} disabled={inactive} value={shipping[key] as string} onChange={e => setShipping(s => ({ ...s, [key]: e.target.value }))} className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C]" />
                  </div>
                ))}
              </div>
              <Toggle value={shipping.freeShipping} onChange={v => setShipping(s => ({ ...s, freeShipping: v }))} label="Free Shipping on Orders Above Threshold" />
              <Toggle value={shipping.cod} onChange={v => setShipping(s => ({ ...s, cod: v }))} label="COD Available" desc="When off, Pay on Delivery is disabled at checkout on the app and website" />
            </div>
          )}

          {/* Payment */}
          {activeTab === 'payment' && (
            <div className="bg-white rounded-2xl border border-[#ECECEC] shadow-sm p-6">
              <h3 className="text-sm font-black text-[#111827] mb-2">Payment Methods</h3>
              <p className="text-xs font-bold text-gray-500 leading-relaxed">
                Online payments (UPI, cards, net banking, wallets) are handled by PhonePe — the methods shown to customers are
                controlled from your PhonePe merchant dashboard. Cash on Delivery is switched on/off under <b>Shipping → COD Available</b>.
                Payment credentials are managed under <b>API Keys</b>.
              </p>
            </div>
          )}

          {/* Notifications */}
          {activeTab === 'notifications' && (
            <div className="bg-white rounded-2xl border border-[#ECECEC] shadow-sm p-6">
              <h3 className="text-sm font-black text-[#111827] mb-5">Notification Settings</h3>
              <Toggle value={notif.orderPlaced} onChange={v => setNotif(n => ({ ...n, orderPlaced: v }))} label="Order Placed" desc="Notify customer when order is placed" />
              <Toggle value={notif.orderShipped} onChange={v => setNotif(n => ({ ...n, orderShipped: v }))} label="Order Shipped" desc="Send shipping updates with tracking link" />
              <Toggle value={notif.orderDelivered} onChange={v => setNotif(n => ({ ...n, orderDelivered: v }))} label="Order Delivered" desc="Confirm delivery to customer" />
              <Toggle value={notif.orderCancelled} onChange={v => setNotif(n => ({ ...n, orderCancelled: v }))} label="Order Cancelled" desc="Inform customer about cancellation" />
              <Toggle value={notif.promo} onChange={v => setNotif(n => ({ ...n, promo: v }))} label="Promotional Emails" inactive desc="Needs unsubscribe/consent handling before marketing emails can be sent" />
              <Toggle value={notif.adminAlerts} onChange={v => setNotif(n => ({ ...n, adminAlerts: v }))} label="Admin Order Alerts" desc="Email the Store Email for every new confirmed order (needs Email set up in API Keys)" />
              <Toggle value={notif.lowStock} onChange={v => setNotif(n => ({ ...n, lowStock: v }))} label="Low Stock Alerts" desc="Email the Store Email when an order takes a product to 5 or fewer in stock" />
            </div>
          )}

          {/* Security */}
          {activeTab === 'security' && (
            <div className="bg-white rounded-2xl border border-[#ECECEC] shadow-sm p-6">
              <h3 className="text-sm font-black text-[#111827] mb-5">Security Settings</h3>
              <div className="py-4 border-b border-[#F8F7FC] flex items-start gap-3">
                <span className="mt-0.5 text-green-600 text-xs font-black">✓</span>
                <div>
                  <p className="text-sm font-black text-[#111827]">Sign-in with one-time code (always on)</p>
                  <p className="text-[11px] font-bold text-gray-400 mt-0.5">Admin and staff sign in only with a code sent to their phone. Password sign-in is disabled on the server.</p>
                </div>
              </div>
              <div className="py-4 border-b border-[#F8F7FC] flex items-start gap-3">
                <span className="mt-0.5 text-green-600 text-xs font-black">✓</span>
                <div>
                  <p className="text-sm font-black text-[#111827]">HTTPS enforced (always on)</p>
                  <p className="text-[11px] font-bold text-gray-400 mt-0.5">The web server redirects every http:// request to https:// with a valid certificate.</p>
                </div>
              </div>
              <Toggle value={security.loginLog} onChange={v => setSecurity(s => ({ ...s, loginLog: v }))} label="Login Activity Log" desc="Record every admin / staff sign-in (time, IP, device) — latest shown below" />
              <Toggle value={security.sessionTimeout} onChange={v => setSecurity(s => ({ ...s, sessionTimeout: v }))} label="Session Timeout" desc="Sign out of the admin panel after 30 minutes without activity" />
              <LoginActivity />
            </div>
          )}

          {/* SEO */}
          {activeTab === 'seo' && (
            <div className="bg-white rounded-2xl border border-[#ECECEC] shadow-sm p-6">
              <h3 className="text-sm font-black text-[#111827] mb-1">SEO Configuration</h3>
              <p className="text-[11px] font-bold text-gray-400 mb-5">Used as the website's default page title, meta description, keywords and social-share image.</p>
              <div className="space-y-4">
                <div>
                  <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Meta Title</label>
                  <input value={seo.title} onChange={e => setSeo(s => ({ ...s, title: e.target.value }))} className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C]" />
                  <p className="text-[10px] font-bold text-gray-400 mt-1">{seo.title.length}/60 characters</p>
                </div>
                <div>
                  <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Meta Description</label>
                  <textarea rows={3} value={seo.description} onChange={e => setSeo(s => ({ ...s, description: e.target.value }))} className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C] resize-none" />
                  <p className="text-[10px] font-bold text-gray-400 mt-1">{seo.description.length}/160 characters</p>
                </div>
                <div>
                  <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Keywords</label>
                  <textarea rows={2} value={seo.keywords} onChange={e => setSeo(s => ({ ...s, keywords: e.target.value }))} className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C] resize-none" />
                </div>
                <div>
                  <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">OG Image URL</label>
                  <input value={seo.ogImage} onChange={e => setSeo(s => ({ ...s, ogImage: e.target.value }))} className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C]" />
                </div>
              </div>
            </div>
          )}

          {/* API Keys */}
          {activeTab === 'apikeys' && (() => {
            const groups = [
              { id: 'otp', label: 'OTP / SMS', desc: 'SMS OTP delivery credentials, and SMS order updates via MSG91 (needs a DLT-approved template with variables order and status)' },
              { id: 'email', label: 'Email (SMTP)', desc: 'Order emails to customers + new-order / low-stock alerts to the Store Email. Works with any SMTP service (Zoho, Google Workspace, Amazon SES…)' },
              { id: 'firebase', label: 'Firebase', desc: 'Push notification credentials' },
              { id: 'payment', label: 'Payment Gateway', desc: 'PhonePe & Razorpay credentials' },
              { id: 'media', label: 'Media / CDN', desc: 'Cloudinary image upload credentials' },
              { id: 'shipping', label: 'Shipping (Delhivery / Shiprocket)', desc: 'Courier API tokens, pickup locations and environment. Secrets are encrypted and never shown back.' },
            ];
            const saveCred = async (key: string) => {
              const val = credEdit[key];
              if (val === undefined) return;
              setCredSaving(s => ({ ...s, [key]: true }));
              try {
                if (key === 'PHONEPE_ENV' && val === 'PRODUCTION' &&
                    !window.confirm('Switch PhonePe to PRODUCTION? Customers will be charged REAL money. Make sure the live Merchant ID / Salt Key are saved first.')) return;
                if (key === 'DELHIVERY_ENV' && val === 'production' &&
                    !window.confirm('Switch Delhivery to PRODUCTION? New orders will create REAL, chargeable shipments.')) return;
                await apiPut('/admin/credentials', { key, value: val });
                showToast('Credential saved!');
                loadCredentials();
                setCredEdit(e => { const c = { ...e }; delete c[key]; return c; });
              } catch (e: any) {
                showErrorDialog({ title: 'Couldn’t save', error: e });
              } finally {
                setCredSaving(s => ({ ...s, [key]: false }));
              }
            };
            return (
              <div className="space-y-5">
                <DelhiveryStatusPanel refreshKey={credentials.length + Object.keys(credSaving).length} />
                {credLoading ? (
                  <div className="flex items-center gap-2 text-gray-400 py-6"><Loader2 size={16} className="animate-spin" /><span className="text-sm font-bold">Loading credentials...</span></div>
                ) : (
                  groups.map(g => {
                    const gCreds = credentials.filter(c => c.group === g.id);
                    if (!gCreds.length) return null;
                    return (
                      <div key={g.id} className="bg-white rounded-2xl border border-[#ECECEC] shadow-sm p-6">
                        <div className="flex items-center justify-between mb-5">
                          <div>
                            <h3 className="text-sm font-black text-[#111827]">{g.label}</h3>
                            <p className="text-[11px] font-bold text-gray-400 mt-0.5">{g.desc}</p>
                          </div>
                          <div className="flex items-center gap-2">
                            {g.id === 'email' && (
                              <button
                                onClick={() => apiPost<{ message: string }>('/admin/email/test', {})
                                  .then(r => showToast(r.message || 'Test email sent'))
                                  .catch(e => showErrorDialog({ title: "Couldn't send the test email", error: e }))}
                                className="px-3 py-2 rounded-lg bg-[#F8F7FC] text-xs font-black text-gray-600 hover:bg-[#FFF3ED] hover:text-[#FF6B2C]"
                              >Send test email</button>
                            )}
                            <button onClick={loadCredentials} className="p-2 rounded-lg hover:bg-gray-100 text-gray-400 hover:text-gray-600 transition-colors"><RefreshCw size={14} /></button>
                          </div>
                        </div>
                        <div className="space-y-4">
                          {gCreds.map(cred => {
                            const isEditing = credEdit[cred.key] !== undefined;
                            const revealed = showSecret[cred.key];
                            return (
                              <div key={cred.key}>
                                <div className="flex items-center justify-between mb-1.5">
                                  <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider">{cred.label}</label>
                                  <div className="flex items-center gap-1.5">
                                    {cred.isSet && <span className="text-[10px] font-black text-green-600 bg-green-50 px-2 py-0.5 rounded-full">CONFIGURED</span>}
                                    {!cred.isSet && <span className="text-[10px] font-black text-red-500 bg-red-50 px-2 py-0.5 rounded-full">NOT SET</span>}
                                  </div>
                                </div>
                                {cred.options ? (
                                  <div className="flex gap-2">
                                    <select value={credEdit[cred.key] ?? cred.value} onChange={e => setCredEdit(ed => ({ ...ed, [cred.key]: e.target.value }))} className="flex-1 border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold text-[#111827] outline-none focus:border-[#FF6B2C] bg-white">
                                      {cred.options.map(o => <option key={o} value={o}>{o}</option>)}
                                    </select>
                                    <button onClick={() => saveCred(cred.key)} disabled={credSaving[cred.key] || !isEditing} className="px-4 py-2.5 bg-[#FF6B2C] text-white rounded-xl text-sm font-black disabled:opacity-40 hover:bg-[#E05520] transition-colors flex items-center gap-1.5">
                                      {credSaving[cred.key] ? <Loader2 size={13} className="animate-spin" /> : <Save size={13} />} Save
                                    </button>
                                  </div>
                                ) : (
                                  <div className="flex gap-2">
                                    <div className="flex-1 relative">
                                      <input
                                        type={cred.secret && !revealed ? 'password' : 'text'}
                                        placeholder={cred.isSet ? '••••••••' : `Enter ${cred.label}`}
                                        value={credEdit[cred.key] ?? ''}
                                        onChange={e => setCredEdit(ed => ({ ...ed, [cred.key]: e.target.value }))}
                                        className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 pr-10 text-sm font-bold text-[#111827] outline-none focus:border-[#FF6B2C] transition-colors"
                                      />
                                      {cred.secret && (
                                        <button type="button" onClick={() => setShowSecret(s => ({ ...s, [cred.key]: !s[cred.key] }))} className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600">
                                          {revealed ? <EyeOff size={14} /> : <Eye size={14} />}
                                        </button>
                                      )}
                                    </div>
                                    <button onClick={() => saveCred(cred.key)} disabled={credSaving[cred.key] || !isEditing} className="px-4 py-2.5 bg-[#FF6B2C] text-white rounded-xl text-sm font-black disabled:opacity-40 hover:bg-[#E05520] transition-colors flex items-center gap-1.5">
                                      {credSaving[cred.key] ? <Loader2 size={13} className="animate-spin" /> : <Save size={13} />} Save
                                    </button>
                                  </div>
                                )}
                                {!isEditing && cred.isSet && cred.value && (
                                  <p className="text-[10px] font-bold text-gray-400 mt-1 font-mono">{cred.value}</p>
                                )}
                              </div>
                            );
                          })}
                        </div>
                      </div>
                    );
                  })
                )}
                <div className="bg-amber-50 border border-amber-200 rounded-2xl p-4">
                  <p className="text-xs font-black text-amber-700">Secret credentials are encrypted in the database and only the last 4 characters are ever shown. Changes take effect within 30 seconds — no server restart needed.</p>
                </div>
              </div>
            );
          })()}

          {activeTab !== 'apikeys' && activeTab !== 'golive' && <div className="flex justify-end">
            <button onClick={handleSave} disabled={saving || loadFailed} className="flex items-center gap-2 bg-[#FF6B2C] text-white px-6 py-3 rounded-xl font-black text-sm shadow-lg shadow-[#FF6B2C]/20 hover:bg-[#E05520] transition-colors disabled:opacity-60">
              {saving ? <><Loader2 size={16} className="animate-spin" />Saving...</> : <><Save size={16} /> Save Changes</>}
            </button>
          </div>}
        </div>
      </div>

      {toast && <Toast msg={toast} onClose={() => setToast('')} />}
    </AdminLayout>
  );
};

export default AdminSettings;
