import React from 'react';
import { ShieldCheck, Eye, Zap, Heart, Globe } from 'lucide-react';

const values = [
  {
    icon: <ShieldCheck size={24} />,
    title: 'Quality First',
    desc: 'We partner with trusted sellers to bring you 100% genuine and high-quality products.'
  },
  {
    icon: <Eye size={24} />,
    title: 'Trust & Transparency',
    desc: 'Honest pricing, clear policies and secure transactions — always.'
  },
  {
    icon: <Zap size={24} />,
    title: 'Fast & Reliable',
    desc: 'Quick delivery and real-time tracking for a smooth shopping experience.'
  },
  {
    icon: <Heart size={24} />,
    title: 'Customer Obsession',
    desc: 'Our customers are at the heart of everything we do.'
  },
  {
    icon: <Globe size={24} />,
    title: 'Building for Everyone',
    desc: 'We are committed to making great products accessible to everyone, everywhere.'
  }
];

const AboutValues: React.FC = () => {
  return (
    <section className="py-20">
      <div className="text-center mb-16">
        <h2 className="text-3xl md:text-4xl font-black text-[#111827] uppercase tracking-tight">Our Values</h2>
        <div className="w-16 h-1.5 bg-[#6C2BFF] rounded-full mx-auto mt-4"></div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-5 gap-6">
        {values.map((v, i) => (
          <div key={i} className="bg-white border border-[#ECECEC] rounded-[24px] p-8 text-center flex flex-col items-center hover:shadow-2xl hover:border-[#6C2BFF]/20 hover:-translate-y-2 transition-all duration-500 group">
             <div className="w-14 h-14 bg-[#F8F5FF] rounded-2xl flex items-center justify-center text-[#6C2BFF] mb-6 group-hover:bg-[#6C2BFF] group-hover:text-white transition-colors shadow-sm">
                {v.icon}
             </div>
             <h4 className="text-sm font-black text-[#111827] mb-3 uppercase tracking-wider">{v.title}</h4>
             <p className="text-xs font-bold text-gray-500 leading-relaxed">{v.desc}</p>
          </div>
        ))}
      </div>
    </section>
  );
};

export default AboutValues;
