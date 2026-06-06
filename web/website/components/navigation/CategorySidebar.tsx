import React from 'react';
import CategoryMenuItem from './CategoryMenuItem';
import {
  LayoutGrid, Shirt, Headphones, Sofa, Sparkles, User, UserRound,
  Trophy, Gamepad2, Apple, HeartPulse, Car, BookOpen, Dog, ShieldAlert
} from 'lucide-react';

const categories = [
  { label: 'All Categories', icon: <LayoutGrid size={18} />, active: true },
  { label: 'Fashion', icon: <Shirt size={18} /> },
  { label: 'Electronics', icon: <Headphones size={18} /> },
  { label: 'Home & Living', icon: <Sofa size={18} /> },
  { label: 'Beauty', icon: <Sparkles size={18} /> },
  { label: 'Men', icon: <User size={18} /> },
  { label: 'Women', icon: <UserRound size={18} /> },
  { label: 'Sports', icon: <Trophy size={18} /> },
  { label: 'Toys & Games', icon: <Gamepad2 size={18} /> },
  { label: 'Grocery', icon: <Apple size={18} /> },
  { label: 'Health & Personal Care', icon: <HeartPulse size={18} /> },
  { label: 'Automotive', icon: <Car size={18} /> },
  { label: 'Books & Stationery', icon: <BookOpen size={18} /> },
  { label: 'Pet Supplies', icon: <Dog size={18} /> },
];

const CategorySidebar: React.FC = () => {
  return (
    <aside className="w-[320px] shrink-0 hidden lg:block">
      <div className="bg-white rounded-[20px] shadow-sm border border-[#ECECEC] p-4 sticky top-32">
        <h2 className="text-xl font-black text-[#111827] px-4 mb-6">Categories</h2>
        <div className="space-y-1">
          {categories.map((cat, i) => (
            <CategoryMenuItem key={i} label={cat.label} icon={cat.icon} isActive={cat.active} />
          ))}
        </div>

        {/* Promo Card */}
        <div className="mt-8 p-6 bg-gradient-to-br from-[#6C2BFF] to-[#A166FF] rounded-2xl text-white relative overflow-hidden group">
           <div className="relative z-10">
              <div className="w-10 h-10 bg-white/20 rounded-full flex items-center justify-center mb-4">
                 <ShieldAlert size={20} />
              </div>
              <h3 className="text-lg font-black mb-2">Best Deals <br />Just For You!</h3>
              <p className="text-[11px] font-bold opacity-80 mb-6">Explore top offers across all categories and save big.</p>
              <button className="bg-white text-[#6C2BFF] px-6 py-2.5 rounded-xl text-xs font-black shadow-lg hover:scale-105 transition-all">
                 View Offers
              </button>
           </div>
           {/* Decorative */}
           <div className="absolute -bottom-4 -right-4 w-20 h-20 bg-white/10 rounded-full blur-xl group-hover:scale-150 transition-transform duration-700"></div>
        </div>
      </div>
    </aside>
  );
};

export default CategorySidebar;
