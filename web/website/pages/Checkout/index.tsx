import React, { useEffect, useRef, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import Header from '../../components/navigation/Header';
import TopBar from '../../components/navigation/TopBar';
import Footer from '../../components/navigation/Footer';
import Container from '../../components/common/Container';
import CheckoutStepper from '../../components/order/CheckoutStepper';
import DeliveryOptionCard from '../../components/order/DeliveryOptionCard';
import PaymentMethodCard from '../../components/order/PaymentMethodCard';
import CheckoutTrustStrip from '../../sections/Checkout/CheckoutTrustStrip';
import { Tag, Plus, CreditCard, Landmark, Wallet, Banknote, Smartphone, Loader2, MapPin, CheckCircle2 } from 'lucide-react';
import { apiGet, apiPost, apiDelete } from '../../utils/api';
import { useStore } from '../../context/StoreContext';
import { showErrorDialog } from '../../components/feedback/ErrorDialog';
import { friendlyError } from '../../utils/api';

interface Address {
  id: string;
  label: string;
  name: string;
  phone: string;
  line1: string;
  line2?: string;
  city: string;
  state: string;
  pincode: string;
  is_default: boolean;
}

type PaymentMethod = 'UPI' | 'Card' | 'NetBanking' | 'Wallet' | 'COD';

const PAYMENT_OPTIONS: { label: string; value: PaymentMethod; icon: React.ReactNode; badge?: string }[] = [
  { label: 'UPI', value: 'UPI', icon: <Smartphone size={20} /> },
  { label: 'Credit / Debit Card', value: 'Card', icon: <CreditCard size={20} /> },
  { label: 'Net Banking', value: 'NetBanking', icon: <Landmark size={20} /> },
  { label: 'Wallets', value: 'Wallet', icon: <Wallet size={20} /> },
  { label: 'Cash on Delivery', value: 'COD', icon: <Banknote size={20} />, badge: 'Available' },
];

const CheckoutPage: React.FC = () => {
  const navigate = useNavigate();
  const { cart, cartTotal, clearCart } = useStore();

  const [addresses, setAddresses] = useState<Address[]>([]);
  const [loadingAddresses, setLoadingAddresses] = useState(true);
  const [selectedAddressId, setSelectedAddressId] = useState<string | null>(null);
  const [payment, setPayment] = useState<PaymentMethod>('COD');
  const [couponCode, setCouponCode] = useState('');
  const [couponDiscount, setCouponDiscount] = useState(0);
  const [couponId, setCouponId] = useState<string | null>(null);
  const [couponMsg, setCouponMsg] = useState('');
  const [applyingCoupon, setApplyingCoupon] = useState(false);
  const [placingOrder, setPlacingOrder] = useState(false);
  const [orderError, setOrderError] = useState('');

  // Address form
  const [showAddForm, setShowAddForm] = useState(false);
  const [newAddr, setNewAddr] = useState({ label: 'Home', name: '', phone: '', line1: '', line2: '', city: '', state: '', pincode: '' });
  const [savingAddr, setSavingAddr] = useState(false);

  const [cartSummary, setCartSummary] = useState<{ delivery_fee: number; tax_amount: number } | null>(null);
  const [summaryFailed, setSummaryFailed] = useState(false);
  const [summaryRetry, setSummaryRetry] = useState(0);
  // Delhivery serviceability of the selected address (null = unknown → never blocks)
  const [svc, setSvc] = useState<{ serviceable: boolean | null; cod: boolean | null } | null>(null);

  const savings = cart.reduce((s, i) => s + (i.oldPrice - i.price) * i.qty, 0);
  const deliveryFee = cartSummary?.delivery_fee ?? (cartTotal > 499 ? 0 : 49);
  // GST is charged on the amount after the coupon (same as the server's order calculation).
  const grossTax = cartSummary?.tax_amount ?? 0;
  const taxAmount = cartTotal > 0 ? Math.round((grossTax * Math.max(0, cartTotal - couponDiscount) / cartTotal) * 100) / 100 : 0;
  const orderTotal = cartTotal + deliveryFee + taxAmount - couponDiscount;

  useEffect(() => {
    if (cart.length === 0) navigate('/cart', { replace: true });
  }, [cart.length, navigate]);

  useEffect(() => {
    apiGet<{ success: boolean; data: { addresses: Address[] } }>('/addresses')
      .then(res => {
        const addrs = res.data.addresses || [];
        setAddresses(addrs);
        const def = addrs.find(a => a.is_default);
        if (def) setSelectedAddressId(def.id);
        else if (addrs.length) setSelectedAddressId(addrs[0].id);
      })
      .catch(() => {})
      .finally(() => setLoadingAddresses(false));
  }, []);

  // Overlapping runs of the effect below (React dev-mode's double-invoke, or a
  // quick address change) must never clear+re-add the shared server-side cart
  // concurrently — that races and can leave duplicated/corrupted quantities.
  // `cartSyncChain` serializes every run strictly after the previous one fully
  // finishes; `cartSyncSeq` additionally lets a run that's gone stale while
  // waiting in that queue skip its (now pointless) network calls entirely, and
  // guarantees only the truly-latest run's result is ever written to state.
  const cartSyncChain = useRef<Promise<void>>(Promise.resolve());
  const cartSyncSeq = useRef(0);

  useEffect(() => {
    if (cart.length === 0) return;
    const mySeq = ++cartSyncSeq.current;
    const pincode = addresses.find(a => a.id === selectedAddressId)?.pincode;
    const cartSnapshot = cart;

    cartSyncChain.current = cartSyncChain.current.then(async () => {
      if (cartSyncSeq.current !== mySeq) return; // superseded before its turn — skip
      try {
        // The backend cart can be stale (left over from a previous session) and
        // out of sync with the locally-tracked cart — sync it first so the tax/
        // delivery preview always reflects what's actually in the user's cart,
        // not whatever the server happened to have last.
        await apiDelete('/cart/clear');
        await Promise.all(cartSnapshot.map(item => apiPost('/cart/add', { product_id: item.id, quantity: item.qty })));
        const res = await apiGet<{ success: boolean; data: { summary: { delivery_fee: number; tax_amount: number } } }>(
          `/cart${pincode ? `?pincode=${pincode}` : ''}`
        );
        if (cartSyncSeq.current === mySeq) { setCartSummary(res.data.summary); setSummaryFailed(false); }
      } catch {
        if (cartSyncSeq.current === mySeq) { setCartSummary(null); setSummaryFailed(true); }
      }
    });
  }, [selectedAddressId, addresses, cart, summaryRetry]);

  // Check whether Delhivery delivers to the selected pincode (and whether COD is offered there).
  useEffect(() => {
    const pin = addresses.find(a => a.id === selectedAddressId)?.pincode;
    if (!pin) { setSvc(null); return; }
    let live = true;
    apiGet<{ data: { serviceable: boolean | null; cod: boolean | null } }>(`/shipping/pincode/${pin}`)
      .then(r => { if (live) setSvc(r.data); })
      .catch(() => { if (live) setSvc(null); });
    return () => { live = false; };
  }, [selectedAddressId, addresses]);
  const notServiceable = svc?.serviceable === false;
  const codUnavailable = svc?.serviceable === true && svc.cod === false;
  useEffect(() => { if (codUnavailable && payment === 'COD') setPayment('UPI'); }, [codUnavailable]);

  const handleApplyCoupon = async () => {
    if (!couponCode.trim()) return;
    setApplyingCoupon(true);
    try {
      const res = await apiPost<{ success: boolean; message: string; data: { coupon_id: string; discount: number } }>(
        '/cart/apply-coupon',
        { code: couponCode, order_total: cartTotal }
      );
      setCouponMsg(`Coupon applied! You saved ₹${res.data.discount.toLocaleString()}`);
      setCouponDiscount(res.data.discount);
      setCouponId(res.data.coupon_id);
    } catch (e: any) {
      setCouponMsg(friendlyError(e, 'Invalid or expired coupon code'));
      setCouponDiscount(0);
      setCouponId(null);
    } finally {
      setApplyingCoupon(false);
    }
  };

  const handleSaveAddress = async () => {
    if (!newAddr.name || !newAddr.phone || !newAddr.line1 || !newAddr.city || !newAddr.state || !newAddr.pincode) return;
    setSavingAddr(true);
    try {
      const res = await apiPost<{ success: boolean; data: { address: Address } }>('/addresses', newAddr);
      const created = res.data.address;
      setAddresses(prev => [created, ...prev]);
      setSelectedAddressId(created.id);
      setShowAddForm(false);
      setNewAddr({ label: 'Home', name: '', phone: '', line1: '', line2: '', city: '', state: '', pincode: '' });
    } catch {}
    setSavingAddr(false);
  };

  const handlePlaceOrder = async () => {
    if (!selectedAddressId) { setOrderError('Please select a delivery address'); return; }
    if (cart.length === 0) { setOrderError('Your cart is empty'); return; }
    if (!cartSummary) { setOrderError('Still calculating your total — please wait a moment.'); return; }
    setPlacingOrder(true); setOrderError('');

    try {
      // Sync local cart to backend
      await apiDelete('/cart/clear');
      await Promise.all(cart.map(item =>
        apiPost('/cart/add', { product_id: item.id, quantity: item.qty })
      ));

      // Place order
      const res = await apiPost<{ success: boolean; data: { order: { id: string; order_number: string; total: number } } }>(
        '/orders',
        { address_id: selectedAddressId, payment_method: payment, coupon_id: couponId }
      );
      const { id: orderId, order_number: orderNumber, total } = res.data.order;
      clearCart();

      if (payment === 'COD') {
        // COD: confirm and go straight to success
        await apiPost('/payment/cod-confirm', { order_id: orderId });
        navigate('/order-success', { state: { orderNumber, total, cod: true }, replace: true });
      } else {
        // Online payment: initiate PhonePe
        const pmtRes = await apiPost<{ success: boolean; data: { payment_url: string; merchant_txn_id: string } }>(
          '/payment/initiate',
          { order_id: orderId, amount: total }
        );
        const { payment_url } = pmtRes.data;
        if (!payment_url) throw new Error('Could not get payment URL. Please try again.');
        // Redirect to PhonePe payment page (replaces current page)
        window.location.href = payment_url;
      }
    } catch (e: any) {
      showErrorDialog({ title: "Couldn't place your order", error: e, fallback: 'We couldn\'t place your order. Please try again.' });
      setPlacingOrder(false);
    }
  };

  return (
    <div className="min-h-screen bg-white font-['Poppins']">
      <TopBar />
      <Header />

      <Container className="py-10">
        <CheckoutStepper />

        <div className="flex flex-col lg:flex-row gap-8 xl:gap-12 mt-4">
          <div className="flex-1 min-w-0 space-y-12">

            {/* 1. Delivery Address */}
            <section>
              <div className="flex items-center justify-between mb-8">
                <div>
                  <h2 className="text-2xl font-black text-[#111827] mb-1">1. Delivery Address</h2>
                  <p className="text-sm font-bold text-gray-400">Choose where you want your order delivered</p>
                </div>
                <button
                  onClick={() => setShowAddForm(v => !v)}
                  className="flex items-center gap-2 text-[#FF6B2C] font-black text-sm hover:underline"
                >
                  <Plus size={18} />
                  Add New Address
                </button>
              </div>

              {showAddForm && (
                <div className="bg-[#F8F7FC] rounded-2xl p-6 border border-[#ECECEC] mb-6 space-y-4">
                  <h3 className="text-sm font-black text-[#111827] uppercase tracking-wider">New Address</h3>
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    {([
                      ['label', 'Label (Home/Work)'],
                      ['name', 'Full Name *'],
                      ['phone', 'Phone *'],
                      ['line1', 'Address Line 1 *'],
                      ['line2', 'Address Line 2'],
                      ['city', 'City *'],
                      ['state', 'State *'],
                      ['pincode', 'Pincode *'],
                    ] as [keyof typeof newAddr, string][]).map(([field, label]) => (
                      <input
                        key={field}
                        placeholder={label}
                        value={newAddr[field]}
                        onChange={e => setNewAddr(p => ({ ...p, [field]: e.target.value }))}
                        className="border border-[#ECECEC] rounded-xl px-4 py-3 text-sm font-bold outline-none focus:border-[#FF6B2C] bg-white"
                      />
                    ))}
                  </div>
                  <div className="flex gap-3">
                    <button
                      onClick={handleSaveAddress}
                      disabled={savingAddr}
                      className="bg-[#FF6B2C] text-white px-6 py-2.5 rounded-xl font-black text-sm hover:bg-[#E05520] disabled:opacity-60 flex items-center gap-2"
                    >
                      {savingAddr && <Loader2 size={14} className="animate-spin" />}
                      Save Address
                    </button>
                    <button onClick={() => setShowAddForm(false)} className="text-gray-400 font-black text-sm hover:text-[#111827]">
                      Cancel
                    </button>
                  </div>
                </div>
              )}

              {loadingAddresses ? (
                <div className="flex items-center gap-3 text-gray-400">
                  <Loader2 size={20} className="animate-spin text-[#FF6B2C]" />
                  <span className="text-sm font-bold">Loading addresses...</span>
                </div>
              ) : addresses.length === 0 ? (
                <div className="py-8 text-center text-gray-400">
                  <MapPin size={32} className="mx-auto mb-3 text-gray-200" />
                  <p className="text-sm font-bold">No addresses saved. Add one above.</p>
                </div>
              ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                  {addresses.map(addr => (
                    <button
                      key={addr.id}
                      onClick={() => setSelectedAddressId(addr.id)}
                      className={`text-left p-5 rounded-2xl border-2 transition-all ${
                        selectedAddressId === addr.id
                          ? 'border-[#FF6B2C] bg-[#FFF8F5] shadow-md shadow-[#FF6B2C]/10'
                          : 'border-[#ECECEC] hover:border-[#FF6B2C]/50'
                      }`}
                    >
                      <div className="flex items-center justify-between mb-3">
                        <span className="text-[10px] font-black bg-gray-100 text-gray-500 px-2 py-0.5 rounded-full uppercase tracking-wider">{addr.label}</span>
                        {selectedAddressId === addr.id && <CheckCircle2 size={18} className="text-[#FF6B2C]" />}
                        {addr.is_default && <span className="text-[9px] font-black text-[#FF6B2C] uppercase tracking-wider">Default</span>}
                      </div>
                      <p className="text-sm font-black text-[#111827] mb-1">{addr.name}</p>
                      <p className="text-xs font-bold text-gray-500 leading-relaxed mb-1">
                        {addr.line1}{addr.line2 ? `, ${addr.line2}` : ''}, {addr.city}, {addr.state} - {addr.pincode}
                      </p>
                      <p className="text-xs font-bold text-gray-400">{addr.phone}</p>
                    </button>
                  ))}
                </div>
              )}
              {notServiceable && (
                <p className="mt-4 text-sm font-bold text-red-500">
                  Sorry, we can't deliver to pincode {addresses.find(a => a.id === selectedAddressId)?.pincode} yet. Please choose or add another address.
                </p>
              )}
            </section>

            {/* 2. Delivery Options */}
            <section>
              <div className="mb-8">
                <h2 className="text-2xl font-black text-[#111827] mb-1">2. Delivery Options</h2>
                <p className="text-sm font-bold text-gray-400">Choose your preferred delivery method</p>
              </div>
              <div className="flex flex-col md:flex-row gap-6">
                {/* Only standard delivery exists (the order is priced by the server with this fee). */}
                <div className="flex-1 text-left">
                  <DeliveryOptionCard
                    type="Standard"
                    duration="Shipped via Delhivery"
                    price={deliveryFee === 0 ? 'FREE' : deliveryFee}
                    isSelected
                  />
                </div>
              </div>
            </section>

            {/* 3. Payment Method */}
            <section>
              <div className="mb-8">
                <h2 className="text-2xl font-black text-[#111827] mb-1">3. Payment Method</h2>
                <p className="text-sm font-bold text-gray-400">Select a payment option</p>
              </div>
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                {PAYMENT_OPTIONS.map(opt => (
                  <button
                    key={opt.value}
                    onClick={() => setPayment(opt.value)}
                    disabled={opt.value === 'COD' && codUnavailable}
                    className="text-left disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    <PaymentMethodCard
                      label={opt.label}
                      icon={opt.icon}
                      isSelected={payment === opt.value}
                      badge={opt.value === 'COD' && codUnavailable ? 'Not available for this pincode' : opt.badge}
                    />
                  </button>
                ))}
              </div>
            </section>

            {/* Coupon */}
            <section className="bg-[#F8F7FC] rounded-[32px] p-8 border border-[#ECECEC] flex flex-col md:flex-row items-center justify-between gap-8 group">
              <div className="flex items-center gap-6">
                <div className="w-14 h-14 bg-white rounded-2xl flex items-center justify-center text-[#FF6B2C] shadow-sm group-hover:scale-110 transition-transform">
                  <Tag size={28} />
                </div>
                <div>
                  <h3 className="text-lg font-black text-[#111827] mb-1">Have a coupon code?</h3>
                  <p className="text-sm font-bold text-gray-400">Apply coupon to get extra discounts</p>
                  {couponMsg && (
                    <p className={`text-xs font-black mt-1 ${couponDiscount > 0 ? 'text-green-600' : 'text-red-500'}`}>{couponMsg}</p>
                  )}
                </div>
              </div>
              <div className="flex flex-1 max-w-[400px] w-full bg-white p-1.5 rounded-xl border border-[#ECECEC] focus-within:border-[#FF6B2C] transition-all">
                <input
                  type="text"
                  value={couponCode}
                  onChange={e => { setCouponCode(e.target.value.toUpperCase()); setCouponMsg(''); setCouponDiscount(0); setCouponId(null); }}
                  placeholder="Enter coupon code"
                  className="flex-1 bg-transparent px-4 text-sm font-bold outline-none uppercase placeholder:normal-case"
                />
                <button
                  onClick={handleApplyCoupon}
                  disabled={applyingCoupon}
                  className="bg-[#FF6B2C] text-white px-8 py-3 rounded-lg font-black text-sm hover:bg-[#E05520] transition-all disabled:opacity-50"
                >
                  {applyingCoupon ? 'Applying...' : 'Apply'}
                </button>
              </div>
            </section>

          </div>

          {/* Right: Order Summary */}
          <div className="lg:w-[340px] xl:w-[380px] shrink-0">
            <div className="sticky top-32 bg-white rounded-2xl border border-[#ECECEC] shadow-sm p-6">
              <h3 className="text-sm font-black text-[#111827] uppercase tracking-wider mb-5 pb-4 border-b border-[#F8F7FC]">Order Summary</h3>

              <div className="space-y-3 mb-5">
                {cart.map(item => (
                  <div key={item.id} className="flex items-center gap-3">
                    <div className="w-12 h-12 rounded-xl overflow-hidden bg-[#F8F7FC] border border-[#ECECEC] shrink-0">
                      <img src={item.img} alt={item.name} className="w-full h-full object-cover" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-xs font-black text-[#111827] truncate">{item.name}</p>
                      <p className="text-[11px] font-bold text-gray-400">Qty: {item.qty}</p>
                    </div>
                    <p className="text-sm font-black text-[#111827] shrink-0">₹{(item.price * item.qty).toLocaleString()}</p>
                  </div>
                ))}
              </div>

              <div className="border-t border-[#F8F7FC] pt-4 space-y-3 mb-5">
                <div className="flex justify-between text-sm font-bold text-gray-500">
                  <span>Price (MRP)</span>
                  <span className="text-[#111827]">₹{(cartTotal + savings).toLocaleString()}</span>
                </div>
                {savings > 0 && (
                  <div className="flex justify-between text-sm font-bold">
                    <span className="text-gray-500">Discount</span>
                    <span className="text-green-600">-₹{savings.toLocaleString()}</span>
                  </div>
                )}
                <div className="flex justify-between text-sm font-bold">
                  <span className="text-gray-500">Delivery</span>
                  <span className={deliveryFee === 0 ? 'text-green-600 font-black text-xs uppercase' : 'text-[#111827]'}>
                    {deliveryFee === 0 ? 'Free' : `₹${deliveryFee}`}
                  </span>
                </div>
                {taxAmount > 0 && (
                  <div className="flex justify-between text-sm font-bold">
                    <span className="text-gray-500">GST</span>
                    <span className="text-[#111827]">₹{taxAmount.toLocaleString()}</span>
                  </div>
                )}
                {couponDiscount > 0 && (
                  <div className="flex justify-between text-sm font-bold">
                    <span className="text-gray-500">Coupon</span>
                    <span className="text-green-600">-₹{couponDiscount.toLocaleString()}</span>
                  </div>
                )}
              </div>

              <div className="flex justify-between items-center mb-6 pt-3 border-t border-[#F8F7FC]">
                <span className="text-lg font-black text-[#111827]">Total Amount</span>
                <span className="text-2xl font-black text-[#111827]">₹{Math.max(0, orderTotal).toLocaleString()}</span>
              </div>

              {orderError && (
                <p className="text-xs font-bold text-red-500 mb-4 text-center">{orderError}</p>
              )}

              <button
                onClick={summaryFailed ? () => setSummaryRetry(n => n + 1) : handlePlaceOrder}
                disabled={placingOrder || cart.length === 0 || !selectedAddressId || notServiceable || (!cartSummary && !summaryFailed)}
                className="w-full bg-gradient-to-r from-[#FF6B2C] to-[#E05520] text-white py-4 rounded-xl font-black flex items-center justify-center gap-3 shadow-xl shadow-[#FF6B2C]/20 hover:scale-[1.02] active:scale-[0.98] transition-all disabled:opacity-60 disabled:scale-100"
              >
                {placingOrder ? (
                  <><Loader2 size={18} className="animate-spin" />Placing Order...</>
                ) : notServiceable ? (
                  <>Can't deliver to this pincode</>
                ) : summaryFailed ? (
                  <>Couldn't calculate total — tap to retry</>
                ) : !cartSummary ? (
                  <><Loader2 size={18} className="animate-spin" />Calculating total...</>
                ) : (
                  <>Place Order • ₹{Math.max(0, orderTotal).toLocaleString()}</>
                )}
              </button>

              <p className="text-[10px] font-bold text-gray-400 text-center mt-4">
                By placing this order you agree to our Terms & Conditions
              </p>
            </div>
          </div>
        </div>

        <CheckoutTrustStrip />
      </Container>

      <Footer />
    </div>
  );
};

export default CheckoutPage;
