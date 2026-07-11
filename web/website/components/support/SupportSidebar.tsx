import React from 'react';
import {
  Home, Truck, RotateCcw, CreditCard, Ship, User,
  Package, Tag, ShieldQuestion, Headphones
} from 'lucide-react';

const menuItems = [
  { id: 'home', label: 'Support Home', icon: <Home size={20} />, active: true },
  { id: 'track', label: 'Track Order', icon: <Truck size={20} /> },
  { id: 'returns', label: 'Returns & Refunds', icon: <RotateCcw size={20} /> },
  { id: 'payments', label: 'Orders & Payments', icon: <CreditCard size={20} /> },
  { id: 'shipping', label: 'Shipping & Delivery', icon: <Ship size={20} /> },
  { id: 'account', label: 'Account & Profile', icon: <User size={20} /> },
  { id: 'products', label: 'Products & Services', icon: <Package size={20} /> },
  { id: 'offers', label: 'Offers & Promotions', icon: <Tag size={20} /> },
  { id: 'policies', label: 'Policies & Help', icon: <ShieldQuestion size={20} /> },
];

const SupportSidebar: React.FC = () => {
  return (
    <aside className="w-[280px] shrink-0 hidden lg:block">
      <div className="bg-white rounded-[24px] border border-[#ECECEC] p-4 sticky top-32 overflow-hidden shadow-sm">
        <div className="space-y-1">
          {menuItems.map((item) => (
            <button
              key={item.id}
              className={`w-full flex items-center gap-3 p-3.5 rounded-xl transition-all group ${
                item.active ? 'bg-[#FF6B2C] text-white shadow-lg shadow-[#FF6B2C]/20' : 'text-gray-600 hover:bg-[#FFF8F5] hover:text-[#FF6B2C]'
              }`}
            >
              <span className={item.active ? 'text-white' : 'text-inherit opacity-70 group-hover:opacity-100'}>
                {item.icon}
              </span>
              <span className="text-sm font-bold">{item.label}</span>
            </button>
          ))}
        </div>

        {/* Support CTA Card */}
        <div className="mt-8 p-6 bg-[#FFF8F5] rounded-2xl border border-[#FF6B2C]/10 text-center">
           <h4 className="text-sm font-black text-[#111827] mb-2 uppercase tracking-tight">Still need help?</h4>
           <p className="text-[11px] font-bold text-gray-400 mb-4 leading-relaxed">Our support team is ready to assist you.</p>
           <button className="w-full bg-white border-2 border-[#FF6B2C] text-[#FF6B2C] py-2.5 rounded-xl font-black text-xs uppercase tracking-widest flex items-center justify-center gap-2 hover:bg-[#FF6B2C] hover:text-white transition-all shadow-sm">
              <Headphones size={14} />
              Contact Us
           </button>
        </div>
      </div>
    </aside>
  );
};

export default SupportSidebar;
