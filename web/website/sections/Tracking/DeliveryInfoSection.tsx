import React from 'react';
import { MapPin, Box } from 'lucide-react';

interface DeliveryInfoSectionProps {
  addrName: string | null;
  addrPhone: string | null;
  line1: string | null;
  line2: string | null;
  city: string | null;
  state: string | null;
  pincode: string | null;
  trackingId: string | null;
}

const DeliveryInfoSection: React.FC<DeliveryInfoSectionProps> = ({ addrName, addrPhone, line1, line2, city, state, pincode, trackingId }) => {
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
              <h4 className="text-sm font-black text-[#111827] mb-2">{addrName || '—'}</h4>
              <p className="text-xs font-bold text-gray-500 leading-relaxed">
                {line1} {line2 && <>, {line2}</>} <br />
                {city}, {state} - {pincode}
              </p>
              <p className="text-xs font-black text-[#111827] mt-3">Phone: {addrPhone || '—'}</p>
           </div>
        </div>

        {/* Delivery Partner */}
        <div className="flex gap-4">
           <div className="w-10 h-10 bg-gray-50 rounded-xl flex items-center justify-center text-gray-400 shrink-0">
              <Box size={20} />
           </div>
           <div>
              <p className="text-[10px] font-black text-gray-400 uppercase tracking-widest mb-2">Tracking Info</p>
              {trackingId ? (
                <p className="text-xs font-bold text-gray-500">Tracking ID: <span className="text-[#111827] font-black">{trackingId}</span></p>
              ) : (
                <p className="text-xs font-bold text-gray-400">Tracking ID not assigned yet</p>
              )}
           </div>
        </div>
      </div>
    </div>
  );
};

export default DeliveryInfoSection;
