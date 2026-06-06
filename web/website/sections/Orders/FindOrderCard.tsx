import React from 'react';
import { Search } from 'lucide-react';

const FindOrderCard: React.FC = () => {
  return (
    <div className="bg-[#F8F5FF] rounded-[24px] border border-[#ECECEC] p-6 shadow-sm relative overflow-hidden group">
      <div className="relative z-10">
        <h3 className="text-sm font-black text-[#111827] uppercase tracking-wider mb-2">Can't find your order?</h3>
        <p className="text-[11px] font-bold text-gray-400 mb-6">Search your order using email <br /> or phone number</p>
        <button className="w-full bg-white border-2 border-[#6C2BFF] text-[#6C2BFF] py-3 rounded-xl font-black text-xs hover:bg-[#6C2BFF] hover:text-white transition-all shadow-sm">
          Find My Order
        </button>
      </div>

      {/* Decorative Icon */}
      <div className="absolute -bottom-2 -right-2 opacity-10 group-hover:scale-110 transition-transform duration-500">
         <Search size={100} className="text-[#6C2BFF]" />
      </div>
    </div>
  );
};

export default FindOrderCard;
