import React from 'react';
import Container from '../common/Container';
import SearchBar from '../common/SearchBar';
import { Heart, ShoppingCart, User, ChevronDown } from 'lucide-react';

const Header: React.FC = () => {
  return (
    <header className="bg-white border-b border-gray-100 sticky top-0 z-50">
      <Container className="flex items-center justify-between py-4 gap-8">
        {/* Logo */}
        <div className="flex items-center gap-2 cursor-pointer">
          <div className="bg-[#6C2BFF] p-2 rounded-xl">
            <ShoppingCart className="text-white" size={24} />
          </div>
          <span className="text-2xl font-bold tracking-tight">chillFi</span>
        </div>

        {/* Search */}
        <SearchBar />

        {/* Actions */}
        <div className="flex items-center gap-6">
          <div className="flex flex-col items-center gap-1 cursor-pointer group">
            <div className="relative">
              <Heart size={24} className="group-hover:text-[#6C2BFF] transition-colors" />
              <span className="absolute -top-1 -right-1 bg-[#FF6B2C] text-white text-[10px] w-4 h-4 flex items-center justify-center rounded-full">0</span>
            </div>
            <span className="text-[11px] font-semibold uppercase tracking-wider">Wishlist</span>
          </div>

          <div className="flex flex-col items-center gap-1 cursor-pointer group">
            <div className="relative">
              <ShoppingCart size={24} className="group-hover:text-[#6C2BFF] transition-colors" />
              <span className="absolute -top-1 -right-1 bg-[#FF6B2C] text-white text-[10px] w-4 h-4 flex items-center justify-center rounded-full">3</span>
            </div>
            <span className="text-[11px] font-semibold uppercase tracking-wider">Cart</span>
          </div>

          <div className="flex items-center gap-3 cursor-pointer group pl-2">
            <div className="w-10 h-10 bg-gray-100 rounded-full flex items-center justify-center group-hover:bg-gray-200 transition-colors">
              <User size={20} />
            </div>
            <div className="flex flex-col">
              <span className="text-[10px] text-gray-500 font-medium">Hello, Sign in</span>
              <span className="text-sm font-bold flex items-center gap-1">
                Account <ChevronDown size={14} />
              </span>
            </div>
          </div>
        </div>
      </Container>
    </header>
  );
};

export default Header;
