import React from 'react';

const AuthTabs: React.FC = () => {
  return (
    <div className="flex items-center justify-center gap-16 border-b border-[#ECECEC] mb-10">
      <button className="relative pb-4 group">
        <span className="text-lg font-black text-[#111827] group-hover:text-[#6C2BFF] transition-colors">Login</span>
        <div className="absolute bottom-0 left-0 right-0 h-1 bg-[#6C2BFF] rounded-t-full"></div>
      </button>
      <button className="relative pb-4 group">
        <span className="text-lg font-bold text-gray-400 group-hover:text-[#6C2BFF] transition-colors">Register</span>
        <div className="absolute bottom-0 left-0 right-0 h-1 bg-transparent group-hover:bg-[#6C2BFF]/30 rounded-t-full transition-all"></div>
      </button>
    </div>
  );
};

export default AuthTabs;
