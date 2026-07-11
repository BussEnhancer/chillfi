import React from 'react';
import { Smartphone, Mail, Lock, KeyRound } from 'lucide-react';

const methods = [
  { id: 'mobile', label: 'Mobile', icon: <Smartphone size={18} />, active: true },
  { id: 'email', label: 'Email', icon: <Mail size={18} /> },
  { id: 'password', label: 'Password', icon: <Lock size={18} /> },
  { id: 'otp', label: 'OTP', icon: <KeyRound size={18} /> },
];

const AuthMethodTabs: React.FC = () => {
  return (
    <div className="grid grid-cols-2 md:grid-cols-4 gap-3 mb-10">
      {methods.map((m) => (
        <button
          key={m.id}
          className={`flex items-center justify-center gap-2 p-3 rounded-xl border-2 transition-all ${
            m.active ? 'border-[#FF6B2C] bg-[#FF6B2C]/5 text-[#FF6B2C]' : 'border-[#ECECEC] bg-white text-gray-500 hover:border-gray-300'
          }`}
        >
          {m.icon}
          <span className="text-xs font-black">{m.label}</span>
        </button>
      ))}
    </div>
  );
};

export default AuthMethodTabs;
