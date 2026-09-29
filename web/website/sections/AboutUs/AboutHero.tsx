import React from 'react';
import { Link } from 'react-router-dom';
import { ChevronRight } from 'lucide-react';

const AboutHero: React.FC = () => {
  return (
    <section className="py-16 md:py-24">
      <div className="flex flex-col lg:flex-row items-center gap-12 lg:gap-20">
        {/* Left Side: Content */}
        <div className="flex-1 text-center lg:text-left">
          <h1 className="text-4xl md:text-5xl lg:text-6xl font-black text-[#111827] leading-[1.1] mb-6">
            About <span className="text-[#FF6B2C]">ChillFi</span>
          </h1>
          <h2 className="text-xl md:text-2xl font-bold text-[#FF6B2C] mb-8">
            Shopping made easy. Prices that make you smile.
          </h2>
          <div className="space-y-6 text-gray-500 font-medium leading-relaxed max-w-[600px] mx-auto lg:mx-0">
            <p>
              At ChillFi, we believe shopping should be simple, affordable and enjoyable for everyone.
              From the latest gadgets to everyday essentials, we bring you a wide range of quality
              products at the best prices, delivered right to your doorstep.
            </p>
            <p>
              Our mission is to create a trusted online shopping experience with hassle-free service,
              secure payments and friendly daily support.
            </p>
          </div>

          <Link to="/products" className="w-fit mt-10 bg-gradient-to-r from-[#FF6B2C] to-[#8B5CFF] text-white px-10 py-4 rounded-2xl font-black text-sm uppercase tracking-widest flex items-center justify-center gap-3 shadow-xl shadow-[#FF6B2C]/20 hover:scale-[1.02] active:scale-[0.98] transition-all mx-auto lg:mx-0">
            Explore Our Products
            <ChevronRight size={20} />
          </Link>
        </div>

        {/* Right Side: Image */}
        <div className="flex-1 w-full max-w-[600px]">
          <div className="bg-[#FFF8F5] rounded-[40px] p-4 md:p-8 border border-[#ECECEC] shadow-sm overflow-hidden group">
            <div className="relative aspect-[4/3] rounded-[32px] overflow-hidden bg-white flex items-center justify-center shadow-inner">
               {/* Mock Hero Image */}
               <img
                 src="https://images.unsplash.com/photo-1556742044-3c52d6e88c62?auto=format&fit=crop&q=80&w=800"
                 alt="ChillFi Team/Shopping"
                 className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-1000"
               />
               <div className="absolute inset-0 bg-[#FF6B2C]/5 mix-blend-multiply"></div>
               {/* Floating elements to match reference look */}
               <div className="absolute top-6 left-6 w-12 h-12 bg-[#FF6B2C] rounded-2xl flex items-center justify-center text-white shadow-lg animate-bounce">
                  <span className="text-xl font-black">cf</span>
               </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
};

export default AboutHero;
