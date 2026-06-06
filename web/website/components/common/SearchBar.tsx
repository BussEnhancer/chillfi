import React from 'react';
import { Search, ChevronDown } from 'lucide-react';

const SearchBar: React.FC = () => {
  return (
    <div className="flex flex-1 max-w-[700px] h-11 bg-gray-100 rounded-lg overflow-hidden border border-transparent focus-within:border-[#6C2BFF] transition-all">
      <div className="flex items-center px-4 gap-2 border-r border-gray-300 cursor-pointer hover:bg-gray-200 transition-colors">
        <span className="text-sm font-medium whitespace-nowrap">All Categories</span>
        <ChevronDown size={16} />
      </div>
      <input
        type="text"
        placeholder="Search for products, brands and more..."
        className="flex-1 px-4 bg-transparent outline-none text-sm"
      />
      <button className="bg-[#6C2BFF] text-white px-6 flex items-center justify-center hover:bg-[#5A24D6] transition-colors">
        <Search size={20} />
      </button>
    </div>
  );
};

export default SearchBar;
