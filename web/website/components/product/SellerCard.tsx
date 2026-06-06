import React from 'react';
import { BadgeCheck, RotateCcw, ShieldCheck } from 'lucide-react';

const SellerCard: React.FC = () => {
  return (
    <div className="bg-white rounded-2xl border border-[#ECECEC] p-6 mb-8">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-3">
          <div className="flex flex-col">
             <span className="text-[10px] font-bold text-gray-400 uppercase tracking-widest mb-1">Sold by</span>
             <div className="flex items-center gap-2">
                <span className="text-sm font-black text-[#111827]">chillFi Retail</span>
                <BadgeCheck size={16} className="text-[#6C2BFF]" />
             </div>
          </div>
        </div>
        <div className="bg-green-50 px-3 py-1 rounded-lg">
           <span className="text-xs font-black text-green-600">4.6 ★</span>
        </div>
      </div>

      <div className="space-y-4 pt-6 border-t border-dashed border-[#ECECEC]">
         <div className="flex items-center gap-3">
            <div className="w-8 h-8 rounded-lg bg-gray-50 flex items-center justify-center text-gray-400">
               <RotateCcw size={16} />
            </div>
            <div>
               <h4 className="text-[11px] font-black text-[#111827] uppercase tracking-wider">7 Days Easy Returns</h4>
               <p className="text-[10px] font-bold text-gray-400">Change of mind is not applicable</p>
            </div>
         </div>
         <div className="flex items-center gap-3">
            <div className="w-8 h-8 rounded-lg bg-gray-50 flex items-center justify-center text-gray-400">
               <ShieldCheck size={16} />
            </div>
            <div>
               <h4 className="text-[11px] font-black text-[#111827] uppercase tracking-wider">1 Year Warranty</h4>
               <p className="text-[10px] font-bold text-gray-400">Brand Warranty of 1 Year</p>
            </div>
         </div>
      </div>
    </div>
  );
};

export default SellerCard;
