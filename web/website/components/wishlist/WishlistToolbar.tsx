import React from 'react';
import { LayoutGrid, List, ChevronDown } from 'lucide-react';

const WishlistToolbar: React.FC = () => {
  return (
    <div className="flex flex-col md:flex-row md:items-center justify-between gap-6 mb-8 py-4 border-y border-[#F8F7FC]">
      <div className="flex items-center gap-4">
        <label className="flex items-center gap-3 cursor-pointer group">
          <input
            type="checkbox"
            className="w-5 h-5 rounded border-[#ECECEC] text-[#6C2BFF] focus:ring-[#6C2BFF]"
          />
          <span className="text-xs font-black text-[#111827] uppercase tracking-widest">Select All</span>
        </label>
      </div>

      <div className="flex items-center gap-6">
        <div className="flex items-center gap-3">
          <span className="text-xs font-bold text-gray-400 uppercase tracking-widest">Sort by:</span>
          <div className="flex items-center gap-2 bg-white border border-[#ECECEC] px-4 py-2 rounded-xl cursor-pointer hover:border-[#6C2BFF] transition-all">
            <span className="text-xs font-black text-[#111827]">Recently Added</span>
            <ChevronDown size={14} className="text-[#6C2BFF]" />
          </div>
        </div>

        <div className="flex items-center bg-[#F8F7FC] p-1 rounded-xl border border-[#ECECEC]">
          <button className="w-8 h-8 flex items-center justify-center bg-white shadow-sm text-[#6C2BFF] rounded-lg">
            <LayoutGrid size={16} />
          </button>
          <button className="w-8 h-8 flex items-center justify-center text-gray-400 hover:text-gray-600 transition-colors">
            <List size={16} />
          </button>
        </div>
      </div>
    </div>
  );
};

export default WishlistToolbar;
