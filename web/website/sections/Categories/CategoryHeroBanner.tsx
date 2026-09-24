import React from 'react';
import { ShoppingBag, Headphones, Watch } from 'lucide-react';

const CategoryHeroBanner: React.FC = () => {
  return (
    <div className="bg-[#F8F7FC] rounded-[32px] p-6 sm:p-10 xl:p-16 flex flex-col md:flex-row items-center justify-between overflow-hidden relative group border border-[#ECECEC]">
      <div className="relative z-10 md:max-w-[50%]">
         <h1 className="text-4xl md:text-5xl font-black text-[#111827] leading-[1.1] mb-6">
            Explore Our Top <br />
            <span className="text-[#FF6B2C]">Categories</span>
         </h1>
         <p className="text-gray-500 font-bold mb-8 leading-relaxed">
            Find the best products across all <br className="hidden md:block" />
            categories and shop your favorites.
         </p>
         <div className="flex gap-4">
            <div className="flex items-center gap-2 bg-white px-5 py-2.5 rounded-full shadow-sm border border-[#ECECEC]">
               <div className="w-2 h-2 rounded-full bg-[#FF6B2C] animate-pulse"></div>
               <span className="text-[11px] font-black uppercase tracking-wider text-[#111827]">Trending Now</span>
            </div>
         </div>
      </div>

      <div className="relative w-full md:w-[45%] h-[300px] flex items-center justify-center mt-10 md:mt-0">
         {/* 3D-style Floating Illustration Showcase */}
         <div className="relative w-full h-full flex items-center justify-center">
            {/* Bag */}
            <div className="absolute top-0 right-1/4 w-32 h-32 bg-[#FF6B2C] rounded-3xl flex items-center justify-center text-white shadow-2xl rotate-12 animate-float">
               <ShoppingBag size={64} />
            </div>
            {/* Headphones */}
            <div className="absolute bottom-4 left-10 w-28 h-28 bg-[#FF6B2C] rounded-3xl flex items-center justify-center text-white shadow-2xl -rotate-12 animate-float-delayed">
               <Headphones size={56} />
            </div>
            {/* Watch */}
            <div className="absolute top-1/2 right-0 w-24 h-24 bg-white rounded-3xl flex items-center justify-center text-[#FF6B2C] shadow-2xl rotate-6 animate-pulse">
               <Watch size={48} />
            </div>

            {/* Large Central Element - Electronics Image */}
            <div className="w-64 h-64 bg-white rounded-full flex items-center justify-center shadow-inner border-8 border-white/50 overflow-hidden relative group">
               <img
                 src="https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&q=80&w=400"
                 alt="Electronics"
                 className="w-full h-full object-cover group-hover:scale-125 transition-transform duration-1000"
               />
               <div className="absolute inset-0 bg-[#FF6B2C]/10 mix-blend-multiply"></div>
            </div>

            {/* Floatables */}
            <div className="absolute top-10 left-1/4 w-4 h-4 bg-[#FF6B2C] rounded-full"></div>
            <div className="absolute bottom-10 right-1/3 w-6 h-6 bg-[#FF6B2C]/20 border border-[#FF6B2C] rounded-lg rotate-45"></div>
         </div>
      </div>

      {/* Decorative */}
      <div className="pointer-events-none absolute -top-20 -right-20 w-80 h-80 bg-[#FF6B2C]/5 rounded-full blur-3xl group-hover:scale-125 transition-transform duration-1000"></div>
    </div>
  );
};

export default CategoryHeroBanner;
