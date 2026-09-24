import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import Container from '../../components/common/Container';
import { ChevronLeft, ChevronRight } from 'lucide-react';

export interface ApiBanner {
  id: string;
  title?: string;
  subtitle?: string;
  image_url: string;
  link?: string;
  background_color?: string;
}

interface HeroSectionProps {
  banners?: ApiBanner[];
}

const STATIC_SLIDE = {
  title: 'Upgrade Your Lifestyle With Best Deals',
  subtitle: 'Shop top products across electronics, audio, wearables & more.',
  link: '/products',
  image_url: '',
  background_color: '',
};

const HeroSection: React.FC<HeroSectionProps> = ({ banners }) => {
  const [idx, setIdx] = useState(0);

  const slides = banners && banners.length > 0 ? banners : null;
  const slide = slides ? slides[idx] : null;

  useEffect(() => {
    if (!slides || slides.length <= 1) return;
    const t = setInterval(() => setIdx(i => (i + 1) % slides.length), 5000);
    return () => clearInterval(t);
  }, [slides]);

  const prev = () => slides && setIdx(i => (i - 1 + slides.length) % slides.length);
  const next = () => slides && setIdx(i => (i + 1) % slides.length);

  if (slide) {
    return (
      <section className="py-8">
        <Container>
          <div
            className="relative h-[500px] rounded-[32px] overflow-hidden flex items-center px-12 md:px-20"
            style={{
              background: slide.background_color
                ? slide.background_color
                : 'linear-gradient(135deg, #FF6B2C, #A166FF)',
            }}
          >
            {slide.image_url && (
              <img
                src={slide.image_url}
                alt={slide.title || 'Banner'}
                className="absolute inset-0 w-full h-full object-cover"
              />
            )}
            <div className="absolute inset-0 bg-black/30" />

            <div className="relative z-10 max-w-[550px] text-white">
              {slide.title && (
                <h1 className="text-4xl md:text-5xl font-black leading-tight mb-4">{slide.title}</h1>
              )}
              {slide.subtitle && (
                <p className="text-lg text-white/80 mb-10 leading-relaxed font-medium">{slide.subtitle}</p>
              )}
              <Link
                to={slide.link || '/products'}
                className="inline-block bg-white text-[#FF6B2C] px-10 py-4 rounded-full font-bold text-lg hover:shadow-2xl hover:scale-105 transition-all active:scale-95 shadow-lg"
              >
                Shop Now
              </Link>
            </div>

            {slides && slides.length > 1 && (
              <>
                <button onClick={prev} className="hidden md:flex absolute left-6 top-1/2 -translate-y-1/2 w-12 h-12 bg-white/20 backdrop-blur-md rounded-full items-center justify-center text-white hover:bg-white hover:text-[#FF6B2C] transition-all border border-white/20 z-20">
                  <ChevronLeft size={24} />
                </button>
                <button onClick={next} className="hidden md:flex absolute right-6 top-1/2 -translate-y-1/2 w-12 h-12 bg-white/20 backdrop-blur-md rounded-full items-center justify-center text-white hover:bg-white hover:text-[#FF6B2C] transition-all border border-white/20 z-20">
                  <ChevronRight size={24} />
                </button>
                <div className="absolute bottom-8 left-1/2 -translate-x-1/2 flex gap-3 z-20">
                  {slides.map((_, i) => (
                    <button key={i} onClick={() => setIdx(i)} className={`h-3 rounded-full transition-all ${i === idx ? 'w-6 bg-white' : 'w-3 bg-white/40 hover:bg-white/60'}`} />
                  ))}
                </div>
              </>
            )}
          </div>
        </Container>
      </section>
    );
  }

  // Static fallback
  return (
    <section className="py-8">
      <Container>
        <div className="relative h-[500px] rounded-[32px] overflow-hidden bg-gradient-to-br from-[#FF6B2C] to-[#A166FF] flex items-center px-12 md:px-20">
          <div className="pointer-events-none absolute top-10 right-1/4 w-32 h-32 bg-white opacity-10 rounded-full blur-3xl animate-pulse" />
          <div className="pointer-events-none absolute bottom-10 left-1/4 w-40 h-40 bg-[#FF6B2C] opacity-20 rounded-full blur-3xl" />

          <div className="relative z-10 max-w-[550px] text-white">
            <span className="inline-block bg-white/20 backdrop-blur-md px-4 py-1.5 rounded-full text-xs font-bold uppercase tracking-widest mb-6 border border-white/20">
              Biggest Sale of the Season
            </span>
            <h1 className="text-5xl md:text-6xl font-bold leading-[1.1] mb-6">
              Upgrade Your Lifestyle <br />
              <span className="text-white/80">With Best Deals</span>
            </h1>
            <p className="text-lg text-white/80 mb-10 leading-relaxed font-medium">
              Shop top products across fashion, electronics, home & more with exciting offers.
            </p>
            <Link to="/products" className="inline-block bg-white text-[#FF6B2C] px-10 py-4 rounded-full font-bold text-lg hover:shadow-2xl hover:scale-105 transition-all active:scale-95 shadow-lg">
              Shop Now
            </Link>
          </div>

          <div className="absolute right-0 top-0 bottom-0 w-1/2 flex items-center justify-center p-10">
            <div className="relative w-full h-full flex items-center justify-center">
              <div className="absolute left-0 bottom-20 w-[240px] h-[240px] rounded-full bg-white/10 backdrop-blur-sm border border-white/20 p-4 transform -rotate-12 hover:rotate-0 transition-transform duration-500">
                <img src="https://images.unsplash.com/photo-1496181133206-80ce9b88a853?auto=format&fit=crop&q=80&w=400" alt="Laptop" className="w-full h-full object-cover rounded-full shadow-2xl" />
              </div>
              <div className="absolute right-10 top-20 w-[320px] h-[320px] rounded-full bg-white/10 backdrop-blur-sm border border-white/20 p-6 transform rotate-6 hover:rotate-0 transition-transform duration-500 z-20">
                <img src="https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&q=80&w=500" alt="Smartphone" className="w-full h-full object-cover rounded-full shadow-2xl" />
              </div>
              <div className="absolute right-0 bottom-10 w-[200px] h-[200px] rounded-full bg-white/10 backdrop-blur-sm border border-white/20 p-4 transform -rotate-6 hover:rotate-0 transition-transform duration-500 z-10">
                <img src="https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&q=80&w=400" alt="Headphones" className="w-full h-full object-cover rounded-full shadow-2xl" />
              </div>
            </div>
          </div>

          <button onClick={prev} className="hidden md:flex absolute left-6 top-1/2 -translate-y-1/2 w-12 h-12 bg-white/20 backdrop-blur-md rounded-full items-center justify-center text-white hover:bg-white hover:text-[#FF6B2C] transition-all border border-white/20">
            <ChevronLeft size={24} />
          </button>
          <button onClick={next} className="hidden md:flex absolute right-6 top-1/2 -translate-y-1/2 w-12 h-12 bg-white/20 backdrop-blur-md rounded-full items-center justify-center text-white hover:bg-white hover:text-[#FF6B2C] transition-all border border-white/20">
            <ChevronRight size={24} />
          </button>

          <div className="absolute bottom-8 left-1/2 -translate-x-1/2 flex gap-3">
            <div className="w-3 h-3 rounded-full bg-white" />
            <div className="w-3 h-3 rounded-full bg-white/40 cursor-pointer hover:bg-white/60" />
            <div className="w-3 h-3 rounded-full bg-white/40 cursor-pointer hover:bg-white/60" />
          </div>
        </div>
      </Container>
    </section>
  );
};

export default HeroSection;
