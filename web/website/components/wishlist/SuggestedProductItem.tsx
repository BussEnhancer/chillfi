import React from 'react';
import { ShoppingBag } from 'lucide-react';

interface SuggestedProductItemProps {
  image: string;
  name: string;
  price: number;
}

const SuggestedProductItem: React.FC<SuggestedProductItemProps> = ({ image, name, price }) => {
  return (
    <div className="flex items-center gap-4 py-4 border-b border-[#F8F7FC] last:border-0 group">
      <div className="w-16 h-16 bg-[#F8F7FC] rounded-xl overflow-hidden border border-[#ECECEC] flex items-center justify-center p-2 shrink-0 group-hover:scale-105 transition-transform duration-500">
        <img src={image} alt={name} className="w-full h-full object-contain" />
      </div>
      <div className="flex-1 min-w-0">
        <h5 className="text-[11px] font-black text-[#111827] truncate mb-1">{name}</h5>
        <div className="flex items-center justify-between">
          <span className="text-xs font-black text-[#FF6B2C]">₹{price.toLocaleString()}</span>
          <button className="bg-[#FF6B2C]/5 text-[#FF6B2C] p-1.5 rounded-lg hover:bg-[#FF6B2C] hover:text-white transition-all">
            <ShoppingBag size={14} />
          </button>
        </div>
      </div>
    </div>
  );
};

export default SuggestedProductItem;
