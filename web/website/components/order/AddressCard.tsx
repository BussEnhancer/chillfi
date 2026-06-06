import React from 'react';

interface AddressCardProps {
  type: 'Home' | 'Work' | 'Other';
  name: string;
  address: string;
  phone: string;
  isSelected?: boolean;
  isDefault?: boolean;
}

const AddressCard: React.FC<AddressCardProps> = ({ type, name, address, phone, isSelected, isDefault }) => {
  return (
    <div
      className={`relative p-6 rounded-[24px] border-2 transition-all cursor-pointer group ${
        isSelected ? 'border-[#6C2BFF] bg-[#6C2BFF]/5 shadow-xl' : 'border-[#ECECEC] bg-white hover:border-gray-300'
      }`}
    >
      <div className="flex items-start justify-between mb-4">
        <div className={`w-5 h-5 rounded-full border-2 flex items-center justify-center ${
          isSelected ? 'border-[#6C2BFF]' : 'border-gray-200'
        }`}>
          {isSelected && <div className="w-2.5 h-2.5 rounded-full bg-[#6C2BFF]"></div>}
        </div>
        <div className="flex items-center gap-2">
           <span className={`text-[10px] font-black uppercase tracking-widest px-3 py-1 rounded-full ${
             isSelected ? 'bg-[#6C2BFF] text-white' : 'bg-gray-100 text-gray-500'
           }`}>{type}</span>
           {isDefault && <span className="text-[10px] font-black uppercase tracking-widest px-3 py-1 rounded-full bg-[#6C2BFF]/10 text-[#6C2BFF]">Default</span>}
        </div>
      </div>

      <div className="mb-6">
        <h4 className="text-sm font-black text-[#111827] mb-3">{name}</h4>
        <p className="text-xs font-bold text-gray-500 leading-relaxed mb-3 pr-4">
          {address}
        </p>
        <p className="text-xs font-black text-[#111827]">
          <span className="text-gray-400 font-bold mr-2">Phone:</span>
          {phone}
        </p>
      </div>

      <div className="flex items-center gap-6 pt-4 border-t border-[#ECECEC]">
         <button className="text-[10px] font-black text-[#6C2BFF] uppercase tracking-widest hover:underline">Edit</button>
         <button className="text-[10px] font-black text-[#FF4D4F] uppercase tracking-widest hover:underline">Remove</button>
      </div>
    </div>
  );
};

export default AddressCard;
