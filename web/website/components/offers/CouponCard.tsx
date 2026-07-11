import React from 'react';
import { Copy } from 'lucide-react';
import Badge from '../common/Badge';

interface CouponCardProps {
  code: string;
  tag: string;
  offer: string;
  condition: string;
  validity: string;
}

const CouponCard: React.FC<CouponCardProps> = ({ code, tag, offer, condition, validity }) => {
  return (
    <div className="bg-white rounded-[20px] p-6 border border-[#ECECEC] hover:shadow-xl hover:border-[#FF6B2C]/10 transition-all group mb-4 flex flex-col md:flex-row items-center gap-6">
      {/* Code Section */}
      <div className="w-full md:w-32 h-20 bg-[#FFF8F5] rounded-2xl border-2 border-dashed border-[#FF6B2C]/20 flex flex-col items-center justify-center shrink-0">
        <span className="text-sm font-black text-[#FF6B2C] tracking-widest uppercase">{code}</span>
        <span className="text-[10px] font-bold text-[#FF6B2C]/60 uppercase tracking-tighter mt-1">Copy Code</span>
      </div>

      {/* Info Section */}
      <div className="flex-1 text-center md:text-left">
        <div className="mb-2">
          <Badge text={tag} className="bg-[#FF6B2C]/10 text-[#FF6B2C] text-[10px] font-black" />
        </div>
        <h4 className="text-lg font-black text-[#111827] mb-1">{offer}</h4>
        <p className="text-xs font-bold text-gray-400">{condition}</p>
      </div>

      {/* Validity Section */}
      <div className="text-center md:text-right shrink-0">
        <p className="text-[10px] font-bold text-gray-400 uppercase tracking-widest mb-1">Valid till {validity}</p>
        <button className="text-[10px] font-black text-[#FF6B2C] uppercase tracking-widest hover:underline">T&C Apply</button>
      </div>

      {/* Action Section */}
      <div className="shrink-0 w-full md:w-auto">
        <button className="w-full md:w-auto bg-white border-2 border-[#FF6B2C] text-[#FF6B2C] px-6 py-2.5 rounded-xl font-black text-xs uppercase tracking-widest flex items-center justify-center gap-2 hover:bg-[#FF6B2C] hover:text-white transition-all shadow-sm">
          <Copy size={14} />
          Copy Code
        </button>
      </div>
    </div>
  );
};

export default CouponCard;
