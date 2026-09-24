import React from 'react';
import Container from '../../components/common/Container';
import { Truck, RotateCcw, ShieldCheck, Headphones } from 'lucide-react';

const features = [
  {
    icon: <Truck size={32} className="text-[#FF6B2C]" />,
    title: 'Free Delivery',
    desc: 'On orders above ₹499',
  },
  {
    icon: <RotateCcw size={32} className="text-[#FF6B2C]" />,
    title: 'Easy Returns',
    desc: 'Within 7 days',
  },
  {
    icon: <ShieldCheck size={32} className="text-[#FF6B2C]" />,
    title: 'Secure Payments',
    desc: '100% secure payments',
  },
  {
    icon: <Headphones size={32} className="text-[#FF6B2C]" />,
    title: 'Daily Support',
    desc: "We're here to help",
  },
];

const TrustBar: React.FC = () => {
  return (
    <section className="py-10 bg-gray-50/50">
      <Container>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-8">
          {features.map((f, i) => (
            <div
              key={i}
              className="flex flex-col items-center md:flex-row md:items-start gap-4 p-6 bg-white rounded-2xl shadow-sm hover:shadow-xl hover:-translate-y-1 transition-all duration-300 border border-gray-100"
            >
              <div className="bg-[#FF6B2C]/10 p-4 rounded-2xl">
                {f.icon}
              </div>
              <div className="text-center md:text-left">
                <h3 className="font-bold text-gray-900 mb-1">{f.title}</h3>
                <p className="text-sm text-gray-500 font-medium">{f.desc}</p>
              </div>
            </div>
          ))}
        </div>
      </Container>
    </section>
  );
};

export default TrustBar;
