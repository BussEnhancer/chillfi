import React from 'react';
import { Check } from 'lucide-react';

const steps = [
  { title: 'Order Placed', date: 'May 15' },
  { title: 'Confirmed', date: 'May 15' },
  { title: 'Shipped', date: 'May 16' },
  { title: 'Out for Delivery', date: 'May 18' },
  { title: 'Delivered', date: 'May 18' },
];

const OrderProgressTracker: React.FC = () => {
  return (
    <div className="bg-white rounded-[24px] border border-[#ECECEC] p-10 mb-8 overflow-hidden">
      <div className="relative flex justify-between">
        {/* Connection Line */}
        <div className="absolute top-5 left-0 right-0 h-1 bg-gray-100 -translate-y-1/2">
           <div className="absolute top-0 left-0 w-full h-full bg-green-500 rounded-full"></div>
        </div>

        {steps.map((step, index) => (
          <div key={index} className="relative z-10 flex flex-col items-center">
            <div className="w-10 h-10 rounded-full bg-green-500 border-4 border-white shadow-md flex items-center justify-center text-white">
              <Check size={20} strokeWidth={4} />
            </div>
            <div className="mt-4 text-center">
               <h4 className="text-[11px] font-black text-[#111827] uppercase tracking-wider mb-1">{step.title}</h4>
               <p className="text-[10px] font-bold text-gray-400 uppercase">{step.date}</p>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default OrderProgressTracker;
