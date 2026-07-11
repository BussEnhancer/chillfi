import React, { useEffect, useState } from 'react';
import { Circle } from 'lucide-react';
import { apiGet } from '../../utils/api';

interface ApiCategory {
  id: string;
  name: string;
  product_count?: number | string;
}

interface CategoryTreeProps {
  selected?: string;
  onSelect?: (categoryId: string) => void;
}

const CategoryTree: React.FC<CategoryTreeProps> = ({ selected, onSelect }) => {
  const [categories, setCategories] = useState<ApiCategory[]>([]);

  useEffect(() => {
    apiGet<{ success: boolean; data: { categories: ApiCategory[] } }>('/categories')
      .then(res => setCategories(res.data.categories || []))
      .catch(() => {});
  }, []);

  return (
    <div className="mb-8">
      <h3 className="text-sm font-black text-[#111827] uppercase tracking-wider mb-6">Categories</h3>
      <ul className="space-y-3">
        <li>
          <button
            onClick={() => onSelect?.('')}
            className={`flex items-center justify-between w-full group ${!selected ? 'text-[#FF6B2C]' : 'text-gray-700 hover:text-[#FF6B2C]'}`}
          >
            <span className="text-sm font-bold">All Categories</span>
            {!selected && <Circle size={6} className="fill-[#FF6B2C] text-[#FF6B2C]" />}
          </button>
        </li>
        {categories.map(cat => (
          <li key={cat.id}>
            <button
              onClick={() => onSelect?.(cat.id)}
              className={`flex items-center justify-between w-full group ${selected === cat.id ? 'text-[#FF6B2C]' : 'text-gray-700 hover:text-[#FF6B2C]'}`}
            >
              <span className="text-sm font-bold">{cat.name}</span>
              <span className="flex items-center gap-2">
                {cat.product_count !== undefined && (
                  <span className="text-[10px] font-bold text-gray-400">({cat.product_count})</span>
                )}
                {selected === cat.id && <Circle size={6} className="fill-[#FF6B2C] text-[#FF6B2C]" />}
              </span>
            </button>
          </li>
        ))}
      </ul>
    </div>
  );
};

export default CategoryTree;
