import React from 'react';
import { Link } from 'react-router-dom';
import { ChevronRight } from 'lucide-react';

interface CategoryMenuItemProps {
  label: string;
  icon: React.ReactNode;
  isActive?: boolean;
  to?: string;
}

const CategoryMenuItem: React.FC<CategoryMenuItemProps> = ({ label, icon, isActive = false, to = '#' }) => {
  return (
    <Link
      to={to}
      className={`flex items-center justify-between px-4 py-3 transition-all rounded-xl group ${
        isActive ? 'bg-[#FF6B2C]/10 text-[#FF6B2C]' : 'text-[#6B7280] hover:bg-[#F8F7FC] hover:text-[#111827]'
      }`}
    >
      <div className="flex items-center gap-3">
        <span className={`transition-colors ${isActive ? 'text-[#FF6B2C]' : 'group-hover:text-[#FF6B2C]'}`}>
          {icon}
        </span>
        <span className={`text-sm font-bold ${isActive ? 'font-black' : ''}`}>{label}</span>
      </div>
      <ChevronRight size={16} className={`transition-transform group-hover:translate-x-1 ${isActive ? 'text-[#FF6B2C]' : 'text-[#ECECEC]'}`} />
    </Link>
  );
};

export default CategoryMenuItem;
