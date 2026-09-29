import React from 'react';
import { Link } from 'react-router-dom';
import { ShoppingBag, Check } from 'lucide-react';
import { useStore } from '../../context/StoreContext';

interface SuggestedProductItemProps {
  id: string;
  image: string;
  name: string;
  price: number;
  oldPrice?: number;
  brand?: string;
  category?: string;
}

const SuggestedProductItem: React.FC<SuggestedProductItemProps> = ({ id, image, name, price, oldPrice = 0, brand = '', category = '' }) => {
  const { addToCart, isInCart } = useStore();
  const added = isInCart(id);

  const handleAdd = () => {
    addToCart({ id, name, img: image, price, oldPrice, brand, category, qty: 1 });
  };

  return (
    <div className="flex items-center gap-4 py-4 border-b border-[#F8F7FC] last:border-0 group">
      <Link to={`/product/${id}`} className="w-16 h-16 bg-[#F8F7FC] rounded-xl overflow-hidden border border-[#ECECEC] flex items-center justify-center p-2 shrink-0 group-hover:scale-105 transition-transform duration-500">
        <img src={image} alt={name} className="w-full h-full object-contain" />
      </Link>
      <div className="flex-1 min-w-0">
        <Link to={`/product/${id}`} className="block text-[11px] font-black text-[#111827] truncate mb-1 hover:text-[#FF6B2C]">{name}</Link>
        <div className="flex items-center justify-between">
          <span className="text-xs font-black text-[#FF6B2C]">₹{price.toLocaleString()}</span>
          <button
            type="button"
            onClick={handleAdd}
            aria-label={added ? 'Added to cart' : `Add ${name} to cart`}
            title={added ? 'Added to cart' : 'Add to cart'}
            className={`p-1.5 rounded-lg transition-all ${added ? 'bg-green-500 text-white' : 'bg-[#FF6B2C]/5 text-[#FF6B2C] hover:bg-[#FF6B2C] hover:text-white'}`}
          >
            {added ? <Check size={14} /> : <ShoppingBag size={14} />}
          </button>
        </div>
      </div>
    </div>
  );
};

export default SuggestedProductItem;
