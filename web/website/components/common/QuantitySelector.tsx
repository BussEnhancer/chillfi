import React from 'react';
import { Minus, Plus } from 'lucide-react';

interface QuantitySelectorProps {
  quantity?: number;
}

const QuantitySelector: React.FC<QuantitySelectorProps> = ({ quantity = 1 }) => {
  return (
    <div className="flex items-center gap-4 bg-[#F8F7FC] border border-[#ECECEC] rounded-xl px-3 py-2 w-fit">
      <button className="text-gray-400 hover:text-[#6C2BFF] transition-colors">
        <Minus size={14} />
      </button>
      <span className="text-sm font-black text-[#111827] min-w-[20px] text-center">{quantity}</span>
      <button className="text-gray-400 hover:text-[#6C2BFF] transition-colors">
        <Plus size={14} />
      </button>
    </div>
  );
};

export default QuantitySelector;
