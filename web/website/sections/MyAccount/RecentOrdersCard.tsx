import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { ChevronRight, Loader2, PackageOpen } from 'lucide-react';
import { apiGet } from '../../utils/api';

interface ApiOrder {
  id: string;
  order_number: string;
  status: string;
  total: number;
  created_at: string;
  items: { product_name: string; product_image: string; quantity: number }[];
}

const statusColor = (status: string) => {
  if (status === 'Delivered') return 'bg-green-50 text-green-600';
  if (status === 'Shipped') return 'bg-amber-50 text-amber-600';
  if (status === 'Cancelled') return 'bg-red-50 text-red-500';
  return 'bg-blue-50 text-blue-600';
};

const RecentOrdersCard: React.FC = () => {
  const [orders, setOrders] = useState<ApiOrder[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    apiGet<{ success: boolean; data: { orders: ApiOrder[] } }>('/orders?limit=3')
      .then(res => setOrders(res.data.orders || []))
      .catch(() => {})
      .finally(() => setLoading(false));
  }, []);

  return (
    <div className="bg-white rounded-[24px] border border-[#ECECEC] p-6 shadow-sm">
      <div className="flex items-center justify-between mb-8">
        <h3 className="text-lg font-black text-[#111827]">Recent Orders</h3>
        <Link to="/account/orders" className="text-[11px] font-black text-[#FF6B2C] uppercase tracking-widest hover:underline">
          View All Orders ›
        </Link>
      </div>

      {loading ? (
        <div className="flex items-center justify-center py-10">
          <Loader2 size={24} className="animate-spin text-[#FF6B2C]" />
        </div>
      ) : orders.length === 0 ? (
        <div className="py-10 text-center">
          <PackageOpen size={32} className="mx-auto text-gray-200 mb-3" />
          <p className="text-sm font-bold text-gray-400">No orders yet</p>
          <Link to="/products" className="text-xs font-black text-[#FF6B2C] hover:underline mt-2 inline-block">
            Start Shopping
          </Link>
        </div>
      ) : (
        <div className="space-y-6">
          {orders.map(order => {
            const firstItem = order.items?.[0];
            const d = new Date(order.created_at);
            const dateStr = d.toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' });
            return (
              <div key={order.id} className="flex items-center gap-6 p-4 rounded-2xl hover:bg-[#FFF8F5] transition-all group border border-transparent hover:border-[#FF6B2C]/10">
                <div className="w-16 h-16 bg-gray-50 rounded-xl overflow-hidden border border-[#ECECEC] flex items-center justify-center p-2 shrink-0">
                  {firstItem?.product_image ? (
                    <img src={firstItem.product_image} alt={firstItem.product_name} className="w-full h-full object-contain" />
                  ) : (
                    <PackageOpen size={24} className="text-gray-300" />
                  )}
                </div>

                <div className="flex-1 min-w-0">
                  <h4 className="text-sm font-black text-[#111827] truncate group-hover:text-[#FF6B2C] transition-colors">
                    {firstItem?.product_name || 'Order'}
                    {order.items?.length > 1 ? ` + ${order.items.length - 1} more` : ''}
                  </h4>
                  <p className="text-[10px] font-bold text-gray-400 uppercase tracking-widest mt-1">
                    {order.order_number} • {dateStr}
                  </p>
                </div>

                <div className="text-right hidden md:block shrink-0">
                  <p className="text-sm font-black text-[#111827]">₹{Number(order.total).toLocaleString()}</p>
                  <p className="text-[10px] font-bold text-gray-400">
                    Qty: {order.items?.reduce((s, i) => s + i.quantity, 0) || 1}
                  </p>
                </div>

                <div className="w-24 text-right shrink-0">
                  <span className={`text-[10px] font-black uppercase tracking-widest px-2.5 py-1 rounded-md mb-2 inline-block ${statusColor(order.status)}`}>
                    {order.status}
                  </span>
                  <Link
                    to="/account/orders"
                    className="flex items-center gap-1 text-[10px] font-black text-[#FF6B2C] uppercase tracking-widest hover:underline justify-end ml-auto"
                  >
                    Details <ChevronRight size={12} />
                  </Link>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
};

export default RecentOrdersCard;
