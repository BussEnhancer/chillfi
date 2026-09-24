import React from 'react';
import { Link } from 'react-router-dom';
import { ChevronRight, Star, ArrowDownWideNarrow, LayoutGrid, Sparkles } from 'lucide-react';

// Only links to real, working listings — no invented bank offers, timers or memberships.
const shopLinks = [
  { icon: <Sparkles size={16} />, title: 'New Arrivals', desc: 'Latest products', to: '/products?sort=newest', color: 'text-[#8B5CFF]' },
  { icon: <Star size={16} />, title: 'Top Rated', desc: 'Loved by customers', to: '/products?sort=rating', color: 'text-amber-500' },
  { icon: <ArrowDownWideNarrow size={16} />, title: 'Lowest Prices', desc: 'Price: low to high', to: '/products?sort=price_asc', color: 'text-[#FF6B2C]' },
  { icon: <LayoutGrid size={16} />, title: 'All Categories', desc: 'Browse by category', to: '/categories', color: 'text-emerald-500' },
];

const OffersSidebar: React.FC = () => {
  return (
    <div className="space-y-8 lg:sticky lg:top-32">
      <div className="bg-white rounded-[24px] border border-[#ECECEC] p-6 shadow-sm">
        <h3 className="text-sm font-black text-[#111827] uppercase tracking-wider mb-6 pb-4 border-b border-[#FFF8F5]">Shop Deals</h3>
        <div className="space-y-4">
          {shopLinks.map((l) => (
            <Link key={l.title} to={l.to} className="flex items-center gap-4 group">
              <div className={`w-9 h-9 rounded-xl bg-gray-50 flex items-center justify-center ${l.color} group-hover:bg-white group-hover:shadow-md transition-all`}>
                {l.icon}
              </div>
              <div className="flex-1">
                <h4 className="text-[12px] font-black text-[#111827]">{l.title}</h4>
                <p className="text-[10px] font-bold text-gray-400 uppercase tracking-widest">{l.desc}</p>
              </div>
              <ChevronRight size={14} className="text-gray-300 group-hover:text-[#FF6B2C] transition-all" />
            </Link>
          ))}
        </div>
      </div>
    </div>
  );
};

export default OffersSidebar;
