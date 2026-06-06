import React from 'react';
import {
  LayoutDashboard, ShoppingBag, Truck, Heart, MapPin, Tag, Wallet,
  CircleDollarSign, Star, Users, Ticket, Settings, Bell, LogOut,
  ShieldCheck, FileText, TruckIcon
} from 'lucide-react';

const menuItems = [
  { id: 'dashboard', label: 'My Dashboard', icon: <LayoutDashboard size={20} /> },
  { id: 'orders', label: 'My Orders', icon: <ShoppingBag size={20} /> },
  { id: 'track', label: 'Track Order', icon: <Truck size={20} /> },
  { id: 'wishlist', label: 'Wishlist', icon: <Heart size={20} /> },
  { id: 'addresses', label: 'Addresses', icon: <MapPin size={20} /> },
  { id: 'offers', label: 'Coupons & Offers', icon: <Tag size={20} /> },
  { id: 'wallet', label: 'chillFi Wallet', icon: <Wallet size={20} /> },
  { id: 'coins', label: 'chillFi Coins', icon: <CircleDollarSign size={20} />, badge: '1200' },
  { id: 'reviews', label: 'Reviews & Ratings', icon: <Star size={20} /> },
  { id: 'refer', label: 'Refer & Earn', icon: <Users size={20} /> },
  { id: 'support', label: 'Support Tickets', icon: <Ticket size={20} /> },
  { id: 'settings', label: 'Account Settings', icon: <Settings size={20} /> },
  { id: 'notifications', label: 'Notification Settings', icon: <Bell size={20} /> },
  { id: 'logout', label: 'Logout', icon: <LogOut size={20} />, danger: true },
];

const legalItems = [
  { id: 'privacy', label: 'Privacy Policy', icon: <ShieldCheck size={20} /> },
  { id: 'terms', label: 'Terms & Conditions', icon: <FileText size={20} /> },
  { id: 'shipping', label: 'Shipping Policy', icon: <TruckIcon size={20} /> },
];

interface AccountSidebarProps {
  activeId?: string;
}

const AccountSidebar: React.FC<AccountSidebarProps> = ({ activeId = 'dashboard' }) => {
  const renderItem = (item: any) => {
    const isActive = item.id === activeId;
    return (
      <button
        key={item.id}
        className={`w-full flex items-center justify-between p-3.5 rounded-xl transition-all group ${
          isActive ? 'bg-gradient-to-r from-[#6C2BFF] to-[#8B5CFF] text-white shadow-lg shadow-[#6C2BFF]/20' :
          item.danger ? 'text-red-500 hover:bg-red-50' : 'text-gray-600 hover:bg-[#F8F5FF] hover:text-[#6C2BFF]'
        }`}
      >
        <div className="flex items-center gap-3">
          <span className={isActive ? 'text-white' : 'text-inherit opacity-70 group-hover:opacity-100'}>
            {item.icon}
          </span>
          <span className="text-sm font-bold">{item.label}</span>
        </div>
        {item.badge && (
          <span className={`text-[10px] font-black px-2 py-0.5 rounded-md ${
            isActive ? 'bg-white/20 text-white' : 'bg-[#6C2BFF]/10 text-[#6C2BFF]'
          }`}>
            {item.badge}
          </span>
        )}
      </button>
    );
  };

  return (
    <aside className="w-[280px] shrink-0 hidden lg:block">
      <div className="bg-white rounded-[24px] border border-[#ECECEC] p-4 sticky top-32 overflow-hidden shadow-sm max-h-[calc(100vh-160px)] overflow-y-auto scrollbar-hide">
        <div className="space-y-1">
          {menuItems.map(renderItem)}
        </div>

        <div className="mt-6 pt-6 border-t border-[#F8F5FF]">
          <h5 className="text-[10px] font-black text-gray-400 uppercase tracking-[0.2em] px-4 mb-4">Legal</h5>
          <div className="space-y-1">
            {legalItems.map(renderItem)}
          </div>
        </div>
      </div>
    </aside>
  );
};

export default AccountSidebar;
