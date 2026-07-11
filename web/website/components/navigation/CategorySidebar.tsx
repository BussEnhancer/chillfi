import React from 'react';
import { Link } from 'react-router-dom';
import CategoryMenuItem from './CategoryMenuItem';
import { LayoutGrid, Tag, ShieldAlert } from 'lucide-react';
import { useStore } from '../../context/StoreContext';

const CategorySidebar: React.FC = () => {
  const { categories } = useStore();
  const active = categories.filter(c => c.status);

  return (
    <aside className="w-[320px] shrink-0 hidden lg:block">
      <div className="bg-white rounded-[20px] shadow-sm border border-[#ECECEC] p-4 sticky top-32">
        <h2 className="text-xl font-black text-[#111827] px-4 mb-6">Categories</h2>
        <div className="space-y-1">
          <CategoryMenuItem label="All Categories" icon={<LayoutGrid size={18} />} isActive to="/categories" />
          {active.map(cat => (
            <CategoryMenuItem key={cat.id} label={cat.name} icon={<Tag size={18} />} to={`/products?category=${cat.id}`} />
          ))}
        </div>

        {/* Promo Card */}
        <div className="mt-8 p-6 bg-gradient-to-br from-[#FF6B2C] to-[#A166FF] rounded-2xl text-white relative overflow-hidden group">
           <div className="relative z-10">
              <div className="w-10 h-10 bg-white/20 rounded-full flex items-center justify-center mb-4">
                 <ShieldAlert size={20} />
              </div>
              <h3 className="text-lg font-black mb-2">Best Deals <br />Just For You!</h3>
              <p className="text-[11px] font-bold opacity-80 mb-6">Explore top offers across all categories and save big.</p>
              <Link to="/offers" className="inline-block bg-white text-[#FF6B2C] px-6 py-2.5 rounded-xl text-xs font-black shadow-lg hover:scale-105 transition-all">
                 View Offers
              </Link>
           </div>
           {/* Decorative */}
           <div className="absolute -bottom-4 -right-4 w-20 h-20 bg-white/10 rounded-full blur-xl group-hover:scale-150 transition-transform duration-700"></div>
        </div>
      </div>
    </aside>
  );
};

export default CategorySidebar;
