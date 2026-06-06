import React from 'react';

const PriceRangeSlider: React.FC = () => {
  return (
    <div className="mb-8">
      <div className="flex items-center justify-between mb-6">
        <h3 className="text-sm font-black text-[#111827] uppercase tracking-wider">Price Range</h3>
        <button className="text-[10px] font-black text-[#6C2BFF] uppercase tracking-widest hover:underline">Clear All</button>
      </div>

      {/* Track UI */}
      <div className="relative h-1.5 bg-gray-100 rounded-full mb-6">
        <div className="absolute left-[10%] right-[30%] h-full bg-[#6C2BFF] rounded-full"></div>
        <div className="absolute left-[10%] -top-1.5 w-4 h-4 bg-white border-2 border-[#6C2BFF] rounded-full shadow-md cursor-pointer"></div>
        <div className="absolute right-[30%] -top-1.5 w-4 h-4 bg-white border-2 border-[#6C2BFF] rounded-full shadow-md cursor-pointer"></div>
      </div>

      <div className="flex items-center gap-3">
        <div className="flex-1">
          <label className="text-[10px] font-bold text-gray-400 uppercase mb-1 block">Min Price</label>
          <div className="flex items-center gap-1 border border-[#ECECEC] rounded-lg px-3 py-2 bg-gray-50/50">
            <span className="text-xs font-bold text-gray-500">₹</span>
            <input type="text" value="499" className="bg-transparent text-sm font-black w-full outline-none" readOnly />
          </div>
        </div>
        <div className="flex-1">
          <label className="text-[10px] font-bold text-gray-400 uppercase mb-1 block">Max Price</label>
          <div className="flex items-center gap-1 border border-[#ECECEC] rounded-lg px-3 py-2 bg-gray-50/50">
            <span className="text-xs font-bold text-gray-500">₹</span>
            <input type="text" value="4999" className="bg-transparent text-sm font-black w-full outline-none" readOnly />
          </div>
        </div>
      </div>
    </div>
  );
};

export default PriceRangeSlider;
