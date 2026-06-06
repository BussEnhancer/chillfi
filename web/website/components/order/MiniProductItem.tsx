import React from 'react';

interface MiniProductItemProps {
  image: string;
  name: string;
  variant: string;
  qty: number;
  price: number;
}

const MiniProductItem: React.FC<MiniProductItemProps> = ({ image, name, variant, qty, price }) => {
  return (
    <div className="flex items-center gap-4 py-4 border-b border-[#F8F7FC] last:border-0">
      <div className="w-16 h-16 bg-[#F8F7FC] rounded-xl overflow-hidden border border-[#ECECEC] flex items-center justify-center p-2">
        <img src={image} alt={name} className="w-full h-full object-contain" />
      </div>
      <div className="flex-1 min-w-0">
        <h5 className="text-xs font-black text-[#111827] truncate mb-1">{name}</h5>
        <div className="flex items-center justify-between">
          <p className="text-[10px] font-bold text-gray-400 uppercase tracking-widest">{variant} • Qty: {qty}</p>
          <span className="text-xs font-black text-[#111827]">₹{price.toLocaleString()}</span>
        </div>
      </div>
    </div>
  );
};

export default MiniProductItem;
