import React, { useEffect, useState } from 'react';
import CategoryTree from './CategoryTree';
import PriceRangeSlider from '../common/PriceRangeSlider';
import { Search } from 'lucide-react';
import { apiGet } from '../../utils/api';

interface ApiBrand {
  id: string;
  name: string;
  product_count?: number | string;
}

interface ProductFilterSidebarProps {
  selectedCategory?: string;
  onCategoryChange?: (categoryId: string) => void;
  selectedBrand?: string;
  onBrandChange?: (brandName: string) => void;
  minPrice?: number;
  maxPrice?: number;
  onPriceChange?: (min: number, max: number) => void;
  mobileOpen?: boolean;
  onClose?: () => void;
}

const ProductFilterSidebar: React.FC<ProductFilterSidebarProps> = ({
  selectedCategory, onCategoryChange,
  selectedBrand, onBrandChange,
  minPrice, maxPrice, onPriceChange,
  mobileOpen = false, onClose,
}) => {
  const [brands, setBrands] = useState<ApiBrand[]>([]);
  const [brandSearch, setBrandSearch] = useState('');
  const [showAllBrands, setShowAllBrands] = useState(false);

  useEffect(() => {
    apiGet<{ success: boolean; data: { brands: ApiBrand[] } }>('/brands')
      .then(res => setBrands(res.data.brands || []))
      .catch(() => {});
  }, []);

  const filteredBrands = brands.filter(b => b.name.toLowerCase().includes(brandSearch.toLowerCase()));
  const visibleBrands = showAllBrands ? filteredBrands : filteredBrands.slice(0, 7);

  const panel = (
      <>
        <CategoryTree selected={selectedCategory} onSelect={onCategoryChange} />

        <div className="border-t border-[#ECECEC] pt-8">
          <h3 className="text-sm font-black text-[#111827] uppercase tracking-wider mb-6">Filter By</h3>

          <PriceRangeSlider minPrice={minPrice} maxPrice={maxPrice} onChange={onPriceChange} />

          <div className="mb-8">
            <h4 className="text-[12px] font-black text-[#111827] mb-4">Brand</h4>
            <div className="relative mb-4">
              <input
                type="text"
                value={brandSearch}
                onChange={e => setBrandSearch(e.target.value)}
                placeholder="Search Brand"
                className="w-full bg-gray-50 border border-[#ECECEC] rounded-lg pl-9 pr-4 py-2 text-sm outline-none focus:border-[#FF6B2C]"
              />
              <Search size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
            </div>

            <div className="space-y-3">
              {visibleBrands.map(brand => (
                <label key={brand.id} className="flex items-center justify-between cursor-pointer group">
                  <div className="flex items-center gap-3">
                    <input
                      type="checkbox"
                      checked={selectedBrand === brand.name}
                      onChange={() => onBrandChange?.(selectedBrand === brand.name ? '' : brand.name)}
                      className="w-4 h-4 rounded border-[#ECECEC] text-[#FF6B2C] focus:ring-[#FF6B2C]"
                    />
                    <span className="text-sm font-bold text-gray-700 group-hover:text-[#FF6B2C] transition-colors">{brand.name}</span>
                  </div>
                  {brand.product_count !== undefined && (
                    <span className="text-[10px] font-bold text-gray-400">({brand.product_count})</span>
                  )}
                </label>
              ))}
              {filteredBrands.length === 0 && (
                <p className="text-xs font-bold text-gray-400">No brands found</p>
              )}
            </div>

            {filteredBrands.length > 7 && (
              <button
                onClick={() => setShowAllBrands(v => !v)}
                className="text-[11px] font-black text-[#FF6B2C] mt-4 hover:underline"
              >
                {showAllBrands ? '− View Less' : '+ View More'}
              </button>
            )}
          </div>
        </div>
      </>
  );

  return (
    <>
      <aside className="w-[320px] shrink-0 hidden lg:block">
        <div className="bg-white rounded-[20px] shadow-sm border border-[#ECECEC] p-6 sticky top-32 overflow-y-auto max-h-[calc(100vh-160px)] scrollbar-hide">
          {panel}
        </div>
      </aside>
      {/* Phones & tablets: same filters in a slide-in drawer */}
      {mobileOpen && (
        <div className="lg:hidden fixed inset-0 z-[60] flex" role="dialog" aria-modal="true" aria-label="Filters">
          <div className="absolute inset-0 bg-black/40" onClick={onClose} />
          <div className="relative ml-auto h-full w-[88%] max-w-[360px] bg-white shadow-2xl flex flex-col">
            <div className="flex items-center justify-between px-5 py-4 border-b border-[#ECECEC]">
              <h3 className="text-base font-black text-[#111827]">Filters</h3>
              <button onClick={onClose} className="w-10 h-10 rounded-xl bg-[#F8F7FC] flex items-center justify-center" aria-label="Close filters">✕</button>
            </div>
            <div className="flex-1 overflow-y-auto p-5">{panel}</div>
            <div className="p-4 border-t border-[#ECECEC]">
              <button onClick={onClose} className="w-full bg-[#FF6B2C] text-white py-3 rounded-xl font-black text-sm active:scale-[0.98] transition-all">Show results</button>
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default ProductFilterSidebar;
