import React from 'react';

const sizes = ['6', '7', '8', '9', '10', '11'];

const SizeSelector: React.FC = () => {
  return (
    <div className="mb-8">
      <div className="flex items-center justify-between mb-4">
        <span className="text-[11px] font-bold text-gray-500 uppercase tracking-widest">Select Size:</span>
        <button className="text-[11px] font-black text-[#6C2BFF] uppercase tracking-widest hover:underline">Size Chart</button>
      </div>
      <div className="flex flex-wrap gap-3">
        {sizes.map((s, i) => (
          <button
            key={i}
            className={`w-12 h-12 flex items-center justify-center rounded-xl text-sm font-black transition-all border-2 ${
              s === '8' ? 'border-[#6C2BFF] text-[#6C2BFF] bg-[#6C2BFF]/5' : 'border-[#ECECEC] text-gray-600 hover:border-gray-400'
            }`}
          >
            {s}
          </button>
        ))}
      </div>
    </div>
  );
};

export default SizeSelector;
