import React, { useState } from 'react';
import { Link, useLocation } from 'react-router-dom';
import Container from '../common/Container';
import SearchBar from '../common/SearchBar';
import { Heart, ShoppingCart, User, ChevronDown, Menu, X } from 'lucide-react';
import { useStore } from '../../context/StoreContext';

const NAV_LINKS = [
  { label: 'Home', to: '/' },
  { label: 'Categories', to: '/categories' },
  { label: 'Deals', to: '/offers' },
  { label: 'New Arrivals', to: '/products?sort=newest' },
  { label: 'Top Rated', to: '/products?sort=rating' },
  { label: 'Track Order', to: '/account/orders' },
];

const Header: React.FC = () => {
  const { cartCount, wishlist, isLoggedIn } = useStore();
  const [mobileOpen, setMobileOpen] = useState(false);
  const { pathname } = useLocation();

  const closeMobile = () => setMobileOpen(false);

  return (
    <header className="bg-white border-b border-gray-100 sticky top-0 z-50">
      <Container className="flex items-center justify-between py-4 gap-4">
        {/* Logo */}
        <Link to="/" className="flex items-center gap-2 cursor-pointer shrink-0">
          <div className="bg-[#FF6B2C] p-2 rounded-xl">
            <img src="/logo-icon-white.png" alt="" className="w-6 h-6" />
          </div>
          <span className="text-2xl font-bold tracking-tight text-gray-900">chillFi</span>
        </Link>

        {/* Search — hidden on mobile */}
        <div className="hidden md:flex flex-1 min-w-0">
          <SearchBar />
        </div>

        {/* Desktop Actions */}
        <div className="hidden md:flex items-center gap-4 lg:gap-6 shrink-0">
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

          <Link to={isLoggedIn ? '/account' : '/login'} aria-label="Account" className="flex items-center gap-3 group pl-2">
            <div className="w-10 h-10 bg-gray-100 rounded-full flex items-center justify-center group-hover:bg-gray-200 transition-colors">
              <User size={20} />
            </div>
            <div className="hidden lg:flex flex-col">
              <span className="text-[10px] text-gray-500 font-medium">{isLoggedIn ? 'Welcome back' : 'Hello, Sign in'}</span>
              <span className="text-sm font-bold flex items-center gap-1">Account <ChevronDown size={14} /></span>
            </div>
          </Link>
        </div>

        {/* Mobile: cart + hamburger */}
        <div className="flex md:hidden items-center gap-3">
          <Link to="/cart" className="relative">
            <ShoppingCart size={24} />
            {cartCount > 0 && (
              <span className="absolute -top-1 -right-1 bg-[#FF6B2C] text-white text-[10px] w-4 h-4 flex items-center justify-center rounded-full">{cartCount > 9 ? '9+' : cartCount}</span>
            )}
          </Link>
          <button
            onClick={() => setMobileOpen(v => !v)}
            className="p-1 rounded-lg hover:bg-gray-100 transition-colors"
            aria-label="Toggle menu"
          >
            {mobileOpen ? <X size={26} /> : <Menu size={26} />}
          </button>
        </div>
      </Container>

      {/* Mobile Drawer */}
      {mobileOpen && (
        <div className="md:hidden bg-white border-t border-gray-100 shadow-lg">
          {/* Mobile Search */}
          <div className="px-4 pt-4 pb-2">
            <SearchBar />
          </div>

          {/* Nav Links */}
          <nav className="px-4 py-2">
            {NAV_LINKS.map(link => (
              <Link
                key={link.label}
                to={link.to}
                onClick={closeMobile}
                className={`flex items-center py-3 border-b border-gray-50 text-sm font-semibold transition-colors ${
                  pathname === link.to ? 'text-[#FF6B2C]' : 'text-gray-700 hover:text-[#FF6B2C]'
                }`}
              >
                {link.label}
              </Link>
            ))}
          </nav>

          {/* Mobile Account + Wishlist */}
          <div className="px-4 py-4 flex gap-3">
            <Link
              to={isLoggedIn ? '/account' : '/login'}
              onClick={closeMobile}
              className="flex-1 flex items-center justify-center gap-2 bg-[#FF6B2C] text-white py-3 rounded-xl font-bold text-sm active:scale-[0.98] transition-all"
            >
              <User size={16} />
              {isLoggedIn ? 'My Account' : 'Sign In'}
            </Link>
            <Link
              to="/account/wishlist"
              onClick={closeMobile}
              className="flex items-center justify-center gap-2 border-2 border-[#FF6B2C] text-[#FF6B2C] px-5 py-3 rounded-xl font-bold text-sm relative"
            >
              <Heart size={16} />
              {wishlist.length > 0 && (
                <span className="absolute -top-1 -right-1 bg-[#FF6B2C] text-white text-[10px] w-4 h-4 flex items-center justify-center rounded-full">{wishlist.length}</span>
              )}
            </Link>
          </div>
        </div>
      )}
    </header>
  );
};

export default Header;
