import React, { useEffect, useState } from 'react';
import Header from '../../components/navigation/Header';
import TopBar from '../../components/navigation/TopBar';
import CategoryNav from '../../components/navigation/CategoryNav';
import Footer from '../../components/navigation/Footer';
import Container from '../../components/common/Container';
import Breadcrumb from '../../components/common/Breadcrumb';
import AccountSidebar from '../../components/profile/AccountSidebar';
import OrderCard from '../../components/order/OrderCard';
import OrderStatsCard from '../../sections/Orders/OrderStatsCard';
import FindOrderCard from '../../sections/Orders/FindOrderCard';
import CheckoutTrustStrip from '../../sections/Checkout/CheckoutTrustStrip';
import { Truck, RotateCcw, FileText, HelpCircle, ChevronLeft, ChevronRight, Loader2, PackageOpen } from 'lucide-react';
import { apiGet } from '../../utils/api';
import { OrderStatus } from '../../components/order/OrderStatusBadge';
import { friendlyError } from '../../utils/api';

interface ApiOrderItem {
  product_name: string;
  product_image: string;
  quantity: number;
  price: number;
}

interface ApiOrder {
  id: string;
  order_number: string;
  status: string;
  payment_method: string;
  payment_status: string;
  total: number;
  created_at: string;
  items: ApiOrderItem[];
  delivered_at?: string | null;
  expected_delivery_date?: string | null;
}

const PAGE_SIZE = 5;
const TABS = ['All', 'Processing', 'Shipped', 'Delivered', 'Cancelled'];

