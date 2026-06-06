import React from 'react';
import { ChevronLeft, ChevronRight, Heart, Maximize2 } from 'lucide-react';

const images = [
  'https://images.unsplash.com/photo-1512374382149-233c42b6a83b?auto=format&fit=crop&q=80&w=600',
  'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&q=80&w=600',
  'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?auto=format&fit=crop&q=80&w=600',
  'https://images.unsplash.com/photo-1605348532760-6753d2c43329?auto=format&fit=crop&q=80&w=600',
  'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?auto=format&fit=crop&q=80&w=600',
];

const ProductGallery: React.FC = () => {
  return (
    <div className="flex flex-col lg:flex-row gap-6">
      {/* Thumbnails */}
      <div className="flex lg:flex-col gap-3 order-2 lg:order-1">
        {images.map((img, i) => (
          <div
            key={i}
            className={`w-16 h-16 md:w-20 md:h-20 rounded-xl border-2 overflow-hidden cursor-pointer transition-all ${
              i === 0 ? 'border-[#6C2BFF]' : 'border-[#ECECEC] hover:border-gray-300'
            }`}
          >
            <img src={img} alt={`Product ${i + 1}`} className="w-full h-full object-cover" />
          </div>
        ))}
        <div className="w-16 h-16 md:w-20 md:h-20 rounded-xl border-2 border-[#ECECEC] flex flex-col items-center justify-center text-gray-400 hover:border-gray-300 cursor-pointer">
           <span className="text-[10px] font-black uppercase">Video</span>
        </div>
      </div>

      {/* Main Image */}
      <div className="flex-1 bg-[#F8F7FC] rounded-[32px] border border-[#ECECEC] relative aspect-square flex items-center justify-center overflow-hidden group order-1 lg:order-2">
         <img
           src={images[0]}
           alt="Main Product"
           className="w-[85%] h-[85%] object-contain group-hover:scale-110 transition-transform duration-700"
         />

         {/* Navigation Arrows */}
         <button className="absolute left-6 top-1/2 -translate-y-1/2 w-10 h-10 bg-white shadow-md rounded-full flex items-center justify-center text-gray-400 hover:text-[#6C2BFF] transition-all opacity-0 group-hover:opacity-100">
            <ChevronLeft size={20} />
         </button>
         <button className="absolute right-6 top-1/2 -translate-y-1/2 w-10 h-10 bg-white shadow-md rounded-full flex items-center justify-center text-gray-400 hover:text-[#6C2BFF] transition-all opacity-0 group-hover:opacity-100">
            <ChevronRight size={20} />
         </button>

         {/* Actions */}
         <button className="absolute top-6 right-6 w-10 h-10 bg-white shadow-md rounded-full flex items-center justify-center text-gray-400 hover:text-[#FF4D4F] transition-all">
            <Heart size={20} />
         </button>

         <button className="absolute bottom-6 left-6 bg-white/80 backdrop-blur-sm px-4 py-2 rounded-lg flex items-center gap-2 text-[11px] font-black uppercase tracking-wider text-[#111827] shadow-sm hover:bg-white transition-all">
            <Maximize2 size={14} className="text-[#6C2BFF]" />
            View Similar
         </button>
      </div>
    </div>
  );
};

export default ProductGallery;
