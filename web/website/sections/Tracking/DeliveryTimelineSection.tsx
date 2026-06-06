import React from 'react';
import { ChevronDown } from 'lucide-react';

const events = [
  { status: 'Delivered', time: 'May 18, 02:45 PM', location: 'Bengaluru, Karnataka', active: true },
  { status: 'Out for Delivery', time: 'May 18, 09:12 AM', location: 'Bengaluru, Karnataka' },
  { status: 'Reached Delivery Hub', time: 'May 17, 08:35 PM', location: 'Bengaluru, Karnataka' },
  { status: 'In Transit', time: 'May 16, 04:20 PM', location: 'Hosur, Tamil Nadu' },
  { status: 'Shipped', time: 'May 16, 11:30 AM', location: 'Hosur, Tamil Nadu' },
];

const DeliveryTimelineSection: React.FC = () => {
  return (
    <div className="bg-white rounded-[24px] border border-[#ECECEC] p-8 shadow-sm">
      <h3 className="text-sm font-black text-[#111827] uppercase tracking-wider mb-8">Delivery Timeline</h3>

      <div className="relative space-y-8">
        {/* Line */}
        <div className="absolute left-[7px] top-2 bottom-4 w-0.5 bg-green-500"></div>

        {events.map((event, i) => (
          <div key={i} className="relative flex items-start gap-6 pl-8">
            <div className={`absolute left-0 top-1 w-4 h-4 rounded-full border-4 border-white shadow-sm transition-all ${
              event.active ? 'bg-green-500 scale-125' : 'bg-green-500'
            }`}></div>

            <div className="flex-1">
               <h4 className={`text-sm font-black ${event.active ? 'text-green-600' : 'text-[#111827]'}`}>{event.status}</h4>
               <p className="text-[10px] font-bold text-gray-400 uppercase tracking-widest mt-0.5">{event.time} • {event.location}</p>
            </div>
          </div>
        ))}
      </div>

      <button className="flex items-center gap-2 text-[10px] font-black text-[#6C2BFF] uppercase tracking-widest hover:underline mt-8 ml-8">
         Show More
         <ChevronDown size={12} />
      </button>
    </div>
  );
};

export default DeliveryTimelineSection;
