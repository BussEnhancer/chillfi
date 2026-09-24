import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Bell, Search, ChevronDown, Settings, LogOut } from 'lucide-react';
import { useStore } from '../../context/StoreContext';
import { useAdminRole } from '../../utils/useAdminRole';
import { apiGet } from '../../utils/api';

interface AlertItem { key: string; count: number; label: string; to: string; tone: 'red' | 'orange' | 'blue' | 'gray' }
const toneClass: Record<AlertItem['tone'], string> = { red: 'bg-red-50 text-red-600', orange: 'bg-[#FFF3ED] text-[#FF6B2C]', blue: 'bg-blue-50 text-blue-600', gray: 'bg-gray-100 text-gray-600' };

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
  const [alerts, setAlerts] = useState<AlertItem[] | null>(null);
  const [alertsFailed, setAlertsFailed] = useState(false);

  // Actionable counts (failed shipments, orders to ship, refunds, messages, low stock); refreshed every minute.
  useEffect(() => {
    let alive = true;
    const load = () => apiGet<{ success: boolean; data: { items: AlertItem[] } }>('/admin/alerts')
      .then(r => { if (alive) { setAlerts(r.data.items); setAlertsFailed(false); } })
      .catch(() => { if (alive) setAlertsFailed(true); });
    load();
    const t = setInterval(load, 60000);
    return () => { alive = false; clearInterval(t); };
  }, []);
  const alertTotal = (alerts || []).reduce((n, a) => n + a.count, 0);

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
            aria-label={alertTotal ? `${alertTotal} items need attention` : 'Notifications'}
            className="relative w-9 h-9 bg-[#F8F7FC] rounded-xl flex items-center justify-center hover:bg-[#FFF3ED] transition-colors"
          >
            <Bell size={16} className="text-gray-500" />
            {alertTotal > 0 && (
              <span className="absolute -top-1 -right-1 min-w-[18px] h-[18px] px-1 bg-[#FF6B2C] text-white text-[10px] font-black rounded-full flex items-center justify-center">
                {alertTotal > 99 ? '99+' : alertTotal}
              </span>
            )}
          </button>
          {showNotif && (
            <>
              <div className="fixed inset-0 z-10" onClick={() => setShowNotif(false)} />
              <div className="absolute right-0 top-11 z-20 w-72 bg-white border border-[#ECECEC] rounded-2xl shadow-xl p-4">
                <p className="text-sm font-black text-[#111827] mb-2">Needs attention</p>
                {alertsFailed ? (
                  <p className="text-xs font-bold text-red-500">Couldn't load alerts. Check your connection.</p>
                ) : alerts === null ? (
                  <p className="text-xs font-bold text-gray-400">Loading…</p>
                ) : alerts.length === 0 ? (
                  <p className="text-xs font-bold text-gray-400">All caught up — nothing needs attention.</p>
                ) : (
                  <div className="space-y-1.5">
                    {alerts.map(a => (
                      <button key={a.key} onClick={() => { setShowNotif(false); navigate(a.to); }}
                        className="w-full flex items-center gap-2.5 text-left px-2 py-2 rounded-xl hover:bg-[#F8F7FC]">
                        <span className={`min-w-[28px] text-center text-xs font-black px-1.5 py-0.5 rounded-lg ${toneClass[a.tone] || toneClass.gray}`}>{a.count}</span>
                        <span className="text-xs font-bold text-gray-600">{a.label}</span>
                      </button>
                    ))}
                  </div>
                )}
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
                {role === 'admin' && <button
                  onClick={() => { setShowProfile(false); navigate('/admin/settings'); }}
                  className="w-full flex items-center gap-2.5 px-3 py-2.5 rounded-xl text-sm font-bold text-gray-600 hover:bg-[#F8F7FC] hover:text-[#FF6B2C]"
                >
                  <Settings size={16} /> Settings
                </button>}
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
