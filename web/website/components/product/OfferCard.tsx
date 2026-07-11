import React from 'react';
import { Tag } from 'lucide-react';

interface OfferCardProps {
  title: string;
  desc: string;
}

const OfferCard: React.FC<OfferCardProps> = ({ title, desc }) => {
  return (
    <div className="flex-1 min-w-[200px] border border-[#ECECEC] rounded-xl p-4 bg-white hover:border-[#FF6B2C]/30 hover:shadow-lg transition-all cursor-pointer group">
      <div className="flex items-center gap-3 mb-2">
        <Tag size={16} className="text-[#FF6B2C]" />
        <span className="text-xs font-black text-[#111827]">{title}</span>
      </div>
      <p className="text-[11px] font-bold text-gray-500 mb-2 leading-tight">{desc}</p>
      <button className="text-[10px] font-black text-[#FF6B2C] uppercase tracking-widest hover:underline">T&C</button>
    </div>
  );
};

export default OfferCard;
