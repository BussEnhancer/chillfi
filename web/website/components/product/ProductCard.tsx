import React from 'react';
import Badge from '../common/Badge';
import { Star, ShoppingCart, Heart } from 'lucide-react';

interface ProductCardProps {
  image: string;
  name: string;
  price: number;
  oldPrice?: number;
  discount?: string;
  rating: number;
  reviews: number;
}

const ProductCard: React.FC<ProductCardProps> = ({
  image, name, price, oldPrice, discount, rating, reviews
}) => {
  return (
    <div className="bg-white rounded-2xl border border-gray-100 p-4 relative group hover:shadow-2xl hover:border-[#6C2BFF]/30 transition-all duration-500">
      {/* Badges */}
      {discount && (
        <Badge text={discount} className="absolute top-4 left-4 z-10" />
      )}

      {/* Actions */}
      <div className="absolute top-4 right-4 flex flex-col gap-2 z-10 opacity-0 group-hover:opacity-100 transition-all duration-300 translate-x-4 group-hover:translate-x-0">
        <button className="w-9 h-9 bg-white shadow-md rounded-full flex items-center justify-center text-gray-400 hover:text-[#FF5252] transition-colors">
          <Heart size={18} />
        </button>
        <button className="w-9 h-9 bg-white shadow-md rounded-full flex items-center justify-center text-gray-400 hover:text-[#6C2BFF] transition-colors">
          <ShoppingCart size={18} />
        </button>
      </div>

      {/* Image */}
      <div className="aspect-square rounded-xl overflow-hidden mb-4 bg-gray-50">
        <img src={image} alt={name} className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-700" />
      </div>

      {/* Content */}
      <h3 className="font-bold text-gray-900 text-sm mb-2 line-clamp-2 min-h-[40px] group-hover:text-[#6C2BFF] transition-colors">
        {name}
      </h3>

      <div className="flex items-center gap-1 mb-3">
        <div className="flex items-center text-yellow-400">
          {[...Array(5)].map((_, i) => (
            <Star key={i} size={12} fill={i < Math.floor(rating) ? "currentColor" : "none"} />
          ))}
        </div>
        <span className="text-[11px] text-gray-400 font-bold">({reviews})</span>
      </div>

      <div className="flex items-center gap-3">
        <span className="text-lg font-extrabold text-[#6C2BFF]">₹{price.toLocaleString()}</span>
        {oldPrice && (
          <span className="text-xs text-gray-400 line-through font-medium">₹{oldPrice.toLocaleString()}</span>
        )}
      </div>
    </div>
  );
};

export default ProductCard;
