import React from 'react';
import Header from '../../components/navigation/Header';
import TopBar from '../../components/navigation/TopBar';
import CategoryNav from '../../components/navigation/CategoryNav';
import Footer from '../../components/navigation/Footer';
import Container from '../../components/common/Container';
import Breadcrumb from '../../components/common/Breadcrumb';
import AccountSidebar from '../../components/profile/AccountSidebar';
import CheckoutTrustStrip from '../../sections/Checkout/CheckoutTrustStrip';
import HeroOfferBanner from '../../sections/Offers/HeroOfferBanner';
import OfferTabs from '../../components/offers/OfferTabs';
import CouponCard from '../../components/offers/CouponCard';
import OffersSidebar from '../../sections/Offers/OffersSidebar';

import { HelpCircle, ChevronDown } from 'lucide-react';

const mockCoupons = [
  { code: 'CHILL15', tag: 'SITEWIDE', offer: 'Flat 15% OFF', condition: 'On minimum order value of ₹1,499', validity: '31 May 2025' },
  { code: 'CHILL30', tag: 'SITEWIDE', offer: 'Flat 30% OFF', condition: 'On minimum order value of ₹2,999', validity: '31 May 2025' },
  { code: 'ELEC10', tag: 'ELECTRONICS', offer: 'Extra 10% OFF', condition: 'On electronics & accessories', validity: '25 May 2025' },
  { code: 'FASH20', tag: 'FASHION', offer: 'Flat 20% OFF', condition: 'On fashion & footwear', validity: '25 May 2025' },
  { code: 'PREPAID5', tag: 'PAYMENT', offer: '5% Instant Discount', condition: 'On prepaid orders', validity: '31 May 2025' },
];

const OffersPage: React.FC = () => {
  const breadcrumbItems = [
    { label: 'My Account', href: '#' },
    { label: 'Coupons & Offers' }
  ];

  return (
    <div className="min-h-screen bg-white font-['Poppins']">
      <TopBar />
      <Header />
      <CategoryNav />
      <Breadcrumb items={breadcrumbItems} />

      <Container className="py-10">
        <div className="flex flex-col md:flex-row items-center justify-between gap-6 mb-10">
          <div>
            <h1 className="text-3xl font-black text-[#111827] mb-1">Offers & Coupons</h1>
            <p className="text-sm font-bold text-gray-400">Save more with exclusive offers, coupons and bank deals</p>
          </div>
          <button className="flex items-center gap-2 border-2 border-[#ECECEC] text-[#111827] px-6 py-2.5 rounded-xl font-black text-sm hover:border-[#6C2BFF] hover:text-[#6C2BFF] transition-all group">
             <HelpCircle size={18} className="text-gray-400 group-hover:text-[#6C2BFF]" />
             How to use coupons?
          </button>
        </div>

        <div className="flex flex-col lg:flex-row gap-10">
          {/* Left: Sidebar */}
          <AccountSidebar activeId="offers" />

          {/* Center: Main Content */}
          <div className="flex-1 min-w-0">
             <HeroOfferBanner />

             <OfferTabs />

             <div className="space-y-4">
                {mockCoupons.map((coupon, i) => (
                  <CouponCard key={i} {...coupon} />
                ))}
             </div>

             <button className="w-full mt-8 py-4 border-2 border-[#ECECEC] rounded-2xl text-sm font-black text-gray-400 uppercase tracking-widest hover:border-[#6C2BFF] hover:text-[#6C2BFF] transition-all flex items-center justify-center gap-2 group">
                View More Coupons
                <ChevronDown size={18} className="group-hover:translate-y-1 transition-transform" />
             </button>
          </div>

          {/* Right: Side Cards */}
          <div className="lg:w-[320px] shrink-0">
             <OffersSidebar />
          </div>
        </div>

        <CheckoutTrustStrip />
      </Container>

      <Footer />
    </div>
  );
};

export default OffersPage;
