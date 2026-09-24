import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { apiGet } from '../../utils/api';

interface ApiBrand {
  id: string;
  name: string;
  product_count?: number | string;
}

const PopularBrands: React.FC = () => {
  const [brands, setBrands] = useState<ApiBrand[]>([]);

  useEffect(() => {
    apiGet<{ success: boolean; data: { brands: ApiBrand[] } }>('/brands')
      .then(res => setBrands(
        [...(res.data.brands || [])].sort((a, b) => Number(b.product_count || 0) - Number(a.product_count || 0))
      ))
      .catch(() => setBrands([]));
  }, []);

  if (brands.length === 0) return null;

  return (
    <div id="brands" className="mt-20 scroll-mt-32">
      <div className="flex items-center justify-between mb-8">
         <h2 className="text-2xl font-black text-[#111827]">Popular Brands</h2>
      </div>

      <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-4">
         {brands.slice(0, 12).map(brand => (
           <Link
             key={brand.id}
             to={`/products?brand=${encodeURIComponent(brand.name)}`}
             className="h-16 flex items-center justify-center p-4 bg-white border border-[#ECECEC] rounded-xl hover:shadow-lg hover:border-[#FF6B2C]/30 hover:-translate-y-1 transition-all group"
           >
              <span className="text-sm font-black text-gray-400 group-hover:text-[#FF6B2C] tracking-tight text-center transition-colors">{brand.name}</span>
           </Link>
         ))}
      </div>
    </div>
  );
};

export default PopularBrands;
