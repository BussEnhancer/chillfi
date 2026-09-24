import React from 'react';
import { Check, X } from 'lucide-react';

interface OrderProgressTrackerProps {
  status: string;
  createdAt: string;
  updatedAt: string;
}

const STAGES = ['Order Placed', 'Processing', 'Shipped', 'Delivered'];

const fmt = (iso: string) => new Date(iso).toLocaleDateString('en-IN', { day: 'numeric', month: 'short' });

const OrderProgressTracker: React.FC<OrderProgressTrackerProps> = ({ status, createdAt, updatedAt }) => {
  if (status === 'Cancelled') {
    return (
      <div className="bg-white rounded-[24px] border border-[#ECECEC] p-10 mb-8 flex items-center gap-6">
        <div className="w-10 h-10 rounded-full bg-red-500 flex items-center justify-center text-white shrink-0">
          <X size={20} strokeWidth={4} />
        </div>
        <div>
          <h4 className="text-sm font-black text-red-600 uppercase tracking-wider">Order Cancelled</h4>
          <p className="text-[11px] font-bold text-gray-400 mt-1">Placed {fmt(createdAt)} • Cancelled {fmt(updatedAt)}</p>
        </div>
      </div>
    );
  }

  const currentIndex = STAGES.indexOf(status);
  const activeIndex = currentIndex === -1 ? 1 : currentIndex;

  return (
    <div className="bg-white rounded-[24px] border border-[#ECECEC] p-5 sm:p-10 mb-8 overflow-hidden">
      <div className="relative flex justify-between">
        <div className="absolute top-5 left-0 right-0 h-1 bg-gray-100 -translate-y-1/2">
           <div
             className="absolute top-0 left-0 h-full bg-green-500 rounded-full transition-all"
             style={{ width: `${(activeIndex / (STAGES.length - 1)) * 100}%` }}
           />
        </div>

        {STAGES.map((stage, index) => {
          const done = index <= activeIndex;
          return (
            <div key={stage} className="relative z-10 flex flex-col items-center w-16 sm:w-auto">
              <div className={`w-10 h-10 rounded-full border-4 border-white shadow-md flex items-center justify-center text-white ${done ? 'bg-green-500' : 'bg-gray-200'}`}>
                {done && <Check size={20} strokeWidth={4} />}
              </div>
              <div className="mt-4 text-center">
                 <h4 className={`text-[9px] sm:text-[11px] font-black uppercase tracking-normal sm:tracking-wider mb-1 leading-tight break-words ${done ? 'text-[#111827]' : 'text-gray-300'}`}>{stage}</h4>
                 <p className="text-[10px] font-bold text-gray-400 uppercase">{index === 0 ? fmt(createdAt) : index === activeIndex ? fmt(updatedAt) : ''}</p>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
};

export default OrderProgressTracker;
