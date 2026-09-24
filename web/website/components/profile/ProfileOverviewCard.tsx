import React from 'react';
import { Link } from 'react-router-dom';
import { User, Edit3, Crown } from 'lucide-react';

interface ProfileOverviewCardProps {
  name?: string;
  phone?: string;
  email?: string;
  memberSince?: string;
}

const ProfileOverviewCard: React.FC<ProfileOverviewCardProps> = ({ name, phone, email, memberSince }) => {
  return (
    <div className="bg-white rounded-[24px] border border-[#ECECEC] p-6 shadow-sm flex flex-col xl:flex-row gap-8 items-center">
      {/* Profile Info */}
      <div className="flex-1 min-w-0 w-full flex items-center gap-6">
        <div className="w-24 h-24 shrink-0 rounded-full bg-[#FFF8F5] flex items-center justify-center text-[#FF6B2C] border-4 border-white shadow-md">
          <User size={48} />
        </div>
        <div>
          <div className="flex items-center gap-3 mb-1">
            <h3 className="text-xl font-black text-[#111827]">{name || 'My Account'}</h3>
          </div>
          <p className="text-sm font-bold text-gray-400 mb-3 break-all">
            {phone ? `+91 ${phone.replace(/^\+91\s?/, '')}` : ''}
            {phone && email ? ' • ' : ''}
            {email || ''}
          </p>
          <Link to="/account/settings" className="flex items-center gap-2 text-[11px] font-black text-[#FF6B2C] uppercase tracking-widest hover:underline">
            <Edit3 size={14} />
            Edit Profile
          </Link>
        </div>
      </div>

      <div className="hidden xl:block w-px h-20 bg-gray-100"></div>

      {/* Only real account facts here (no wallet/coins/premium — those features don't exist). */}
      {memberSince && (
        <div className="flex-1 min-w-[140px] xl:w-[180px]">
          <div className="flex items-center gap-3 mb-2">
            <div className="w-8 h-8 rounded-lg bg-[#FF6B2C]/10 flex items-center justify-center text-[#FF6B2C]">
              <Crown size={18} />
            </div>
            <span className="text-[11px] font-black text-gray-400 uppercase tracking-wider">Member Since</span>
          </div>
          <p className="text-sm font-black text-[#111827] mb-1">{memberSince ? new Date(memberSince).toLocaleDateString('en-IN', { month: 'long', year: 'numeric' }) : null}</p>
        </div>
      )}
    </div>
  );
};

export default ProfileOverviewCard;
