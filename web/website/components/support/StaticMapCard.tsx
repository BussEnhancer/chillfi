import React from 'react';
import { MapPin } from 'lucide-react';

const StaticMapCard: React.FC = () => {
  return (
    <div className="bg-gray-100 rounded-[24px] overflow-hidden border border-[#ECECEC] relative h-[400px] lg:h-auto min-h-[350px] shadow-inner group">
      {/* Mock Map Background Grid */}
      <div className="absolute inset-0 opacity-20 pointer-events-none" style={{
        backgroundImage: 'radial-gradient(#FF6B2C 0.5px, transparent 0.5px)',
        backgroundSize: '20px 20px'
      }}></div>

      {/* Mock Roads/Paths */}
      <div className="absolute inset-0 pointer-events-none">
        <div className="absolute top-1/2 left-0 w-full h-8 bg-white/40 -translate-y-1/2 rotate-[-10deg]"></div>
        <div className="absolute top-0 left-1/2 w-10 h-full bg-white/40 -translate-x-1/2 rotate-[15deg]"></div>
      </div>

      {/* Location Pin */}
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 flex flex-col items-center group-hover:scale-110 transition-transform duration-500">
        <div className="w-12 h-12 bg-[#FF6B2C] rounded-full flex items-center justify-center text-white shadow-2xl relative animate-bounce">
           <MapPin size={24} />
           <div className="absolute -bottom-1 left-1/2 -translate-x-1/2 w-2 h-2 bg-[#FF6B2C] rotate-45"></div>
        </div>
      </div>

      {/* Address Overlay */}
      <div className="absolute top-6 right-6 bg-white/90 backdrop-blur-md p-5 rounded-2xl shadow-2xl border border-white/50 max-w-[220px]">
        <h5 className="text-[11px] font-black text-[#111827] uppercase tracking-widest mb-1">chillFi Headquarters</h5>
        <p className="text-[10px] font-bold text-gray-500 leading-tight">
          123, Green Park Society, Indiranagar, Bengaluru, 560038
        </p>
      </div>

      {/* UI Controls */}
      <div className="absolute bottom-6 right-6 flex flex-col gap-2">
         <button className="w-10 h-10 bg-white rounded-xl flex items-center justify-center text-gray-400 font-bold shadow-lg hover:text-[#FF6B2C] transition-all">+</button>
         <button className="w-10 h-10 bg-white rounded-xl flex items-center justify-center text-gray-400 font-bold shadow-lg hover:text-[#FF6B2C] transition-all">-</button>
      </div>
    </div>
  );
};

export default StaticMapCard;
