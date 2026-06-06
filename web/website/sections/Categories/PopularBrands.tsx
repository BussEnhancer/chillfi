import React from 'react';
import { ChevronRight } from 'lucide-react';

const brands = [
  { name: 'Puma', logo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/88/Puma_logo.svg/2560px-Puma_logo.svg.png' },
  { name: 'boAt', logo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Boat_Logo.svg/1200px-Boat_Logo.svg.png' },
  { name: 'Fastrack', logo: 'https://upload.wikimedia.org/wikipedia/en/thumb/5/52/Fastrack_Logo.svg/1200px-Fastrack_Logo.svg.png' },
  { name: 'Realme', logo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/13/Realme-logo.svg/2560px-Realme-logo.svg.png' },
  { name: 'Samsung', logo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/Samsung_Logo.svg/2560px-Samsung_Logo.svg.png' },
  { name: 'Nike', logo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a6/Logo_NIKE.svg/1200px-Logo_NIKE.svg.png' },
  { name: 'Adidas', logo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/20/Adidas_Logo.svg/2560px-Adidas_Logo.svg.png' },
  { name: 'Apple', logo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Apple_logo_black.svg/1667px-Apple_logo_black.svg.png' },
];

const PopularBrands: React.FC = () => {
  return (
    <div className="mt-20">
      <div className="flex items-center justify-between mb-8">
         <h2 className="text-2xl font-black text-[#111827]">Popular Brands</h2>
         <button className="flex items-center gap-1.5 text-[#6C2BFF] font-black text-sm hover:underline">
            View All Brands <ChevronRight size={16} />
         </button>
      </div>

      <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-8 gap-4">
         {brands.map((brand, i) => (
           <div
             key={i}
             className="h-16 flex items-center justify-center p-4 bg-white border border-[#ECECEC] rounded-xl hover:shadow-lg hover:border-[#6C2BFF]/30 hover:-translate-y-1 transition-all cursor-pointer group"
           >
              <img
                src={brand.logo}
                alt={brand.name}
                className="max-h-full max-w-full object-contain grayscale group-hover:grayscale-0 transition-all duration-300"
              />
           </div>
         ))}
      </div>
    </div>
  );
};

export default PopularBrands;
