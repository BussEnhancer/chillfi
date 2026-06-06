import React from 'react';
import { Trash2 } from 'lucide-react';
import QuantitySelector from '../common/QuantitySelector';
import Badge from '../common/Badge';

interface CartItemProps {
  image: string;
  name: string;
  size: string;
  color: string;
  price: number;
  oldPrice: number;
  discount: string;
  quantity: number;
  subtotal: number;
  isChecked?: boolean;
}

const CartItem: React.FC<CartItemProps> = ({
  image, name, size, color, price, oldPrice, discount, quantity, subtotal, isChecked = true
}) => {
  return (
    <div className="flex items-center py-6 border-b border-[#F8F7FC] group">
      {/* Checkbox */}
      <div className="w-12">
        <input
          type="checkbox"
          checked={isChecked}
          className="w-5 h-5 rounded border-[#ECECEC] text-[#6C2BFF] focus:ring-[#6C2BFF]"
          readOnly
        />
      </div>

      {/* Product Info */}
      <div className="flex-1 flex items-center gap-6">
        <div className="w-24 h-24 bg-[#F8F7FC] rounded-2xl overflow-hidden flex items-center justify-center border border-[#ECECEC]">
          <img src={image} alt={name} className="w-[80%] h-[80%] object-contain" />
        </div>
        <div>
          <h3 className="text-sm font-black text-[#111827] mb-1 hover:text-[#6C2BFF] cursor-pointer transition-colors">{name}</h3>
          <div className="flex items-center gap-4 text-[11px] font-bold text-gray-400 uppercase tracking-widest mb-2">
            <span>Size: {size}</span>
            <span>Color: {color}</span>
          </div>
          <div className="flex items-center gap-2">
            <div className="w-1.5 h-1.5 rounded-full bg-green-500"></div>
            <span className="text-[10px] font-black text-green-500 uppercase tracking-widest">In Stock</span>
          </div>
        </div>
      </div>

      {/* Price */}
      <div className="w-40">
        <div className="flex flex-col">
          <span className="text-sm font-black text-[#111827]">₹{price.toLocaleString()}</span>
          <div className="flex items-center gap-2 mt-1">
            <span className="text-[10px] text-gray-400 line-through font-bold">₹{oldPrice.toLocaleString()}</span>
            <span className="text-[10px] font-black text-[#FF4D4F]">{discount} OFF</span>
          </div>
        </div>
      </div>

      {/* Quantity */}
      <div className="w-40">
        <QuantitySelector quantity={quantity} />
      </div>

      {/* Subtotal */}
      <div className="w-32">
        <span className="text-sm font-black text-[#111827]">₹{subtotal.toLocaleString()}</span>
      </div>

      {/* Actions */}
      <div className="w-12 flex justify-end">
        <button className="text-gray-300 hover:text-[#FF4D4F] transition-colors">
          <Trash2 size={20} />
        </button>
      </div>
    </div>
  );
};

export default CartItem;
