import React from 'react';
import { Sparkles, ShoppingBag } from 'lucide-react';

const HeroOfferBanner: React.FC = () => {
  return (
    <div className="bg-gradient-to-br from-[#FF6B2C] to-[#8B5CFF] rounded-[32px] p-8 md:p-12 mb-10 text-white relative overflow-hidden group border border-[#FF6B2C]/20">
      {/* Background Decor */}
      <div className="pointer-events-none absolute -top-10 -right-10 w-64 h-64 bg-white/10 rounded-full blur-3xl group-hover:scale-150 transition-transform duration-1000"></div>
      <div className="absolute top-1/2 left-1/4 w-32 h-32 bg-amber-400/20 rounded-full blur-2xl"></div>

      <div className="relative z-10 flex flex-col md:flex-row items-center justify-between gap-10">
        <div className="text-center md:text-left md:max-w-[50%]">
          <div className="inline-flex items-center gap-2 bg-white/20 backdrop-blur-md px-4 py-1.5 rounded-full border border-white/20 mb-6">
            <Sparkles size={14} className="text-amber-300" />
            <span className="text-[10px] font-black uppercase tracking-widest">Mega Savings!</span>
          </div>
          <h1 className="text-4xl md:text-5xl font-black leading-[1.1] mb-4">
            Get up to <br />
            <span className="text-amber-300 italic">80% OFF</span>
          </h1>
          <p className="text-sm font-bold text-white/80 uppercase tracking-[0.2em] mb-10">On top brands & categories</p>
          <button className="bg-white text-[#FF6B2C] px-10 py-3.5 rounded-xl font-black text-sm uppercase tracking-widest hover:scale-105 active:scale-95 transition-all shadow-xl shadow-black/10">
            Shop Now
          </button>
        </div>

        <div className="relative w-full md:w-[45%] h-[200px] flex items-center justify-center">
          {/* 3D Illustration Mockup */}
          <div className="relative w-full h-full flex items-center justify-center">
            <div className="absolute right-0 w-32 h-32 bg-white/20 backdrop-blur-md rounded-3xl flex items-center justify-center rotate-12 animate-float">
               <ShoppingBag size={64} className="text-white opacity-40" />
            </div>
            <div className="absolute left-10 bottom-0 w-24 h-24 bg-amber-400 rounded-3xl flex items-center justify-center shadow-2xl -rotate-12 animate-float-delayed">
               <span className="text-3xl font-black text-white">%</span>
            </div>
            {/* Gift Box Renders */}
            <div className="w-48 h-48 bg-white/10 rounded-full border-8 border-white/5 flex items-center justify-center overflow-hidden">
               <div className="w-32 h-32 bg-white rounded-2xl rotate-45 flex items-center justify-center shadow-2xl">
                  <div className="w-full h-full bg-[#FF6B2C]/10 rounded-xl flex items-center justify-center -rotate-45">
                     <Sparkles size={48} className="text-[#FF6B2C]" />
                  </div>
               </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default HeroOfferBanner;
