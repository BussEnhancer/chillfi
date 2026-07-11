import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Bell, Search, ChevronDown, Settings, LogOut } from 'lucide-react';
import { useStore } from '../../context/StoreContext';
import { useAdminRole } from '../../utils/useAdminRole';

interface AdminHeaderProps {
  title: string;
  subtitle?: string;
}

const roleLabel: Record<string, string> = {
  admin: 'Super Admin',
  support_staff: 'Support Staff',
  customer: 'Customer',
};

const AdminHeader: React.FC<AdminHeaderProps> = ({ title, subtitle }) => {
  const navigate = useNavigate();
  const { logoutUser } = useStore();
  const { role, name } = useAdminRole();
  const [query, setQuery] = useState('');
  const [showNotif, setShowNotif] = useState(false);
  const [showProfile, setShowProfile] = useState(false);

  const handleSearch = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Enter' && query.trim()) {
      navigate(`/admin/products?search=${encodeURIComponent(query.trim())}`);
    }
  };

  return (
    <header className="h-16 bg-white border-b border-[#ECECEC] flex items-center justify-between px-6 shrink-0">
      {/* Left: Title */}
      <div>
        <h1 className="text-lg font-black text-[#111827]">{title}</h1>
        {subtitle && <p className="text-[11px] font-bold text-gray-400">{subtitle}</p>}
      </div>

      {/* Right: Actions */}
      <div className="flex items-center gap-4">
        {/* Search */}
        <div className="relative hidden md:block">
          <input
            type="text"
            value={query}
            onChange={e => setQuery(e.target.value)}
            onKeyDown={handleSearch}
            placeholder="Search products..."
            className="w-52 bg-[#F8F7FC] border border-[#ECECEC] rounded-xl pl-9 pr-4 py-2 text-sm font-bold text-gray-700 placeholder:text-gray-400 outline-none focus:border-[#FF6B2C] transition-colors"
          />
          <Search size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
        </div>

        {/* Notifications */}
        <div className="relative">
          <button
            onClick={() => { setShowNotif(v => !v); setShowProfile(false); }}
            className="relative w-9 h-9 bg-[#F8F7FC] rounded-xl flex items-center justify-center hover:bg-[#FFF3ED] transition-colors"
          >
            <Bell size={16} className="text-gray-500" />
          </button>
          {showNotif && (
            <>
              <div className="fixed inset-0 z-10" onClick={() => setShowNotif(false)} />
              <div className="absolute right-0 top-11 z-20 w-64 bg-white border border-[#ECECEC] rounded-2xl shadow-xl p-4">
                <p className="text-sm font-black text-[#111827] mb-1">Notifications</p>
                <p className="text-xs font-bold text-gray-400">No new notifications.</p>
              </div>
            </>
          )}
        </div>

        {/* Profile */}
        <div className="relative">
          <button
            onClick={() => { setShowProfile(v => !v); setShowNotif(false); }}
            className="flex items-center gap-2.5 hover:bg-[#F8F7FC] px-2 py-1.5 rounded-xl transition-colors"
          >
            <div className="w-8 h-8 bg-[#FF6B2C] rounded-xl flex items-center justify-center text-white font-black text-xs shadow-sm">
              {name.split(' ').map(n => n[0]).join('').slice(0, 2).toUpperCase() || 'AD'}
            </div>
            <div className="hidden md:block text-left">
              <p className="text-xs font-black text-[#111827] leading-tight">{name}</p>
              <p className="text-[10px] font-bold text-gray-400">{roleLabel[role] || role}</p>
            </div>
            <ChevronDown size={14} className="text-gray-400 hidden md:block" />
          </button>
          {showProfile && (
            <>
              <div className="fixed inset-0 z-10" onClick={() => setShowProfile(false)} />
              <div className="absolute right-0 top-12 z-20 w-48 bg-white border border-[#ECECEC] rounded-2xl shadow-xl p-2">
                <button
                  onClick={() => { setShowProfile(false); navigate('/admin/settings'); }}
                  className="w-full flex items-center gap-2.5 px-3 py-2.5 rounded-xl text-sm font-bold text-gray-600 hover:bg-[#F8F7FC] hover:text-[#FF6B2C]"
                >
                  <Settings size={16} /> Settings
                </button>
                <button
                  onClick={() => { setShowProfile(false); logoutUser(); navigate('/login'); }}
                  className="w-full flex items-center gap-2.5 px-3 py-2.5 rounded-xl text-sm font-bold text-red-500 hover:bg-red-50"
                >
                  <LogOut size={16} /> Logout
                </button>
              </div>
            </>
          )}
        </div>
      </div>
    </header>
  );
};

export default AdminHeader;
