import React from 'react';
import { Search, Filter } from 'lucide-react';

const OrdersSearchBar: React.FC = () => {
  return (
    <div className="flex flex-col md:flex-row gap-4 mb-8">
      <div className="flex-1 bg-white border border-[#ECECEC] rounded-xl px-5 py-3 flex items-center gap-4 focus-within:border-[#6C2BFF] transition-all shadow-sm">
        <Search size={20} className="text-gray-400" />
        <input
          type="text"
          placeholder="Search by Order ID, Product or Brand..."
          className="flex-1 bg-transparent outline-none text-sm font-bold text-[#111827]"
        />
      </div>
      <button className="bg-white border border-[#ECECEC] rounded-xl px-6 py-3 flex items-center justify-center gap-3 text-sm font-black text-gray-700 hover:border-[#6C2BFF] hover:text-[#6C2BFF] transition-all shadow-sm">
        <Filter size={18} />
        Filter
      </button>
    </div>
  );
};

export default OrdersSearchBar;
