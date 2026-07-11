import React from 'react';
import { Link } from 'react-router-dom';
import CouponCard from '../../components/common/CouponCard';
import { ShieldCheck, RotateCcw, Package, ChevronRight } from 'lucide-react';

const PriceSummaryCard: React.FC = () => {
  return (
    <div className="sticky top-32 space-y-6">
      <div className="bg-white rounded-[24px] border border-[#ECECEC] p-6 shadow-sm">
        <h3 className="text-sm font-black text-[#111827] uppercase tracking-wider mb-6">Price Details</h3>

        <div className="space-y-4 mb-6">
          <div className="flex justify-between items-center text-sm font-bold text-gray-500">
            <span>Price (4 items)</span>
            <span className="text-[#111827]">₹13,292</span>
          </div>
          <div className="flex justify-between items-center text-sm font-bold">
            <span className="text-gray-500">Discount</span>
            <span className="text-green-600">- ₹1,948</span>
          </div>
          <div className="flex justify-between items-center text-sm font-bold">
            <div className="flex items-center gap-1 text-gray-500">
              <span>Delivery Charges</span>
              <div className="w-3.5 h-3.5 rounded-full border border-gray-300 flex items-center justify-center text-[8px]">i</div>
            </div>
            <span className="text-green-600 uppercase font-black text-xs">Free</span>
          </div>
        </div>

        <div className="border-t border-[#F8F7FC] pt-6 mb-8">
          <div className="flex justify-between items-center mb-2">
            <span className="text-lg font-black text-[#111827]">Total Amount</span>
            <span className="text-2xl font-black text-[#111827]">₹11,344</span>
          </div>
          <p className="text-[11px] font-black text-green-600">You will save ₹1,948 on this order</p>
        </div>

        <div className="mb-8">
          <CouponCard />
        </div>

        <div className="space-y-4">
          <Link to="/checkout" className="w-full bg-[#FF6B2C] text-white py-4 rounded-xl font-black flex items-center justify-center gap-3 shadow-xl shadow-[#FF6B2C]/20 hover:scale-[1.02] transition-all">
            Proceed to Checkout
            <ChevronRight size={18} />
          </Link>
          <Link to="/products" className="w-full border-2 border-[#ECECEC] text-[#111827] py-4 rounded-xl font-black hover:border-gray-400 transition-all flex items-center justify-center">
             ← Continue Shopping
          </Link>
        </div>

        <div className="mt-8 pt-8 border-t border-[#F8F7FC]">
          <span className="text-[10px] font-black text-gray-400 uppercase tracking-widest block mb-4">We Accept</span>
          <div className="flex items-center gap-3 flex-wrap">
            <span className="text-[10px] font-black text-gray-400 italic tracking-wider border border-gray-200 px-2 py-1 rounded">VISA</span>
            <span className="flex items-center gap-0.5 border border-gray-200 px-2 py-1 rounded">
              <span className="w-3 h-3 rounded-full bg-red-400 -mr-1.5"></span>
              <span className="w-3 h-3 rounded-full bg-yellow-300"></span>
            </span>
            <span className="text-[10px] font-black text-gray-400 tracking-wider border border-gray-200 px-2 py-1 rounded">RuPay</span>
            <span className="text-[10px] font-black tracking-wider border border-gray-200 px-2 py-1 rounded"><span className="text-[#FF6B2C]">U</span>PI</span>
            <span className="text-[10px] font-black text-gray-400 border border-gray-200 px-2 py-1 rounded">Paytm</span>
          </div>
        </div>
      </div>

      <div className="bg-[#F8F7FC] rounded-2xl p-6 border border-[#ECECEC] space-y-4">
         {[
           { icon: <ShieldCheck size={18} />, title: '100% Secure Payments' },
           { icon: <RotateCcw size={18} />, title: '7 Days Easy Returns' },
           { icon: <Package size={18} />, title: 'Original Products' },
         ].map((item, i) => (
           <div key={i} className="flex items-center gap-4 text-xs font-black text-[#111827]">
              <span className="text-[#FF6B2C]">{item.icon}</span>
              {item.title}
           </div>
         ))}
      </div>
    </div>
  );
};

export default PriceSummaryCard;
