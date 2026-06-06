import React from 'react';
import { User, Edit3, Wallet, CircleDollarSign, Crown, ChevronRight } from 'lucide-react';

const ProfileOverviewCard: React.FC = () => {
  return (
    <div className="bg-white rounded-[24px] border border-[#ECECEC] p-6 shadow-sm flex flex-col md:flex-row gap-8 items-center">
      {/* Profile Info */}
      <div className="flex-1 flex items-center gap-6">
        <div className="w-24 h-24 rounded-full bg-[#F8F5FF] flex items-center justify-center text-[#6C2BFF] border-4 border-white shadow-md">
          <User size={48} />
        </div>
        <div>
          <div className="flex items-center gap-3 mb-1">
            <h3 className="text-xl font-black text-[#111827]">Rohit Sharma</h3>
            <span className="flex items-center gap-1.5 bg-[#6C2BFF]/10 text-[#6C2BFF] text-[10px] font-black uppercase tracking-widest px-3 py-1 rounded-full border border-[#6C2BFF]/20">
              <Crown size={12} />
              Premium Member
            </span>
          </div>
          <p className="text-sm font-bold text-gray-400 mb-3">+91 98765 43210 • rohit.sharma@gmail.com</p>
          <button className="flex items-center gap-2 text-[11px] font-black text-[#6C2BFF] uppercase tracking-widest hover:underline">
            <Edit3 size={14} />
            Edit Profile
          </button>
        </div>
      </div>

      {/* Vertical Divider */}
      <div className="hidden md:block w-px h-20 bg-gray-100"></div>

      {/* Stats Cards */}
      <div className="flex flex-wrap md:flex-nowrap gap-6 w-full md:w-auto">
        {/* Wallet */}
        <div className="flex-1 md:w-[180px]">
          <div className="flex items-center gap-3 mb-2">
            <div className="w-8 h-8 rounded-lg bg-[#6C2BFF]/10 flex items-center justify-center text-[#6C2BFF]">
              <Wallet size={18} />
            </div>
            <span className="text-[11px] font-black text-gray-400 uppercase tracking-wider">chillFi Wallet</span>
          </div>
          <p className="text-lg font-black text-[#111827] mb-1">₹1,250.00</p>
          <button className="flex items-center gap-1 text-[10px] font-black text-[#6C2BFF] uppercase tracking-widest group">
            View Wallet <ChevronRight size={12} className="group-hover:translate-x-1 transition-transform" />
          </button>
        </div>

        {/* Coins */}
        <div className="flex-1 md:w-[180px]">
          <div className="flex items-center gap-3 mb-2">
            <div className="w-8 h-8 rounded-lg bg-amber-100 flex items-center justify-center text-amber-600">
              <CircleDollarSign size={18} />
            </div>
            <span className="text-[11px] font-black text-gray-400 uppercase tracking-wider">chillFi Coins</span>
          </div>
          <p className="text-lg font-black text-[#111827] mb-1">1,200</p>
          <button className="flex items-center gap-1 text-[10px] font-black text-[#6C2BFF] uppercase tracking-widest group">
            View Coins <ChevronRight size={12} className="group-hover:translate-x-1 transition-transform" />
          </button>
        </div>

        {/* Premium */}
        <div className="flex-1 md:w-[180px]">
          <div className="flex items-center gap-3 mb-2">
            <div className="w-8 h-8 rounded-lg bg-[#6C2BFF]/10 flex items-center justify-center text-[#6C2BFF]">
              <Crown size={18} />
            </div>
            <span className="text-[11px] font-black text-gray-400 uppercase tracking-wider">Premium Member</span>
          </div>
          <p className="text-sm font-black text-[#111827] mb-1">Valid till 12 May 2025</p>
          <button className="flex items-center gap-1 text-[10px] font-black text-[#6C2BFF] uppercase tracking-widest group">
            View Benefits <ChevronRight size={12} className="group-hover:translate-x-1 transition-transform" />
          </button>
        </div>
      </div>
    </div>
  );
};

export default ProfileOverviewCard;
