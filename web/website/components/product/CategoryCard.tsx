import React from 'react';
import { ChevronRight } from 'lucide-react';

interface CategoryCardProps {
  image: string;
  name: string;
  count: string;
  discount: string;
  bgColor?: string;
}

const CategoryCard: React.FC<CategoryCardProps> = ({
  image, name, count, discount, bgColor = '#F8F7FC'
}) => {
  return (
    <div className="bg-white rounded-[20px] p-6 shadow-sm border border-[#ECECEC] hover:shadow-xl hover:-translate-y-2 transition-all duration-500 cursor-pointer group flex flex-col items-center text-center">
      <div
        className="w-full aspect-[4/3] rounded-2xl flex items-center justify-center mb-6 overflow-hidden transition-all group-hover:bg-[#FF6B2C]/5"
        style={{ backgroundColor: bgColor }}
      >
        <img
          src={image}
          alt={name}
          className="w-[70%] h-[70%] object-contain group-hover:scale-110 transition-transform duration-700"
        />
      </div>

      <div className="flex flex-col items-center">
         <h3 className="text-lg font-black text-[#111827] mb-1 group-hover:text-[#FF6B2C] transition-colors">{name}</h3>
         <p className="text-[11px] font-bold text-[#6B7280] uppercase tracking-widest mb-3">{count} Products</p>
         <div className="flex items-center gap-2">
            <span className="text-[#FF6B2C] font-black text-sm">{discount}</span>
            <div className="w-6 h-6 rounded-full bg-[#F8F7FC] flex items-center justify-center group-hover:bg-[#FF6B2C] group-hover:text-white transition-all">
               <ChevronRight size={14} />
            </div>
         </div>
      </div>
    </div>
  );
};

export default CategoryCard;
