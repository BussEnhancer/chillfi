import React from 'react';
import Container from '../common/Container';
import { Menu } from 'lucide-react';

const navItems = [
  { label: 'Home', active: true },
  { label: 'Categories' },
  { label: 'Deals' },
  { label: 'New Arrivals' },
  { label: 'Best Sellers' },
  { label: 'Brands' },
  { label: 'Track Order' },
];

const CategoryNav: React.FC = () => {
  return (
    <nav className="bg-white border-b border-gray-100 py-1 hidden md:block">
      <Container className="flex items-center gap-8">
        <button className="bg-[#6C2BFF] text-white px-6 py-2.5 rounded-lg flex items-center gap-3 font-semibold text-sm hover:bg-[#5A24D6] transition-all">
          <Menu size={18} />
          Browse Categories
        </button>

        <ul className="flex items-center gap-8">
          {navItems.map((item) => (
            <li key={item.label}>
              <a
                href="#"
                className={`text-sm font-semibold transition-colors hover:text-[#6C2BFF] ${
                  item.active ? 'text-[#6C2BFF]' : 'text-gray-700'
                }`}
              >
                {item.label}
              </a>
            </li>
          ))}
        </ul>
      </Container>
    </nav>
  );
};

export default CategoryNav;
