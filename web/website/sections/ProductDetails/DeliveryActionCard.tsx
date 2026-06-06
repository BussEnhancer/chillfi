import React from 'react';
import { MapPin, Truck, ShieldCheck, Heart, ShoppingCart, Zap } from 'lucide-react';

const DeliveryActionCard: React.FC = () => {
  return (
    <div className="sticky top-32 space-y-6">
      <div className="bg-white rounded-[24px] border border-[#ECECEC] p-6 shadow-sm">
        {/* Pincode Section */}
        <div className="flex items-center justify-between mb-6">
          <div className="flex items-center gap-2">
            <MapPin size={18} className="text-[#6C2BFF]" />
            <span className="text-sm font-bold text-gray-500 uppercase tracking-wider text-[11px]">Delivery</span>
          </div>
          <div className="flex items-center gap-3">
             <span className="text-sm font-black text-[#111827]">560001</span>
             <button className="text-[11px] font-black text-[#6C2BFF] uppercase tracking-widest hover:underline">Change</button>
          </div>
        </div>

        <div className="space-y-4 mb-8">
          <div className="flex items-start gap-3">
            <Truck size={20} className="text-gray-400 mt-0.5" />
            <div>
              <p className="text-sm font-black text-[#111827]">Get it by Tomorrow, 19 May</p>
              <p className="text-[11px] font-bold text-green-600">FREE Delivery on orders above ₹499</p>
            </div>
          </div>
        </div>

        <div className="space-y-3 pt-6 border-t border-[#F8F7FC] mb-8">
           {[
             { icon: <ShieldCheck size={16} />, text: '100% Original Products' },
             { icon: <Zap size={16} />, text: 'Secure Payments' },
           ].map((item, i) => (
             <div key={i} className="flex items-center gap-3 text-[11px] font-bold text-gray-500">
                <span className="text-[#6C2BFF]">{item.icon}</span>
                {item.text}
             </div>
           ))}
        </div>

        {/* Primary Actions */}
        <div className="space-y-4">
          <button className="w-full bg-[#6C2BFF] text-white py-4 rounded-xl font-black flex items-center justify-center gap-3 shadow-xl shadow-[#6C2BFF]/20 hover:scale-[1.02] transition-all">
            <ShoppingCart size={20} />
            Add To Cart
          </button>
          <button className="w-full border-2 border-[#6C2BFF] text-[#6C2BFF] py-4 rounded-xl font-black hover:bg-[#6C2BFF]/5 transition-all">
            Buy Now
          </button>
          <button className="w-full border-2 border-[#ECECEC] text-gray-700 py-4 rounded-xl font-black flex items-center justify-center gap-3 hover:border-gray-400 transition-all">
            <Heart size={20} />
            Add To Wishlist
          </button>
        </div>
      </div>
    </div>
  );
};

export default DeliveryActionCard;
