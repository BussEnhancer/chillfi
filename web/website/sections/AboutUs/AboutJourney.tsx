import React from 'react';
import { Rocket, Users, TrendingUp, ShoppingBag } from 'lucide-react';

const AboutJourney: React.FC = () => {
  return (
    <section className="py-20 mb-20">
      <div className="bg-[#FFF8F5] rounded-[40px] border border-[#ECECEC] p-10 md:p-16 relative overflow-hidden group">
        <div className="relative z-10 flex flex-col xl:flex-row items-center justify-between gap-12">

          {/* Left Side: Illustration */}
          <div className="xl:w-[200px] shrink-0 flex items-center justify-center">
            <div className="w-40 h-40 bg-white rounded-3xl flex items-center justify-center text-[#FF6B2C] shadow-2xl rotate-12 group-hover:rotate-0 transition-transform duration-700">
               <ShoppingBag size={80} />
            </div>
          </div>

          {/* Center: Content */}
          <div className="flex-1 text-center xl:text-left">
            <h2 className="text-3xl font-black text-[#111827] mb-6 uppercase tracking-tight">Our Journey</h2>
            <p className="text-sm font-bold text-gray-400 leading-relaxed max-w-[600px] mx-auto xl:mx-0">
              Founded in 2021, ChillFi started with a simple idea — to revolutionize online shopping in India.
              Today, we continue to innovate, grow and serve with the same passion and commitment.
            </p>
          </div>

          {/* Right Side: Mini Stats */}
          <div className="flex flex-wrap md:flex-nowrap gap-10 xl:w-[450px]">
             {[
               { icon: <Rocket size={20} />, label: '2021', sub: 'Founded' },
               { icon: <Users size={20} />, label: '100+', sub: 'Team Members' },
               { icon: <TrendingUp size={20} />, label: 'Growing Everyday', sub: 'To serve you better' },
             ].map((item, i) => (
               <div key={i} className="flex flex-col items-center xl:items-start text-center xl:text-left">
                  <div className="w-10 h-10 bg-white rounded-xl flex items-center justify-center text-[#FF6B2C] mb-3 shadow-sm">
                     {item.icon}
                  </div>
                  <h4 className="text-sm font-black text-[#111827] uppercase tracking-wider">{item.label}</h4>
                  <p className="text-[10px] font-bold text-gray-400 uppercase tracking-widest">{item.sub}</p>
               </div>
             ))}
          </div>
        </div>

        {/* Decorative background icon */}
        <div className="absolute top-1/2 left-1/4 -translate-y-1/2 opacity-[0.03] pointer-events-none group-hover:scale-110 transition-transform duration-1000">
           <Rocket size={400} />
        </div>
      </div>
    </section>
  );
};

export default AboutJourney;
