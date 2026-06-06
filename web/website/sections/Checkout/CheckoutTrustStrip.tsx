import React from 'react';
import { ShieldCheck, RotateCcw, Truck, Headphones } from 'lucide-react';

const features = [
  {
    icon: <ShieldCheck size={28} />,
    title: '100% Secure Payments',
    desc: 'Your payments are safe with us'
  },
  {
    icon: <RotateCcw size={28} />,
    title: 'Easy Returns',
    desc: 'Return within 7 days of delivery'
  },
  {
    icon: <Truck size={28} />,
    title: 'Free Delivery',
    desc: 'On orders above ₹499'
  },
  {
    icon: <Headphones size={28} />,
    title: '24/7 Customer Support',
    desc: "We're here to help you"
  }
];

const CheckoutTrustStrip: React.FC = () => {
  return (
    <div className="mt-20 py-10 border-t border-[#F8F7FC] grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
      {features.map((f, i) => (
        <div key={i} className="flex items-center gap-5 p-6 bg-[#F8F7FC] rounded-[24px] border border-[#ECECEC] hover:shadow-lg transition-all cursor-default">
           <div className="w-14 h-14 bg-white rounded-2xl flex items-center justify-center text-[#6C2BFF] shadow-sm">
              {f.icon}
           </div>
           <div>
              <h4 className="text-xs font-black text-[#111827] uppercase tracking-wider mb-1">{f.title}</h4>
              <p className="text-[10px] font-bold text-gray-400">{f.desc}</p>
           </div>
        </div>
      ))}
    </div>
  );
};

export default CheckoutTrustStrip;
