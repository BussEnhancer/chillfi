import React from 'react';
import { Link, useLocation } from 'react-router-dom';
import Container from '../common/Container';
import { Menu } from 'lucide-react';

const navItems = [
  { label: 'Home', to: '/' },
  { label: 'Categories', to: '/categories' },
  { label: 'Deals', to: '/offers' },
  { label: 'New Arrivals', to: '/products?sort=newest' },
  { label: 'Best Sellers', to: '/products?sort=rating' },
  { label: 'Brands', to: '/products?view=brands' },
  { label: 'Track Order', to: '/account/orders' },
];

const CategoryNav: React.FC = () => {
  const { pathname, search } = useLocation();
  const current = pathname + search;

  return (
    <nav className="bg-white border-b border-gray-100 py-1 hidden md:block">
      <Container className="flex items-center gap-8">
        <Link to="/categories" className="bg-[#FF6B2C] text-white px-6 py-2.5 rounded-lg flex items-center gap-3 font-semibold text-sm hover:bg-[#E05520] transition-all">
          <Menu size={18} />
          Browse Categories
        </Link>

        <ul className="flex items-center gap-8">
          {navItems.map((item) => (
            <li key={item.label}>
              <Link
                to={item.to}
                className={`text-sm font-semibold transition-colors hover:text-[#FF6B2C] ${
                  current === item.to ? 'text-[#FF6B2C]' : 'text-gray-700'
                }`}
              >
                {item.label}
              </Link>
            </li>
          ))}
        </ul>
      </Container>
    </nav>
  );
};

export default CategoryNav;
