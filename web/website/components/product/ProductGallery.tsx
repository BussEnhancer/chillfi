import React, { useState } from 'react';
import { ChevronLeft, ChevronRight, Heart, Maximize2 } from 'lucide-react';

const FALLBACK = 'https://images.unsplash.com/photo-1512374382149-233c42b6a83b?auto=format&fit=crop&q=80&w=600';

interface ProductGalleryProps {
  images?: string[];
  isWishlisted?: boolean;
  onWishlistToggle?: () => void;
}

const ProductGallery: React.FC<ProductGalleryProps> = ({
  images = [FALLBACK],
  isWishlisted = false,
  onWishlistToggle,
}) => {
  const [active, setActive] = useState(0);
  const imgs = images.length ? images : [FALLBACK];

  const prev = () => setActive(i => (i - 1 + imgs.length) % imgs.length);
  const next = () => setActive(i => (i + 1) % imgs.length);

  return (
    <div className="flex flex-col lg:flex-row gap-6">
      {/* Thumbnails */}
      <div className="flex lg:flex-col gap-3 order-2 lg:order-1">
        {imgs.map((img, i) => (
          <button
            key={i}
            onClick={() => setActive(i)}
            className={`w-16 h-16 md:w-20 md:h-20 rounded-xl border-2 overflow-hidden transition-all ${
              i === active ? 'border-[#FF6B2C]' : 'border-[#ECECEC] hover:border-gray-300'
            }`}
          >
            <img src={img} alt={`View ${i + 1}`} className="w-full h-full object-cover" />
          </button>
        ))}
      </div>

      {/* Main Image */}
      <div className="flex-1 bg-[#F8F7FC] rounded-[32px] border border-[#ECECEC] relative aspect-square flex items-center justify-center overflow-hidden group order-1 lg:order-2">
        <img
          src={imgs[active]}
          alt="Product"
          className="w-[85%] h-[85%] object-contain group-hover:scale-110 transition-transform duration-700"
        />

        {imgs.length > 1 && (
          <>
            <button onClick={prev} className="absolute left-4 top-1/2 -translate-y-1/2 w-10 h-10 bg-white shadow-md rounded-full flex items-center justify-center text-gray-400 hover:text-[#FF6B2C] transition-all opacity-100 lg:opacity-0 lg:group-hover:opacity-100" aria-label="Image navigation">
              <ChevronLeft size={20} />
            </button>
            <button onClick={next} className="absolute right-14 top-1/2 -translate-y-1/2 w-10 h-10 bg-white shadow-md rounded-full flex items-center justify-center text-gray-400 hover:text-[#FF6B2C] transition-all opacity-100 lg:opacity-0 lg:group-hover:opacity-100" aria-label="Image navigation">
              <ChevronRight size={20} />
            </button>
          </>
        )}

        <button
          onClick={onWishlistToggle}
          className={`absolute top-6 right-6 w-10 h-10 bg-white shadow-md rounded-full flex items-center justify-center transition-all ${
            isWishlisted ? 'text-red-500' : 'text-gray-400 hover:text-red-400'
          }`}
        >
          <Heart size={20} className={isWishlisted ? 'fill-red-500' : ''} />
        </button>

        <button className="absolute bottom-6 left-6 bg-white/80 backdrop-blur-sm px-4 py-2 rounded-lg flex items-center gap-2 text-[11px] font-black uppercase tracking-wider text-[#111827] shadow-sm hover:bg-white transition-all">
          <Maximize2 size={14} className="text-[#FF6B2C]" />
          {imgs.length > 1 ? `${active + 1} / ${imgs.length}` : 'Product Image'}
        </button>
      </div>
    </div>
  );
};

export default ProductGallery;
