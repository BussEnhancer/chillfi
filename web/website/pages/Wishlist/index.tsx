import React from 'react';
import Header from '../../components/navigation/Header';
import TopBar from '../../components/navigation/TopBar';
import CategoryNav from '../../components/navigation/CategoryNav';
import Footer from '../../components/navigation/Footer';
import Container from '../../components/common/Container';
import Breadcrumb from '../../components/common/Breadcrumb';
import AccountSidebar from '../../components/profile/AccountSidebar';
import CheckoutTrustStrip from '../../sections/Checkout/CheckoutTrustStrip';
import WishlistToolbar from '../../components/wishlist/WishlistToolbar';
import WishlistItemCard from '../../components/wishlist/WishlistItemCard';
import WishlistSummary from '../../sections/Wishlist/WishlistSummary';
import WishlistSuggestions from '../../sections/Wishlist/WishlistSuggestions';
import WishlistPromo from '../../sections/Wishlist/WishlistPromo';

import { Share2, ShoppingBag, ChevronLeft, ChevronRight } from 'lucide-react';

const mockWishlistItems: any[] = [
  {
    image: 'https://images.unsplash.com/photo-1512374382149-233c42b6a83b?auto=format&fit=crop&q=80&w=400',
    name: "Nike Air Max Excee Men's Sneakers",
    size: '8 UK',
    color: 'Black/White',
    addedDate: 'May 15, 2025',
    price: 5999,
    stockStatus: 'In Stock',
    isChecked: true,
  },
  {
    image: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&q=80&w=400',
    name: 'Fastrack Men Black Analog Watch',
    color: 'Brown',
    addedDate: 'May 14, 2025',
    price: 2495,
    stockStatus: 'In Stock',
  },
  {
    image: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&q=80&w=400',
    name: 'Puma Smashic Unisex Sneakers',
    size: '7 UK',
    color: 'White',
    addedDate: 'May 13, 2025',
    price: 2999,
    stockStatus: 'In Stock',
  },
  {
    image: 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?auto=format&fit=crop&q=80&w=400',
    name: 'Lavie Women Green Satchel Bag',
    color: 'Green',
    addedDate: 'May 12, 2025',
    price: 1799,
    stockStatus: 'Low Stock',
    stockCount: 2,
  },
];

const WishlistPage: React.FC = () => {
  const breadcrumbItems = [
    { label: 'My Account', href: '#' },
    { label: 'Wishlist' }
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
            <h1 className="text-3xl font-black text-[#111827] mb-1">My Wishlist <span className="text-gray-400 font-bold">(12)</span></h1>
            <p className="text-sm font-bold text-gray-400 uppercase tracking-widest">Items you love, saved for later</p>
          </div>
          <div className="flex items-center gap-4">
             <button className="flex items-center gap-2 border-2 border-[#ECECEC] text-[#111827] px-6 py-2.5 rounded-xl font-black text-sm hover:border-[#6C2BFF] hover:text-[#6C2BFF] transition-all">
                <Share2 size={18} />
                Share Wishlist
             </button>
             <button className="flex items-center gap-2 bg-[#6C2BFF] text-white px-6 py-2.5 rounded-xl font-black text-sm hover:bg-[#5A24D6] shadow-lg shadow-[#6C2BFF]/20 transition-all">
                <ShoppingBag size={18} />
                Move All to Bag
             </button>
          </div>
        </div>

        <div className="flex flex-col lg:flex-row gap-10">
          {/* Left: Sidebar */}
          <AccountSidebar activeId="wishlist" />

          {/* Center: Main Content */}
          <div className="flex-1 min-w-0">
             <WishlistToolbar />

             <div className="space-y-4">
                {mockWishlistItems.map((item, i) => (
                  <WishlistItemCard key={i} {...item} />
                ))}
             </div>

             {/* Pagination */}
             <div className="mt-12 flex items-center justify-between">
                <p className="text-xs font-bold text-gray-400">Showing 1 to 4 of 12 items</p>
                <div className="flex items-center gap-2">
                   <button className="w-10 h-10 flex items-center justify-center text-gray-400 border border-[#ECECEC] rounded-xl hover:border-[#6C2BFF] transition-all">
                      <ChevronLeft size={20} />
                   </button>
                   {[1, 2, 3].map((p, i) => (
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

          {/* Right: Sidebar */}
          <div className="lg:w-[320px] shrink-0 space-y-8">
             <WishlistSuggestions />
             <WishlistSummary />
             <WishlistPromo />
          </div>
        </div>

        {/* Global Trust Strip */}
        <CheckoutTrustStrip />
      </Container>

      <Footer />
    </div>
  );
};

export default WishlistPage;
