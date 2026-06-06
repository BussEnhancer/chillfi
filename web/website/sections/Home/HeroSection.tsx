import React from 'react';
import Container from '../../components/common/Container';
import { ChevronLeft, ChevronRight } from 'lucide-react';

const HeroSection: React.FC = () => {
  return (
    <section className="py-8">
      <Container>
        <div className="relative h-[500px] rounded-[32px] overflow-hidden bg-gradient-to-br from-[#6C2BFF] to-[#A166FF] flex items-center px-12 md:px-20">
          {/* Background Decorative Elements */}
          <div className="absolute top-10 right-1/4 w-32 h-32 bg-white opacity-10 rounded-full blur-3xl animate-pulse"></div>
          <div className="absolute bottom-10 left-1/4 w-40 h-40 bg-[#FF6B2C] opacity-20 rounded-full blur-3xl"></div>

          {/* Content */}
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
            <button className="bg-white text-[#6C2BFF] px-10 py-4 rounded-full font-bold text-lg hover:shadow-2xl hover:scale-105 transition-all active:scale-95 shadow-lg">
              Shop Now
            </button>
          </div>

          {/* Product Showcase (Mockup) */}
          <div className="absolute right-0 top-0 bottom-0 w-1/2 flex items-center justify-center p-10">
            <div className="relative w-full h-full flex items-center justify-center">
              {/* Product 1: Watch */}
              <div className="absolute left-0 bottom-20 w-[240px] h-[240px] rounded-full bg-white/10 backdrop-blur-sm border border-white/20 p-4 transform -rotate-12 hover:rotate-0 transition-transform duration-500">
                 <img src="https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&q=80&w=400" alt="Watch" className="w-full h-full object-cover rounded-full shadow-2xl" />
              </div>
              {/* Product 2: Sneakers */}
              <div className="absolute right-10 top-20 w-[320px] h-[320px] rounded-full bg-white/10 backdrop-blur-sm border border-white/20 p-6 transform rotate-6 hover:rotate-0 transition-transform duration-500 z-20">
                 <img src="https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&q=80&w=500" alt="Sneakers" className="w-full h-full object-cover rounded-full shadow-2xl" />
              </div>
              {/* Product 3: Bag */}
              <div className="absolute right-0 bottom-10 w-[200px] h-[200px] rounded-full bg-white/10 backdrop-blur-sm border border-white/20 p-4 transform -rotate-6 hover:rotate-0 transition-transform duration-500 z-10">
                 <img src="https://images.unsplash.com/photo-1548036328-c9fa89d128fa?auto=format&fit=crop&q=80&w=400" alt="Bag" className="w-full h-full object-cover rounded-full shadow-2xl" />
              </div>
            </div>
          </div>

          {/* Controls */}
          <button className="absolute left-6 top-1/2 -translate-y-1/2 w-12 h-12 bg-white/20 backdrop-blur-md rounded-full flex items-center justify-center text-white hover:bg-white hover:text-[#6C2BFF] transition-all border border-white/20">
            <ChevronLeft size={24} />
          </button>
          <button className="absolute right-6 top-1/2 -translate-y-1/2 w-12 h-12 bg-white/20 backdrop-blur-md rounded-full flex items-center justify-center text-white hover:bg-white hover:text-[#6C2BFF] transition-all border border-white/20">
            <ChevronRight size={24} />
          </button>

          {/* Pagination */}
          <div className="absolute bottom-8 left-1/2 -translate-x-1/2 flex gap-3">
            <div className="w-3 h-3 rounded-full bg-white"></div>
            <div className="w-3 h-3 rounded-full bg-white/40 cursor-pointer hover:bg-white/60"></div>
            <div className="w-3 h-3 rounded-full bg-white/40 cursor-pointer hover:bg-white/60"></div>
          </div>
        </div>
      </Container>
    </section>
  );
};

export default HeroSection;
