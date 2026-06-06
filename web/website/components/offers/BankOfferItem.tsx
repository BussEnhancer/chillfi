import React from 'react';
import { ChevronRight } from 'lucide-react';

interface BankOfferItemProps {
  bankLogo: string;
  bankName: string;
  offer: string;
  condition: string;
}

const BankOfferItem: React.FC<BankOfferItemProps> = ({ bankLogo, bankName, offer, condition }) => {
  return (
    <div className="flex items-center gap-4 py-4 border-b border-[#F8F5FF] last:border-0 group cursor-pointer">
      <div className="w-10 h-10 bg-white rounded-xl border border-[#ECECEC] flex items-center justify-center p-1.5 shrink-0 shadow-sm group-hover:border-[#6C2BFF]/30 transition-all">
        <img src={bankLogo} alt={bankName} className="w-full h-full object-contain" />
      </div>
      <div className="flex-1 min-w-0">
        <h5 className="text-[11px] font-black text-gray-400 uppercase tracking-widest mb-0.5">{bankName}</h5>
        <h4 className="text-[12px] font-black text-[#111827] truncate mb-0.5">{offer}</h4>
        <p className="text-[10px] font-bold text-gray-400 truncate">{condition}</p>
      </div>
      <ChevronRight size={14} className="text-gray-300 group-hover:text-[#6C2BFF] group-hover:translate-x-1 transition-all" />
    </div>
  );
};

export default BankOfferItem;
