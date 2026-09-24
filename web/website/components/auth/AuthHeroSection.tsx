import React from 'react';
import { Gift, Zap, ShieldCheck, Smartphone } from 'lucide-react';
import BenefitItem from './BenefitItem';

const AuthHeroSection: React.FC = () => {
  return (
    <div className="bg-[#FFF8F5] rounded-[32px] p-10 md:p-16 relative overflow-hidden flex-1 border border-[#ECECEC]">
      <div className="relative z-10 max-w-[450px]">
        <h1 className="text-4xl md:text-5xl font-black text-[#111827] leading-[1.1] mb-4">
          Welcome to <br />
          <span className="text-[#FF6B2C]">chillFi</span>
        </h1>
        <h2 className="text-xl font-bold text-[#FF6B2C] mb-6">Shop Smart. Chill More.</h2>
        <p className="text-sm font-bold text-gray-400 mb-10 leading-relaxed">
          Sign in to access the best deals, faster checkout and personalized shopping experience.
        </p>

        <div className="space-y-2">
          <BenefitItem
            icon={<Gift size={20} />}
            title="Exclusive Offers"
            desc="Access member-only deals & discounts"
          />
          <BenefitItem
            icon={<Zap size={20} />}
            title="Faster Delivery"
            desc="Get faster delivery on all orders"
          />
          <BenefitItem
            icon={<ShieldCheck size={20} />}
            title="100% Secure"
            desc="Your data is safe with us"
          />
        </div>
      </div>

      {/* Hero Illustration Mockup */}
      <div className="absolute right-0 bottom-0 top-0 w-1/2 hidden xl:flex items-center justify-center p-10">
        <div className="relative w-full h-full flex items-center justify-center">
          {/* Phone Mockup UI */}
          <div className="relative w-[220px] h-[440px] bg-white rounded-[40px] shadow-2xl border-8 border-white overflow-hidden transform rotate-6 hover:rotate-0 transition-transform duration-700">
            <div className="absolute top-0 left-0 right-0 h-8 flex items-center justify-center">
              <div className="w-16 h-4 bg-gray-100 rounded-full"></div>
            </div>
            <div className="pt-12 px-6">
              <div className="w-12 h-12 bg-[#FF6B2C]/10 rounded-xl flex items-center justify-center mb-6">
                <Smartphone size={24} className="text-[#FF6B2C]" />
              </div>
              <div className="space-y-4">
                <div className="h-4 bg-gray-100 rounded-lg w-3/4"></div>
                <div className="h-4 bg-gray-100 rounded-lg w-full"></div>
                <div className="h-4 bg-gray-100 rounded-lg w-1/2"></div>
              </div>
              <div className="mt-10 h-10 bg-[#FF6B2C] rounded-xl w-full"></div>
            </div>
          </div>

          {/* Floating Decoratives */}
          <div className="absolute top-20 right-10 w-12 h-12 bg-white rounded-2xl shadow-lg flex items-center justify-center text-[#FF6B2C] animate-bounce">
            <ShieldCheck size={24} />
          </div>
          <div className="pointer-events-none absolute bottom-20 left-0 w-32 h-32 bg-[#FF6B2C]/10 rounded-full blur-3xl"></div>
          <div className="absolute top-1/2 left-0 w-20 h-20 bg-[#FF6B2C] rounded-2xl flex items-center justify-center text-white shadow-2xl -rotate-12">
            <Gift size={40} />
          </div>
        </div>
      </div>

      {/* Decorative Circles */}
      <div className="pointer-events-none absolute -top-20 -right-20 w-80 h-80 bg-[#FF6B2C]/5 rounded-full blur-3xl"></div>
    </div>
  );
};

export default AuthHeroSection;
