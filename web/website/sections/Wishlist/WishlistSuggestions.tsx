import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import SuggestedProductItem from '../../components/wishlist/SuggestedProductItem';
import { apiGet } from '../../utils/api';

interface ApiProduct {
  id: string;
  name: string;
  price: number;
  old_price: number;
  primary_image?: string;
  brand_name?: string;
  category_name?: string;
}

const WishlistSuggestions: React.FC = () => {
  const [products, setProducts] = useState<ApiProduct[]>([]);

  useEffect(() => {
    apiGet<{ success: boolean; data: { products: ApiProduct[] } }>('/products?page=1&limit=3&sort=rating&order=DESC')
      .then(res => setProducts(res.data.products || []))
      .catch(() => setProducts([]));
  }, []);

  if (products.length === 0) return null;

  return (
    <div className="bg-white rounded-[24px] border border-[#ECECEC] p-6 shadow-sm">
      <div className="flex items-center justify-between mb-6 pb-4 border-b border-[#FFF8F5]">
        <h3 className="text-sm font-black text-[#111827] uppercase tracking-wider">You May Also Like</h3>
        <Link to="/products" className="text-[10px] font-black text-[#FF6B2C] uppercase tracking-widest hover:underline">View All</Link>
      </div>
      <div className="space-y-2">
        {products.map(p => (
          <SuggestedProductItem
            key={p.id}
            id={String(p.id)}
            image={p.primary_image || ''}
            name={p.name}
            price={Number(p.price)}
            oldPrice={Number(p.old_price) || 0}
            brand={p.brand_name || ''}
            category={p.category_name || ''}
          />
        ))}
      </div>
    </div>
  );
};

export default WishlistSuggestions;
