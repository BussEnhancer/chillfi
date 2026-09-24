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
  courier?: string | null;
  env?: string | null;
  expectedDelivery?: string | null;
}

const DeliveryInfoSection: React.FC<DeliveryInfoSectionProps> = ({ addrName, addrPhone, line1, line2, city, state, pincode, trackingId, courier, env, expectedDelivery }) => {
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
                <>
                  <p className="text-xs font-bold text-gray-500">Courier: <span className="text-[#111827] font-black capitalize">{courier || 'Delhivery'}</span></p>
                  <p className="text-xs font-bold text-gray-500 mt-1">AWB: <span className="text-[#111827] font-black">{trackingId}</span></p>
                  {expectedDelivery && (
                    <p className="text-xs font-bold text-gray-500 mt-1">Expected by: <span className="text-[#111827] font-black">{new Date(expectedDelivery).toLocaleDateString('en-IN', { day: 'numeric', month: 'short' })}</span></p>
                  )}
                  {(courier || 'delhivery') === 'delhivery' && env === 'production' && (
                    <a href={`https://www.delhivery.com/track-v2/package/${trackingId}`} target="_blank" rel="noopener noreferrer" className="inline-block text-xs font-black text-[#FF6B2C] mt-2 hover:underline">Track on Delhivery →</a>
                  )}
                </>
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
