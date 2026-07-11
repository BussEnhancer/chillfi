import React from 'react';
import { User, Edit3, Wallet, CircleDollarSign, Crown, ChevronRight } from 'lucide-react';

interface ProfileOverviewCardProps {
  name?: string;
  phone?: string;
  email?: string;
}

const ProfileOverviewCard: React.FC<ProfileOverviewCardProps> = ({ name, phone, email }) => {
  return (
    <div className="bg-white rounded-[24px] border border-[#ECECEC] p-6 shadow-sm flex flex-col md:flex-row gap-8 items-center">
      {/* Profile Info */}
      <div className="flex-1 flex items-center gap-6">
        <div className="w-24 h-24 rounded-full bg-[#FFF8F5] flex items-center justify-center text-[#FF6B2C] border-4 border-white shadow-md">
          <User size={48} />
        </div>
        <div>
          <div className="flex items-center gap-3 mb-1">
            <h3 className="text-xl font-black text-[#111827]">{name || 'My Account'}</h3>
          </div>
          <p className="text-sm font-bold text-gray-400 mb-3">
            {phone ? `+91 ${phone.replace(/^\+91\s?/, '')}` : ''}
            {phone && email ? ' • ' : ''}
            {email || ''}
          </p>
          <button className="flex items-center gap-2 text-[11px] font-black text-[#FF6B2C] uppercase tracking-widest hover:underline">
            <Edit3 size={14} />
            Edit Profile
          </button>
        </div>
      </div>

      <div className="hidden md:block w-px h-20 bg-gray-100"></div>

      <div className="flex flex-wrap md:flex-nowrap gap-6 w-full md:w-auto">
        <div className="flex-1 md:w-[180px]">
          <div className="flex items-center gap-3 mb-2">
            <div className="w-8 h-8 rounded-lg bg-[#FF6B2C]/10 flex items-center justify-center text-[#FF6B2C]">
              <Wallet size={18} />
            </div>
            <span className="text-[11px] font-black text-gray-400 uppercase tracking-wider">chillFi Wallet</span>
          </div>
          <p className="text-lg font-black text-[#111827] mb-1">₹0.00</p>
          <button className="flex items-center gap-1 text-[10px] font-black text-[#FF6B2C] uppercase tracking-widest group">
            View Wallet <ChevronRight size={12} className="group-hover:translate-x-1 transition-transform" />
          </button>
        </div>

        <div className="flex-1 md:w-[180px]">
          <div className="flex items-center gap-3 mb-2">
            <div className="w-8 h-8 rounded-lg bg-amber-100 flex items-center justify-center text-amber-600">
              <CircleDollarSign size={18} />
            </div>
            <span className="text-[11px] font-black text-gray-400 uppercase tracking-wider">chillFi Coins</span>
          </div>
          <p className="text-lg font-black text-[#111827] mb-1">0</p>
          <button className="flex items-center gap-1 text-[10px] font-black text-[#FF6B2C] uppercase tracking-widest group">
            View Coins <ChevronRight size={12} className="group-hover:translate-x-1 transition-transform" />
          </button>
        </div>

        <div className="flex-1 md:w-[180px]">
          <div className="flex items-center gap-3 mb-2">
            <div className="w-8 h-8 rounded-lg bg-[#FF6B2C]/10 flex items-center justify-center text-[#FF6B2C]">
              <Crown size={18} />
            </div>
            <span className="text-[11px] font-black text-gray-400 uppercase tracking-wider">Member Since</span>
          </div>
          <p className="text-sm font-black text-[#111827] mb-1">ChillFi User</p>
          <button className="flex items-center gap-1 text-[10px] font-black text-[#FF6B2C] uppercase tracking-widest group">
            View Benefits <ChevronRight size={12} className="group-hover:translate-x-1 transition-transform" />
          </button>
        </div>
      </div>
    </div>
  );
};

export default ProfileOverviewCard;
