import React from 'react';
import { MapPin, Clock, Info } from 'lucide-react';

const OfficeInfoCard: React.FC = () => {
  return (
    <div className="bg-white border border-[#ECECEC] rounded-[24px] p-8 shadow-sm h-full">
      <h3 className="text-sm font-black text-[#111827] uppercase tracking-wider mb-8">Our Office</h3>

      <div className="space-y-8">
        <div className="flex gap-4">
          <MapPin size={24} className="text-[#FF6B2C] shrink-0 mt-1" />
          <div>
            <h4 className="text-sm font-black text-[#111827] mb-2 uppercase tracking-wider">chillFi Headquarters</h4>
            <p className="text-xs font-bold text-gray-500 leading-relaxed">
              123, Green Park Society <br />
              Indiranagar, Bengaluru <br />
              Karnataka - 560038 <br />
              India
            </p>
          </div>
        </div>

        <div className="flex gap-4">
          <Clock size={24} className="text-[#FF6B2C] shrink-0 mt-1" />
          <div>
            <h4 className="text-sm font-black text-[#111827] mb-2 uppercase tracking-wider">Business Hours</h4>
            <p className="text-xs font-bold text-gray-500">
              Mon – Sun: 9:00 AM – 9:00 PM
            </p>
          </div>
        </div>

        <div className="flex gap-4 pt-4 border-t border-[#FFF8F5]">
          <Info size={20} className="text-amber-500 shrink-0" />
          <p className="text-[11px] font-bold text-gray-400">
            We are closed on national holidays.
          </p>
        </div>
      </div>
    </div>
  );
};

export default OfficeInfoCard;
