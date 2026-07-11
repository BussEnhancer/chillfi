import React from 'react';

interface QuickActionCardProps {
  icon: React.ReactNode;
  title: string;
  desc: string;
  color?: string;
}

const QuickActionCard: React.FC<QuickActionCardProps> = ({ icon, title, desc, color = '#FF6B2C' }) => {
  return (
    <div className="flex-1 bg-white border border-[#ECECEC] rounded-[20px] p-5 shadow-sm hover:shadow-xl hover:-translate-y-1 transition-all cursor-pointer group">
      <div
        className="w-12 h-12 rounded-2xl flex items-center justify-center mb-4 transition-transform group-hover:scale-110"
        style={{ backgroundColor: `${color}10`, color: color }}
      >
        {icon}
      </div>
      <h4 className="text-sm font-black text-[#111827] mb-1">{title}</h4>
      <p className="text-[11px] font-bold text-gray-400">{desc}</p>
    </div>
  );
};

export default QuickActionCard;
