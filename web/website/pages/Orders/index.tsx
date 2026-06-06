import React from 'react';
import Header from '../../components/navigation/Header';
import TopBar from '../../components/navigation/TopBar';
import CategoryNav from '../../components/navigation/CategoryNav';
import Footer from '../../components/navigation/Footer';
import Container from '../../components/common/Container';
import Breadcrumb from '../../components/common/Breadcrumb';
import AccountSidebar from '../../components/profile/AccountSidebar';
import OrdersSearchBar from '../../sections/Orders/OrdersSearchBar';
import OrdersTabs from '../../sections/Orders/OrdersTabs';
import OrderCard from '../../components/order/OrderCard';
import OrderStatsCard from '../../sections/Orders/OrderStatsCard';
import FindOrderCard from '../../sections/Orders/FindOrderCard';
import BuyAgainBanner from '../../sections/Orders/BuyAgainBanner';
import CheckoutTrustStrip from '../../sections/Checkout/CheckoutTrustStrip';
import QuickActionCard from '../../components/profile/QuickActionCard';

import { Truck, RotateCcw, FileText, HelpCircle, ChevronLeft, ChevronRight } from 'lucide-react';

const mockOrders: any[] = [
  {
    id: '#CHI2345678',
    date: 'May 15, 2025',
    time: '10:30 AM',
    image: 'https://images.unsplash.com/photo-1512374382149-233c42b6a83b?auto=format&fit=crop&q=80&w=400',
    name: "Nike Air Max Excee Men's Sneakers",
    variant: 'Size: 8 UK • Color: Black/White',
    qty: 1,
    amount: 5999,
    paymentStatus: 'Paid',
    paymentMethod: 'Online Payment',
    deliveryDate: 'May 18, 2025',
    status: 'Delivered'
  },
  {
    id: '#CHI2345677',
    date: 'May 14, 2025',
    time: '03:15 PM',
    image: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&q=80&w=400',
    name: 'Fastrack Men Black Analog Watch',
    variant: 'Color: Brown',
    qty: 1,
    amount: 2495,
    paymentStatus: 'Paid',
    paymentMethod: 'UPI',
    deliveryDate: 'May 17, 2025',
    status: 'Delivered'
  },
  {
    id: '#CHI2345676',
    date: 'May 13, 2025',
    time: '08:45 PM',
    image: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&q=80&w=400',
    name: 'Puma Smashic Unisex Sneakers',
    variant: 'Size: 7 UK • Color: White',
    qty: 1,
    amount: 2999,
    paymentStatus: 'Paid',
    paymentMethod: 'Credit Card',
    deliveryDate: 'May 15, 2025',
    status: 'Shipped'
  },
  {
    id: '#CHI2345675',
    date: 'May 12, 2025',
    time: '02:20 PM',
    image: 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?auto=format&fit=crop&q=80&w=400',
    name: 'Lavie Women Green Satchel Bag',
    variant: 'Color: Green',
    qty: 1,
    amount: 1799,
    paymentStatus: 'COD',
    paymentMethod: 'Cash on Delivery',
    deliveryDate: 'Expected by May 19',
    status: 'Processing'
  },
];

const OrdersPage: React.FC = () => {
  const breadcrumbItems = [
    { label: 'My Account', href: '#' },
    { label: 'My Orders' }
  ];

  return (
    <div className="min-h-screen bg-white font-['Poppins']">
      <TopBar />
      <Header />
      <CategoryNav />
      <Breadcrumb items={breadcrumbItems} />

      <Container className="py-10">
        <div className="mb-8">
           <h1 className="text-3xl font-black text-[#111827] mb-1">My Orders</h1>
           <p className="text-sm font-bold text-gray-400">Track, manage and reorder your purchases</p>
        </div>

        <div className="flex flex-col lg:flex-row gap-10">
          {/* Left: Sidebar */}
          <AccountSidebar activeId="orders" />

          {/* Center: Main Content */}
          <div className="flex-1 min-w-0">
             <OrdersSearchBar />

             <OrdersTabs />

             <div className="space-y-4">
                {mockOrders.map((order, i) => (
                  <OrderCard key={i} {...order} />
                ))}
             </div>

             {/* Pagination */}
             <div className="mt-12 flex items-center justify-between">
                <p className="text-xs font-bold text-gray-400">Showing 1 to 4 of 24 orders</p>
                <div className="flex items-center gap-2">
                   <button className="w-10 h-10 flex items-center justify-center text-gray-400 border border-[#ECECEC] rounded-xl hover:border-[#6C2BFF] transition-all">
                      <ChevronLeft size={20} />
                   </button>
                   {[1, 2, 3, '...', 6].map((p, i) => (
                     <button
                       key={i}
                       className={`w-10 h-10 flex items-center justify-center text-sm font-black rounded-xl transition-all ${
                         p === 1 ? 'bg-[#6C2BFF] text-white shadow-lg' : 'text-gray-500 hover:bg-gray-50'
                       }`}
                     >
                       {p}
                     </button>
                   ))}
                   <button className="w-10 h-10 flex items-center justify-center text-gray-400 border border-[#ECECEC] rounded-xl hover:border-[#6C2BFF] transition-all">
                      <ChevronRight size={20} />
                   </button>
                </div>
             </div>
          </div>

          {/* Right: Side Cards */}
          <div className="lg:w-[320px] shrink-0 space-y-8">
             <OrderStatsCard />

             <FindOrderCard />

             {/* Quick Actions */}
             <div className="bg-white rounded-[24px] border border-[#ECECEC] p-6 shadow-sm">
                <h3 className="text-sm font-black text-[#111827] uppercase tracking-wider mb-6">Quick Actions</h3>
                <div className="space-y-3">
                   {[
                     { icon: <Truck size={18} />, title: 'Track Your Order', subtitle: 'Get real-time updates' },
                     { icon: <RotateCcw size={18} />, title: 'Return / Replace Item', subtitle: 'Hassle-free returns' },
                     { icon: <FileText size={18} />, title: 'Download Invoices', subtitle: 'View and download invoices' },
                     { icon: <HelpCircle size={18} />, title: 'Need Help?', subtitle: 'Visit our support center' },
                   ].map((item, i) => (
                     <button key={i} className="w-full flex items-center justify-between p-4 rounded-2xl hover:bg-[#F8F5FF] group transition-all text-left">
                        <div className="flex items-center gap-4">
                           <div className="w-10 h-10 bg-gray-50 rounded-xl flex items-center justify-center text-gray-400 group-hover:text-[#6C2BFF] group-hover:bg-white transition-all">
                              {item.icon}
                           </div>
                           <div>
                              <h4 className="text-[11px] font-black text-[#111827] uppercase tracking-tight">{item.title}</h4>
                              <p className="text-[10px] font-bold text-gray-400">{item.subtitle}</p>
                           </div>
                        </div>
                        <ChevronRight size={14} className="text-gray-300 group-hover:text-[#6C2BFF] transition-colors" />
                     </button>
                   ))}
                </div>
             </div>

             <BuyAgainBanner />
          </div>
        </div>

        {/* Global Trust Section */}
        <CheckoutTrustStrip />
      </Container>

      <Footer />
    </div>
  );
};

export default OrdersPage;
