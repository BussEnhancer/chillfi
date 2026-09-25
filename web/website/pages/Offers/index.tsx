import React, { useState } from 'react';
import Header from '../../components/navigation/Header';
import TopBar from '../../components/navigation/TopBar';
import CategoryNav from '../../components/navigation/CategoryNav';
import Footer from '../../components/navigation/Footer';
import Container from '../../components/common/Container';
import Breadcrumb from '../../components/common/Breadcrumb';
import AccountSidebar from '../../components/profile/AccountSidebar';
import CheckoutTrustStrip from '../../sections/Checkout/CheckoutTrustStrip';
import HeroOfferBanner from '../../sections/Offers/HeroOfferBanner';
import OffersSidebar from '../../sections/Offers/OffersSidebar';
import { HelpCircle, ChevronDown, Copy, Check, Tag, X, AlertCircle } from 'lucide-react';
import { useStore } from '../../context/StoreContext';

const typeTag: Record<string, string> = { Percentage: 'SITEWIDE', Flat: 'SITEWIDE', 'Free Shipping': 'SHIPPING' };

const OffersPage: React.FC = () => {
  const { coupons } = useStore();
  const [copied, setCopied] = useState('');
  const [copyError, setCopyError] = useState('');
  const [showHowToUse, setShowHowToUse] = useState(false);

  const activeCoupons = coupons.filter(c => c.status);

  const handleCopy = async (code: string) => {
    try {
      await navigator.clipboard.writeText(code);
      setCopied(code);
      setTimeout(() => setCopied(''), 2000);
    } catch {
      setCopyError(code);
      setTimeout(() => setCopyError(''), 2000);
    }
  };

  const formatExpiry = (iso: string) => {
    if (!iso) return 'No expiry';
    try {
      const d = new Date(iso);
      if (isNaN(d.getTime())) return 'No expiry';
      return d.toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' });
    } catch { return 'No expiry'; }
  };

  const breadcrumbItems = [
    { label: 'My Account', href: '/account' },
    { label: 'Coupons & Offers' }
  ];

  return (
    <div className="min-h-screen bg-white font-['Poppins']">
      <TopBar />
      <Header />
      <CategoryNav />
      <Breadcrumb items={breadcrumbItems} />

      <Container className="py-10 animate-page-in">
        <div className="flex flex-col md:flex-row items-center justify-between gap-6 mb-10">
          <div>
            <h1 className="text-3xl font-black text-[#111827] mb-1">Offers & Coupons</h1>
            <p className="text-sm font-bold text-gray-400">{activeCoupons.length > 0 ? `Save more with ${activeCoupons.length} exclusive offers and coupons` : 'Exclusive deals & coupon codes'}</p>
          </div>
          <button onClick={() => setShowHowToUse(true)} className="flex items-center gap-2 border-2 border-[#ECECEC] text-[#111827] px-6 py-2.5 rounded-xl font-black text-sm hover:border-[#FF6B2C] hover:text-[#FF6B2C] transition-all group">
            <HelpCircle size={18} className="text-gray-400 group-hover:text-[#FF6B2C]" />
            How to use coupons?
          </button>
        </div>

        <div className="flex flex-col lg:flex-row gap-10">
          <AccountSidebar activeId="offers" />

          <div className="flex-1 min-w-0">
            <HeroOfferBanner />

            <div className="space-y-4">
              {activeCoupons.map((coupon) => (
                <div key={coupon.id} className="bg-white border border-[#ECECEC] rounded-2xl p-5 flex flex-col sm:flex-row gap-5 shadow-sm hover:shadow-md transition-shadow">
                  <div className="flex items-center justify-center w-14 h-14 bg-[#FFF8F5] rounded-2xl shrink-0">
                    <Tag size={22} className="text-[#FF6B2C]" />
                  </div>
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-1">
                      <span className="text-[9px] font-black bg-[#FFF3ED] text-[#FF6B2C] px-2 py-0.5 rounded-full uppercase tracking-widest">{typeTag[coupon.type] || 'OFFER'}</span>
                    </div>
                    <p className="text-base font-black text-[#111827] mb-0.5">
                      {coupon.type === 'Percentage' ? `Flat ${coupon.value}% OFF` : coupon.type === 'Flat' ? `Flat ₹${coupon.value} OFF` : 'Free Shipping'}
                    </p>
                    <p className="text-xs font-bold text-gray-500">
                      {coupon.minOrder > 0 ? `Min. order ₹${coupon.minOrder.toLocaleString()}` : 'No minimum order'}
                      {coupon.maxDiscount > 0 ? ` • Max. discount ₹${coupon.maxDiscount.toLocaleString()}` : ''}
                    </p>
                    <p className="text-[10px] font-bold text-gray-400 mt-1">{coupon.expiry ? `Valid till ${formatExpiry(coupon.expiry)}` : 'No expiry'}</p>
                  </div>
                  <div className="flex flex-col items-end justify-center gap-2 shrink-0">
                    <div className="flex items-center gap-2 border-2 border-dashed border-[#FF6B2C]/40 bg-[#FFF8F5] px-4 py-2 rounded-xl">
                      <span className="text-sm font-black text-[#FF6B2C] tracking-widest">{coupon.code}</span>
                      <button onClick={() => handleCopy(coupon.code)} className="text-[#FF6B2C] hover:text-[#E05520]">
                        {copied === coupon.code ? <Check size={14} /> : copyError === coupon.code ? <AlertCircle size={14} className="text-red-500" /> : <Copy size={14} />}
                      </button>
                    </div>
                    {copyError === coupon.code ? (
                      <span className="text-[10px] font-bold text-red-500">Couldn't copy — select manually</span>
                    ) : (
                      <span className="text-[10px] font-bold text-gray-400">{coupon.used.toLocaleString()} used</span>
                    )}
                  </div>
                </div>
              ))}

              {activeCoupons.length === 0 && (
                <div className="py-16 text-center">
                  <Tag size={40} className="text-gray-200 mx-auto mb-4" />
                  <p className="text-gray-500 font-bold text-base mb-1">No active offers right now</p>
                  <p className="text-gray-400 font-medium text-sm">Check back soon — new deals are added regularly.</p>
                </div>
              )}
            </div>
          </div>

          <div className="lg:w-[320px] shrink-0">
            <OffersSidebar />
          </div>
        </div>

        <CheckoutTrustStrip />
      </Container>

      {showHowToUse && (
        <div className="fixed inset-0 bg-black/40 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl shadow-2xl w-full max-w-md p-6">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-black text-[#111827]">How to use coupons</h3>
              <button onClick={() => setShowHowToUse(false)} className="w-8 h-8 rounded-xl bg-[#F8F7FC] flex items-center justify-center hover:bg-red-50 hover:text-red-500 transition-colors"><X size={16} /></button>
            </div>
            <ol className="space-y-3 text-sm font-bold text-gray-600 list-decimal list-inside">
              <li>Click the copy icon next to any active coupon code above.</li>
              <li>Add items to your cart and proceed to checkout.</li>
              <li>Paste the coupon code in the "Apply Coupon" field at checkout.</li>
              <li>The discount is applied automatically if your order meets the minimum order value.</li>
              <li>Each coupon can only be used once per account, before its expiry date.</li>
            </ol>
            <button onClick={() => setShowHowToUse(false)} className="w-full mt-6 bg-[#FF6B2C] text-white py-2.5 rounded-xl font-black text-sm hover:scale-[1.02] transition-all">Got it</button>
          </div>
        </div>
      )}

      <Footer />
    </div>
  );
};

export default OffersPage;
