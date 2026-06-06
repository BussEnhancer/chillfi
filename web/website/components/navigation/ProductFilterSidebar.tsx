import React from 'react';
import CategoryTree from './CategoryTree';
import PriceRangeSlider from '../common/PriceRangeSlider';
import { Search } from 'lucide-react';

const brands = [
  { name: 'Puma', count: 126, checked: true },
  { name: 'Nike', count: 95, checked: true },
  { name: 'Adidas', count: 112 },
  { name: 'Skechers', count: 76 },
  { name: 'Reebok', count: 54 },
];

const ProductFilterSidebar: React.FC = () => {
  return (
    <aside className="w-[320px] shrink-0 hidden lg:block">
      <div className="bg-white rounded-[20px] shadow-sm border border-[#ECECEC] p-6 sticky top-32 overflow-y-auto max-h-[calc(100vh-160px)] scrollbar-hide">
        <CategoryTree />

        <div className="border-t border-[#ECECEC] pt-8">
          <h3 className="text-sm font-black text-[#111827] uppercase tracking-wider mb-6">Filter By</h3>

          <PriceRangeSlider />

          <div className="mb-8">
            <h4 className="text-[12px] font-black text-[#111827] mb-4">Brand</h4>
            <div className="relative mb-4">
              <input
                type="text"
                placeholder="Search Brand"
                className="w-full bg-gray-50 border border-[#ECECEC] rounded-lg pl-9 pr-4 py-2 text-sm outline-none focus:border-[#6C2BFF]"
              />
              <Search size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
            </div>

            <div className="space-y-3">
              {brands.map((brand, i) => (
                <label key={i} className="flex items-center justify-between cursor-pointer group">
                  <div className="flex items-center gap-3">
                    <input
                      type="checkbox"
                      checked={brand.checked}
                      className="w-4 h-4 rounded border-[#ECECEC] text-[#6C2BFF] focus:ring-[#6C2BFF]"
                    />
                    <span className="text-sm font-bold text-gray-700 group-hover:text-[#6C2BFF] transition-colors">{brand.name}</span>
                  </div>
                  <span className="text-[10px] font-bold text-gray-400">({brand.count})</span>
                </label>
              ))}
            </div>

            <button className="text-[11px] font-black text-[#6C2BFF] mt-4 hover:underline">+ View More</button>
          </div>
        </div>
      </div>
    </aside>
  );
};

export default ProductFilterSidebar;
