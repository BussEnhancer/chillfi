import React from 'react';
import { Link } from 'react-router-dom';
import Container from '../common/Container';
import SearchBar from '../common/SearchBar';
import { Heart, ShoppingCart, User, ChevronDown } from 'lucide-react';
import { useStore } from '../../context/StoreContext';

const Header: React.FC = () => {
  const { cartCount, wishlist, isLoggedIn } = useStore();

  return (
    <header className="bg-white border-b border-gray-100 sticky top-0 z-50">
      <Container className="flex items-center justify-between py-4 gap-8">
        {/* Logo */}
        <Link to="/" className="flex items-center gap-2 cursor-pointer">
          <div className="bg-[#FF6B2C] p-2 rounded-xl">
            <ShoppingCart className="text-white" size={24} />
          </div>
          <span className="text-2xl font-bold tracking-tight text-gray-900">chillFi</span>
        </Link>

        {/* Search */}
        <SearchBar />

        {/* Actions */}
        <div className="flex items-center gap-6">
          <Link to="/account/wishlist" className="flex flex-col items-center gap-1 group">
            <div className="relative">
              <Heart size={24} className="group-hover:text-[#FF6B2C] transition-colors" />
              {wishlist.length > 0 && (
                <span className="absolute -top-1 -right-1 bg-[#FF6B2C] text-white text-[10px] w-4 h-4 flex items-center justify-center rounded-full">{wishlist.length}</span>
              )}
            </div>
            <span className="text-[11px] font-semibold uppercase tracking-wider">Wishlist</span>
          </Link>

          <Link to="/cart" className="flex flex-col items-center gap-1 group">
            <div className="relative">
              <ShoppingCart size={24} className="group-hover:text-[#FF6B2C] transition-colors" />
              {cartCount > 0 && (
                <span className="absolute -top-1 -right-1 bg-[#FF6B2C] text-white text-[10px] w-4 h-4 flex items-center justify-center rounded-full">{cartCount > 9 ? '9+' : cartCount}</span>
              )}
            </div>
            <span className="text-[11px] font-semibold uppercase tracking-wider">Cart</span>
          </Link>

          <Link to={isLoggedIn ? '/account' : '/login'} className="flex items-center gap-3 group pl-2">
            <div className="w-10 h-10 bg-gray-100 rounded-full flex items-center justify-center group-hover:bg-gray-200 transition-colors">
              <User size={20} />
            </div>
            <div className="flex flex-col">
              <span className="text-[10px] text-gray-500 font-medium">{isLoggedIn ? 'Welcome back' : 'Hello, Sign in'}</span>
              <span className="text-sm font-bold flex items-center gap-1">
                Account <ChevronDown size={14} />
              </span>
            </div>
          </Link>
        </div>
      </Container>
    </header>
  );
};

export default Header;
