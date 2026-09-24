import React from 'react';
import { Heart, ShoppingBag, CircleDollarSign } from 'lucide-react';

interface WishlistSummaryProps {
  totalItems: number;
  totalValue: number;
  itemsInBag: number;
}

const WishlistSummary: React.FC<WishlistSummaryProps> = ({ totalItems, totalValue, itemsInBag }) => {
  return (
    <div className="bg-white rounded-[24px] border border-[#ECECEC] p-6 shadow-sm">
      <h3 className="text-sm font-black text-[#111827] uppercase tracking-wider mb-6 pb-4 border-b border-[#FFF8F5]">Wishlist Summary</h3>
      <div className="space-y-5">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <Heart size={16} className="text-gray-400" />
            <span className="text-sm font-bold text-gray-500">Total Items</span>
          </div>
          <span className="text-sm font-black text-[#111827]">{totalItems}</span>
        </div>
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <CircleDollarSign size={16} className="text-gray-400" />
            <span className="text-sm font-bold text-gray-500">Total Value</span>
          </div>
          <span className="text-sm font-black text-[#111827]">₹{totalValue.toLocaleString()}</span>
        </div>
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <ShoppingBag size={16} className="text-gray-400" />
            <span className="text-sm font-bold text-gray-500">Items in Bag</span>
          </div>
          <span className="text-sm font-black text-amber-500">{itemsInBag}</span>
        </div>
      </div>
    </div>
  );
};

export default WishlistSummary;
