import React from 'react';
import { Heart, ShoppingBag, CircleDollarSign } from 'lucide-react';

const WishlistSummary: React.FC = () => {
  return (
    <div className="bg-white rounded-[24px] border border-[#ECECEC] p-6 shadow-sm">
      <h3 className="text-sm font-black text-[#111827] uppercase tracking-wider mb-6 pb-4 border-b border-[#F8F5FF]">Wishlist Summary</h3>
      <div className="space-y-5">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <Heart size={16} className="text-gray-400" />
            <span className="text-sm font-bold text-gray-500">Total Items</span>
          </div>
          <span className="text-sm font-black text-[#111827]">12</span>
        </div>
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <CircleDollarSign size={16} className="text-gray-400" />
            <span className="text-sm font-bold text-gray-500">Total Value</span>
          </div>
          <span className="text-sm font-black text-[#111827]">₹13,292</span>
        </div>
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <ShoppingBag size={16} className="text-gray-400" />
            <span className="text-sm font-bold text-gray-500">Items in Bag</span>
          </div>
          <span className="text-sm font-black text-amber-500">0</span>
        </div>
      </div>
    </div>
  );
};

export default WishlistSummary;
