import React from 'react';

interface PrivacyContactCardProps {
  icon: React.ReactNode;
  label: string;
  detail: React.ReactNode;
}

const PrivacyContactCard: React.FC<PrivacyContactCardProps> = ({ icon, label, detail }) => {
  return (
    <div className="flex-1 min-w-[200px] flex items-start gap-4 p-5 bg-white border border-[#ECECEC] rounded-2xl hover:border-[#6C2BFF]/30 hover:shadow-lg transition-all group">
      <div className="w-10 h-10 bg-[#F8F5FF] rounded-xl flex items-center justify-center text-[#6C2BFF] shrink-0 group-hover:bg-[#6C2BFF] group-hover:text-white transition-colors">
        {icon}
      </div>
      <div>
        <p className="text-[10px] font-black text-gray-400 uppercase tracking-widest mb-1">{label}</p>
        <div className="text-xs font-black text-[#111827] leading-relaxed">
          {detail}
        </div>
      </div>
    </div>
  );
};

export default PrivacyContactCard;
