import React from 'react';
import { CheckCircle2, Star } from 'lucide-react';

const TrackingStatusCard: React.FC = () => {
  return (
    <div className="bg-green-50 rounded-[24px] border border-green-100 p-6 flex flex-col md:flex-row items-center justify-between gap-6 mb-8">
      <div className="flex items-center gap-6">
        <div className="w-14 h-14 bg-green-500 rounded-2xl flex items-center justify-center text-white shadow-lg shadow-green-200">
          <CheckCircle2 size={32} />
        </div>
        <div>
          <h3 className="text-xl font-black text-[#111827] mb-1">Delivered</h3>
          <p className="text-sm font-bold text-gray-500 leading-tight">
            Your order has been delivered on <br />
            <span className="text-[#111827]">May 18, 2025 at 02:45 PM</span>
          </p>
        </div>
      </div>

      <button className="bg-white border-2 border-[#6C2BFF] text-[#6C2BFF] px-8 py-3 rounded-xl font-black text-sm flex items-center gap-2 hover:bg-[#6C2BFF] hover:text-white transition-all shadow-sm">
        <Star size={18} />
        Rate & Review
      </button>
    </div>
  );
};

export default TrackingStatusCard;
