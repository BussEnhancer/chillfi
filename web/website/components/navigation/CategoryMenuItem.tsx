import React from 'react';
import { ChevronRight } from 'lucide-react';

interface CategoryMenuItemProps {
  label: string;
  icon: React.ReactNode;
  isActive?: boolean;
}

const CategoryMenuItem: React.FC<CategoryMenuItemProps> = ({ label, icon, isActive = false }) => {
  return (
    <div
      className={`flex items-center justify-between px-4 py-3 cursor-pointer transition-all rounded-xl group ${
        isActive ? 'bg-[#6C2BFF]/10 text-[#6C2BFF]' : 'text-[#6B7280] hover:bg-[#F8F7FC] hover:text-[#111827]'
      }`}
    >
      <div className="flex items-center gap-3">
        <span className={`transition-colors ${isActive ? 'text-[#6C2BFF]' : 'group-hover:text-[#6C2BFF]'}`}>
          {icon}
        </span>
        <span className={`text-sm font-bold ${isActive ? 'font-black' : ''}`}>{label}</span>
      </div>
      <ChevronRight size={16} className={`transition-transform group-hover:translate-x-1 ${isActive ? 'text-[#6C2BFF]' : 'text-[#ECECEC]'}`} />
    </div>
  );
};

export default CategoryMenuItem;
