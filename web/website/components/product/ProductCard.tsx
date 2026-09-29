import React from 'react';
import { Link } from 'react-router-dom';
import Badge from '../common/Badge';
import { Star, ShoppingCart, Heart, Check } from 'lucide-react';
import { useStore } from '../../context/StoreContext';

interface ProductCardProps {
  id?: string | number;
  image: string;
  name: string;
  price: number;
  oldPrice?: number;
  discount?: string;
  rating: number;
  reviews: number;
}

const ProductCard: React.FC<ProductCardProps> = ({
  id = 1, image, name, price, oldPrice, discount, rating, reviews
}) => {
  const { addToCart, toggleWishlist, isInWishlist, isInCart, products } = useStore();
  const strId = String(id);
  const inWishlist = isInWishlist(strId);
  const added = isInCart(strId);

  const handleWishlist = (e: React.MouseEvent) => {
    e.preventDefault();
    const p = products.find(x => x.id === strId);
    if (p) toggleWishlist(p);
  };
  const handleCart = (e: React.MouseEvent) => {
    e.preventDefault();
    const p = products.find(x => x.id === strId);
    if (!p) return;
    addToCart(p);
  };

  return (
    <Link to={`/product/${id}`} className="block bg-white rounded-2xl border border-gray-100 p-4 relative group hover:shadow-2xl hover:border-[#FF6B2C]/30 transition-all duration-500">
      {discount && (
        <Badge text={discount} className="absolute top-4 left-4 z-10" />
      )}

      <div className="absolute top-4 right-4 flex flex-col gap-2 z-10 opacity-100 lg:opacity-0 lg:group-hover:opacity-100 transition-all duration-300 lg:translate-x-4 lg:group-hover:translate-x-0">
        <button onClick={handleWishlist} className={`w-9 h-9 bg-white shadow-md rounded-full flex items-center justify-center transition-colors ${inWishlist ? 'text-red-500' : 'text-gray-400 hover:text-red-500'}`}>
          <Heart size={18} fill={inWishlist ? 'currentColor' : 'none'} />
        </button>
        <button onClick={handleCart} className={`w-9 h-9 shadow-md rounded-full flex items-center justify-center transition-colors ${added ? 'bg-green-500 text-white' : 'bg-white text-gray-400 hover:text-[#FF6B2C]'}`}>
          {added ? <Check size={18} /> : <ShoppingCart size={18} />}
        </button>
      </div>

      {/* Image */}
      <div className="aspect-square rounded-xl overflow-hidden mb-4 bg-gray-50">
        <img src={image} alt={name} className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-700" />
      </div>

      {/* Content */}
      <h3 className="font-bold text-gray-900 text-sm mb-2 line-clamp-2 min-h-[40px] group-hover:text-[#FF6B2C] transition-colors">
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
        <span className="text-lg font-extrabold text-[#FF6B2C]">₹{price.toLocaleString()}</span>
        {oldPrice && (
          <span className="text-xs text-gray-400 line-through font-medium">₹{oldPrice.toLocaleString()}</span>
        )}
      </div>
    </Link>
  );
};

export default ProductCard;
