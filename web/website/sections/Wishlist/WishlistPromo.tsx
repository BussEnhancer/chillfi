import React from 'react';
import { ShoppingBag, ChevronRight } from 'lucide-react';

const WishlistPromo: React.FC = () => {
  return (
    <div className="bg-gradient-to-br from-[#6C2BFF] to-[#8B5CFF] rounded-[24px] p-8 text-white relative overflow-hidden group">
      {/* Background Decor */}
      <div className="absolute -top-10 -right-10 w-32 h-32 bg-white/10 rounded-full blur-2xl group-hover:scale-150 transition-transform duration-1000"></div>

      <div className="relative z-10">
        <h3 className="text-lg font-black uppercase tracking-tight mb-2 leading-tight">Don't wait too long!</h3>
        <p className="text-xs font-bold text-white/80 leading-relaxed mb-8 max-w-[200px]">
          Prices and availability may change. Move your favorites to bag now.
        </p>

        <button className="bg-white text-[#6C2BFF] px-6 py-2.5 rounded-xl font-black text-xs flex items-center gap-2 hover:shadow-2xl hover:scale-105 transition-all">
          Shop Now
          <ChevronRight size={14} />
        </button>
      </div>

      <div className="absolute right-0 bottom-0 p-4 opacity-30 group-hover:opacity-100 transition-opacity duration-700 pointer-events-none">
        <ShoppingBag size={100} className="text-white transform rotate-12" />
      </div>
    </div>
  );
};

export default WishlistPromo;
