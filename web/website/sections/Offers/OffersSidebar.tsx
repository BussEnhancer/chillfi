import React from 'react';
import { ChevronRight, Clock, Zap, Percent } from 'lucide-react';
import BankOfferItem from '../../components/offers/BankOfferItem';

const bankOffers = [
  { bankName: 'HDFC Bank', bankLogo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/72/HDFC_Bank_Logo.svg/2560px-HDFC_Bank_Logo.svg.png', offer: 'Up to ₹1,500 Instant Discount', condition: 'On HDFC Credit Cards & EMI' },
  { bankName: 'ICICI Bank', bankLogo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/12/ICICI_Bank_Logo.svg/2560px-ICICI_Bank_Logo.svg.png', offer: 'Up to ₹1,250 Instant Discount', condition: 'On ICICI Credit Cards & EMI' },
  { bankName: 'SBI Card', bankLogo: 'https://upload.wikimedia.org/wikipedia/en/thumb/5/58/State_Bank_of_India_logo.svg/1200px-State_Bank_of_India_logo.svg.png', offer: 'Up to ₹1,000 Instant Discount', condition: 'On SBI Credit Cards' },
  { bankName: 'Kotak Bank', bankLogo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c0/Kotak_Mahindra_Bank_logo.svg/2560px-Kotak_Mahindra_Bank_logo.svg.png', offer: 'Up to ₹1,000 Instant Discount', condition: 'On Kotak Credit Cards' },
];

const topDeals = [
  { icon: <Clock size={16} />, title: 'Deal of the Day', desc: 'Ends in 08h : 32m : 15s', color: 'text-red-500' },
  { icon: <Percent size={16} />, title: 'Clearance Sale', desc: 'Up to 70% Off', color: 'text-[#6C2BFF]' },
  { icon: <Zap size={16} />, title: 'Flash Sale', desc: 'Limited time offers', color: 'text-amber-500' },
];

const OffersSidebar: React.FC = () => {
  return (
    <div className="space-y-8 sticky top-32">
      {/* Bank Offers */}
      <div className="bg-white rounded-[24px] border border-[#ECECEC] p-6 shadow-sm">
        <div className="flex items-center justify-between mb-6 pb-4 border-b border-[#F8F5FF]">
           <h3 className="text-sm font-black text-[#111827] uppercase tracking-wider">Bank Offers</h3>
           <button className="text-[10px] font-black text-[#6C2BFF] uppercase tracking-widest hover:underline">View All</button>
        </div>
        <div className="space-y-2">
          {bankOffers.map((item, i) => (
            <BankOfferItem key={i} {...item} />
          ))}
        </div>
      </div>

      {/* Top Deals */}
      <div className="bg-white rounded-[24px] border border-[#ECECEC] p-6 shadow-sm">
        <h3 className="text-sm font-black text-[#111827] uppercase tracking-wider mb-6 pb-4 border-b border-[#F8F5FF]">Top Deals</h3>
        <div className="space-y-4">
          {topDeals.map((deal, i) => (
            <div key={i} className="flex items-center gap-4 group cursor-pointer">
               <div className={`w-9 h-9 rounded-xl bg-gray-50 flex items-center justify-center ${deal.color} group-hover:bg-white group-hover:shadow-md transition-all`}>
                  {deal.icon}
               </div>
               <div className="flex-1">
                  <h4 className="text-[12px] font-black text-[#111827]">{deal.title}</h4>
                  <p className="text-[10px] font-bold text-gray-400 uppercase tracking-widest">{deal.desc}</p>
               </div>
               <ChevronRight size={14} className="text-gray-300 group-hover:text-[#6C2BFF] transition-all" />
            </div>
          ))}
        </div>
      </div>

      {/* Premium Promo */}
      <div className="bg-gradient-to-br from-[#6C2BFF] to-[#8B5CFF] rounded-[24px] p-6 text-white relative overflow-hidden group">
         <div className="relative z-10">
            <h3 className="text-sm font-black uppercase tracking-wider mb-2">Exclusive for You!</h3>
            <p className="text-[11px] font-bold opacity-80 mb-6">Unlock extra savings with <br /> chillFi Premium</p>
            <button className="w-full bg-white text-[#6C2BFF] py-2.5 rounded-xl font-black text-xs uppercase tracking-widest hover:shadow-lg transition-all">
               Explore Benefits
            </button>
         </div>
         {/* Decor */}
         <div className="absolute -bottom-4 -right-4 w-20 h-20 bg-white/10 rounded-full blur-xl group-hover:scale-150 transition-all"></div>
      </div>
    </div>
  );
};

export default OffersSidebar;
