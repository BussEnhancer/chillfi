import React from 'react';
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
          <button className="w-full bg-[#6C2BFF] text-white py-4 rounded-xl font-black flex items-center justify-center gap-3 shadow-xl shadow-[#6C2BFF]/20 hover:scale-[1.02] transition-all">
            Proceed to Checkout
            <ChevronRight size={18} />
          </button>
          <button className="w-full border-2 border-[#ECECEC] text-[#111827] py-4 rounded-xl font-black hover:border-gray-400 transition-all">
             ← Continue Shopping
          </button>
        </div>

        <div className="mt-8 pt-8 border-t border-[#F8F7FC]">
          <span className="text-[10px] font-black text-gray-400 uppercase tracking-widest block mb-4">We Accept</span>
          <div className="flex items-center gap-4 flex-wrap">
             <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Visa_Inc._logo.svg/2560px-Visa_Inc._logo.svg.png" alt="Visa" className="h-3 opacity-60 grayscale" />
             <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Mastercard-logo.svg/1280px-Mastercard-logo.svg.png" alt="Mastercard" className="h-5 opacity-60 grayscale" />
             <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/e/e1/UPI-Logo-vector.svg/1200px-UPI-Logo-vector.svg.png" alt="UPI" className="h-4 opacity-60 grayscale" />
             <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/Paytm_Logo_%28standalone%29.svg/1200px-Paytm_Logo_%28standalone%29.svg.png" alt="Paytm" className="h-3 opacity-60 grayscale" />
             <span className="text-[10px] font-black text-gray-400">+5</span>
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
              <span className="text-[#6C2BFF]">{item.icon}</span>
              {item.title}
           </div>
         ))}
      </div>
    </div>
  );
};

export default PriceSummaryCard;
