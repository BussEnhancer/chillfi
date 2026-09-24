import React from 'react';
import { ShoppingBag } from 'lucide-react';

const PLP_HeroBanner: React.FC = () => {
  return (
    <div className="relative bg-[#F8F7FC] rounded-[32px] p-8 md:p-12 mb-10 flex flex-col md:flex-row items-center justify-between border border-[#ECECEC] overflow-hidden group">
      <div className="relative z-10 md:max-w-[50%] text-center md:text-left">
         <h2 className="text-3xl md:text-4xl font-black text-[#111827] leading-tight mb-4">
            Power Up Your <span className="text-[#FF6B2C]">Tech</span>
         </h2>
         <p className="text-gray-500 font-bold">Premium Electronics Collection <br className="hidden md:block" /> Free delivery on orders above ₹499</p>
      </div>

      <div className="relative w-full md:w-[45%] h-[200px] flex items-center justify-center mt-8 md:mt-0">
         {/* 3D Package and Product */}
         <div className="relative w-full h-full flex items-center justify-center">
            {/* Box */}
            <div className="absolute right-0 w-48 h-32 bg-[#FF6B2C] rounded-2xl flex flex-col items-center justify-center text-white shadow-2xl rotate-6 group-hover:rotate-0 transition-transform duration-700">
               <ShoppingBag size={32} className="mb-2 opacity-40" />
               <span className="text-sm font-black tracking-tighter uppercase">chillFi</span>
            </div>
            {/* Shoes Illustration */}
            <div className="absolute left-0 top-0 w-56 h-48 flex items-center justify-center -rotate-12 group-hover:rotate-0 transition-transform duration-700">
               <img
                 src="https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&q=80&w=400"
                 alt="Smartphone"
                 className="w-full h-full object-contain drop-shadow-[0_20px_40px_rgba(0,0,0,0.1)]"
               />
            </div>
         </div>
      </div>

      {/* Background Decor */}
      <div className="pointer-events-none absolute -bottom-10 -left-10 w-40 h-40 bg-[#FF6B2C]/5 rounded-full blur-3xl group-hover:scale-150 transition-transform duration-1000"></div>
    </div>
  );
};

export default PLP_HeroBanner;