const OrdersPage: React.FC = () => {
  const [orders, setOrders] = useState<ApiOrder[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [activeTab, setActiveTab] = useState('All');
  const [search, setSearch] = useState('');
  const [page, setPage] = useState(1);
  const [total, setTotal] = useState(0);
  const [allStatuses, setAllStatuses] = useState<string[]>([]);

  const breadcrumbItems = [
    { label: 'My Account', href: '/account' },
    { label: 'My Orders' }
  ];

  const loadOrders = async (status: string, pg: number, q = search) => {
    setLoading(true); setError('');
    try {
      const params = new URLSearchParams({ page: String(pg), limit: String(PAGE_SIZE) });
      if (status !== 'All') params.set('status', status);
      if (q.trim()) params.set('search', q.trim()); // server searches all orders, not just this page
      const res = await apiGet<{ success: boolean; data: { orders: ApiOrder[]; total: number } }>(
        `/orders?${params}`
      );
      setOrders(res.data.orders || []);
      setTotal(res.data.total || 0);
    } catch (e: any) {
      setError(friendlyError(e, 'Failed to load orders'));
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { setPage(1); loadOrders(activeTab, 1); }, [activeTab]);
  useEffect(() => { loadOrders(activeTab, page); }, [page]);
  // Debounced search → back to page 1
  useEffect(() => {
    const t = setTimeout(() => { setPage(1); loadOrders(activeTab, 1, search); }, 350);
    return () => clearTimeout(t);
  }, [search]);

  useEffect(() => {
    apiGet<{ success: boolean; data: { orders: ApiOrder[] } }>('/orders?limit=500')
      .then(res => setAllStatuses((res.data.orders || []).map(o => o.status)))
      .catch(() => {});
  }, []);

  const statusCounts = {
    total: allStatuses.length,
    delivered: allStatuses.filter(s => s === 'Delivered').length,
    processing: allStatuses.filter(s => s === 'Processing').length,
    shipped: allStatuses.filter(s => s === 'Shipped').length,
    cancelled: allStatuses.filter(s => s === 'Cancelled').length,
  };

  const filtered = orders;

  const totalPages = Math.ceil(total / PAGE_SIZE);
  // Compact pagination: first, last, current ±1, with ellipses (never one button per page).
  const pageWindow = (cur: number, last: number): (number | string)[] => {
    const set = new Set([1, last, cur - 1, cur, cur + 1].filter(n => n >= 1 && n <= last));
    const nums = [...set].sort((a, b) => a - b); const out: (number | string)[] = [];
    nums.forEach((n, i) => { if (i && n - nums[i - 1] > 1) out.push(`gap${n}`); out.push(n); });
    return out;
  };

  const toCardProps = (o: ApiOrder) => {
    const d = new Date(o.created_at);
    return {
      id: o.order_number || o.id,
      orderId: o.id,
      date: d.toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' }),
      time: d.toLocaleTimeString('en-IN', { hour: '2-digit', minute: '2-digit', hour12: true }),
      image: o.items?.[0]?.product_image || '',
      name: o.items?.length > 1 ? `${o.items[0].product_name} + ${o.items.length - 1} more` : (o.items?.[0]?.product_name || '—'),
      variant: o.items?.length > 1 ? `${o.items.length} items` : '',
      qty: o.items?.reduce((s, i) => s + i.quantity, 0) || 1,
      amount: Number(o.total),
      paymentStatus: o.payment_status || 'Pending',
      paymentMethod: o.payment_method || 'COD',
      // Real dates only: delivered_at once delivered, Delhivery's expected date while in transit.
      deliveryDate: (() => {
        const raw = o.status === 'Delivered' ? o.delivered_at : o.status === 'Cancelled' ? null : o.expected_delivery_date;
        return raw ? new Date(raw).toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' }) : '—';
      })(),
      status: o.status as OrderStatus,
    };
  };

  return (
    <div className="min-h-screen bg-white font-['Poppins']">
      <TopBar />
      <Header />
      <CategoryNav />
      <Breadcrumb items={breadcrumbItems} />

      <Container className="py-10 animate-page-in">
        <div className="mb-8">
          <h1 className="text-3xl font-black text-[#111827] mb-1">My Orders</h1>
          <p className="text-sm font-bold text-gray-400">Track, manage and reorder your purchases</p>
        </div>

        <div className="flex flex-col lg:flex-row gap-10">
          <AccountSidebar activeId="orders" />

          <div className="flex-1 min-w-0">
            {/* Search */}
            <div className="mb-6">
              <input
                type="text"
                value={search}
                onChange={e => setSearch(e.target.value)}
                placeholder="Search by order ID or product name..."
                className="w-full border border-[#ECECEC] rounded-xl px-5 py-3 text-sm font-bold outline-none focus:border-[#FF6B2C] transition-all"
              />
            </div>

            {/* Tabs */}
            <div className="flex gap-2 flex-wrap mb-6">
              {TABS.map(t => (
                <button
                  key={t}
                  onClick={() => setActiveTab(t)}
                  className={`px-5 py-2 rounded-full text-xs font-black transition-all ${
                    activeTab === t
                      ? 'bg-[#FF6B2C] text-white shadow-lg shadow-[#FF6B2C]/20'
                      : 'bg-gray-50 text-gray-500 border border-[#ECECEC] hover:border-[#FF6B2C] hover:text-[#FF6B2C]'
                  }`}
                >
                  {t}
                </button>
              ))}
            </div>

            {loading ? (
              <div className="flex items-center justify-center py-20">
                <Loader2 size={32} className="animate-spin text-[#FF6B2C]" />
              </div>
            ) : error ? (
              <div className="py-16 text-center">
                <p className="text-red-500 font-bold mb-4">{error}</p>
                <button onClick={() => loadOrders(activeTab, page)} className="text-[#FF6B2C] font-black text-sm hover:underline">Try again</button>
              </div>
            ) : filtered.length === 0 ? (
              <div className="py-20 text-center">
                <PackageOpen size={48} className="mx-auto text-gray-200 mb-4" />
                <h3 className="text-lg font-black text-[#111827] mb-2">No orders found</h3>
                <p className="text-sm font-bold text-gray-400">
                  {search ? 'Try a different search term' : activeTab !== 'All' ? `No ${activeTab.toLowerCase()} orders` : "You haven't placed any orders yet"}
                </p>
              </div>
            ) : (
              <div className="space-y-4">
                {filtered.map((o, i) => <OrderCard key={i} {...toCardProps(o)} />)}
              </div>
            )}

            {totalPages > 1 && !loading && (
              <div className="mt-12 flex flex-col sm:flex-row items-center justify-between gap-4">
                <p className="text-xs font-bold text-gray-400">
                  Showing {(page - 1) * PAGE_SIZE + 1}–{Math.min(page * PAGE_SIZE, total)} of {total} orders
                </p>
                <div className="flex flex-wrap items-center justify-center gap-2">
                  <button
                    disabled={page === 1}
                    onClick={() => setPage(p => p - 1)}
                    className="w-10 h-10 flex items-center justify-center text-gray-400 border border-[#ECECEC] rounded-xl hover:border-[#FF6B2C] disabled:opacity-40"
                  >
                    <ChevronLeft size={20} />
                  </button>
                  {pageWindow(page, totalPages).map(p => (
                    typeof p === 'string' ? <span key={p} className="w-6 text-center text-gray-400 font-black">…</span> :
                    <button
                      key={p}
                      onClick={() => setPage(p)}
                      className={`w-10 h-10 flex items-center justify-center text-sm font-black rounded-xl transition-all ${
                        p === page ? 'bg-[#FF6B2C] text-white shadow-lg' : 'text-gray-500 hover:bg-gray-50'
                      }`}
                    >
                      {p}
                    </button>
                  ))}
                  <button
                    disabled={page === totalPages}
                    onClick={() => setPage(p => p + 1)}
                    className="w-10 h-10 flex items-center justify-center text-gray-400 border border-[#ECECEC] rounded-xl hover:border-[#FF6B2C] disabled:opacity-40"
                  >
                    <ChevronRight size={20} />
                  </button>
                </div>
              </div>
            )}
          </div>

          <div className="lg:w-[320px] shrink-0 space-y-8">
            <OrderStatsCard {...statusCounts} />
            <FindOrderCard />
            <div className="bg-white rounded-[24px] border border-[#ECECEC] p-6 shadow-sm">
              <h3 className="text-sm font-black text-[#111827] uppercase tracking-wider mb-6">Quick Actions</h3>
              <div className="space-y-3">
                {[
                  { icon: <Truck size={18} />, title: 'Track Your Order', subtitle: 'Get real-time updates', href: '/account/orders' },
                  { icon: <RotateCcw size={18} />, title: 'Return / Replace Item', subtitle: 'Hassle-free returns', href: '/account' },
                  { icon: <HelpCircle size={18} />, title: 'Need Help?', subtitle: 'Visit our support center', href: '/contact' },
                ].map((item, i) => (
                  <button key={i} onClick={() => window.location.href = item.href} className="w-full flex items-center justify-between p-4 rounded-2xl hover:bg-[#FFF8F5] group transition-all text-left">
                    <div className="flex items-center gap-4">
                      <div className="w-10 h-10 bg-gray-50 rounded-xl flex items-center justify-center text-gray-400 group-hover:text-[#FF6B2C] group-hover:bg-white transition-all">
                        {item.icon}
                      </div>
                      <div>
                        <h4 className="text-[11px] font-black text-[#111827] uppercase tracking-tight">{item.title}</h4>
                        <p className="text-[10px] font-bold text-gray-400">{item.subtitle}</p>
                      </div>
                    </div>
                    <ChevronRight size={14} className="text-gray-300 group-hover:text-[#FF6B2C] transition-colors" />
                  </button>
                ))}
              </div>
            </div>
          </div>
        </div>

        <CheckoutTrustStrip />
      </Container>

      <Footer />
    </div>
  );
};

export default OrdersPage;
