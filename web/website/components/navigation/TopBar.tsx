import React from 'react';
import Container from '../common/Container';
import { Truck, RotateCcw, ShieldCheck, Headphones, Smartphone } from 'lucide-react';
import { useAppConfig, freeDeliveryText } from '../../utils/useAppConfig';

const TopBar: React.FC = () => {
  const cfg = useAppConfig();
  return (
    <div className="bg-[#121212] text-white py-2 text-[12px] font-medium hidden lg:block">
      <Container className="flex justify-between items-center">
        <div className="flex gap-8">
          <div className="flex items-center gap-2">
            <Truck size={14} className="text-[#FF6B2C]" />
            <span>{cfg && !cfg.free_shipping_enabled ? freeDeliveryText(cfg) : freeDeliveryText(cfg, 'Free Delivery on orders above')}</span>
          </div>
          <div className="flex items-center gap-2">
            <RotateCcw size={14} className="text-[#FF6B2C]" />
            <span>Easy Returns & Refunds</span>
          </div>
          <div className="flex items-center gap-2">
            <ShieldCheck size={14} className="text-[#FF6B2C]" />
            <span>Secure Payments</span>
          </div>
          <div className="flex items-center gap-2">
            <Headphones size={14} className="text-[#FF6B2C]" />
            <span>Support 9 AM – 9 PM, every day</span>
          </div>
        </div>
        <div title="Coming soon" className="flex items-center gap-2 opacity-60 cursor-not-allowed">
          <Smartphone size={14} />
          <span>Download App (Coming Soon)</span>
        </div>
      </Container>
    </div>
  );
};

export default TopBar;
