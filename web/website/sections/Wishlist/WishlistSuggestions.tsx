import React from 'react';
import SuggestedProductItem from '../../components/wishlist/SuggestedProductItem';

const suggestions = [
  {
    image: 'https://images.unsplash.com/photo-1484704849700-f032a568e944?auto=format&fit=crop&q=80&w=400',
    name: 'boAt Rockerz 450 Wireless Headphones',
    price: 1499,
  },
  {
    image: 'https://images.unsplash.com/photo-1549463595-b093057de965?auto=format&fit=crop&q=80&w=400',
    name: 'Skybags Casual Backpack',
    price: 999,
  },
  {
    image: 'https://images.unsplash.com/photo-1511556532299-8f662fc26c06?auto=format&fit=crop&q=80&w=400',
    name: 'Vincero UV Protected Sunglasses',
    price: 799,
  },
];

const WishlistSuggestions: React.FC = () => {
  return (
    <div className="bg-white rounded-[24px] border border-[#ECECEC] p-6 shadow-sm">
      <div className="flex items-center justify-between mb-6 pb-4 border-b border-[#F8F5FF]">
        <h3 className="text-sm font-black text-[#111827] uppercase tracking-wider">You May Also Like</h3>
        <button className="text-[10px] font-black text-[#6C2BFF] uppercase tracking-widest hover:underline">View All</button>
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
