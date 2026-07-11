import React from 'react';
import SuggestedProductItem from '../../components/wishlist/SuggestedProductItem';

const suggestions = [
  {
    image: 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?auto=format&fit=crop&q=80&w=400',
    name: 'boAt Airdopes 141 TWS Earbuds',
    price: 1299,
  },
  {
    image: 'https://images.unsplash.com/photo-1508685096489-7aac2715a99a?auto=format&fit=crop&q=80&w=400',
    name: 'Mi Smart Band 8 Pro AMOLED',
    price: 2499,
  },
  {
    image: 'https://images.unsplash.com/photo-1527814050087-3793815479db?auto=format&fit=crop&q=80&w=400',
    name: 'Logitech MK295 Wireless Keyboard & Mouse',
    price: 2495,
  },
];

const WishlistSuggestions: React.FC = () => {
  return (
    <div className="bg-white rounded-[24px] border border-[#ECECEC] p-6 shadow-sm">
      <div className="flex items-center justify-between mb-6 pb-4 border-b border-[#FFF8F5]">
        <h3 className="text-sm font-black text-[#111827] uppercase tracking-wider">You May Also Like</h3>
        <button className="text-[10px] font-black text-[#FF6B2C] uppercase tracking-widest hover:underline">View All</button>
      </div>
      <div className="space-y-2">
        {suggestions.map((item, i) => (
          <SuggestedProductItem key={i} {...item} />
        ))}
      </div>
    </div>
  );
};

export default WishlistSuggestions;
