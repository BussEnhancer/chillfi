import React from 'react';
import { ShieldCheck, RotateCcw, Truck } from 'lucide-react';
import { useAppConfig, freeDeliveryText } from '../../utils/useAppConfig';

const TrustStripSmall: React.FC = () => {
  const cfg = useAppConfig();
  return (
    <div className="flex items-center gap-6 text-[11px] font-black text-gray-400 uppercase tracking-widest">
      <div className="flex items-center gap-2">
        <ShieldCheck size={14} className="text-[#FF6B2C]" />
        <span>100% Secure Payments</span>
      </div>
      <div className="flex items-center gap-2">
        <RotateCcw size={14} className="text-[#FF6B2C]" />
        <span>Easy Returns</span>
      </div>
      <div className="flex items-center gap-2">
        <Truck size={14} className="text-[#FF6B2C]" />
        <span>{cfg && !cfg.free_shipping_enabled ? freeDeliveryText(cfg) : freeDeliveryText(cfg, 'Free Delivery above')}</span>
      </div>
    </div>
  );
};

export default TrustStripSmall;
