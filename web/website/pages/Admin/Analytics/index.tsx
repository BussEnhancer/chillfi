import React, { useEffect, useState } from 'react';
import AdminLayout from '../../../components/admin/AdminLayout';
import { TrendingUp, Users, ShoppingCart, Package, ArrowUpRight, Loader2, MapPin } from 'lucide-react';
import { apiGet, friendlyError } from '../../../utils/api';

interface SalesPoint { date: string; orders: string; revenue: string; }
interface TopCategory { category: string; items_sold: string; revenue: string; }
interface AnalyticsData {
  sales_over_time: SalesPoint[];
  top_categories: TopCategory[];
  unique_buyers: number;
  user_growth: { date: string; new_users: string }[];
  top_regions?: { region: string; orders: string | number; revenue: string | number }[];
}

const CHART_COLORS = ['#FF6B2C', '#0EA5E9', '#10B981', '#F59E0B', '#EF4444', '#8B5CFF'];

const periods = [
  { label: '7 Days', days: 7 },
  { label: '30 Days', days: 30 },
  { label: '90 Days', days: 90 },
  { label: '1 Year', days: 365 },
];

const AdminAnalytics: React.FC = () => {
  const [period, setPeriod] = useState(periods[0]);
  const [data, setData] = useState<AnalyticsData | null>(null);
  const [loadError, setLoadError] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Ignore responses for a period the admin has already switched away from (a slow 7-day
    // response must not overwrite the 1-year numbers).
    let current = true;
    setLoading(true);
    apiGet<{ success: boolean; data: AnalyticsData }>(`/admin/analytics?period=${period.days}`)
      .then(res => { if (current) { setData(res.data); setLoadError(''); } })
      .catch((e) => { if (current) { setData(null); setLoadError(friendlyError(e, "Couldn't load analytics")); } })
      .finally(() => { if (current) setLoading(false); });
    return () => { current = false; };
  }, [period]);

  const sales = data?.sales_over_time || [];
  const totalRevenue = sales.reduce((s, d) => s + parseFloat(d.revenue), 0);
  const totalOrders = sales.reduce((s, d) => s + parseInt(d.orders), 0);
  const avgOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0;
  const maxRevenue = Math.max(1, ...sales.map(d => parseFloat(d.revenue)));

  const categories = data?.top_categories || [];
  const totalCatRevenue = categories.reduce((s, c) => s + parseFloat(c.revenue), 0) || 1;

  if (loading && !data) {
    return (
      <AdminLayout title="Analytics" subtitle="Sales performance and insights">
      {loadError && <div className="mb-6 bg-red-50 border border-red-100 text-red-600 text-sm font-bold rounded-2xl px-5 py-4">{loadError}</div>}
        <div className="flex items-center gap-3 text-gray-400 py-20 justify-center">
          <Loader2 size={24} className="animate-spin text-[#FF6B2C]" />
          <span className="text-sm font-bold">Loading analytics...</span>
        </div>
      </AdminLayout>
    );
  }

  return (
    <AdminLayout title="Analytics" subtitle="Sales performance and insights">
      {/* Period Selector */}
      <div className="flex items-center gap-2 mb-6">
        {periods.map(p => (
          <button
            key={p.label}
            onClick={() => setPeriod(p)}
            className={`px-4 py-2 rounded-xl text-xs font-black transition-all ${period.label === p.label ? 'bg-[#FF6B2C] text-white shadow-lg shadow-[#FF6B2C]/20' : 'bg-white border border-[#ECECEC] text-gray-500 hover:border-[#FF6B2C]'}`}
          >
            {p.label}
          </button>
        ))}
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-2 xl:grid-cols-4 gap-4 mb-6">
        {[
          { label: 'Revenue', value: `₹${totalRevenue.toLocaleString('en-IN')}`, icon: <TrendingUp size={18} /> },
          { label: 'Orders', value: `${totalOrders}`, icon: <ShoppingCart size={18} /> },
          { label: 'Avg. Order Value', value: `₹${avgOrderValue.toFixed(0)}`, icon: <Package size={18} /> },
          { label: 'Unique Buyers', value: `${data?.unique_buyers ?? 0}`, icon: <Users size={18} /> },
        ].map((k, i) => (
          <div key={i} className="bg-white rounded-2xl p-5 border border-[#ECECEC] shadow-sm">
            <div className="flex items-center justify-between mb-3">
              <div className="w-9 h-9 bg-[#FFF3ED] rounded-xl flex items-center justify-center text-[#FF6B2C]">{k.icon}</div>
            </div>
            <p className="text-xl font-black text-[#111827] mb-1">{k.value}</p>
            <p className="text-[11px] font-bold text-gray-400">{k.label}</p>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-1 xl:grid-cols-3 gap-6 mb-6">
        {/* Revenue Bar Chart */}
        <div className="xl:col-span-2 bg-white rounded-2xl p-6 border border-[#ECECEC] shadow-sm">
          <div className="flex items-center justify-between mb-6">
            <h3 className="text-sm font-black text-[#111827]">Daily Revenue (₹)</h3>
            <span className="text-[10px] font-black text-gray-400 bg-[#F8F7FC] px-3 py-1.5 rounded-lg">{period.label}</span>
          </div>
          {sales.length === 0 ? (
            <div className="py-16 text-center text-gray-400 text-sm font-bold">No orders in this period.</div>
          ) : (
            <div className="flex items-end gap-2 h-48 overflow-x-auto">
              {sales.map((d, i) => (
                <div key={i} className="flex-1 min-w-[28px] flex flex-col items-center gap-2">
                  <span className="text-[9px] font-black text-gray-400">₹{Math.round(parseFloat(d.revenue))}</span>
                  <div className="w-full relative group cursor-pointer">
                    <div
                      className="w-full bg-[#FF6B2C] rounded-t-xl hover:bg-[#E05520] transition-colors"
                      style={{ height: `${(parseFloat(d.revenue) / maxRevenue) * 160}px` }}
                    />
                  </div>
                  <span className="text-[10px] font-bold text-gray-400">{new Date(d.date).toLocaleDateString('en-IN', { day: '2-digit', month: 'short' })}</span>
                  <span className="text-[9px] font-bold text-gray-300">{d.orders} orders</span>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Category Breakdown */}
        <div className="bg-white rounded-2xl p-6 border border-[#ECECEC] shadow-sm">
          <h3 className="text-sm font-black text-[#111827] mb-6">Revenue by Category</h3>

          {categories.length === 0 ? (
            <div className="py-12 text-center text-gray-400 text-sm font-bold">No category sales in this period.</div>
          ) : (
            <>
              <div className="relative w-36 h-36 mx-auto mb-6">
                <svg viewBox="0 0 100 100" className="w-full h-full -rotate-90">
                  {categories.reduce((acc, cat, i) => {
                    const offset = acc.offset;
                    const pct = (parseFloat(cat.revenue) / totalCatRevenue) * 100;
                    const dash = pct * 2.51327;
                    const gap = 251.327 - dash;
                    acc.elements.push(
                      <circle
                        key={i}
                        cx="50" cy="50" r="40"
                        fill="none"
                        stroke={CHART_COLORS[i % CHART_COLORS.length]}
                        strokeWidth="20"
                        strokeDasharray={`${dash} ${gap}`}
                        strokeDashoffset={-offset}
                      />
                    );
                    acc.offset += dash;
                    return acc;
                  }, { offset: 0, elements: [] as React.ReactElement[] }).elements}
                </svg>
                <div className="absolute inset-0 flex items-center justify-center">
                  <div className="text-center">
                    <p className="text-lg font-black text-[#111827]">100%</p>
                    <p className="text-[9px] font-bold text-gray-400">Total</p>
                  </div>
                </div>
              </div>

              <div className="space-y-3">
                {categories.map((cat, i) => (
                  <div key={i} className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <div className="w-2.5 h-2.5 rounded-full" style={{ background: CHART_COLORS[i % CHART_COLORS.length] }} />
                      <span className="text-xs font-bold text-gray-600">{cat.category}</span>
                    </div>
                    <span className="text-xs font-black text-[#111827]">{((parseFloat(cat.revenue) / totalCatRevenue) * 100).toFixed(0)}%</span>
                  </div>
                ))}
              </div>
            </>
          )}
        </div>
      </div>

      {/* Orders/revenue by delivery state (revenue = paid & not cancelled, same as dashboard) */}
      <div className="bg-white rounded-2xl p-6 border border-[#ECECEC] shadow-sm">
        <div className="flex items-center justify-between mb-2">
          <h3 className="text-sm font-black text-[#111827]">Top Regions</h3>
        </div>
        {(data?.top_regions || []).length === 0 ? (
          <div className="py-10 text-center text-gray-400">
            <MapPin size={28} className="mx-auto mb-3 text-gray-200" />
            <p className="text-sm font-bold">No orders in this period.</p>
          </div>
        ) : (
          <div className="space-y-3 mt-3">
            {(data?.top_regions || []).map((r) => (
              <div key={r.region} className="flex items-center justify-between text-sm font-bold">
                <span className="text-[#111827]">{r.region}</span>
                <span className="text-gray-500">{Number(r.orders)} orders • ₹{Number(r.revenue).toLocaleString('en-IN')}</span>
              </div>
            ))}
          </div>
        )}
      </div>
    </AdminLayout>
  );
};

export default AdminAnalytics;
