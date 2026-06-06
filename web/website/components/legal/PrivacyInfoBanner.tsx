import React from 'react';

interface PrivacyInfoBannerProps {
  icon: React.ReactNode;
  title: string;
  desc: string;
}

const PrivacyInfoBanner: React.FC<PrivacyInfoBannerProps> = ({ icon, title, desc }) => {
  return (
    <div className="bg-[#F8F5FF] rounded-[24px] p-8 flex items-start gap-6 border border-[#6C2BFF]/10">
      <div className="w-14 h-14 bg-white rounded-2xl flex items-center justify-center text-[#6C2BFF] shadow-sm shrink-0">
        {icon}
      </div>
      <div>
        <h3 className="text-sm font-black text-[#111827] uppercase tracking-wider mb-2">{title}</h3>
        <p className="text-sm font-bold text-gray-400 leading-relaxed">{desc}</p>
      </div>
    </div>
  );
};

export default PrivacyInfoBanner;
