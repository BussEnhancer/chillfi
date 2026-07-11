import React from 'react';
import { LayoutGrid, List, ChevronDown, Filter } from 'lucide-react';

const ProductSortBar: React.FC = () => {
  return (
    <div className="flex flex-col md:flex-row md:items-center justify-between gap-6 mb-8">
      <div>
        <h2 className="text-2xl font-black text-[#111827] mb-1">Sneakers</h2>
        <p className="text-[12px] font-bold text-gray-400 uppercase tracking-widest">Showing 1–24 of 356 products</p>
      </div>

      <div className="flex items-center gap-4 self-end">
        <div className="flex items-center gap-2 mr-4">
          <span className="text-sm font-bold text-gray-500">Sort By:</span>
          <div className="flex items-center gap-2 bg-white border border-[#ECECEC] px-4 py-2 rounded-xl cursor-pointer hover:border-[#FF6B2C] transition-all">
            <span className="text-sm font-black text-[#111827]">Popularity</span>
            <ChevronDown size={16} className="text-[#FF6B2C]" />
          </div>
        </div>

        <div className="flex items-center bg-[#F8F7FC] p-1 rounded-xl border border-[#ECECEC]">
           <button className="w-9 h-9 flex items-center justify-center bg-white shadow-sm text-[#FF6B2C] rounded-lg">
              <LayoutGrid size={18} />
           </button>
           <button className="w-9 h-9 flex items-center justify-center text-gray-400 hover:text-gray-600">
              <List size={18} />
           </button>
        </div>

        <button className="lg:hidden flex items-center gap-2 bg-[#FF6B2C] text-white px-5 py-2.5 rounded-xl font-bold text-sm shadow-lg shadow-[#FF6B2C]/20">
           <Filter size={18} />
           Filter
        </button>
      </div>
    </div>
  );
};

export default ProductSortBar;
