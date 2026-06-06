import React from 'react';
import Container from '../../components/common/Container';
import { Gift, Zap, Crown, Percent } from 'lucide-react';

const PromoBanners: React.FC = () => {
  return (
    <section className="py-16 bg-gray-50/30">
      <Container className="grid md:grid-cols-2 gap-8">
        {/* Banner 1: First Order */}
        <div className="bg-[#6C2BFF] rounded-[32px] p-10 flex items-center justify-between text-white overflow-hidden relative group">
          <div className="relative z-10 max-w-[60%]">
             <h3 className="text-3xl font-black mb-4">Get Extra 10% Off <br />On Your First Order</h3>
             <div className="flex items-center gap-3 mb-8">
                <span className="text-sm font-bold opacity-80 uppercase tracking-widest">Use code:</span>
                <span className="bg-white/20 backdrop-blur-md px-4 py-1.5 rounded-lg font-black tracking-widest border border-white/20">CHILL10</span>
             </div>
             <button className="bg-white text-[#6C2BFF] px-8 py-3 rounded-xl font-bold hover:scale-105 transition-all">Shop Now</button>
          </div>
          <div className="relative z-10 w-[150px] h-[150px] flex items-center justify-center">
             <div className="w-full h-full bg-white/10 rounded-full flex items-center justify-center animate-bounce">
                <Gift size={80} className="text-white" />
             </div>
          </div>
          {/* Decorative Pattern */}
          <div className="absolute -bottom-10 -right-10 w-40 h-40 bg-white/5 rounded-full blur-2xl group-hover:scale-150 transition-transform duration-1000"></div>
          <div className="absolute top-0 left-0 p-4 opacity-10">
             <Percent size={120} />
          </div>
        </div>

        {/* Banner 2: Premium Membership */}
        <div className="bg-white border-2 border-[#6C2BFF]/10 rounded-[32px] p-10 flex items-center justify-between overflow-hidden relative group">
           <div className="relative z-10">
              <div className="flex items-center gap-2 mb-4">
                 <ShoppingCart className="text-[#6C2BFF]" size={24} />
                 <span className="text-xl font-black tracking-tight text-[#121212]">chillFi <span className="text-[#6C2BFF]">Premium</span></span>
              </div>
              <ul className="space-y-3 mb-8">
                 {[
                   { icon: <Zap size={14} />, text: 'Free Fast Delivery' },
                   { icon: <Gift size={14} />, text: 'Exclusive Offers' },
                   { icon: <Crown size={14} />, text: 'Early Access to Sales' },
                 ].map((item, i) => (
                   <li key={i} className="flex items-center gap-2 text-gray-600 font-bold text-sm">
                      <span className="text-[#6C2BFF]">{item.icon}</span>
                      {item.text}
                   </li>
                 ))}
              </ul>
              <button className="bg-[#6C2BFF] text-white px-8 py-3 rounded-xl font-bold hover:shadow-xl transition-all">Join Premium ›</button>
           </div>

           <div className="relative z-10 w-[200px]">
              <img
                src="https://images.unsplash.com/photo-1549463595-b093057de965?auto=format&fit=crop&q=80&w=400"
                alt="Premium Box"
                className="w-full drop-shadow-2xl animate-float"
              />
           </div>

           {/* Decorative elements */}
           <div className="absolute -top-10 -right-10 w-60 h-60 bg-[#6C2BFF]/5 rounded-full blur-3xl"></div>
        </div>
      </Container>
    </section>
  );
};

export default PromoBanners;
