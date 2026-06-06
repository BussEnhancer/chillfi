import React from 'react';
import Container from '../common/Container';
import { Truck, RotateCcw, ShieldCheck, Headphones, Smartphone } from 'lucide-react';

const TopBar: React.FC = () => {
  return (
    <div className="bg-[#121212] text-white py-2 text-[12px] font-medium hidden lg:block">
      <Container className="flex justify-between items-center">
        <div className="flex gap-8">
          <div className="flex items-center gap-2">
            <Truck size={14} className="text-[#6C2BFF]" />
            <span>Free Delivery on orders above ₹499</span>
          </div>
          <div className="flex items-center gap-2">
            <RotateCcw size={14} className="text-[#6C2BFF]" />
            <span>Easy Returns & Refunds</span>
          </div>
          <div className="flex items-center gap-2">
            <ShieldCheck size={14} className="text-[#6C2BFF]" />
            <span>Secure Payments</span>
          </div>
          <div className="flex items-center gap-2">
            <Headphones size={14} className="text-[#6C2BFF]" />
            <span>24/7 Customer Support</span>
          </div>
        </div>
        <div className="flex items-center gap-2 cursor-pointer hover:text-[#6C2BFF] transition-colors">
          <Smartphone size={14} />
          <span>Download App</span>
        </div>
      </Container>
    </div>
  );
};

export default TopBar;
