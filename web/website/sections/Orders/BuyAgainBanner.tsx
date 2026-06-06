import React from 'react';
import { ShoppingBag, ChevronRight } from 'lucide-react';

const BuyAgainBanner: React.FC = () => {
  return (
    <div className="bg-gradient-to-br from-[#6C2BFF] to-[#8B5CFF] rounded-[24px] p-6 text-white relative overflow-hidden group">
      <div className="relative z-10">
        <h3 className="text-sm font-black uppercase tracking-wider mb-2">You love it, buy it again!</h3>
        <p className="text-[11px] font-bold opacity-80 mb-6 max-w-[180px]">Reorder your favourite products in just one click.</p>
        <button className="bg-white text-[#6C2BFF] px-6 py-2.5 rounded-xl font-black text-xs flex items-center gap-2 hover:shadow-lg hover:scale-105 transition-all">
          Buy Again
          <ChevronRight size={14} />
        </button>
      </div>

      {/* Decorative */}
      <div className="absolute -bottom-6 -right-6 p-4 opacity-20 group-hover:scale-125 transition-transform duration-700">
         <ShoppingBag size={120} className="text-white" />
      </div>
    </div>
  );
};

export default BuyAgainBanner;
