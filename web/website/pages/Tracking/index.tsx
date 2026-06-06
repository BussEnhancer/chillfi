import React from 'react';
import Header from '../../components/navigation/Header';
import TopBar from '../../components/navigation/TopBar';
import CategoryNav from '../../components/navigation/CategoryNav';
import Footer from '../../components/navigation/Footer';
import Container from '../../components/common/Container';
import Breadcrumb from '../../components/common/Breadcrumb';
import AccountSidebar from '../../components/profile/AccountSidebar';
import CheckoutTrustStrip from '../../sections/Checkout/CheckoutTrustStrip';
import TrackingStatusCard from '../../components/order/TrackingStatusCard';
import OrderProgressTracker from '../../components/order/OrderProgressTracker';
import DeliveryInfoSection from '../../sections/Tracking/DeliveryInfoSection';
import DeliveryTimelineSection from '../../sections/Tracking/DeliveryTimelineSection';
import TrackingOrderSummary from '../../sections/Tracking/TrackingOrderSummary';

import { Headphones } from 'lucide-react';

const TrackingPage: React.FC = () => {
  const breadcrumbItems = [
    { label: 'My Orders', href: '#' },
    { label: 'Track Order' }
  ];

  return (
    <div className="min-h-screen bg-white font-['Poppins']">
      <TopBar />
      <Header />
      <CategoryNav />
      <Breadcrumb items={breadcrumbItems} />

      <Container className="py-10">
        <div className="flex flex-col lg:flex-row items-center justify-between gap-6 mb-10">
          <div>
            <h1 className="text-3xl font-black text-[#111827] mb-1">Track Your Order</h1>
            <p className="text-sm font-bold text-gray-400">Order ID: <span className="text-[#111827]">#CH12345678</span> | Placed on May 15, 2025 at 10:30 AM</p>
          </div>
          <button className="flex items-center gap-2 border-2 border-[#6C2BFF] text-[#6C2BFF] px-6 py-2.5 rounded-xl font-black text-sm hover:bg-[#6C2BFF] hover:text-white transition-all">
             <Headphones size={18} />
             Contact Support
          </button>
        </div>

        <div className="flex flex-col lg:flex-row gap-10">
          {/* Left: Sidebar */}
          <AccountSidebar activeId="track" />

          {/* Center: Content */}
          <div className="flex-1 min-w-0">
             <TrackingStatusCard />

             <OrderProgressTracker />

             <div className="grid grid-cols-1 xl:grid-cols-2 gap-8 mb-8">
                <DeliveryInfoSection />
                <DeliveryTimelineSection />
             </div>

             {/* Order Items List */}
             <div className="bg-white rounded-[24px] border border-[#ECECEC] p-8 shadow-sm">
                <h3 className="text-sm font-black text-[#111827] uppercase tracking-wider mb-8">Order Items (1)</h3>
                <div className="flex items-center gap-6 p-4 rounded-2xl bg-[#F8F5FF] border border-[#6C2BFF]/10">
                   <div className="w-20 h-20 bg-white rounded-xl overflow-hidden border border-[#ECECEC] flex items-center justify-center p-2 shrink-0 shadow-sm">
                      <img src="https://images.unsplash.com/photo-1512374382149-233c42b6a83b?auto=format&fit=crop&q=80&w=400" alt="Product" className="w-full h-full object-contain" />
                   </div>
                   <div className="flex-1 flex flex-col md:flex-row md:items-center justify-between gap-4">
                      <div>
                         <h4 className="text-sm font-black text-[#111827] mb-1">Nike Air Max Excee Men's Sneakers</h4>
                         <p className="text-[10px] font-bold text-gray-400 uppercase tracking-widest">Size: 8 UK • Color: Black / White • Qty: 1</p>
                      </div>
                      <div className="text-right">
                         <span className="text-lg font-black text-[#111827]">₹5,999</span>
                      </div>
                   </div>
                </div>
             </div>
          </div>

          {/* Right: Sidebar */}
          <div className="lg:w-[320px] shrink-0">
             <TrackingOrderSummary />
          </div>
        </div>

        <CheckoutTrustStrip />
      </Container>

      <Footer />
    </div>
  );
};

export default TrackingPage;
