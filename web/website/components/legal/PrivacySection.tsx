import React from 'react';

interface PrivacySectionProps {
  title: string;
  children: React.ReactNode;
}

const PrivacySection: React.FC<PrivacySectionProps> = ({ title, children }) => {
  return (
    <div className="py-8 border-b border-[#FFF8F5] last:border-0">
      <h3 className="text-lg font-black text-[#111827] mb-4">{title}</h3>
      <div className="text-sm font-bold text-gray-500 leading-relaxed space-y-4">
        {children}
      </div>
    </div>
  );
};

export default PrivacySection;
