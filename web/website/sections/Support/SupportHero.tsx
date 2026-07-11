import React from 'react';
import { Search, Sparkles } from 'lucide-react';

const SupportHero: React.FC = () => {
  return (
    <div className="bg-[#FFF8F5] rounded-[32px] p-8 md:p-12 mb-12 relative overflow-hidden group border border-[#FF6B2C]/10">
      <div className="relative z-10 flex flex-col md:flex-row items-center justify-between gap-10">
        <div className="flex-1 w-full text-center md:text-left">
          <h1 className="text-3xl md:text-4xl font-black text-[#111827] leading-tight mb-4">
            How can we <span className="text-[#FF6B2C]">help you?</span>
          </h1>
          <p className="text-sm font-bold text-gray-400 mb-8 uppercase tracking-widest">Search our help articles or browse topics</p>

          <div className="flex bg-white p-2 rounded-2xl border border-[#ECECEC] shadow-sm focus-within:border-[#FF6B2C] transition-all max-w-[600px] mx-auto md:mx-0">
            <div className="flex items-center gap-3 flex-1 px-4">
              <Search size={20} className="text-gray-400" />
              <input
                type="text"
                placeholder="Search for help articles..."
                className="w-full bg-transparent outline-none text-sm font-bold text-[#111827]"
              />
            </div>
            <button className="bg-[#FF6B2C] text-white px-8 py-3 rounded-xl font-black text-sm uppercase tracking-widest hover:bg-[#E05520] transition-all shadow-lg shadow-[#FF6B2C]/20">
              Search
            </button>
          </div>

          {/* Popular Searches */}
          <div className="mt-6 flex flex-wrap items-center justify-center md:justify-start gap-4">
            <span className="text-[10px] font-black text-gray-400 uppercase tracking-widest">Popular searches:</span>
            {['Track Order', 'Return & Refund', 'Cancel Order', 'Payment Help'].map((tag) => (
              <button key={tag} className="bg-white border border-[#ECECEC] px-3 py-1.5 rounded-lg text-[10px] font-bold text-[#111827] hover:border-[#FF6B2C] hover:text-[#FF6B2C] transition-all shadow-sm">
                {tag}
              </button>
            ))}
          </div>
        </div>

        {/* Support Illustration */}
        <div className="relative w-full md:w-[40%] h-[200px] flex items-center justify-center">
           <div className="relative w-48 h-48 bg-white rounded-[40px] flex items-center justify-center text-[#FF6B2C] shadow-2xl rotate-6 group-hover:rotate-0 transition-transform duration-700">
              <div className="w-full h-full bg-[#FF6B2C]/5 rounded-3xl flex items-center justify-center">
                <Sparkles size={80} className="animate-pulse" />
              </div>
              {/* Badge */}
              <div className="absolute -top-4 -right-4 bg-amber-400 text-white px-3 py-1.5 rounded-xl font-black text-[10px] uppercase tracking-widest shadow-lg rotate-12">
                 24/7 Support
              </div>
           </div>
           {/* Decorative floating dots/shapes */}
           <div className="absolute top-0 left-1/4 w-3 h-3 bg-[#FF6B2C] rounded-full animate-bounce"></div>
           <div className="absolute bottom-4 right-1/4 w-4 h-4 bg-[#FF6B2C] rounded-lg rotate-45 animate-float"></div>
        </div>
      </div>

      {/* Background Decor */}
      <div className="absolute -top-10 -right-10 w-64 h-64 bg-white/50 rounded-full blur-3xl group-hover:scale-150 transition-transform duration-1000"></div>
    </div>
  );
};

export default SupportHero;
