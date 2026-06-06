import React from 'react';
import { ChevronRight } from 'lucide-react';

const orders = [
  {
    id: '#CHI2345678',
    image: 'https://images.unsplash.com/photo-1512374382149-233c42b6a83b?auto=format&fit=crop&q=80&w=400',
    name: "Nike Air Max Excee Men's Sneakers",
    date: 'May 15, 2025',
    price: 5999,
    qty: 1,
    status: 'Delivered',
    statusColor: 'green'
  },
  {
    id: '#CHI2345675',
    image: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&q=80&w=400',
    name: 'Fastrack Men Black Analog Watch',
    date: 'May 12, 2025',
    price: 2495,
    qty: 1,
    status: 'Shipped',
    statusColor: 'amber'
  },
  {
    id: '#CHI2345670',
    image: 'https://images.unsplash.com/photo-1484704849700-f032a568e944?auto=format&fit=crop&q=80&w=400',
    name: 'boAt Rockerz 450 Wireless Headphones',
    date: 'May 10, 2025',
    price: 1499,
    qty: 1,
    status: 'Delivered',
    statusColor: 'green'
  }
];

const RecentOrdersCard: React.FC = () => {
  return (
    <div className="bg-white rounded-[24px] border border-[#ECECEC] p-6 shadow-sm">
      <div className="flex items-center justify-between mb-8">
        <h3 className="text-lg font-black text-[#111827]">Recent Orders</h3>
        <button className="text-[11px] font-black text-[#6C2BFF] uppercase tracking-widest hover:underline">View All Orders ›</button>
      </div>

      <div className="space-y-6">
        {orders.map((order, i) => (
          <div key={i} className="flex items-center gap-6 p-4 rounded-2xl hover:bg-[#F8F5FF] transition-all group border border-transparent hover:border-[#6C2BFF]/10">
            <div className="w-16 h-16 bg-gray-50 rounded-xl overflow-hidden border border-[#ECECEC] flex items-center justify-center p-2 shrink-0">
              <img src={order.image} alt={order.name} className="w-full h-full object-contain" />
            </div>

            <div className="flex-1 min-w-0">
              <h4 className="text-sm font-black text-[#111827] truncate group-hover:text-[#6C2BFF] transition-colors">{order.name}</h4>
              <p className="text-[10px] font-bold text-gray-400 uppercase tracking-widest mt-1">
                Order ID: {order.id} • {order.date}
              </p>
            </div>

            <div className="text-right hidden md:block">
              <p className="text-sm font-black text-[#111827]">₹{order.price.toLocaleString()}</p>
              <p className="text-[10px] font-bold text-gray-400">Qty: {order.qty}</p>
            </div>

            <div className="w-24 text-right">
              <span className={`text-[10px] font-black uppercase tracking-widest px-2.5 py-1 rounded-md mb-2 inline-block ${
                order.statusColor === 'green' ? 'bg-green-50 text-green-600' : 'bg-amber-50 text-amber-600'
              }`}>
                {order.status}
              </span>
              <button className="flex items-center gap-1 text-[10px] font-black text-[#6C2BFF] uppercase tracking-widest hover:underline justify-end ml-auto">
                View Details <ChevronRight size={12} />
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default RecentOrdersCard;
