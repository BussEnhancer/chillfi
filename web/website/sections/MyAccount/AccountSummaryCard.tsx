import React, { useEffect, useState } from 'react';
import { ShoppingBag, CheckCircle, Clock, XCircle, CreditCard, Calendar, Loader2 } from 'lucide-react';
import { apiGet } from '../../utils/api';

interface OrderStats {
  total: number;
  delivered: number;
  pending: number;
  cancelled: number;
  totalSpent: number;
  memberSince: string;
}

const AccountSummaryCard: React.FC = () => {
  const [stats, setStats] = useState<OrderStats | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    Promise.allSettled([
      apiGet<{ success: boolean; data: { total: number } }>('/orders?limit=1'),
      apiGet<{ success: boolean; data: { total: number } }>('/orders?status=Delivered&limit=1'),
      apiGet<{ success: boolean; data: { total: number } }>('/orders?status=Processing&limit=1'),
      apiGet<{ success: boolean; data: { total: number } }>('/orders?status=Cancelled&limit=1'),
      apiGet<{ success: boolean; data: { id: string; name: string; created_at: string } }>('/profile'),
    ]).then(([allRes, delivRes, pendRes, cancelRes, profileRes]) => {
      const total     = allRes.status    === 'fulfilled' ? allRes.value.data.total    ?? 0 : 0;
      const delivered = delivRes.status  === 'fulfilled' ? delivRes.value.data.total  ?? 0 : 0;
      const pending   = pendRes.status   === 'fulfilled' ? pendRes.value.data.total   ?? 0 : 0;
      const cancelled = cancelRes.status === 'fulfilled' ? cancelRes.value.data.total ?? 0 : 0;
      const memberSince = profileRes.status === 'fulfilled'
        ? new Date((profileRes.value.data as any).created_at).toLocaleDateString('en-IN', { month: 'short', year: 'numeric' })
        : '—';

      setStats({ total, delivered, pending, cancelled, totalSpent: 0, memberSince });
    }).finally(() => setLoading(false));
  }, []);

  const rows = stats
    ? [
        { label: 'Total Orders',     value: String(stats.total),     icon: <ShoppingBag size={16} /> },
        { label: 'Delivered',         value: String(stats.delivered), icon: <CheckCircle size={16} />, color: 'text-green-500' },
        { label: 'Pending / Active',  value: String(stats.pending),   icon: <Clock size={16} />,       color: 'text-amber-500' },
        { label: 'Cancelled',         value: String(stats.cancelled), icon: <XCircle size={16} />,     color: 'text-red-500' },
        { label: 'Member Since',      value: stats.memberSince,       icon: <Calendar size={16} /> },
      ]
    : [];

  return (
    <div className="bg-white rounded-[24px] border border-[#ECECEC] p-6 shadow-sm">
      <h3 className="text-lg font-black text-[#111827] mb-8">Account Summary</h3>

      {loading ? (
        <div className="flex items-center justify-center py-8">
          <Loader2 size={24} className="animate-spin text-[#FF6B2C]" />
        </div>
      ) : (
        <div className="space-y-5">
          {rows.map((stat, i) => (
            <div key={i} className="flex items-center justify-between pb-4 border-b border-[#FFF8F5] last:border-0 last:pb-0">
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 rounded-lg bg-[#FFF8F5] flex items-center justify-center text-gray-400">
                  {stat.icon}
                </div>
                <span className="text-sm font-bold text-gray-500">{stat.label}</span>
              </div>
              <span className={`text-sm font-black ${stat.color || 'text-[#111827]'}`}>{stat.value}</span>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

export default AccountSummaryCard;
