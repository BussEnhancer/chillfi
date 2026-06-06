import React from 'react';

const colors = [
  { name: 'Black / White', image: 'https://images.unsplash.com/photo-1512374382149-233c42b6a83b?auto=format&fit=crop&q=80&w=100' },
  { name: 'Navy / Blue', image: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&q=80&w=100' },
  { name: 'Pure White', image: 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?auto=format&fit=crop&q=80&w=100' },
  { name: 'Grey / Slate', image: 'https://images.unsplash.com/photo-1511556532299-8f662fc26c06?auto=format&fit=crop&q=80&w=100' },
];

const ColorSelector: React.FC = () => {
  return (
    <div className="mb-8">
      <div className="flex items-center gap-2 mb-4">
        <span className="text-sm font-bold text-gray-500 uppercase tracking-widest text-[11px]">Color:</span>
        <span className="text-sm font-black text-[#111827]">Black / White</span>
      </div>
      <div className="flex gap-4">
        {colors.map((c, i) => (
          <div
            key={i}
            className={`w-14 h-14 rounded-xl border-2 overflow-hidden cursor-pointer transition-all hover:scale-105 ${
              i === 0 ? 'border-[#6C2BFF]' : 'border-transparent bg-gray-50'
            }`}
          >
            <img src={c.image} alt={c.name} className="w-full h-full object-cover" />
          </div>
        ))}
      </div>
    </div>
  );
};

export default ColorSelector;
