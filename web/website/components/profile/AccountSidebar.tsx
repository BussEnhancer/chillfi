import React from 'react';
import { Link, useNavigate } from 'react-router-dom';
import {
  LayoutDashboard, ShoppingBag, Truck, Heart, MapPin, Tag, Wallet,
  CircleDollarSign, Star, Users, Ticket, Settings, Bell, LogOut,
  ShieldCheck, FileText, TruckIcon, RotateCcw, Banknote
} from 'lucide-react';
import { useStore } from '../../context/StoreContext';

const menuItems = [
  { id: 'dashboard', label: 'My Dashboard', icon: <LayoutDashboard size={20} />, path: '/account' },
  { id: 'orders', label: 'My Orders', icon: <ShoppingBag size={20} />, path: '/account/orders' },
  { id: 'track', label: 'Track Order', icon: <Truck size={20} />, path: '/account/orders' },
  { id: 'wishlist', label: 'Wishlist', icon: <Heart size={20} />, path: '/account/wishlist' },
  { id: 'addresses', label: 'Addresses', icon: <MapPin size={20} />, path: '/account/addresses' },
  { id: 'offers', label: 'Coupons & Offers', icon: <Tag size={20} />, path: '/offers' },
  { id: 'wallet', label: 'chillFi Wallet', icon: <Wallet size={20} />, comingSoon: true },
  { id: 'coins', label: 'chillFi Coins', icon: <CircleDollarSign size={20} />, comingSoon: true },
  { id: 'reviews', label: 'Reviews & Ratings', icon: <Star size={20} />, path: '/account/reviews' },
  { id: 'refer', label: 'Refer & Earn', icon: <Users size={20} />, comingSoon: true },
  { id: 'support', label: 'Help & Support', icon: <Ticket size={20} />, path: '/support' },
  { id: 'settings', label: 'Account Settings', icon: <Settings size={20} />, path: '/account/settings' },
  { id: 'notifications', label: 'Notification Settings', icon: <Bell size={20} />, path: '/account/notifications' },
  { id: 'logout', label: 'Logout', icon: <LogOut size={20} />, danger: true, action: 'logout' },
];

const legalItems = [
  { id: 'privacy', label: 'Privacy Policy', icon: <ShieldCheck size={20} />, path: '/privacy-policy' },
  { id: 'terms', label: 'Terms & Conditions', icon: <FileText size={20} />, path: '/terms' },
  { id: 'shipping', label: 'Shipping Policy', icon: <TruckIcon size={20} />, path: '/shipping-policy' },
  { id: 'return', label: 'Return Policy', icon: <RotateCcw size={20} />, path: '/return-policy' },
  { id: 'refund', label: 'Refund Policy', icon: <Banknote size={20} />, path: '/refund-policy' },
];

interface AccountSidebarProps {
  activeId?: string;
}

const AccountSidebar: React.FC<AccountSidebarProps> = ({ activeId = 'dashboard' }) => {
  const navigate = useNavigate();
  const { logoutUser } = useStore();

  const handleClick = (item: any) => {
    if (item.comingSoon) return;
    if (item.action === 'logout') { logoutUser(); navigate('/'); return; }
    if (item.path) navigate(item.path);
  };

  const renderItem = (item: any) => {
    const isActive = item.id === activeId;
    // Real links for navigation (new tab, correct semantics); buttons for actions / "Soon" items.
    const Tag: any = item.path && !item.comingSoon ? Link : 'button';
    const tagProps = item.path && !item.comingSoon
      ? { to: item.path, 'aria-current': isActive ? 'page' : undefined }
      : { onClick: () => handleClick(item), disabled: item.comingSoon, type: 'button' };
    return (
      <Tag
        key={item.id}
        {...tagProps}
        className={`w-full flex items-center justify-between p-3.5 rounded-xl transition-all group ${
          isActive ? 'bg-gradient-to-r from-[#FF6B2C] to-[#8B5CFF] text-white shadow-lg shadow-[#FF6B2C]/20' :
          item.danger ? 'text-red-500 hover:bg-red-50' :
          item.comingSoon ? 'text-gray-300 cursor-not-allowed' : 'text-gray-600 hover:bg-[#FFF8F5] hover:text-[#FF6B2C]'
        }`}
      >
        <div className="flex items-center gap-3">
          <span className={isActive ? 'text-white' : 'text-inherit opacity-70 group-hover:opacity-100'}>
            {item.icon}
          </span>
          <span className="text-sm font-bold">{item.label}</span>
        </div>
        {item.comingSoon && (
          <span className="text-[10px] font-black px-2 py-0.5 rounded-md bg-gray-100 text-gray-400 uppercase tracking-wider">
            Soon
          </span>
        )}
      </Tag>
    );
  };

  return (
    <>
    {/* Phones & tablets: account menu as a horizontal strip (the sidebar is desktop-only) */}
    <nav className="lg:hidden -mx-4 px-4 mb-6 overflow-x-auto scrollbar-hide" aria-label="Account menu">
      <div className="flex gap-2 w-max">
        {menuItems.filter(i => !i.comingSoon).map(item => {
          const isActive = item.id === activeId;
          const Tag: any = item.path ? Link : 'button';
          const tagProps = item.path
            ? { to: item.path, 'aria-current': isActive ? 'page' : undefined }
            : { onClick: () => handleClick(item), type: 'button' };
          return (
            <Tag
              key={item.id}
              {...tagProps}
              className={`flex items-center gap-2 px-4 py-2.5 rounded-xl text-xs font-black whitespace-nowrap border transition-colors ${
                isActive ? 'bg-[#FF6B2C] text-white border-[#FF6B2C]' :
                item.danger ? 'text-red-500 border-red-100 bg-white' : 'text-gray-600 border-[#ECECEC] bg-white'
              }`}
            >
              <span className="[&>svg]:w-4 [&>svg]:h-4">{item.icon}</span>{item.label}
            </Tag>
          );
        })}
      </div>
    </nav>
    <aside className="w-[280px] shrink-0 hidden lg:block">
      <div className="bg-white rounded-[24px] border border-[#ECECEC] p-4 sticky top-32 overflow-hidden shadow-sm max-h-[calc(100vh-160px)] overflow-y-auto scrollbar-hide">
        <div className="space-y-1">
          {menuItems.map(renderItem)}
        </div>

        <div className="mt-6 pt-6 border-t border-[#FFF8F5]">
          <h5 className="text-[10px] font-black text-gray-400 uppercase tracking-[0.2em] px-4 mb-4">Legal</h5>
          <div className="space-y-1">
            {legalItems.map(renderItem)}
          </div>
        </div>
      </div>
    </aside>
    </>
  );
};

export default AccountSidebar;
