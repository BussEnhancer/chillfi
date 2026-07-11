import React from 'react';
import { ChevronRight } from 'lucide-react';

const brands = ['Samsung', 'Apple', 'OnePlus', 'Sony', 'boAt', 'Realme', 'Mi', 'Dell', 'LG', 'Lenovo', 'Noise', 'JBL'];

const PopularBrands: React.FC = () => {
  return (
    <div className="mt-20">
      <div className="flex items-center justify-between mb-8">
         <h2 className="text-2xl font-black text-[#111827]">Popular Brands</h2>
         <button className="flex items-center gap-1.5 text-[#FF6B2C] font-black text-sm hover:underline">
            View All Brands <ChevronRight size={16} />
         </button>
      </div>

      <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-4">
         {brands.map((brand, i) => (
           <div
             key={i}
             className="h-16 flex items-center justify-center p-4 bg-white border border-[#ECECEC] rounded-xl hover:shadow-lg hover:border-[#FF6B2C]/30 hover:-translate-y-1 transition-all cursor-pointer group"
           >
              <span className="text-sm font-black text-gray-400 group-hover:text-[#FF6B2C] tracking-tight text-center transition-colors">{brand}</span>
           </div>
         ))}
      </div>
    </div>
  );
};

export default PopularBrands;
