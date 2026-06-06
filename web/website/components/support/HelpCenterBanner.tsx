import React from 'react';
import { HelpCircle, ChevronRight } from 'lucide-react';

const HelpCenterBanner: React.FC = () => {
  return (
    <div className="bg-[#F8F5FF] rounded-[32px] p-8 md:p-10 border border-[#ECECEC] flex flex-col md:flex-row items-center justify-between gap-8 group mt-16 mb-20">
      <div className="flex items-center gap-6">
        <div className="w-16 h-16 bg-white rounded-2xl flex items-center justify-center text-[#6C2BFF] shadow-sm group-hover:scale-110 transition-transform">
          <HelpCircle size={32} />
        </div>
        <div>
          <h3 className="text-xl font-black text-[#111827] mb-1">Have questions?</h3>
          <p className="text-sm font-bold text-gray-400">Check out our Help Center for answers to common questions.</p>
        </div>
      </div>
      <button className="bg-white border-2 border-[#6C2BFF] text-[#6C2BFF] px-10 py-4 rounded-2xl font-black text-sm uppercase tracking-widest hover:bg-[#6C2BFF] hover:text-white transition-all shadow-sm flex items-center gap-2">
        Visit Help Center
        <ChevronRight size={18} />
      </button>
    </div>
  );
};

export default HelpCenterBanner;
