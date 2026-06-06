import React from 'react';
import { ChevronLeft, ChevronRight, ChevronDown } from 'lucide-react';

const Pagination: React.FC = () => {
  return (
    <div className="mt-16 pt-8 border-t border-[#ECECEC] flex flex-col md:flex-row items-center justify-between gap-8">
      {/* Spacer for centering logic on desktop */}
      <div className="hidden md:block w-32"></div>

      {/* Pages */}
      <div className="flex items-center gap-2">
        <button className="w-10 h-10 flex items-center justify-center text-gray-400 hover:text-[#6C2BFF] border border-[#ECECEC] rounded-xl hover:border-[#6C2BFF] transition-all">
          <ChevronLeft size={20} />
        </button>
        {[1, 2, 3, 4, 5, '...', 15].map((page, i) => (
          <button
            key={i}
            className={`w-10 h-10 flex items-center justify-center text-sm font-black rounded-xl transition-all ${
              page === 1 ? 'bg-[#6C2BFF] text-white shadow-lg shadow-[#6C2BFF]/30' : 'text-gray-500 hover:text-[#6C2BFF] hover:bg-[#6C2BFF]/5'
            }`}
          >
            {page}
          </button>
        ))}
        <button className="w-10 h-10 flex items-center justify-center text-gray-400 hover:text-[#6C2BFF] border border-[#ECECEC] rounded-xl hover:border-[#6C2BFF] transition-all">
          <ChevronRight size={20} />
        </button>
      </div>

      {/* Page Size */}
      <div className="flex items-center gap-3">
        <span className="text-sm font-bold text-gray-400">Show:</span>
        <div className="flex items-center gap-2 bg-white border border-[#ECECEC] px-4 py-2 rounded-xl cursor-pointer hover:border-[#6C2BFF] transition-all">
          <span className="text-sm font-black text-[#111827]">24 per page</span>
          <ChevronDown size={16} className="text-[#6C2BFF]" />
        </div>
      </div>
    </div>
  );
};

export default Pagination;
