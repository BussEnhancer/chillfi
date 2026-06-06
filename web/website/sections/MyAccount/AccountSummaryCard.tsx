import React from 'react';
import { ShoppingBag, CheckCircle, Clock, XCircle, CreditCard, Calendar } from 'lucide-react';

const stats = [
  { label: 'Total Orders', value: '24', icon: <ShoppingBag size={16} /> },
  { label: 'Delivered Orders', value: '18', icon: <CheckCircle size={16} />, color: 'text-green-500' },
  { label: 'Pending Orders', value: '3', icon: <Clock size={16} />, color: 'text-amber-500' },
  { label: 'Cancelled Orders', value: '3', icon: <XCircle size={16} />, color: 'text-red-500' },
  { label: 'Total Spent', value: '₹48,750', icon: <CreditCard size={16} /> },
  { label: 'Member Since', value: 'Jan 2024', icon: <Calendar size={16} /> },
];

const AccountSummaryCard: React.FC = () => {
  return (
    <div className="bg-white rounded-[24px] border border-[#ECECEC] p-6 shadow-sm">
      <h3 className="text-lg font-black text-[#111827] mb-8">Account Summary</h3>

      <div className="space-y-5">
        {stats.map((stat, i) => (
          <div key={i} className="flex items-center justify-between pb-4 border-b border-[#F8F5FF] last:border-0 last:pb-0">
            <div className="flex items-center gap-3">
              <div className="w-8 h-8 rounded-lg bg-[#F8F5FF] flex items-center justify-center text-gray-400">
                {stat.icon}
              </div>
              <span className="text-sm font-bold text-gray-500">{stat.label}</span>
            </div>
            <span className={`text-sm font-black ${stat.color || 'text-[#111827]'}`}>{stat.value}</span>
          </div>
        ))}
      </div>
    </div>
  );
};

export default AccountSummaryCard;
