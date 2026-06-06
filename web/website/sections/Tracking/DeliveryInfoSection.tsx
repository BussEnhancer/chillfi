import React from 'react';
import { MapPin, Box, ExternalLink } from 'lucide-react';

const DeliveryInfoSection: React.FC = () => {
  return (
    <div className="bg-white rounded-[24px] border border-[#ECECEC] p-8 h-full shadow-sm">
      <h3 className="text-sm font-black text-[#111827] uppercase tracking-wider mb-8">Delivery Information</h3>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-10">
        {/* Delivered To */}
        <div className="flex gap-4">
           <div className="w-10 h-10 bg-gray-50 rounded-xl flex items-center justify-center text-gray-400 shrink-0">
              <MapPin size={20} />
           </div>
           <div>
              <p className="text-[10px] font-black text-gray-400 uppercase tracking-widest mb-2">Delivered To</p>
              <h4 className="text-sm font-black text-[#111827] mb-2">Rohit Sharma</h4>
              <p className="text-xs font-bold text-gray-500 leading-relaxed">
                123, Green Park Society <br />
                Indiranagar, Bengaluru <br />
                Karnataka - 560038
              </p>
              <p className="text-xs font-black text-[#111827] mt-3">Phone: +91 98765 43210</p>
           </div>
        </div>

        {/* Delivery Partner */}
        <div className="flex gap-4">
           <div className="w-10 h-10 bg-gray-50 rounded-xl flex items-center justify-center text-gray-400 shrink-0">
              <Box size={20} />
           </div>
           <div>
              <p className="text-[10px] font-black text-gray-400 uppercase tracking-widest mb-2">Delivery Partner</p>
              <div className="flex items-center gap-3 mb-2">
                 <div className="text-blue-600 font-black italic text-lg tracking-tighter">ekart</div>
                 <span className="text-sm font-black text-[#111827]">E-Kart Logistics</span>
              </div>
              <p className="text-xs font-bold text-gray-500">Tracking ID: <span className="text-[#111827] font-black">EK123456789IN</span></p>
              <button className="flex items-center gap-2 text-[10px] font-black text-[#6C2BFF] uppercase tracking-widest hover:underline mt-4">
                 View on E-Kart
                 <ExternalLink size={12} />
              </button>
           </div>
        </div>
      </div>
    </div>
  );
};

export default DeliveryInfoSection;
