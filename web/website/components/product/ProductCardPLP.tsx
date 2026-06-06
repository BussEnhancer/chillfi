import React from 'react';
import { Star, Heart, ShoppingCart } from 'lucide-react';
import Badge from '../common/Badge';

interface ProductCardPLPProps {
  image: string;
  name: string;
  brand: string;
  price: number;
  oldPrice?: number;
  discount?: string;
  rating: number;
  reviews: number;
  colors?: number;
  isBestSeller?: boolean;
}

const ProductCardPLP: React.FC<ProductCardPLPProps> = ({
  image, name, brand, price, oldPrice, discount, rating, reviews, colors, isBestSeller
}) => {
  return (
    <div className="bg-white rounded-[20px] p-4 border border-[#ECECEC] group hover:shadow-2xl hover:border-[#6C2BFF]/20 transition-all duration-500 relative flex flex-col h-full">
      {/* Top Action Bar */}
      <div className="absolute top-4 left-4 right-4 flex justify-between items-start z-10">
        <div className="flex flex-col gap-2">
           {discount && <Badge text={discount} className="bg-[#FF4D4F]" />}
           {isBestSeller && <Badge text="Best Seller" className="bg-[#6C2BFF]" />}
        </div>
        <button className="w-8 h-8 bg-white/80 backdrop-blur-sm shadow-sm rounded-full flex items-center justify-center text-gray-400 hover:text-[#FF4D4F] hover:bg-white transition-all">
          <Heart size={16} />
        </button>
      </div>

      {/* Image Container */}
      <div className="aspect-square rounded-2xl bg-[#F8F7FC] mb-4 overflow-hidden relative flex items-center justify-center">
        <img src={image} alt={name} className="w-[85%] h-[85%] object-contain group-hover:scale-110 transition-transform duration-700" />
      </div>

      {/* Info Section */}
      <div className="flex flex-col flex-1">
        <div className="flex items-center justify-between mb-1">
          <span className="text-[10px] font-black uppercase tracking-widest text-[#6C2BFF]">{brand}</span>
          <div className="flex items-center gap-1">
            <Star size={10} className="fill-yellow-400 text-yellow-400" />
            <span className="text-[10px] font-black text-[#111827]">{rating} <span className="text-gray-400">({reviews})</span></span>
          </div>
        </div>

        <h3 className="text-sm font-bold text-[#111827] line-clamp-1 mb-3 group-hover:text-[#6C2BFF] transition-colors">{name}</h3>

        <div className="flex items-baseline gap-2 mb-4">
          <span className="text-lg font-black text-[#111827]">₹{price.toLocaleString()}</span>
          {oldPrice && <span className="text-xs text-gray-400 line-through font-bold">₹{oldPrice.toLocaleString()}</span>}
        </div>

        {colors && (
          <div className="mb-4">
             <span className="text-[10px] font-black text-[#16A34A] uppercase tracking-wider">{colors} Colors Available</span>
          </div>
        )}

        {/* Action Button */}
        <button className="mt-auto w-full border-2 border-[#6C2BFF] text-[#6C2BFF] py-2.5 rounded-xl font-black text-xs flex items-center justify-center gap-2 hover:bg-[#6C2BFF] hover:text-white transition-all active:scale-95">
          <ShoppingCart size={14} />
          Add To Cart
        </button>
      </div>
    </div>
  );
};

export default ProductCardPLP;
