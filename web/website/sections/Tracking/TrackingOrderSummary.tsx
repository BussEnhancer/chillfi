import React from 'react';
import { Link } from 'react-router-dom';
import { MapPin, Headphones } from 'lucide-react';

interface OrderItem {
  product_name: string;
  product_image: string;
  quantity: number;
  price: number;
}

interface TrackingOrderSummaryProps {
  items: OrderItem[];
  subtotal: number;
  deliveryFee: number;
  discount: number;
  taxAmount: number;
  total: number;
  addrName: string | null;
  addrPhone: string | null;
  line1: string | null;
  line2: string | null;
  city: string | null;
  state: string | null;
  pincode: string | null;
}

const TrackingOrderSummary: React.FC<TrackingOrderSummaryProps> = ({
  items, subtotal, deliveryFee, discount, taxAmount, total, addrName, addrPhone, line1, line2, city, state, pincode
}) => {
  const first = items[0];
  return (
    <div className="sticky top-32 space-y-6">
      {/* 1. Order Summary */}
      <div className="bg-white rounded-[24px] border border-[#ECECEC] p-6 shadow-sm">
        <h3 className="text-sm font-black text-[#111827] uppercase tracking-wider mb-6">Order Summary</h3>
        {first && (
          <div className="flex items-center gap-4 mb-6 pb-6 border-b border-[#FFF8F5]">
             <div className="w-16 h-16 bg-[#FFF8F5] rounded-xl overflow-hidden border border-[#ECECEC] flex items-center justify-center p-2 shrink-0">
               <img src={first.product_image} alt={first.product_name} className="w-full h-full object-contain" />
             </div>
             <div className="min-w-0">
                <h5 className="text-xs font-black text-[#111827] truncate">{first.product_name}{items.length > 1 ? ` + ${items.length - 1} more` : ''}</h5>
                <p className="text-[10px] font-bold text-gray-400 uppercase">Qty: {items.reduce((s, i) => s + i.quantity, 0)}</p>
             </div>
          </div>
        )}

        <div className="space-y-4 mb-6">
           <div className="flex justify-between items-center text-xs font-bold text-gray-400 uppercase tracking-widest">
              <span>Item Total</span>
              <span className="text-[#111827]">₹{subtotal.toLocaleString()}</span>
           </div>
           <div className="flex justify-between items-center text-xs font-bold text-gray-400 uppercase tracking-widest">
              <span>Delivery Charges</span>
              <span className={deliveryFee === 0 ? 'text-green-600' : 'text-[#111827]'}>{deliveryFee === 0 ? 'FREE' : `₹${deliveryFee.toLocaleString()}`}</span>
           </div>
           {discount > 0 && (
             <div className="flex justify-between items-center text-xs font-bold text-gray-400 uppercase tracking-widest">
                <span>Discount</span>
                <span className="text-green-600">- ₹{discount.toLocaleString()}</span>
             </div>
           )}
           {taxAmount > 0 && (
             <div className="flex justify-between items-center text-xs font-bold text-gray-400 uppercase tracking-widest">
                {/* Orders before 25 Sep 2026 added GST on top; newer orders include it in the price. */}
                <span>{Math.abs(total - (subtotal + deliveryFee - discount)) < 0.01 ? 'Includes GST' : 'GST'}</span>
                <span className="text-[#111827]">₹{taxAmount.toLocaleString()}</span>
             </div>
           )}
        </div>

        <div className="pt-6 border-t border-[#FFF8F5] flex justify-between items-center">
           <span className="text-sm font-black text-[#111827] uppercase tracking-widest">Total Amount</span>
           <span className="text-xl font-black text-[#111827]">₹{total.toLocaleString()}</span>
        </div>
      </div>

      {/* 2. Delivery Address */}
      <div className="bg-white rounded-[24px] border border-[#ECECEC] p-6 shadow-sm">
         <h3 className="text-sm font-black text-[#111827] uppercase tracking-wider mb-4 flex items-center gap-2">
            <MapPin size={16} className="text-[#FF6B2C]" />
            Delivery Address
         </h3>
         <div className="mb-6">
            <h4 className="text-xs font-black text-[#111827] mb-2">{addrName || '—'}</h4>
            <p className="text-[11px] font-bold text-gray-400 leading-relaxed">
               {line1}{line2 ? `, ${line2}` : ''}, {city}, {state} - {pincode}
            </p>
            <p className="text-[11px] font-black text-[#111827] mt-2">Phone: {addrPhone || '—'}</p>
         </div>
         <Link to="/account/addresses" className="w-full block text-center border-2 border-[#ECECEC] text-[#111827] py-3 rounded-xl font-black text-xs hover:border-gray-400 transition-all">
            View or Edit Address
         </Link>
      </div>

      {/* 3. Need Help */}
      <div className="bg-[#FFF8F5] rounded-[24px] border border-[#ECECEC] p-6 shadow-sm relative overflow-hidden group">
         <div className="relative z-10">
            <h3 className="text-sm font-black text-[#111827] uppercase tracking-wider mb-2">Need Help?</h3>
            <p className="text-[11px] font-bold text-gray-400 mb-6 leading-relaxed">We're here to help you with your order</p>
            <Link to="/support" className="w-full bg-white border-2 border-[#FF6B2C] text-[#FF6B2C] py-3 rounded-xl font-black text-xs flex items-center justify-center gap-2 hover:bg-[#FF6B2C] hover:text-white transition-all shadow-sm">
               <Headphones size={14} />
               Contact Support
            </Link>
         </div>
         <Headphones size={80} className="absolute -bottom-4 -right-4 text-[#FF6B2C] opacity-10 group-hover:scale-110 transition-transform duration-500" />
      </div>
    </div>
  );
};

export default TrackingOrderSummary;
