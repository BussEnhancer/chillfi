import React from 'react';
import MiniProductItem from '../../components/order/MiniProductItem';
import { ChevronRight, ShieldCheck, Lock } from 'lucide-react';

const products = [
  {
    image: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&q=80&w=400',
    name: 'Samsung Galaxy S24 FE 5G',
    variant: 'Color: Graphite, 256GB',
    qty: 1,
    price: 39999
  },
  {
    image: 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?auto=format&fit=crop&q=80&w=400',
    name: 'boAt Airdopes 141 TWS Earbuds',
    variant: 'Color: Active Black',
    qty: 1,
    price: 1299
  },
  {
    image: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&q=80&w=400',
    name: 'Sony WH-1000XM5 Headphones',
    variant: 'Color: Midnight Black',
    qty: 1,
    price: 24990
  },
  {
    image: 'https://images.unsplash.com/photo-1508685096489-7aac2715a99a?auto=format&fit=crop&q=80&w=400',
    name: 'Mi Smart Band 8 Pro AMOLED',
    variant: 'Color: Black',
    qty: 1,
    price: 2499
  }
];

const OrderSummaryCard: React.FC = () => {
  return (
    <div className="sticky top-32 space-y-6">
      <div className="bg-white rounded-[24px] border border-[#ECECEC] p-6 shadow-sm overflow-hidden">
        <div className="flex items-center justify-between mb-6 pb-4 border-b border-[#F8F7FC]">
           <h3 className="text-sm font-black text-[#111827] uppercase tracking-wider">Order Summary</h3>
           <span className="text-[10px] font-black text-gray-400 uppercase tracking-widest bg-gray-50 px-3 py-1 rounded-full">4 Items</span>
        </div>

        {/* Product Mini List */}
        <div className="mb-6 max-h-[280px] overflow-y-auto scrollbar-hide">
          {products.map((p, i) => (
            <MiniProductItem key={i} {...p} />
          ))}
        </div>

        {/* Price Breakdown */}
        <div className="space-y-4 pt-6 border-t border-[#F8F7FC] mb-8">
           <div className="flex justify-between items-center text-sm font-bold text-gray-500">
             <span>Price (4 items)</span>
             <span className="text-[#111827]">₹68,787</span>
           </div>
           <div className="flex justify-between items-center text-sm font-bold">
             <span className="text-gray-500">Discount</span>
             <span className="text-green-600">- ₹9,000</span>
           </div>
           <div className="flex justify-between items-center text-sm font-bold">
             <span className="text-gray-500">Delivery Charges</span>
             <span className="text-green-600 uppercase font-black text-xs">Free</span>
           </div>
        </div>

        <div className="bg-green-50 px-4 py-2 rounded-xl border border-green-100 mb-8">
           <p className="text-[11px] font-black text-green-600 uppercase tracking-wider text-center">You will save ₹9,000 on this order</p>
        </div>

        <div className="flex flex-col mb-8">
           <div className="flex justify-between items-center mb-1">
              <span className="text-lg font-black text-[#111827]">Total Amount</span>
              <span className="text-2xl font-black text-[#111827]">₹59,787</span>
           </div>
           <p className="text-[10px] font-bold text-gray-400 uppercase tracking-widest">Inclusive of all taxes</p>
        </div>

        <button className="w-full bg-[#FF6B2C] text-white py-4 rounded-xl font-black flex items-center justify-center gap-3 shadow-xl shadow-[#FF6B2C]/20 hover:scale-[1.02] transition-all mb-4">
           Proceed to Review
           <ChevronRight size={18} />
        </button>

        <div className="flex items-center justify-center gap-2 text-[10px] font-black text-gray-400 uppercase tracking-widest">
           <Lock size={12} className="text-[#16A34A]" />
           <span>100% Secure Payments</span>
        </div>
      </div>

      {/* Trust Mini Strip */}
      <div className="bg-[#F8F7FC] rounded-2xl p-6 border border-[#ECECEC] space-y-4">
         <div className="flex items-center gap-4 text-xs font-black text-[#111827]">
            <ShieldCheck size={18} className="text-[#FF6B2C]" />
            Your payments are safe with us
         </div>
      </div>
    </div>
  );
};

export default OrderSummaryCard;
