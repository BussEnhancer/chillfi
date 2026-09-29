import React from 'react';
import { Link } from 'react-router-dom';
import { Star, Heart, ShoppingCart, Check } from 'lucide-react';
import Badge from '../common/Badge';
import { useStore } from '../../context/StoreContext';

interface ProductCardPLPProps {
  id?: string | number;
  image: string;
  name: string;
  brand: string;
  category?: string;
  price: number;
  oldPrice?: number;
  discount?: string;
  rating: number;
  reviews: number;
  colors?: number;
  isBestSeller?: boolean;
}

const ProductCardPLP: React.FC<ProductCardPLPProps> = ({
  id = 1, image, name, brand, category = '', price, oldPrice, discount, rating, reviews, colors, isBestSeller
}) => {
  const { addToCart, toggleWishlist, isInWishlist, isInCart } = useStore();
  const inWish = isInWishlist(String(id));
  const inCart = isInCart(String(id));

  const handleAddToCart = (e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();
    addToCart({ id: String(id), name, img: image, price, oldPrice: oldPrice || 0, brand, category, qty: 1 });
  };

  const handleWishlist = (e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();
    toggleWishlist({ id: String(id), name, img: image, price, oldPrice: oldPrice || 0, brand, category, rating, reviews, stock: 99, status: 'Active', description: '' });
  };

  return (
    <div className="bg-white rounded-[20px] p-4 border border-[#ECECEC] group hover:shadow-2xl hover:border-[#FF6B2C]/20 transition-all duration-500 relative flex flex-col h-full">
      {/* Top Action Bar */}
      <div className="absolute top-4 left-4 right-4 flex justify-between items-start z-10">
        <div className="flex flex-col gap-2">
           {discount && <Badge text={discount} className="bg-[#FF4D4F]" />}
           {isBestSeller && <Badge text="Best Seller" className="bg-[#FF6B2C]" />}
        </div>
        <button
          onClick={handleWishlist}
          className={`w-8 h-8 bg-white/80 backdrop-blur-sm shadow-sm rounded-full flex items-center justify-center transition-all ${inWish ? 'text-[#FF4D4F]' : 'text-gray-400 hover:text-[#FF4D4F]'} hover:bg-white`}
        >
          <Heart size={16} className={inWish ? 'fill-current' : ''} />
        </button>
      </div>

      {/* Image + Info → navigate to product detail */}
      <Link to={`/product/${id}`} className="flex flex-col flex-1">
        {/* Image Container */}
        <div className="aspect-square rounded-2xl bg-[#F8F7FC] mb-4 overflow-hidden relative flex items-center justify-center">
          <img src={image} alt={name} className="w-[85%] h-[85%] object-contain group-hover:scale-110 transition-transform duration-700" />
        </div>

        {/* Info Section */}
        <div className="flex flex-col flex-1">
          <div className="flex items-center justify-between mb-1">
            <span className="text-[10px] font-black uppercase tracking-widest text-[#FF6B2C]">{brand}</span>
            <div className="flex items-center gap-1">
              <Star size={10} className="fill-yellow-400 text-yellow-400" />
              <span className="text-[10px] font-black text-[#111827]">{rating} <span className="text-gray-400">({reviews})</span></span>
            </div>
          </div>

          <h3 className="text-sm font-bold text-[#111827] line-clamp-1 mb-3 group-hover:text-[#FF6B2C] transition-colors">{name}</h3>

          <div className="flex items-baseline gap-2 mb-4">
            <span className="text-lg font-black text-[#111827]">₹{price.toLocaleString()}</span>
            {oldPrice && <span className="text-xs text-gray-400 line-through font-bold">₹{oldPrice.toLocaleString()}</span>}
          </div>

          {colors && (
            <div className="mb-4">
               <span className="text-[10px] font-black text-[#16A34A] uppercase tracking-wider">{colors} Colors Available</span>
            </div>
          )}
        </div>
      </Link>

      {/* Add to Cart — separate from Link, no navigation */}
      <button
        onClick={handleAddToCart}
        className={`mt-auto w-full border-2 py-2.5 rounded-xl font-black text-xs flex items-center justify-center gap-2 transition-all active:scale-95 ${
          inCart
            ? 'bg-green-500 border-green-500 text-white'
            : 'border-[#FF6B2C] text-[#FF6B2C] hover:bg-[#FF6B2C] hover:text-white'
        }`}
      >
        {inCart ? <Check size={14} /> : <ShoppingCart size={14} />}
        {inCart ? 'Added to Cart' : 'Add To Cart'}
      </button>
    </div>
  );
};

export default ProductCardPLP;
