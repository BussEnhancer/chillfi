import React, { useState, useEffect } from 'react';
import AdminLayout from '../../../components/admin/AdminLayout';
import { Search, Eye, ChevronLeft, ChevronRight, Download, X, Check, MapPin, Loader2, Truck, Navigation, RefreshCw, AlertTriangle } from 'lucide-react';
import { apiGet, apiPut, apiPost } from '../../../utils/api';
import { useAdminRole } from '../../../utils/useAdminRole';
import { Order } from '../../../context/StoreContext';

const statusStyle: Record<string, string> = {
  Delivered: 'bg-green-50 text-green-600',
  Shipped: 'bg-blue-50 text-blue-600',
  Processing: 'bg-amber-50 text-amber-600',
  Pending: 'bg-yellow-50 text-yellow-600',
  Cancelled: 'bg-red-50 text-red-500',
};
const allStatuses = ['Processing', 'Shipped', 'Delivered', 'Cancelled'];
const tabs = ['All', 'Processing', 'Shipped', 'Delivered', 'Cancelled'];

interface ApiOrder {
  id: string; order_number?: string; customer_name?: string; customer_email?: string;
  customer_phone?: string; total: string | number; payment_method?: string; status?: string;
  created_at?: string; address_line1?: string; address_line2?: string;
  address_city?: string; address_state?: string; address_pincode?: string; item_count?: number | string; line_count?: number | string;
  tracking_id?: string; payment_status?: string;
  shipping_status?: string; courier_status?: string; shipment_error?: string; shipment_env?: string; shipment_provider?: string;
  product?: string; img?: string;
  items?: Array<{ product_name?: string; image?: string; quantity?: number }>;
}

type AdminOrder = Order & {
  trackingId?: string; paymentStatus?: string; shippingStatus?: string; courierStatus?: string;
  shipmentError?: string; shipmentEnv?: string;
};

// Mirrors backend utils/shipmentStatus.js labels
const SHIPPING_LABEL: Record<string, string> = {
  pending: 'Awaiting shipment', creating: 'Creating shipment', failed: 'Shipment failed',
  manifested: 'Shipment created', pickup_pending: 'Awaiting pickup', in_transit: 'In transit',
  at_destination_hub: 'At delivery hub', out_for_delivery: 'Out for delivery', delivered: 'Delivered',
  rto_in_transit: 'Returning (RTO)', rto_delivered: 'Returned to seller', cancelled: 'Shipment cancelled',
};
const shippingTone = (s?: string) =>
  s === 'failed' || s?.startsWith('rto') ? 'text-red-500' : s === 'delivered' ? 'text-green-600' : 'text-blue-500';

const normalizeApiOrder = (o: ApiOrder): AdminOrder => ({
  id: o.id,
  orderNumber: o.order_number || o.id,
  customer: o.customer_name || 'Unknown',
  email: o.customer_email || '',
  phone: o.customer_phone || '',
  product: (Number(o.line_count) > 1 ? `${o.product} + ${Number(o.line_count) - 1} more` : o.product) || (Array.isArray(o.items) && o.items.length > 0 ? (o.items[0].product_name || 'Product') : 'Multiple items'),
  qty: Number(o.item_count || 1),
  amount: Number(o.total || 0),
  payment: o.payment_method || 'COD',
  status: o.status || 'Processing',
  date: o.created_at ? new Date(o.created_at).toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' }) : '',
  address: [o.address_line1, o.address_line2, o.address_city, o.address_state, o.address_pincode].filter(Boolean).join(', '),
  img: o.img || (Array.isArray(o.items) && o.items.length > 0 ? (o.items[0].image || '') : ''),
  trackingId: o.tracking_id || '',
  paymentStatus: o.payment_status,
  shippingStatus: o.shipping_status,
  courierStatus: o.courier_status,
  shipmentError: o.shipment_error,
  shipmentEnv: o.shipment_env,
});

const Toast: React.FC<{ msg: string; onClose: () => void; isError?: boolean }> = ({ msg, onClose, isError }) => (
  <div className="fixed bottom-6 right-6 z-[100] flex items-center gap-3 bg-[#121212] text-white px-5 py-3.5 rounded-2xl shadow-2xl">
    <div className={`w-6 h-6 ${isError ? 'bg-red-500' : 'bg-green-500'} rounded-full flex items-center justify-center shrink-0`}>
      {isError ? <X size={13} /> : <Check size={13} />}
    </div>
    <span className="text-sm font-bold">{msg}</span>
    <button onClick={onClose} className="ml-2 text-white/50 hover:text-white"><X size={14} /></button>
  </div>
);

