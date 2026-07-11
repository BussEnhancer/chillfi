import React from 'react';

interface PaymentMethodCardProps {
  label: string;
  icon: React.ReactNode;
  isSelected?: boolean;
  badge?: string;
}

const PaymentMethodCard: React.FC<PaymentMethodCardProps> = ({ label, icon, isSelected, badge }) => {
  return (
    <div
      className={`flex-1 flex items-center justify-between p-5 rounded-2xl border-2 transition-all cursor-pointer ${
        isSelected ? 'border-[#FF6B2C] bg-[#FF6B2C]/5' : 'border-[#ECECEC] bg-white hover:border-gray-300'
      }`}
    >
      <div className="flex items-center gap-4">
        <div className={`w-5 h-5 rounded-full border-2 flex items-center justify-center ${
          isSelected ? 'border-[#FF6B2C]' : 'border-gray-200'
        }`}>
          {isSelected && <div className="w-2.5 h-2.5 rounded-full bg-[#FF6B2C]"></div>}
        </div>
        <div className="flex items-center gap-3">
          <div className={`text-[#111827] ${isSelected ? 'text-[#FF6B2C]' : ''}`}>
            {icon}
          </div>
          <span className={`text-sm font-black ${isSelected ? 'text-[#FF6B2C]' : 'text-gray-700'}`}>{label}</span>
        </div>
      </div>
      {badge && (
        <span className="text-[10px] font-black uppercase tracking-wider bg-green-50 text-green-600 px-2.5 py-1 rounded-md">
          {badge}
        </span>
      )}
    </div>
  );
};

export default PaymentMethodCard;
