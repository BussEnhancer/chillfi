import React from 'react';
import { Crown, Gift, ChevronRight } from 'lucide-react';

const PremiumBanner: React.FC = () => {
  return (
    <div className="bg-gradient-to-br from-[#FF6B2C] to-[#8B5CFF] rounded-[24px] p-8 text-white relative overflow-hidden group flex flex-col justify-between">
      {/* Background Decor */}
      <div className="pointer-events-none absolute -top-10 -right-10 w-40 h-40 bg-white/10 rounded-full blur-3xl group-hover:scale-150 transition-transform duration-1000"></div>

      <div className="relative z-10">
        <div className="flex items-center gap-3 mb-4">
          <div className="w-10 h-10 bg-white/20 backdrop-blur-md rounded-xl flex items-center justify-center">
            <Crown size={24} className="text-white" />
          </div>
          <h3 className="text-2xl font-black tracking-tight">ChillFi <span className="opacity-80">Premium</span></h3>
        </div>

        <p className="text-sm font-bold text-white/80 leading-relaxed mb-10 max-w-[200px]">
          You are enjoying FREE delivery, exclusive offers and more!
        </p>

        <button className="bg-white text-[#FF6B2C] px-6 py-3 rounded-xl font-black text-xs flex items-center gap-2 hover:shadow-2xl hover:scale-105 transition-all">
          View Premium Benefits
          <ChevronRight size={14} />
        </button>
      </div>

      {/* Illustration Area */}
      <div className="absolute right-0 bottom-0 p-6 opacity-30 group-hover:opacity-100 transition-opacity duration-700">
        <div className="relative">
           <Gift size={120} className="text-white transform rotate-12" />
           <div className="absolute -top-4 -right-2 w-8 h-8 bg-white rounded-lg flex items-center justify-center text-[#FF6B2C] shadow-lg animate-bounce">
              <Crown size={16} />
           </div>
        </div>
      </div>
    </div>
  );
};

export default PremiumBanner;
