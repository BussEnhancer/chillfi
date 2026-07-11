import React from 'react';
import { Send, MessageSquare } from 'lucide-react';

const SupportHelpCard: React.FC = () => {
  return (
    <div className="bg-[#FFF8F5] rounded-[32px] border border-[#ECECEC] p-8 md:p-10 shadow-sm relative overflow-hidden group">
      <div className="relative z-10 flex flex-col md:flex-row items-center justify-between gap-10">
        <div className="flex-1 text-center md:text-left">
           <h2 className="text-2xl font-black text-[#111827] mb-2 uppercase tracking-tight">Still Need Help?</h2>
           <p className="text-sm font-bold text-gray-400 mb-8 leading-relaxed max-w-[400px] mx-auto md:mx-0">
             Our support team is here for you 24/7. Reach out and we'll get back to you as soon as possible.
           </p>
           <button className="bg-[#FF6B2C] text-white px-10 py-3.5 rounded-2xl font-black text-sm uppercase tracking-widest flex items-center justify-center gap-3 shadow-xl shadow-[#FF6B2C]/20 hover:scale-[1.02] active:scale-[0.98] transition-all mx-auto md:mx-0">
              Contact Support
              <Send size={18} />
           </button>
        </div>

        <div className="relative w-[200px] h-[150px] flex items-center justify-center pointer-events-none">
           <div className="absolute w-24 h-24 bg-white rounded-3xl flex items-center justify-center text-[#FF6B2C] shadow-2xl rotate-12 group-hover:rotate-0 transition-transform duration-700">
              <MessageSquare size={48} />
           </div>
           {/* Envelopes/Decoratives */}
           <div className="absolute -top-4 -right-2 w-12 h-12 bg-[#FF6B2C] rounded-2xl rotate-[-20deg] opacity-20"></div>
           <div className="absolute bottom-0 left-0 w-8 h-8 bg-amber-400 rounded-xl rotate-45 opacity-20 animate-pulse"></div>
        </div>
      </div>

      {/* Background Decor */}
      <div className="absolute top-1/2 left-1/4 -translate-y-1/2 opacity-[0.03] pointer-events-none group-hover:scale-110 transition-transform duration-1000">
         <MessageSquare size={300} />
      </div>
    </div>
  );
};

export default SupportHelpCard;
