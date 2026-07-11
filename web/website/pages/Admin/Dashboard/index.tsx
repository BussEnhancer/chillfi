import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import AdminLayout from '../../../components/admin/AdminLayout';
import { TrendingUp, ShoppingCart, Package, Users, ArrowUpRight, ArrowDownRight, Eye, ChevronRight } from 'lucide-react';
import { useStore } from '../../../context/StoreContext';
import { apiGet } from '../../../utils/api';

const statusStyle: Record<string, string> = {
  Delivered: 'bg-green-50 text-green-600',
  Shipped: 'bg-blue-50 text-blue-600',
  Processing: 'bg-amber-50 text-amber-600',
  Cancelled: 'bg-red-50 text-red-500',
};

const chartBars = [
  { label: 'Jan', h: 40 }, { label: 'Feb', h: 55 }, { label: 'Mar', h: 48 },
  { label: 'Apr', h: 70 }, { label: 'May', h: 62 }, { label: 'Jun', h: 88 },
  { label: 'Jul', h: 75 }, { label: 'Aug', h: 82 }, { label: 'Sep', h: 68 },
  { label: 'Oct', h: 90 }, { label: 'Nov', h: 78 }, { label: 'Dec', h: 95 },
];

interface DashData {
  revenue: number;
  orders: { total: number; by_status: Record<string, number> };
  products: number;
  users: number;
  recent_orders: Array<{ order_number: string; customer: string; total: number; status: string; created_at: string; item_count: number }>;
  top_products: Array<{ name: string; units_sold: number; revenue: number; image: string }>;
  monthly_revenue: Array<{ month: string; revenue: number }>;
  changes?: { revenue: number; orders: number; users: number };
}