interface TrackingScan { location: string; instructions: string; status: string; time: string; }
interface TrackingData {
  waybill: string; status: string; expected_delivery: string; scans: TrackingScan[];
  shipping_status_label?: string; last_update?: string; synced_at?: string; stale?: boolean; env?: string;
}

const TrackingModal: React.FC<{ orderId: string; waybill: string; onClose: () => void }> = ({ orderId, waybill, onClose }) => {
  const [data, setData] = useState<TrackingData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const [syncing, setSyncing] = useState(false);
  useEffect(() => {
    apiGet<{ success: boolean; data: TrackingData }>(`/admin/orders/${orderId}/tracking`)
      .then(res => setData(res.data))
      .catch(e => setError(e.message || 'Failed to fetch tracking'))
      .finally(() => setLoading(false));
  }, [orderId]);

  const syncNow = async () => {
    setSyncing(true); setError('');
    try {
      const res = await apiPost<{ success: boolean; data: { tracking: TrackingData } }>(`/admin/orders/${orderId}/sync-tracking`, {});
      if (res.data?.tracking) setData(res.data.tracking);
    } catch (e: any) { setError(e.message || 'Sync failed'); } finally { setSyncing(false); }
  };

  return (
    <div className="fixed inset-0 bg-black/40 backdrop-blur-sm z-50 flex items-center justify-center p-4">
      <div className="bg-white rounded-2xl shadow-2xl w-full max-w-lg max-h-[85vh] flex flex-col">
        <div className="flex items-center justify-between px-6 py-4 border-b border-[#F8F7FC] shrink-0">
          <div>
            <h3 className="text-lg font-black text-[#111827]">Live Tracking</h3>
            <p className="text-xs font-bold text-gray-400">Waybill: {waybill}{data?.env ? ` • ${data.env}` : ''}</p>
          </div>
          <button onClick={syncNow} disabled={syncing} title="Pull latest status from Delhivery"
            className="ml-auto mr-2 flex items-center gap-1 px-3 h-8 rounded-xl bg-blue-50 text-blue-600 text-xs font-black hover:bg-blue-100 disabled:opacity-60">
            <RefreshCw size={12} className={syncing ? 'animate-spin' : ''} /> Sync
          </button>
          <button onClick={onClose} className="w-8 h-8 rounded-xl bg-[#F8F7FC] flex items-center justify-center hover:bg-red-50 hover:text-red-500"><X size={16} /></button>
        </div>
        <div className="overflow-y-auto p-6">
          {loading && <div className="flex items-center justify-center py-12 gap-2 text-gray-400"><Loader2 size={20} className="animate-spin" /><span className="text-sm font-bold">Fetching from Delhivery...</span></div>}
          {error && <p className="text-sm font-bold text-red-500 text-center py-8">{error}</p>}
          {data && (
            <div className="space-y-4">
              <div className="bg-blue-50 rounded-xl p-4 flex items-center justify-between">
                <div>
                  <p className="text-[10px] font-black text-blue-400 uppercase tracking-widest">Current Status</p>
                  <p className="text-base font-black text-blue-700 mt-0.5">{data.shipping_status_label || data.status}</p>
                  {data.status && data.shipping_status_label && <p className="text-[10px] font-bold text-blue-400">Delhivery: {data.status}</p>}
                  {data.synced_at && <p className="text-[10px] font-bold text-blue-300">Last synced {new Date(data.synced_at).toLocaleString('en-IN')}{data.stale ? ' (Delhivery unreachable — showing stored data)' : ''}</p>}
                </div>
                {data.expected_delivery && (
                  <div className="text-right">
                    <p className="text-[10px] font-black text-blue-400 uppercase tracking-widest">Expected</p>
                    <p className="text-sm font-black text-blue-700 mt-0.5">{new Date(data.expected_delivery).toLocaleDateString('en-IN')}</p>
                  </div>
                )}
              </div>
              <div>
                <p className="text-[10px] font-black text-gray-400 uppercase tracking-widest mb-3">Scan History</p>
                {data.scans.length === 0 && <p className="text-sm font-bold text-gray-400 text-center py-4">No scans yet</p>}
                <div className="space-y-3">
                  {data.scans.map((scan, i) => (
                    <div key={i} className="flex gap-3">
                      <div className="flex flex-col items-center">
                        <div className={`w-3 h-3 rounded-full shrink-0 mt-1 ${i === 0 ? 'bg-blue-500' : 'bg-gray-200'}`} />
                        {i < data.scans.length - 1 && <div className="w-0.5 flex-1 bg-gray-100 mt-1" />}
                      </div>
                      <div className="pb-3">
                        <p className="text-xs font-black text-[#111827]">{scan.status}</p>
                        <p className="text-[11px] font-bold text-gray-500">{scan.instructions}</p>
                        <p className="text-[10px] font-bold text-gray-400 mt-0.5">{scan.location} • {scan.time ? new Date(scan.time).toLocaleString('en-IN') : ''}</p>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

const OrderDetailModal: React.FC<{
  order: AdminOrder;
  onClose: () => void;
  onStatusChange: (id: string, s: string) => Promise<void>;
  onShip: (id: string) => Promise<void>;
  onTrack: (id: string, waybill: string) => void;
}> = ({ order, onClose, onStatusChange, onShip, onTrack }) => {
  const [status, setStatus] = useState(order.status);
  const [saving, setSaving] = useState(false);
  const { isSupportStaff } = useAdminRole();
  // Support staff can view/track but not change orders; Delivered/Cancelled are final (server enforces too).
  const canEditStatus = !isSupportStaff && !['Cancelled', 'Delivered'].includes(order.status);
  const [shipping, setShipping] = useState(false);

  const steps = ['Processing', 'Shipped', 'Delivered'];
  const stepIdx = steps.indexOf(order.status);

  const handleSave = async () => {
    setSaving(true);
    await onStatusChange(order.id, status);
    setSaving(false);
    onClose();
  };

  const handleShip = async () => {
    setShipping(true);
    await onShip(order.id);
    setShipping(false);
    onClose();
  };

  return (
    <div className="fixed inset-0 bg-black/40 backdrop-blur-sm z-50 flex items-end md:items-center justify-center p-0 md:p-4">
      <div className="bg-white rounded-t-3xl md:rounded-2xl shadow-2xl w-full max-w-2xl max-h-[92vh] flex flex-col">
        <div className="flex items-center justify-between px-6 py-4 border-b border-[#F8F7FC] shrink-0">
          <div>
            <h3 className="text-lg font-black text-[#111827]">Order {order.orderNumber || order.id}</h3>
            <p className="text-xs font-bold text-gray-400">{order.date}</p>
          </div>
          <button onClick={onClose} className="w-8 h-8 rounded-xl bg-[#F8F7FC] flex items-center justify-center hover:bg-red-50 hover:text-red-500 transition-colors"><X size={16} /></button>
        </div>

        <div className="overflow-y-auto p-6 space-y-5">
          <div className="flex items-center gap-4 bg-[#F8F7FC] rounded-2xl p-4">
            <div className="w-16 h-16 rounded-xl overflow-hidden bg-white border border-[#ECECEC] shrink-0 flex items-center justify-center">
              {order.img ? <img src={order.img} alt={order.product} className="w-full h-full object-cover" /> : <span className="text-2xl">📦</span>}
            </div>
            <div className="flex-1">
              <p className="text-sm font-black text-[#111827]">{order.product}</p>
              <p className="text-xs font-bold text-gray-400 mt-0.5">Qty: {order.qty} • Payment: {order.payment}</p>
            </div>
            <p className="text-lg font-black text-[#FF6B2C]">₹{order.amount.toLocaleString()}</p>
          </div>

          {/* Delhivery section */}
          <div className="border border-[#ECECEC] rounded-2xl p-4 space-y-3">
            <p className="text-[11px] font-black text-gray-400 uppercase tracking-widest flex items-center gap-1.5"><Truck size={11} />Delhivery Shipment
              {order.shipmentEnv && <span className={`ml-1 px-1.5 py-0.5 rounded text-[9px] ${order.shipmentEnv === 'production' ? 'bg-green-50 text-green-600' : 'bg-amber-50 text-amber-600'}`}>{order.shipmentEnv}</span>}
            </p>
            {order.shippingStatus && (
              <p className={`text-xs font-black ${shippingTone(order.shippingStatus)}`}>
                {SHIPPING_LABEL[order.shippingStatus] || order.shippingStatus}
                {order.courierStatus && <span className="text-gray-400 font-bold"> • Delhivery: {order.courierStatus}</span>}
              </p>
            )}
            {order.shippingStatus === 'failed' && order.shipmentError && (
              <p className="text-[11px] font-bold text-red-500 bg-red-50 rounded-lg p-2 flex gap-1.5"><AlertTriangle size={12} className="shrink-0 mt-0.5" />{order.shipmentError}</p>
            )}
            {order.trackingId ? (
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-[10px] font-bold text-gray-400">Waybill (AWB)</p>
                  <p className="text-sm font-black text-blue-600">{order.trackingId}</p>
                </div>
                <button
                  onClick={async () => {
                    try {
                      const r = await apiGet<{ data: { pdf_url: string | null } }>(`/admin/orders/${order.id}/label`);
                      if (r.data?.pdf_url) window.open(r.data.pdf_url, '_blank', 'noopener');
                      else alert('Delhivery returned no PDF link for this label. Print it from Delhivery One → Shipments.');
                    } catch (e: any) { alert(e.message || 'Could not fetch label'); }
                  }}
                  className="flex items-center gap-1.5 px-4 py-2 bg-[#F8F7FC] text-gray-600 rounded-xl text-xs font-black hover:bg-[#FFF3ED] hover:text-[#FF6B2C] mr-2"
                >
                  <Download size={12} /> Print Label
                </button>
                <button
                  onClick={() => onTrack(order.id, order.trackingId!)}
                  className="flex items-center gap-1.5 px-4 py-2 bg-blue-50 text-blue-600 rounded-xl text-xs font-black hover:bg-blue-100"
                >
                  <Navigation size={12} /> Live Track
                </button>
              </div>
            ) : (
              <div className="flex items-center justify-between">
                <p className="text-xs font-bold text-gray-400">
                  {order.payment !== 'COD' && order.paymentStatus !== 'Paid' ? 'Waiting for payment before shipping' : 'No shipment created yet'}
                </p>
                {/* 'creating' stays clickable: the backend refuses while a claim is fresh and reclaims a stale one */}
                {!isSupportStaff && order.status === 'Processing' && (order.payment === 'COD' || order.paymentStatus === 'Paid') && (
                  <button
                    onClick={handleShip}
                    disabled={shipping}
                    className="flex items-center gap-1.5 px-4 py-2 bg-[#FF6B2C] text-white rounded-xl text-xs font-black hover:bg-[#E05520] disabled:opacity-60"
                  >
                    {shipping ? <Loader2 size={12} className="animate-spin" /> : <Truck size={12} />}
                    {shipping ? 'Creating...' : order.shippingStatus === 'failed' ? 'Retry Shipment' : 'Create Shipment'}
                  </button>
                )}
              </div>
            )}
          </div>

          {order.status !== 'Cancelled' && (
            <div className="bg-white border border-[#ECECEC] rounded-2xl p-5">
              <p className="text-[11px] font-black text-gray-400 uppercase tracking-widest mb-4">Order Progress</p>
              <div className="flex items-center">
                {steps.map((s, i) => (
                  <React.Fragment key={s}>
                    <div className="flex flex-col items-center gap-1.5">
                      <div className={`w-8 h-8 rounded-full flex items-center justify-center font-black text-xs transition-colors ${i <= stepIdx ? 'bg-[#FF6B2C] text-white' : 'bg-gray-100 text-gray-400'}`}>
                        {i < stepIdx ? <Check size={14} /> : i + 1}
                      </div>
                      <span className={`text-[9px] font-black uppercase tracking-wider ${i <= stepIdx ? 'text-[#FF6B2C]' : 'text-gray-300'}`}>{s}</span>
                    </div>
                    {i < steps.length - 1 && <div className={`flex-1 h-0.5 mx-2 mb-4 rounded ${i < stepIdx ? 'bg-[#FF6B2C]' : 'bg-gray-100'}`} />}
                  </React.Fragment>
                ))}
              </div>
            </div>
          )}

          <div className="grid grid-cols-2 gap-3">
            <div className="bg-[#F8F7FC] rounded-2xl p-4">
              <p className="text-[10px] font-black text-gray-400 uppercase tracking-widest mb-2">Customer</p>
              <p className="text-sm font-black text-[#111827]">{order.customer}</p>
              <p className="text-xs font-bold text-gray-400 mt-1">{order.email}</p>
              <p className="text-xs font-bold text-gray-400">{order.phone}</p>
            </div>
            <div className="bg-[#F8F7FC] rounded-2xl p-4">
              <p className="text-[10px] font-black text-gray-400 uppercase tracking-widest mb-2 flex items-center gap-1"><MapPin size={10} />Delivery Address</p>
              <p className="text-sm font-bold text-[#111827] leading-relaxed">{order.address || 'N/A'}</p>
            </div>
          </div>

          {canEditStatus ? <div className="border border-[#ECECEC] rounded-2xl p-4">
            <p className="text-[11px] font-black text-gray-400 uppercase tracking-widest mb-3">Update Order Status</p>
            <div className="flex gap-2 flex-wrap">
              {allStatuses.map(s => (
                <button key={s} onClick={() => setStatus(s)}
                  className={`px-4 py-2 rounded-xl text-xs font-black transition-all ${status === s ? 'bg-[#FF6B2C] text-white shadow-md' : 'bg-[#F8F7FC] text-gray-500 hover:bg-[#FFF3ED] hover:text-[#FF6B2C]'}`}
                >{s}</button>
              ))}
            </div>
          </div> : (
            <p className="text-xs font-bold text-gray-400">
              {isSupportStaff ? 'Only admins can change order status.' : `This order is ${order.status.toLowerCase()} — its status is final. Use Refunds for returns/refunds.`}
            </p>
          )}
        </div>

        <div className="flex gap-3 px-6 py-4 border-t border-[#F8F7FC] shrink-0">
          <button onClick={onClose} disabled={saving} className="flex-1 border-2 border-[#ECECEC] text-gray-600 py-2.5 rounded-xl font-black text-sm">Cancel</button>
          {canEditStatus && <button
            onClick={handleSave}
            disabled={saving || status === order.status}
            className="flex-1 bg-[#FF6B2C] text-white py-2.5 rounded-xl font-black text-sm shadow-lg shadow-[#FF6B2C]/20 hover:bg-[#E05520] disabled:opacity-60 flex items-center justify-center gap-2"
          >
            {saving ? <><Loader2 size={14} className="animate-spin" />Saving...</> : 'Save Changes'}
          </button>}
        </div>
      </div>
    </div>
  );
};

const PAGE_SIZE = 10;

const AdminOrders: React.FC = () => {
  const [orders, setOrders] = useState<AdminOrder[]>([]);
  const [serverTotal, setServerTotal] = useState(0);
  const [activeTab, setActiveTab] = useState('All');
  const [search, setSearch] = useState('');
  const [viewing, setViewing] = useState<AdminOrder | null>(null);
  const [tracking, setTracking] = useState<{ orderId: string; waybill: string } | null>(null);
  const [toast, setToast] = useState('');
  const [toastError, setToastError] = useState(false);
  const [loading, setLoading] = useState(false);
  const [page, setPage] = useState(1);

  const showToast = (msg: string, isError = false) => { setToast(msg); setToastError(isError); setTimeout(() => setToast(''), 3500); };

  const loadOrders = async () => {
    setLoading(true);
    try {
      const res = await apiGet<{ success: boolean; data: { orders: ApiOrder[]; total?: number } }>('/admin/orders?limit=1000');
      setServerTotal(Number(res.data?.total || 0));
      if (res.data?.orders) setOrders(res.data.orders.map(normalizeApiOrder));
    } catch { } finally { setLoading(false); }
  };

  useEffect(() => { loadOrders(); }, []);

  const handleStatusChange = async (id: string, status: string) => {
    try {
      await apiPut(`/admin/orders/${id}/status`, { status });
      showToast(`Order marked as ${status}`);
    } catch (e: any) { showToast(e.message || 'Failed to update status', true); }
    await loadOrders();
  };

  const handleShip = async (id: string) => {
    try {
      const res = await apiPost<{ success: boolean; data: { awb: string; env?: string }; message: string }>(`/admin/orders/${id}/ship`, { provider: 'delhivery' });
      showToast(`${res.message || 'Shipment created'} — AWB ${res.data?.awb}`);
    } catch (e: any) { showToast(e.message || 'Failed to create shipment', true); }
    // Order status only changes to Shipped when Delhivery reports pickup; reload server truth.
    await loadOrders();
  };

  const filtered = orders.filter(o =>
    (activeTab === 'All' || o.status === activeTab) &&
    ((o.orderNumber || o.id).toLowerCase().includes(search.toLowerCase()) ||
      o.customer.toLowerCase().includes(search.toLowerCase()) ||
      o.product.toLowerCase().includes(search.toLowerCase()))
  );

  const totalPages = Math.max(1, Math.ceil(filtered.length / PAGE_SIZE));
  const paginated = filtered.slice((page - 1) * PAGE_SIZE, page * PAGE_SIZE);

  return (
    <AdminLayout title="Orders" subtitle={`${serverTotal || orders.length} total orders`}>
      {serverTotal > orders.length && (
        <div className="mb-4 bg-amber-50 border border-amber-100 text-amber-700 text-xs font-bold rounded-xl px-4 py-3">
          Showing the latest {orders.length} of {serverTotal} orders.
        </div>
      )}
      <div className="flex items-center gap-2 mb-5 overflow-x-auto pb-1">
        {tabs.map(tab => (
          <button key={tab} onClick={() => { setActiveTab(tab); setPage(1); }}
            className={`px-4 py-2 rounded-xl text-xs font-black whitespace-nowrap transition-all ${activeTab === tab ? 'bg-[#FF6B2C] text-white shadow-lg shadow-[#FF6B2C]/20' : 'bg-white border border-[#ECECEC] text-gray-500 hover:border-[#FF6B2C]'}`}
          >
            {tab} <span className="ml-1 opacity-70">{tab === 'All' ? orders.length : orders.filter(o => o.status === tab).length}</span>
          </button>
        ))}
      </div>

      <div className="flex flex-wrap items-center justify-between gap-4 mb-4">
        <div className="relative">
          <input value={search} onChange={e => { setSearch(e.target.value); setPage(1); }} type="text" placeholder="Search orders, customers..." className="w-64 bg-white border border-[#ECECEC] rounded-xl pl-9 pr-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C] shadow-sm" />
          <Search size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
        </div>
        <button
          onClick={() => {
            const csv = ['Order ID,Customer,Product,Qty,Amount,Payment,Date,Status,Waybill',
              ...orders.map(o => `${o.orderNumber || o.id},"${o.customer}","${o.product}",${o.qty},${o.amount},${o.payment},"${o.date}",${o.status},${o.trackingId || ''}`)
            ].join('\n');
            const a = document.createElement('a'); a.href = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csv);
            a.download = `orders_${new Date().toISOString().slice(0, 10)}.csv`; a.click();
          }}
          className="flex items-center gap-2 px-4 py-2.5 bg-white border border-[#ECECEC] rounded-xl text-sm font-bold text-gray-600 hover:border-[#FF6B2C] shadow-sm">
          <Download size={14} /> Export CSV
        </button>
      </div>

      <div className="bg-white rounded-2xl border border-[#ECECEC] shadow-sm overflow-hidden">
        {loading ? (
          <div className="flex items-center justify-center py-8 gap-2 text-gray-400">
            <Loader2 size={18} className="animate-spin" /><span className="text-sm font-bold">Loading orders...</span>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="bg-[#F8F7FC] border-b border-[#ECECEC]">
                  {['Order ID', 'Customer', 'Product', 'Qty', 'Amount', 'Payment', 'Date', 'Status', 'Waybill', 'Actions'].map(h => (
                    <th key={h} className="px-4 py-3 text-left text-[10px] font-black text-gray-400 uppercase tracking-widest whitespace-nowrap">{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody className="divide-y divide-[#F8F7FC]">
                {paginated.map((o) => (
                  <tr key={o.id} className="hover:bg-[#FFF8F5] transition-colors">
                    <td className="px-4 py-3.5 text-xs font-black text-[#FF6B2C] whitespace-nowrap">{o.orderNumber || o.id}</td>
                    <td className="px-4 py-3.5 whitespace-nowrap">
                      <p className="text-xs font-black text-[#111827]">{o.customer}</p>
                      <p className="text-[10px] font-bold text-gray-400">{o.phone}</p>
                    </td>
                    <td className="px-4 py-3.5">
                      <div className="flex items-center gap-2">
                        <div className="w-8 h-8 rounded-lg overflow-hidden bg-[#F8F7FC] border border-[#ECECEC] shrink-0 flex items-center justify-center">
                          {o.img ? <img src={o.img} alt="" className="w-full h-full object-cover" /> : <span className="text-sm">📦</span>}
                        </div>
                        <span className="text-xs font-bold text-gray-600 max-w-[140px] truncate">{o.product}</span>
                      </div>
                    </td>
                    <td className="px-4 py-3.5 text-xs font-bold text-gray-600">{o.qty}</td>
                    <td className="px-4 py-3.5 text-sm font-black text-[#111827] whitespace-nowrap">₹{o.amount.toLocaleString()}</td>
                    <td className="px-4 py-3.5 text-xs font-bold text-gray-500 whitespace-nowrap">{o.payment}</td>
                    <td className="px-4 py-3.5 text-xs font-bold text-gray-400 whitespace-nowrap">{o.date}</td>
                    <td className="px-4 py-3.5 whitespace-nowrap">
                      <span className={`text-[10px] font-black px-2.5 py-1 rounded-lg uppercase tracking-wide ${statusStyle[o.status] || 'bg-gray-100 text-gray-500'}`}>{o.status}</span>
                      {o.shippingStatus && o.shippingStatus !== 'pending' && (
                        <p className={`text-[9px] font-black mt-1 ${shippingTone(o.shippingStatus)}`}>{SHIPPING_LABEL[o.shippingStatus] || o.shippingStatus}</p>
                      )}
                    </td>
                    <td className="px-4 py-3.5 whitespace-nowrap">
                      {o.trackingId ? (
                        <button onClick={() => setTracking({ orderId: o.id, waybill: o.trackingId! })}
                          className="text-[10px] font-black text-blue-600 bg-blue-50 px-2 py-1 rounded-lg hover:bg-blue-100 flex items-center gap-1">
                          <Navigation size={9} />{o.trackingId}
                        </button>
                      ) : (
                        <span className="text-[10px] font-bold text-gray-300">—</span>
                      )}
                    </td>
                    <td className="px-4 py-3.5">
                      <button onClick={() => setViewing(o)} className="w-7 h-7 rounded-lg bg-[#F8F7FC] flex items-center justify-center text-gray-500 hover:bg-[#FFF3ED] hover:text-[#FF6B2C] transition-colors" title="View Details">
                        <Eye size={13} />
                      </button>
                    </td>
                  </tr>
                ))}
                {paginated.length === 0 && (
                  <tr><td colSpan={10} className="px-4 py-12 text-center text-sm font-bold text-gray-400">No orders found</td></tr>
                )}
              </tbody>
            </table>
          </div>
        )}
        <div className="flex items-center justify-between px-6 py-4 border-t border-[#F8F7FC]">
          <p className="text-xs font-bold text-gray-400">Showing {Math.min((page - 1) * PAGE_SIZE + 1, filtered.length)}–{Math.min(page * PAGE_SIZE, filtered.length)} of {filtered.length} orders</p>
          <div className="flex items-center gap-2">
            <button onClick={() => setPage(p => Math.max(1, p - 1))} disabled={page === 1} className="w-8 h-8 flex items-center justify-center rounded-lg border border-[#ECECEC] text-gray-400 disabled:opacity-40"><ChevronLeft size={14} /></button>
            {Array.from({ length: Math.min(5, totalPages) }, (_, i) => {
              const pg = Math.max(1, page - 2) + i;
              return pg <= totalPages ? (
                <button key={pg} onClick={() => setPage(pg)} className={`w-8 h-8 flex items-center justify-center rounded-lg text-xs font-black ${pg === page ? 'bg-[#FF6B2C] text-white' : 'text-gray-500 hover:bg-gray-50'}`}>{pg}</button>
              ) : null;
            })}
            <button onClick={() => setPage(p => Math.min(totalPages, p + 1))} disabled={page === totalPages} className="w-8 h-8 flex items-center justify-center rounded-lg border border-[#ECECEC] text-gray-400 disabled:opacity-40"><ChevronRight size={14} /></button>
          </div>
        </div>
      </div>

      {viewing && (
        <OrderDetailModal
          order={viewing}
          onClose={() => setViewing(null)}
          onStatusChange={handleStatusChange}
          onShip={handleShip}
          onTrack={(id, waybill) => { setViewing(null); setTracking({ orderId: id, waybill }); }}
        />
      )}
      {tracking && <TrackingModal orderId={tracking.orderId} waybill={tracking.waybill} onClose={() => setTracking(null)} />}
      {toast && <Toast msg={toast} onClose={() => setToast('')} isError={toastError} />}
    </AdminLayout>
  );
};

export default AdminOrders;
