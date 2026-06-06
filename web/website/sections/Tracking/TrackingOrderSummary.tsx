import React from 'react';
import { FileText, MapPin, Headphones, ChevronRight } from 'lucide-react';

const TrackingOrderSummary: React.FC = () => {
  return (
    <div className="sticky top-32 space-y-6">
      {/* 1. Order Summary */}
      <div className="bg-white rounded-[24px] border border-[#ECECEC] p-6 shadow-sm">
        <h3 className="text-sm font-black text-[#111827] uppercase tracking-wider mb-6">Order Summary</h3>
        <div className="flex items-center gap-4 mb-6 pb-6 border-b border-[#F8F5FF]">
           <div className="w-16 h-16 bg-[#F8F5FF] rounded-xl overflow-hidden border border-[#ECECEC] flex items-center justify-center p-2 shrink-0">
             <img src="https://images.unsplash.com/photo-1512374382149-233c42b6a83b?auto=format&fit=crop&q=80&w=400" alt="Product" className="w-full h-full object-contain" />
           </div>
           <div className="min-w-0">
              <h5 className="text-xs font-black text-[#111827] truncate">Nike Air Max Excee Men's Sneakers</h5>
              <p className="text-[10px] font-bold text-gray-400 uppercase">Qty: 1</p>
           </div>
        </div>

        <div className="space-y-4 mb-6">
           <div className="flex justify-between items-center text-xs font-bold text-gray-400 uppercase tracking-widest">
              <span>Item Total</span>
              <span className="text-[#111827]">₹5,999</span>
           </div>
           <div className="flex justify-between items-center text-xs font-bold text-gray-400 uppercase tracking-widest">
              <span>Delivery Charges</span>
              <span className="text-green-600">FREE</span>
           </div>
           <div className="flex justify-between items-center text-xs font-bold text-gray-400 uppercase tracking-widest">
              <span>Discount</span>
              <span className="text-green-600">- ₹1,500</span>
           </div>
        </div>

        <div className="pt-6 border-t border-[#F8F5FF] flex justify-between items-center mb-6">
           <span className="text-sm font-black text-[#111827] uppercase tracking-widest">Total Amount</span>
           <span className="text-xl font-black text-[#111827]">₹4,499</span>
        </div>

        <button className="w-full flex items-center justify-center gap-2 text-[10px] font-black text-[#6C2BFF] uppercase tracking-widest hover:underline">
           <FileText size={14} />
           View Invoice
           <ChevronRight size={12} />
        </button>
      </div>

      {/* 2. Delivery Address */}
      <div className="bg-white rounded-[24px] border border-[#ECECEC] p-6 shadow-sm">
         <h3 className="text-sm font-black text-[#111827] uppercase tracking-wider mb-4 flex items-center gap-2">
            <MapPin size={16} className="text-[#6C2BFF]" />
            Delivery Address
         </h3>
         <div className="mb-6">
            <h4 className="text-xs font-black text-[#111827] mb-2">Rohit Sharma</h4>
            <p className="text-[11px] font-bold text-gray-400 leading-relaxed">
               123, Green Park Society, Indiranagar, Bengaluru, Karnataka - 560038
            </p>
            <p className="text-[11px] font-black text-[#111827] mt-2">Phone: +91 98765 43210</p>
         </div>
         <button className="w-full border-2 border-[#ECECEC] text-[#111827] py-3 rounded-xl font-black text-xs hover:border-gray-400 transition-all">
            View or Edit Address
         </button>
      </div>

      {/* 3. Need Help */}
      <div className="bg-[#F8F5FF] rounded-[24px] border border-[#ECECEC] p-6 shadow-sm relative overflow-hidden group">
         <div className="relative z-10">
            <h3 className="text-sm font-black text-[#111827] uppercase tracking-wider mb-2">Need Help?</h3>
            <p className="text-[11px] font-bold text-gray-400 mb-6 leading-relaxed">We're here to help you with your order</p>
            <button className="w-full bg-white border-2 border-[#6C2BFF] text-[#6C2BFF] py-3 rounded-xl font-black text-xs flex items-center justify-center gap-2 hover:bg-[#6C2BFF] hover:text-white transition-all shadow-sm">
               <Headphones size={14} />
               Contact Support
            </button>
         </div>
         <Headphones size={80} className="absolute -bottom-4 -right-4 text-[#6C2BFF] opacity-10 group-hover:scale-110 transition-transform duration-500" />
      </div>
    </div>
  );
};

export default TrackingOrderSummary;
