import React from 'react';
import { Tag, ChevronRight } from 'lucide-react';

const CouponCard: React.FC = () => {
  return (
    <div className="bg-white border-2 border-dashed border-[#FF6B2C]/20 rounded-2xl p-4 flex items-center justify-between cursor-pointer hover:border-[#FF6B2C]/50 transition-all group">
      <div className="flex items-center gap-4">
        <div className="w-10 h-10 bg-[#FF6B2C]/10 rounded-xl flex items-center justify-center text-[#FF6B2C]">
          <Tag size={20} />
        </div>
        <div>
          <h4 className="text-sm font-black text-[#111827]">Apply Coupon</h4>
          <p className="text-[11px] font-bold text-gray-400">Save extra with best offers</p>
        </div>
      </div>
      <ChevronRight size={20} className="text-gray-300 group-hover:text-[#FF6B2C] group-hover:translate-x-1 transition-all" />
    </div>
  );
};

export default CouponCard;
