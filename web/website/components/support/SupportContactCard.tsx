import React from 'react';

interface SupportContactCardProps {
  icon: React.ReactNode;
  title: string;
  desc: string;
  buttonText: string;
  href: string; // tel:, mailto: or https://wa.me/ link the button opens
  detail?: string;
  color?: string;
}

const SupportContactCard: React.FC<SupportContactCardProps> = ({
  icon, title, desc, buttonText, href, detail, color = '#FF6B2C'
}) => {
  return (
    <div className="flex-1 min-w-[240px] bg-white border border-[#ECECEC] rounded-[24px] p-6 text-center flex flex-col items-center hover:shadow-xl transition-all group">
      <div
        className="w-12 h-12 rounded-full flex items-center justify-center mb-4 transition-transform group-hover:scale-110"
        style={{ backgroundColor: `${color}10`, color: color }}
      >
        {icon}
      </div>
      <h4 className="text-sm font-black text-[#111827] mb-1 uppercase tracking-wider">{title}</h4>
      <p className="text-[11px] font-bold text-gray-400 mb-4">{desc}</p>
      {detail && <p className="text-sm font-black text-[#111827] mb-6">{detail}</p>}

      <a
        href={href}
        {...(href.startsWith('http') ? { target: '_blank', rel: 'noopener noreferrer' } : {})}
        className="mt-auto block w-full py-2.5 rounded-xl border-2 font-black text-[11px] uppercase tracking-widest transition-all"
        style={{ borderColor: color, color: color }}
        onMouseEnter={(e) => {
           e.currentTarget.style.backgroundColor = color;
           e.currentTarget.style.color = '#FFFFFF';
        }}
        onMouseLeave={(e) => {
           e.currentTarget.style.backgroundColor = 'transparent';
           e.currentTarget.style.color = color;
        }}
      >
        {buttonText}
      </a>
    </div>
  );
};

export default SupportContactCard;
