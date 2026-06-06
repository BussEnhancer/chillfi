import React from 'react';

interface ContactInfoCardProps {
  icon: React.ReactNode;
  title: string;
  desc: string;
  detail: string;
  color?: string;
}

const ContactInfoCard: React.FC<ContactInfoCardProps> = ({ icon, title, desc, detail, color = '#6C2BFF' }) => {
  return (
    <div className="bg-white border border-[#ECECEC] rounded-[24px] p-6 shadow-sm hover:shadow-xl hover:-translate-y-1 transition-all duration-300 group text-center flex flex-col items-center">
      <div
        className="w-14 h-14 rounded-full flex items-center justify-center mb-4 transition-transform group-hover:scale-110 shadow-sm"
        style={{ backgroundColor: `${color}10`, color: color }}
      >
        {icon}
      </div>
      <h4 className="text-sm font-black text-[#111827] mb-1 uppercase tracking-wider">{title}</h4>
      <p className="text-[11px] font-bold text-gray-400 mb-3">{desc}</p>
      <p className="text-sm font-black text-[#111827] group-hover:text-[#6C2BFF] transition-colors">{detail}</p>
    </div>
  );
};

export default ContactInfoCard;
