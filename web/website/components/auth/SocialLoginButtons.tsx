import React from 'react';
import { Apple } from 'lucide-react';

const SocialLoginButtons: React.FC = () => {
  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-8">
      <button className="flex items-center justify-center gap-3 py-3 px-4 border-2 border-[#ECECEC] rounded-xl hover:bg-gray-50 hover:border-gray-300 transition-all group">
        <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png" alt="Google" className="w-5 h-5 group-hover:scale-110 transition-transform" />
        <span className="text-sm font-black text-[#111827]">Google</span>
      </button>

      <button className="flex items-center justify-center gap-3 py-3 px-4 border-2 border-[#ECECEC] rounded-xl hover:bg-gray-50 hover:border-gray-300 transition-all group">
        <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/Facebook_Logo_%282019%29.png/1024px-Facebook_Logo_%282019%29.png" alt="Facebook" className="w-5 h-5 group-hover:scale-110 transition-transform" />
        <span className="text-sm font-black text-[#111827]">Facebook</span>
      </button>

      <button className="flex items-center justify-center gap-3 py-3 px-4 border-2 border-[#ECECEC] rounded-xl hover:bg-gray-50 hover:border-gray-300 transition-all group">
        <Apple size={20} className="group-hover:scale-110 transition-transform" />
        <span className="text-sm font-black text-[#111827]">Apple</span>
      </button>
    </div>
  );
};

export default SocialLoginButtons;
