import React from 'react';
import { ChevronRight } from 'lucide-react';
import OrderStatusBadge, { OrderStatus } from './OrderStatusBadge';

interface OrderCardProps {
  id: string;
  date: string;
  time: string;
  image: string;
  name: string;
  variant: string;
  qty: number;
  amount: number;
  paymentStatus: string;
  paymentMethod: string;
  deliveryDate: string;
  status: OrderStatus;
}

const OrderCard: React.FC<OrderCardProps> = ({
  id, date, time, image, name, variant, qty, amount,
  paymentStatus, paymentMethod, deliveryDate, status
}) => {
  return (
    <div className="bg-white rounded-[20px] p-6 border border-[#ECECEC] hover:shadow-xl hover:border-[#6C2BFF]/10 transition-all group mb-4">
      <div className="flex flex-col xl:flex-row gap-6">
        {/* Order Meta Header (Mobile only or top row) */}
        <div className="flex flex-wrap items-center justify-between gap-4 pb-4 border-b border-[#F8F5FF] xl:hidden">
          <div>
            <span className="text-[10px] font-black text-gray-400 uppercase tracking-widest">Order ID</span>
            <p className="text-sm font-black text-[#111827]">{id}</p>
          </div>
          <OrderStatusBadge status={status} />
        </div>

        {/* Product Info */}
        <div className="flex flex-1 gap-6">
          <div className="w-20 h-20 bg-gray-50 rounded-xl overflow-hidden border border-[#ECECEC] flex items-center justify-center p-2 shrink-0">
            <img src={image} alt={name} className="w-full h-full object-contain" />
          </div>
          <div className="flex-1 min-w-0">
            <div className="hidden xl:block mb-1">
              <span className="text-[10px] font-black text-gray-400 uppercase tracking-widest">Order ID: {id}</span>
              <p className="text-[10px] font-bold text-gray-400 uppercase tracking-widest">{date} • {time}</p>
            </div>
            <h4 className="text-sm font-black text-[#111827] truncate group-hover:text-[#6C2BFF] transition-colors">{name}</h4>
            <p className="text-[10px] font-bold text-gray-400 uppercase tracking-widest mt-1">{variant} • Qty: {qty}</p>
          </div>
        </div>

        {/* Order Details Desktop View */}
        <div className="hidden xl:grid grid-cols-4 gap-8 flex-[2] border-l border-[#F8F5FF] pl-8 items-center">
          <div>
            <span className="text-[10px] font-black text-gray-400 uppercase tracking-widest block mb-1">Total Amount</span>
            <p className="text-sm font-black text-[#111827]">₹{amount.toLocaleString()}</p>
            <p className="text-[10px] font-bold text-gray-400">(1 Item)</p>
          </div>

          <div>
            <span className="text-[10px] font-black text-gray-400 uppercase tracking-widest block mb-1">Payment</span>
            <p className="text-sm font-black text-green-600">{paymentStatus}</p>
            <p className="text-[10px] font-bold text-gray-400">{paymentMethod}</p>
          </div>

          <div>
             <span className="text-[10px] font-black text-gray-400 uppercase tracking-widest block mb-1">
               {status === 'Delivered' ? 'Delivered on' : 'Expected by'}
             </span>
             <p className="text-sm font-black text-[#111827]">{deliveryDate}</p>
          </div>

          <div className="text-right">
             <div className="mb-2">
               <OrderStatusBadge status={status} />
             </div>
             <button className="flex items-center gap-1 text-[10px] font-black text-[#6C2BFF] uppercase tracking-widest hover:underline ml-auto">
               View Details <ChevronRight size={12} />
             </button>
          </div>
        </div>

        {/* Mobile Detail Row */}
        <div className="xl:hidden grid grid-cols-2 gap-4 pt-4 border-t border-[#F8F5FF]">
           <div>
             <span className="text-[10px] font-bold text-gray-400 uppercase">Amount</span>
             <p className="text-xs font-black text-[#111827]">₹{amount.toLocaleString()}</p>
           </div>
           <div className="text-right">
             <button className="flex items-center gap-1 text-[10px] font-black text-[#6C2BFF] uppercase tracking-widest hover:underline ml-auto">
               View Details <ChevronRight size={12} />
             </button>
           </div>
        </div>
      </div>
    </div>
  );
};

export default OrderCard;