const AdminDashboard: React.FC = () => {
  const { products, orders } = useStore();
  const [dash, setDash] = useState<DashData | null>(null);

  useEffect(() => {
    apiGet<{ success: boolean; data: DashData }>('/admin/dashboard')
      .then(r => setDash(r.data))
      .catch(() => {}); // fallback to StoreContext data
  }, []);

  const totalRevenue = dash ? dash.revenue : orders.reduce((s, o) => s + o.amount, 0);
  const totalOrders = dash ? dash.orders.total : orders.length;
  const totalProducts = dash ? dash.products : products.length;
  const totalUsers = dash ? dash.users : 0;

  const fmtChange = (n: number) => `${n >= 0 ? '+' : ''}${n}%`;
  const ch = dash?.changes;
  const stats = [
    { label: 'Total Revenue', value: `₹${totalRevenue.toLocaleString()}`, change: ch ? fmtChange(ch.revenue) : '—', up: (ch?.revenue ?? 0) >= 0, icon: <TrendingUp size={20} />, color: '#FF6B2C', bg: '#FFF3ED' },
    { label: 'Total Orders', value: totalOrders.toLocaleString(), change: ch ? fmtChange(ch.orders) : '—', up: (ch?.orders ?? 0) >= 0, icon: <ShoppingCart size={20} />, color: '#0EA5E9', bg: '#E0F2FE' },
    { label: 'Total Products', value: totalProducts.toLocaleString(), change: '—', up: true, icon: <Package size={20} />, color: '#10B981', bg: '#D1FAE5' },
    { label: 'Total Users', value: totalUsers.toLocaleString(), change: ch ? fmtChange(ch.users) : '—', up: (ch?.users ?? 0) >= 0, icon: <Users size={20} />, color: '#F59E0B', bg: '#FEF3C7' },
  ];

  const recentOrders = dash
    ? dash.recent_orders.slice(0, 5).map(o => ({
        id: o.order_number,
        customer: o.customer,
        product: `${o.item_count} item${o.item_count !== 1 ? 's' : ''}`,
        amount: `₹${Number(o.total).toLocaleString()}`,
        status: o.status,
        date: new Date(o.created_at).toLocaleDateString('en-IN', { day: 'numeric', month: 'short' }),
      }))
    : orders.slice(0, 5).map(o => ({ id: o.id, customer: o.customer, product: o.product, amount: `₹${o.amount.toLocaleString()}`, status: o.status, date: o.date }));

  const topProducts = dash
    ? dash.top_products.slice(0, 4).map(p => ({ name: p.name, sales: p.units_sold, revenue: `₹${Number(p.revenue).toLocaleString()}`, img: p.image }))
    : products.filter(p => p.status === 'Active').slice(0, 4).map(p => ({ name: p.name, sales: p.reviews, revenue: `₹${(p.price * Math.floor(p.reviews / 10)).toLocaleString()}`, img: p.img }));

  const barData = dash?.monthly_revenue ?? chartBars.map(b => ({ month: b.label, revenue: b.h * 1000 }));
  const maxRevenue = Math.max(...barData.map(b => Number(b.revenue)), 1);

  return (
    <AdminLayout title="Dashboard" subtitle="Welcome back, Admin! Here's what's happening.">
      {/* Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-5 mb-6">
        {stats.map((s, i) => (
          <div key={i} className="bg-white rounded-2xl p-5 border border-[#ECECEC] shadow-sm hover:shadow-md transition-shadow">
            <div className="flex items-center justify-between mb-4">
              <div className="w-10 h-10 rounded-xl flex items-center justify-center" style={{ background: s.bg, color: s.color }}>
                {s.icon}
              </div>
              <span className={`flex items-center gap-1 text-xs font-black px-2 py-1 rounded-lg ${s.up ? 'bg-green-50 text-green-600' : 'bg-red-50 text-red-500'}`}>
                {s.up ? <ArrowUpRight size={12} /> : <ArrowDownRight size={12} />}
                {s.change}
              </span>
            </div>
            <p className="text-2xl font-black text-[#111827] mb-1">{s.value}</p>
            <p className="text-xs font-bold text-gray-400">{s.label}</p>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-1 xl:grid-cols-3 gap-6 mb-6">
        {/* Revenue Chart */}
        <div className="xl:col-span-2 bg-white rounded-2xl p-6 border border-[#ECECEC] shadow-sm">
          <div className="flex items-center justify-between mb-6">
            <div>
              <h3 className="text-sm font-black text-[#111827]">Revenue Overview</h3>
              <p className="text-xs font-bold text-gray-400 mt-0.5">Last 12 months (paid orders)</p>
            </div>
          </div>
          {barData.length === 0 ? (
            <div className="h-40 flex items-center justify-center text-sm font-bold text-gray-400">No revenue data yet</div>
          ) : (
            <div className="flex items-end gap-2 h-40">
              {barData.map((b, i) => (
                <div key={i} className="flex-1 flex flex-col items-center gap-1">
                  <div
                    className="w-full rounded-t-lg bg-[#FF6B2C]/20 hover:bg-[#FF6B2C] transition-colors cursor-pointer relative group"
                    style={{ height: `${Math.max((Number(b.revenue) / maxRevenue) * 100, 2)}%` }}
                  >
                    <div className="absolute -top-7 left-1/2 -translate-x-1/2 bg-[#121212] text-white text-[9px] font-black px-2 py-1 rounded-md opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap">
                      ₹{Number(b.revenue).toLocaleString()}
                    </div>
                  </div>
                  <span className="text-[9px] font-bold text-gray-400">{b.month}</span>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Top Products */}
        <div className="bg-white rounded-2xl p-6 border border-[#ECECEC] shadow-sm">
          <div className="flex items-center justify-between mb-6">
            <h3 className="text-sm font-black text-[#111827]">Top Products</h3>
            <Link to="/admin/products" className="text-[10px] font-black text-[#FF6B2C] hover:underline">View All</Link>
          </div>
          <div className="space-y-4">
            {topProducts.map((p, i) => (
              <div key={i} className="flex items-center gap-3">
                <span className="text-[10px] font-black text-gray-300 w-4">{i + 1}</span>
                <div className="w-10 h-10 rounded-xl overflow-hidden bg-[#F8F7FC] border border-[#ECECEC] shrink-0">
                  <img src={p.img} alt={p.name} className="w-full h-full object-cover" />
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-[11px] font-black text-[#111827] truncate">{p.name}</p>
                  <p className="text-[10px] font-bold text-gray-400">{p.sales} sold</p>
                </div>
                <span className="text-[10px] font-black text-[#111827] shrink-0">{p.revenue}</span>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Recent Orders */}
      <div className="bg-white rounded-2xl border border-[#ECECEC] shadow-sm overflow-hidden">
        <div className="flex items-center justify-between px-6 py-4 border-b border-[#F8F7FC]">
          <h3 className="text-sm font-black text-[#111827]">Recent Orders</h3>
          <Link to="/admin/orders" className="flex items-center gap-1 text-[10px] font-black text-[#FF6B2C] hover:underline">
            View All <ChevronRight size={12} />
          </Link>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="bg-[#F8F7FC]">
                {['Order ID', 'Customer', 'Product', 'Amount', 'Date', 'Status'].map((h) => (
                  <th key={h} className="px-6 py-3 text-left text-[10px] font-black text-gray-400 uppercase tracking-widest">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody className="divide-y divide-[#F8F7FC]">
              {recentOrders.map((o, i) => (
                <tr key={i} className="hover:bg-[#FFF8F5] transition-colors">
                  <td className="px-6 py-3.5 text-xs font-black text-[#FF6B2C]">{o.id}</td>
                  <td className="px-6 py-3.5 text-xs font-bold text-[#111827]">{o.customer}</td>
                  <td className="px-6 py-3.5 text-xs font-bold text-gray-500 max-w-[200px] truncate">{o.product}</td>
                  <td className="px-6 py-3.5 text-xs font-black text-[#111827]">{o.amount}</td>
                  <td className="px-6 py-3.5 text-xs font-bold text-gray-400">{o.date}</td>
                  <td className="px-6 py-3.5">
                    <span className={`text-[10px] font-black px-2.5 py-1 rounded-lg uppercase tracking-wide ${statusStyle[o.status]}`}>
                      {o.status}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </AdminLayout>
  );
};

export default AdminDashboard;
