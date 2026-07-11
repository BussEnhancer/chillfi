import React from 'react';
import { Truck, Zap } from 'lucide-react';

interface DeliveryOptionCardProps {
  type: 'Standard' | 'Express';
  duration: string;
  price: number | 'FREE';
  oldPrice?: number;
  isSelected?: boolean;
}

const DeliveryOptionCard: React.FC<DeliveryOptionCardProps> = ({ type, duration, price, oldPrice, isSelected }) => {
  return (
    <div
      className={`flex-1 flex items-center gap-6 p-6 rounded-[24px] border-2 transition-all cursor-pointer ${
        isSelected ? 'border-[#FF6B2C] bg-[#FF6B2C]/5' : 'border-[#ECECEC] bg-white hover:border-gray-300'
      }`}
    >
      <div className={`w-6 h-6 rounded-full border-2 flex items-center justify-center ${
        isSelected ? 'border-[#FF6B2C]' : 'border-gray-200'
      }`}>
        {isSelected && <div className="w-3 h-3 rounded-full bg-[#FF6B2C]"></div>}
      </div>

      <div className={`w-14 h-14 rounded-2xl flex items-center justify-center ${
        isSelected ? 'bg-[#FF6B2C] text-white' : 'bg-gray-50 text-gray-400'
      }`}>
        {type === 'Standard' ? <Truck size={28} /> : <Zap size={28} />}
      </div>

      <div className="flex-1">
        <h4 className="text-sm font-black text-[#111827] mb-1">{type} Delivery</h4>
        <p className="text-xs font-bold text-gray-400">{duration}</p>
      </div>

      <div className="text-right">
        <span className={`text-sm font-black ${price === 'FREE' ? 'text-[#16A34A]' : 'text-[#111827]'}`}>
          {price === 'FREE' ? 'FREE' : `₹${price}`}
        </span>
        {oldPrice && <p className="text-[10px] text-gray-400 line-through font-bold">₹{oldPrice}</p>}
      </div>
    </div>
  );
};

export default DeliveryOptionCard;
