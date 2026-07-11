import React from 'react';

interface OrderStatsCardProps {
  total: number;
  delivered: number;
  processing: number;
  shipped: number;
  cancelled: number;
}

const OrderStatsCard: React.FC<OrderStatsCardProps> = ({ total, delivered, processing, shipped, cancelled }) => {
  const stats = [
    { label: 'Total Orders', value: total },
    { label: 'Delivered Orders', value: delivered, color: 'text-green-600' },
    { label: 'Processing Orders', value: processing, color: 'text-amber-600' },
    { label: 'Shipped Orders', value: shipped, color: 'text-blue-600' },
    { label: 'Cancelled Orders', value: cancelled, color: 'text-red-600' },
  ];

  return (
    <div className="bg-white rounded-[24px] border border-[#ECECEC] p-6 shadow-sm">
      <h3 className="text-sm font-black text-[#111827] uppercase tracking-wider mb-6">Order Summary</h3>
      <div className="space-y-4">
        {stats.map((s, i) => (
          <div key={i} className="flex items-center justify-between py-2 border-b border-[#FFF8F5] last:border-0">
            <span className="text-sm font-bold text-gray-500">{s.label}</span>
            <span className={`text-sm font-black ${s.color || 'text-[#111827]'}`}>{s.value}</span>
          </div>
        ))}
      </div>
    </div>
  );
};

export default OrderStatsCard;
