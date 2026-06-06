import React from 'react';
import { ShieldCheck, RotateCcw, Truck } from 'lucide-react';

const TrustStripSmall: React.FC = () => {
  return (
    <div className="flex items-center gap-6 text-[11px] font-black text-gray-400 uppercase tracking-widest">
      <div className="flex items-center gap-2">
        <ShieldCheck size={14} className="text-[#6C2BFF]" />
        <span>100% Secure Payments</span>
      </div>
      <div className="flex items-center gap-2">
        <RotateCcw size={14} className="text-[#6C2BFF]" />
        <span>Easy Returns</span>
      </div>
      <div className="flex items-center gap-2">
        <Truck size={14} className="text-[#6C2BFF]" />
        <span>Free Delivery above ₹499</span>
      </div>
    </div>
  );
};

export default TrustStripSmall;
