import React, { useState, useEffect } from 'react';

const MIN = 0;
const MAX = 100000;

interface PriceRangeSliderProps {
  minPrice?: number;
  maxPrice?: number;
  onChange?: (min: number, max: number) => void;
}

const PriceRangeSlider: React.FC<PriceRangeSliderProps> = ({ minPrice, maxPrice, onChange }) => {
  const [min, setMin] = useState(minPrice ?? MIN);
  const [max, setMax] = useState(maxPrice ?? MAX);

  useEffect(() => { setMin(minPrice ?? MIN); }, [minPrice]);
  useEffect(() => { setMax(maxPrice ?? MAX); }, [maxPrice]);

  const commit = (nextMin: number, nextMax: number) => {
    setMin(nextMin); setMax(nextMax);
    onChange?.(nextMin, nextMax);
  };

  const clear = () => commit(MIN, MAX);

  const leftPct = Math.min(100, (min / MAX) * 100);
  const rightPct = Math.min(100, 100 - (max / MAX) * 100);

  return (
    <div className="mb-8">
      <div className="flex items-center justify-between mb-6">
        <h3 className="text-sm font-black text-[#111827] uppercase tracking-wider">Price Range</h3>
        <button onClick={clear} className="text-[10px] font-black text-[#FF6B2C] uppercase tracking-widest hover:underline">Clear All</button>
      </div>

      <div className="relative h-1.5 bg-gray-100 rounded-full mb-6">
        <div className="absolute h-full bg-[#FF6B2C] rounded-full" style={{ left: `${leftPct}%`, right: `${rightPct}%` }} />
      </div>
      <input
        type="range"
        min={MIN}
        max={MAX}
        step={500}
        value={min}
        onChange={e => commit(Math.min(+e.target.value, max - 500), max)}
        className="w-full accent-[#FF6B2C] mb-2"
      />
      <input
        type="range"
        min={MIN}
        max={MAX}
        step={500}
        value={max}
        onChange={e => commit(min, Math.max(+e.target.value, min + 500))}
        className="w-full accent-[#FF6B2C] mb-4"
      />

      <div className="flex items-center gap-3">
        <div className="flex-1">
          <label className="text-[10px] font-bold text-gray-400 uppercase mb-1 block">Min Price</label>
          <div className="flex items-center gap-1 border border-[#ECECEC] rounded-lg px-3 py-2 bg-gray-50/50">
            <span className="text-xs font-bold text-gray-500">₹</span>
            <input
              type="number"
              value={min}
              onChange={e => commit(Math.min(+e.target.value || 0, max - 500), max)}
              className="bg-transparent text-sm font-black w-full outline-none"
            />
          </div>
        </div>
        <div className="flex-1">
          <label className="text-[10px] font-bold text-gray-400 uppercase mb-1 block">Max Price</label>
          <div className="flex items-center gap-1 border border-[#ECECEC] rounded-lg px-3 py-2 bg-gray-50/50">
            <span className="text-xs font-bold text-gray-500">₹</span>
            <input
              type="number"
              value={max}
              onChange={e => commit(min, Math.max(+e.target.value || 0, min + 500))}
              className="bg-transparent text-sm font-black w-full outline-none"
            />
          </div>
        </div>
      </div>
    </div>
  );
};

export default PriceRangeSlider;
