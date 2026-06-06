import React from 'react';
import { ShoppingBag, Trash2, X } from 'lucide-react';

interface WishlistItemCardProps {
  image: string;
  name: string;
  size?: string;
  color?: string;
  addedDate: string;
  price: number;
  stockStatus: 'In Stock' | 'Low Stock' | 'Out of Stock';
  stockCount?: number;
  isChecked?: boolean;
}

const WishlistItemCard: React.FC<WishlistItemCardProps> = ({
  image, name, size, color, addedDate, price, stockStatus, stockCount, isChecked = false
}) => {
  return (
    <div className="bg-white rounded-[20px] p-6 border border-[#ECECEC] hover:shadow-xl hover:border-[#6C2BFF]/10 transition-all group relative mb-4">
      <button className="absolute top-4 right-4 text-gray-300 hover:text-[#FF4D4F] transition-colors">
        <X size={18} />
      </button>

      <div className="flex flex-col md:flex-row items-center gap-6">
        {/* Checkbox & Image */}
        <div className="flex items-center gap-4 w-full md:w-auto">
          <input
            type="checkbox"
            checked={isChecked}
            className="w-5 h-5 rounded border-[#ECECEC] text-[#6C2BFF] focus:ring-[#6C2BFF]"
            readOnly
          />
          <div className="w-24 h-24 bg-[#F8F7FC] rounded-2xl overflow-hidden flex items-center justify-center border border-[#ECECEC] shrink-0">
            <img src={image} alt={name} className="w-[80%] h-[80%] object-contain group-hover:scale-110 transition-transform duration-700" />
          </div>
        </div>

        {/* Product Info */}
        <div className="flex-1 min-w-0">
          <h3 className="text-sm font-black text-[#111827] mb-1 hover:text-[#6C2BFF] cursor-pointer transition-colors truncate">{name}</h3>
          <div className="flex flex-wrap items-center gap-4 text-[10px] font-bold text-gray-400 uppercase tracking-widest mb-2">
            {size && <span>Size: {size}</span>}
            {color && <span>Color: {color}</span>}
          </div>
          <p className="text-[10px] font-bold text-gray-400 uppercase tracking-widest">Added on {addedDate}</p>
        </div>

        {/* Price & Stock */}
        <div className="flex flex-col items-end gap-2 shrink-0">
          <span className="text-lg font-black text-[#111827]">₹{price.toLocaleString()}</span>
          <span className={`text-[10px] font-black uppercase tracking-widest ${
            stockStatus === 'In Stock' ? 'text-green-500' : 'text-amber-500'
          }`}>
            {stockStatus === 'Low Stock' ? `Only ${stockCount} Left` : stockStatus}
          </span>
        </div>

        {/* Action Buttons */}
        <div className="flex items-center gap-3 w-full md:w-auto">
          <button className="flex-1 md:flex-none flex items-center justify-center gap-2 bg-white border-2 border-[#6C2BFF] text-[#6C2BFF] px-6 py-2.5 rounded-xl font-black text-[11px] uppercase tracking-widest hover:bg-[#6C2BFF] hover:text-white transition-all whitespace-nowrap">
            <ShoppingBag size={14} />
            Move to Bag
          </button>
          <button className="flex items-center justify-center gap-2 text-gray-400 hover:text-[#FF4D4F] font-black text-[11px] uppercase tracking-widest transition-colors px-4 py-2.5">
            <Trash2 size={16} />
            Remove
          </button>
        </div>
      </div>
    </div>
  );
};

export default WishlistItemCard;
