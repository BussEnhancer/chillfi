import React from 'react';

interface BenefitItemProps {
  icon: React.ReactNode;
  title: string;
  desc: string;
}

const BenefitItem: React.FC<BenefitItemProps> = ({ icon, title, desc }) => {
  return (
    <div className="flex items-start gap-4 mb-6">
      <div className="w-10 h-10 bg-white rounded-xl flex items-center justify-center text-[#FF6B2C] shadow-sm shrink-0">
        {icon}
      </div>
      <div>
        <h4 className="text-sm font-black text-[#111827] mb-1">{title}</h4>
        <p className="text-[11px] font-bold text-gray-400 leading-tight">{desc}</p>
      </div>
    </div>
  );
};

export default BenefitItem;
