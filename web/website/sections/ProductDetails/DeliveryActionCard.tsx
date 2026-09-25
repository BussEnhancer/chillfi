import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { MapPin, Truck, ShieldCheck, Heart, ShoppingCart, Zap, CheckCircle2 } from 'lucide-react';
import { useStore } from '../../context/StoreContext';
import { CartItem } from '../../context/StoreContext';
import { useAppConfig, freeDeliveryText } from '../../utils/useAppConfig';

interface DeliveryActionCardProps {
  product?: {
    id: string;
    name: string;
    price: number;
    oldPrice: number;
    stock: number;
    img: string;
    brand: string;
    category: string;
  };
  isWishlisted?: boolean;
  onWishlistToggle?: () => void;
}

const DeliveryActionCard: React.FC<DeliveryActionCardProps> = ({
  product,
  isWishlisted = false,
  onWishlistToggle,
}) => {
  const cfg = useAppConfig();
  const { addToCart, cart } = useStore();
  const navigate = useNavigate();
  const [added, setAdded] = useState(false);

  const inCart = product ? cart.some(i => i.id === product.id) : false;

  const handleAddToCart = () => {
    if (!product || product.stock === 0) return;
    const item: CartItem = {
      id: product.id,
      name: product.name,
      img: product.img,
      price: product.price,
      oldPrice: product.oldPrice,
      brand: product.brand,
      category: product.category,
      qty: 1,
    };
    addToCart(item);
    setAdded(true);
    setTimeout(() => setAdded(false), 2000);
  };

  const outOfStock = product ? product.stock === 0 : false;

  return (
    <div className="sticky top-32 space-y-6">
      <div className="bg-white rounded-[24px] border border-[#ECECEC] p-6 shadow-sm">
        {/* Delivery */}
        <div className="flex items-center justify-between mb-6">
          <div className="flex items-center gap-2">
            <MapPin size={18} className="text-[#FF6B2C]" />
            <span className="text-[11px] font-bold text-gray-500 uppercase tracking-wider">Delivery</span>
          </div>
          <div className="flex items-center gap-3">
            <span className="text-sm font-black text-[#111827]">Across India</span>
          </div>
        </div>

        <div className="space-y-4 mb-8">
          <div className="flex items-start gap-3">
            <Truck size={20} className="text-gray-400 mt-0.5" />
            <div>
              <p className="text-sm font-black text-[#111827]">{cfg?.max_delivery_days ? `Delivery in up to ${cfg.max_delivery_days} days` : 'Standard Delivery via Delhivery'}</p>
              <p className="text-[11px] font-bold text-green-600">{cfg && !cfg.free_shipping_enabled ? freeDeliveryText(cfg) : freeDeliveryText(cfg, 'FREE Delivery on orders above')}</p>
            </div>
          </div>
        </div>

        {outOfStock && (
          <div className="bg-red-50 text-red-600 text-xs font-black uppercase tracking-widest px-4 py-3 rounded-xl border border-red-100 mb-6 text-center">
            Out of Stock
          </div>
        )}

        {product && !outOfStock && (
          <p className="text-[11px] font-bold text-green-600 mb-4">
            ✓ {product.stock} units in stock
          </p>
        )}

        <div className="space-y-3 pt-4 border-t border-[#F8F7FC] mb-8">
          {[
            { icon: <ShieldCheck size={16} />, text: '100% Original Products' },
            { icon: <Zap size={16} />, text: 'Secure & Easy Payments' },
          ].map((item, i) => (
            <div key={i} className="flex items-center gap-3 text-[11px] font-bold text-gray-500">
              <span className="text-[#FF6B2C]">{item.icon}</span>
              {item.text}
            </div>
          ))}
        </div>

        <div className="space-y-4">
          <button
            onClick={inCart ? () => navigate('/cart') : handleAddToCart}
            disabled={outOfStock}
            className={`w-full py-4 rounded-xl font-black flex items-center justify-center gap-3 shadow-xl transition-all ${
              added
                ? 'bg-green-500 text-white shadow-green-500/20'
                : outOfStock
                ? 'bg-gray-100 text-gray-400 cursor-not-allowed shadow-none'
                : inCart
                ? 'bg-green-600 text-white shadow-green-600/20 hover:scale-[1.02] active:scale-[0.98]'
                : 'bg-[#FF6B2C] text-white shadow-[#FF6B2C]/20 hover:scale-[1.02] active:scale-[0.98]'
            }`}
          >
            {added ? (
              <><CheckCircle2 size={20} />Added to Cart!</>
            ) : inCart ? (
              <><ShoppingCart size={20} />Go to Cart</>
            ) : (
              <><ShoppingCart size={20} />Add To Cart</>
            )}
          </button>

          <button
            onClick={onWishlistToggle}
            className={`w-full border-2 py-4 rounded-xl font-black flex items-center justify-center gap-3 transition-all ${
              isWishlisted
                ? 'border-red-400 text-red-500 bg-red-50'
                : 'border-[#ECECEC] text-gray-700 hover:border-gray-400'
            }`}
          >
            <Heart size={20} className={isWishlisted ? 'fill-red-500' : ''} />
            {isWishlisted ? 'Wishlisted' : 'Add To Wishlist'}
          </button>
        </div>
      </div>
    </div>
  );
};

export default DeliveryActionCard;
