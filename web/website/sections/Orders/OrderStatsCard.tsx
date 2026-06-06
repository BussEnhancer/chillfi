import React from 'react';

const stats = [
  { label: 'Total Orders', value: 24 },
  { label: 'Delivered Orders', value: 18, color: 'text-green-600' },
  { label: 'Processing Orders', value: 3, color: 'text-amber-600' },
  { label: 'Shipped Orders', value: 4, color: 'text-blue-600' },
  { label: 'Cancelled Orders', value: 3, color: 'text-red-600' },
  { label: 'Returned Orders', value: 2, color: 'text-gray-600' },
];

const OrderStatsCard: React.FC = () => {
  return (
    <div className="bg-white rounded-[24px] border border-[#ECECEC] p-6 shadow-sm">
      <h3 className="text-sm font-black text-[#111827] uppercase tracking-wider mb-6">Order Summary</h3>
      <div className="space-y-4">
        {stats.map((s, i) => (
          <div key={i} className="flex items-center justify-between py-2 border-b border-[#F8F5FF] last:border-0">
            <span className="text-sm font-bold text-gray-500">{s.label}</span>
            <span className={`text-sm font-black ${s.color || 'text-[#111827]'}`}>{s.value}</span>
          </div>
        ))}
      </div>
    </div>
  );
};

export default OrderStatsCard;
