import React from 'react';
import { Link, useLocation } from 'react-router-dom';
import {
  LayoutDashboard, Package, ShoppingCart, Users, LayoutGrid,
  BarChart2, Tag, Settings, ChevronRight, Zap, Image, Star, Mail, Bell, RotateCcw, Truck
} from 'lucide-react';
import { useAdminRole } from '../../utils/useAdminRole';

const navItems = [
  { label: 'Dashboard', icon: <LayoutDashboard size={18} />, to: '/admin', staffAllowed: false },
  { label: 'Products', icon: <Package size={18} />, to: '/admin/products', staffAllowed: false },
  { label: 'Orders', icon: <ShoppingCart size={18} />, to: '/admin/orders', staffAllowed: true },
  { label: 'Refunds', icon: <RotateCcw size={18} />, to: '/admin/refunds', staffAllowed: false },
  { label: 'Users', icon: <Users size={18} />, to: '/admin/users', staffAllowed: false },
  { label: 'Categories', icon: <LayoutGrid size={18} />, to: '/admin/categories', staffAllowed: false },
  { label: 'Brands', icon: <Tag size={18} />, to: '/admin/brands', staffAllowed: false },
  { label: 'Reviews', icon: <Star size={18} />, to: '/admin/reviews', staffAllowed: true },
  { label: 'Messages', icon: <Mail size={18} />, to: '/admin/messages', staffAllowed: true },
  { label: 'Notifications', icon: <Bell size={18} />, to: '/admin/notifications', staffAllowed: false },
  { label: 'Analytics', icon: <BarChart2 size={18} />, to: '/admin/analytics', staffAllowed: false },
  { label: 'Banners', icon: <Image size={18} />, to: '/admin/banners', staffAllowed: false },
  { label: 'Testimonials', icon: <Star size={18} />, to: '/admin/testimonials', staffAllowed: false },
  { label: 'Promo Banners', icon: <Zap size={18} />, to: '/admin/promo-banners', staffAllowed: false },
  { label: 'Coupons', icon: <Tag size={18} />, to: '/admin/coupons', staffAllowed: false },
  { label: 'Shipping Rules', icon: <Truck size={18} />, to: '/admin/shipping-rules', staffAllowed: false },
  { label: 'Settings', icon: <Settings size={18} />, to: '/admin/settings', staffAllowed: false },
];

const AdminSidebar: React.FC = () => {
  const { pathname } = useLocation();
  const { isSupportStaff } = useAdminRole();
  const visibleItems = isSupportStaff ? navItems.filter(i => i.staffAllowed) : navItems;

  const isActive = (to: string) => {
    if (to === '/admin') return pathname === '/admin';
    return pathname.startsWith(to);
  };

  return (
    <aside className="w-[260px] shrink-0 bg-[#121212] min-h-screen flex flex-col">
      {/* Logo */}
      <div className="px-6 py-6 border-b border-white/5">
        <Link to="/" className="flex items-center gap-3 group">
          <div className="w-9 h-9 bg-[#FF6B2C] rounded-xl flex items-center justify-center shadow-lg shadow-[#FF6B2C]/30">
            <Zap size={18} className="text-white" />
          </div>
          <div>
            <span className="text-white font-black text-lg tracking-tight">chillFi</span>
            <span className="block text-[10px] font-bold text-white/30 uppercase tracking-widest -mt-0.5">Admin Panel</span>
          </div>
        </Link>
      </div>

      {/* Nav */}
      <nav className="flex-1 px-3 py-6 space-y-1 overflow-y-auto">
        {visibleItems.slice(0, 5).length > 0 && (
          <p className="text-[10px] font-black text-white/20 uppercase tracking-widest px-3 mb-4">Main Menu</p>
        )}
        {visibleItems.slice(0, 5).map((item) => (
          <Link
            key={item.to}
            to={item.to}
            className={`flex items-center justify-between px-3 py-2.5 rounded-xl transition-all group ${
              isActive(item.to)
                ? 'bg-[#FF6B2C] text-white shadow-lg shadow-[#FF6B2C]/20'
                : 'text-white/50 hover:text-white hover:bg-white/5'
            }`}
          >
            <div className="flex items-center gap-3">
              <span className={isActive(item.to) ? 'text-white' : 'text-white/40 group-hover:text-white/80'}>{item.icon}</span>
              <span className="text-sm font-bold">{item.label}</span>
            </div>
            {isActive(item.to) && <ChevronRight size={14} className="text-white/60" />}
          </Link>
        ))}

        {visibleItems.slice(5).length > 0 && (
          <p className="text-[10px] font-black text-white/20 uppercase tracking-widest px-3 mt-6 mb-4">Management</p>
        )}
        {visibleItems.slice(5).map((item) => (
          <Link
            key={item.to}
            to={item.to}
            className={`flex items-center justify-between px-3 py-2.5 rounded-xl transition-all group ${
              isActive(item.to)
                ? 'bg-[#FF6B2C] text-white shadow-lg shadow-[#FF6B2C]/20'
                : 'text-white/50 hover:text-white hover:bg-white/5'
            }`}
          >
            <div className="flex items-center gap-3">
              <span className={isActive(item.to) ? 'text-white' : 'text-white/40 group-hover:text-white/80'}>{item.icon}</span>
              <span className="text-sm font-bold">{item.label}</span>
            </div>
            {isActive(item.to) && <ChevronRight size={14} className="text-white/60" />}
          </Link>
        ))}
      </nav>

      {/* Bottom: View Store */}
      <div className="px-3 py-4 border-t border-white/5">
        <Link
          to="/"
          className="flex items-center gap-3 px-3 py-2.5 rounded-xl text-white/40 hover:text-white hover:bg-white/5 transition-all group"
        >
          <Zap size={16} className="group-hover:text-[#FF6B2C]" />
          <span className="text-sm font-bold">View Store</span>
        </Link>
      </div>
    </aside>
  );
};

export default AdminSidebar;
