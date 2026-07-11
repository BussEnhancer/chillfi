import React from 'react';
import { Trash2, Heart, RotateCcw } from 'lucide-react';

const CartActionBar: React.FC = () => {
  return (
    <div className="flex items-center justify-between py-6">
      <div className="flex items-center gap-8">
        <label className="flex items-center gap-3 cursor-pointer group">
          <input
            type="checkbox"
            checked
            className="w-5 h-5 rounded border-[#ECECEC] text-[#FF6B2C] focus:ring-[#FF6B2C]"
            readOnly
          />
          <span className="text-xs font-black text-[#111827] uppercase tracking-widest">Select All (4)</span>
        </label>

        <div className="flex items-center gap-6">
          <button className="flex items-center gap-2 text-[11px] font-black text-gray-400 uppercase tracking-widest hover:text-[#FF4D4F] transition-colors">
            <Trash2 size={16} />
            Remove Selected
          </button>
          <button className="flex items-center gap-2 text-[11px] font-black text-gray-400 uppercase tracking-widest hover:text-[#FF6B2C] transition-colors">
            <Heart size={16} />
            Move to Wishlist
          </button>
        </div>
      </div>

      <button className="flex items-center gap-2 text-[11px] font-black text-[#FF4D4F] uppercase tracking-widest hover:underline">
        <RotateCcw size={16} />
        Clear Cart
      </button>
    </div>
  );
};

export default CartActionBar;
