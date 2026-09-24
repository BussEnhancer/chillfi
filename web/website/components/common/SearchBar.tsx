import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Search, ChevronDown } from 'lucide-react';
import { useStore } from '../../context/StoreContext';

const SearchBar: React.FC = () => {
  const navigate = useNavigate();
  const { categories } = useStore();
  const [q, setQ] = useState('');
  const [categoryId, setCategoryId] = useState('');

  const handleSearch = () => {
    const trimmed = q.trim();
    // With a category chosen, search within it on the listing page (supports category + q).
    if (categoryId) {
      navigate(`/products?category=${encodeURIComponent(categoryId)}${trimmed ? `&q=${encodeURIComponent(trimmed)}` : ''}`);
      return;
    }
    if (trimmed) navigate(`/search?q=${encodeURIComponent(trimmed)}`);
  };

  return (
    <div className="flex flex-1 min-w-0 max-w-[700px] h-11 bg-gray-100 rounded-lg overflow-hidden border border-transparent focus-within:border-[#FF6B2C] transition-all">
      <label className="relative hidden lg:flex items-center border-r border-gray-300 hover:bg-gray-200 transition-colors">
        <span className="sr-only">Search in category</span>
        <select
          value={categoryId}
          onChange={e => setCategoryId(e.target.value)}
          className="appearance-none bg-transparent pl-4 pr-8 h-full text-sm font-medium outline-none cursor-pointer max-w-[170px] truncate"
        >
          <option value="">All Categories</option>
          {categories.filter(c => c.status !== false).map(c => (
            <option key={c.id} value={c.id}>{c.name}</option>
          ))}
        </select>
        <ChevronDown size={16} className="pointer-events-none absolute right-2" />
      </label>
      <input
        type="text"
        value={q}
        onChange={e => setQ(e.target.value)}
        onKeyDown={e => e.key === 'Enter' && handleSearch()}
        placeholder="Search for products, brands and more..."
        aria-label="Search products"
        className="flex-1 min-w-0 px-4 bg-transparent outline-none text-sm"
      />
      <button
        onClick={handleSearch}
        aria-label="Search"
        className="bg-[#FF6B2C] text-white px-4 lg:px-6 flex items-center justify-center hover:bg-[#E05520] transition-colors shrink-0"
      >
        <Search size={20} />
      </button>
    </div>
  );
};

export default SearchBar;
