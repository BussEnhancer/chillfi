import React from 'react';
import { Link } from 'react-router-dom';
import { ChevronRight } from 'lucide-react';

interface SupportTopicCardProps {
  icon: React.ReactNode;
  title: string;
  desc: string;
  to: string;
  color?: string;
}

const SupportTopicCard: React.FC<SupportTopicCardProps> = ({ icon, title, desc, to, color = '#FF6B2C' }) => {
  return (
    <Link to={to} className="bg-white border border-[#ECECEC] rounded-[24px] p-8 hover:shadow-xl hover:border-[#FF6B2C]/10 hover:-translate-y-1 transition-all duration-300 group cursor-pointer flex flex-col items-center text-center">
      <div
        className="w-14 h-14 rounded-2xl flex items-center justify-center mb-6 shadow-sm transition-transform group-hover:scale-110"
        style={{ backgroundColor: `${color}10`, color: color }}
      >
        {icon}
      </div>
      <h4 className="text-[15px] font-black text-[#111827] mb-2 uppercase tracking-tight">{title}</h4>
      <p className="text-[11px] font-bold text-gray-400 mb-6 leading-relaxed px-4">{desc}</p>

      <span className="flex items-center gap-1.5 text-[10px] font-black text-[#FF6B2C] uppercase tracking-widest group-hover:gap-3 transition-all">
        Learn More
        <ChevronRight size={14} />
      </span>
    </Link>
  );
};

export default SupportTopicCard;
