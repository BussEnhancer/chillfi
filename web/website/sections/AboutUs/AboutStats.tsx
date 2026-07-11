import React from 'react';
import { Users, ShoppingBag, MapPin, Smile } from 'lucide-react';

const stats = [
  {
    icon: <Users size={28} />,
    value: '10M+',
    label: 'Happy Customers',
    desc: 'Trusted by millions across India'
  },
  {
    icon: <ShoppingBag size={28} />,
    value: '5M+',
    label: 'Products Sold',
    desc: 'Across all categories'
  },
  {
    icon: <MapPin size={28} />,
    value: '19,000+',
    label: 'Pincodes Served',
    desc: 'Delivering smiles everywhere'
  },
  {
    icon: <Smile size={28} />,
    value: '99.8%',
    label: 'Customer Satisfaction',
    desc: 'Your trust drives us every day'
  }
];

const AboutStats: React.FC = () => {
  return (
    <section className="py-16 border-y border-[#FFF8F5]">
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
        {stats.map((stat, i) => (
          <div key={i} className="flex items-center gap-6 p-6 bg-[#FAFAFA] rounded-[24px] border border-[#ECECEC] hover:shadow-xl hover:border-[#FF6B2C]/10 transition-all group">
             <div className="w-16 h-16 bg-white rounded-2xl flex items-center justify-center text-[#FF6B2C] shadow-sm group-hover:scale-110 transition-transform">
                {stat.icon}
             </div>
             <div>
                <h3 className="text-2xl font-black text-[#111827] mb-1">{stat.value}</h3>
                <h4 className="text-sm font-bold text-[#111827] uppercase tracking-wider mb-1">{stat.label}</h4>
                <p className="text-[11px] font-bold text-gray-400">{stat.desc}</p>
             </div>
          </div>
        ))}
      </div>
    </section>
  );
};

export default AboutStats;
