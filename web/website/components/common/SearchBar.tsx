import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Search, ChevronDown } from 'lucide-react';

const SearchBar: React.FC = () => {
  const navigate = useNavigate();
  const [q, setQ] = useState('');

  const handleSearch = () => {
    const trimmed = q.trim();
    if (trimmed) navigate(`/search?q=${encodeURIComponent(trimmed)}`);
  };

  return (
    <div className="flex flex-1 max-w-[700px] h-11 bg-gray-100 rounded-lg overflow-hidden border border-transparent focus-within:border-[#FF6B2C] transition-all">
      <div className="flex items-center px-4 gap-2 border-r border-gray-300 cursor-pointer hover:bg-gray-200 transition-colors">
        <span className="text-sm font-medium whitespace-nowrap">All Categories</span>
        <ChevronDown size={16} />
      </div>
      <input
        type="text"
        value={q}
        onChange={e => setQ(e.target.value)}
        onKeyDown={e => e.key === 'Enter' && handleSearch()}
        placeholder="Search for products, brands and more..."
        className="flex-1 px-4 bg-transparent outline-none text-sm"
      />
      <button
        onClick={handleSearch}
        className="bg-[#FF6B2C] text-white px-6 flex items-center justify-center hover:bg-[#E05520] transition-colors"
      >
        <Search size={20} />
      </button>
    </div>
  );
};

export default SearchBar;
