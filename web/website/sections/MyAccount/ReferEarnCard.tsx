import React from 'react';
import { Users, Send } from 'lucide-react';

const ReferEarnCard: React.FC = () => {
  return (
    <div className="bg-[#FFF8F5] rounded-[24px] border border-[#ECECEC] p-6 flex flex-col md:flex-row items-center justify-between gap-6 group">
      <div className="flex items-center gap-6">
        <div className="w-14 h-14 bg-white rounded-2xl flex items-center justify-center text-[#FF6B2C] shadow-sm group-hover:scale-110 transition-transform">
          <Users size={28} />
        </div>
        <div>
          <h3 className="text-lg font-black text-[#111827] mb-1">Refer & Earn</h3>
          <p className="text-sm font-bold text-gray-400">Invite your friends and earn chillFi Coins</p>
        </div>
      </div>

      <div className="flex items-center gap-8">
        <div className="text-center md:text-right">
          <p className="text-[10px] font-black text-gray-400 uppercase tracking-widest mb-1">Potential Earnings</p>
          <p className="text-sm font-black text-[#111827]">You can earn up to <span className="text-[#FF6B2C]">500 Coins</span></p>
        </div>
        <button className="bg-[#FF6B2C] text-white px-8 py-3 rounded-xl font-black text-sm flex items-center gap-2 shadow-xl shadow-[#FF6B2C]/20 hover:scale-[1.05] transition-all active:scale-[0.98]">
          Refer Now
          <Send size={16} />
        </button>
      </div>
    </div>
  );
};

export default ReferEarnCard;
