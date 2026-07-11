import React from 'react';
import { ChevronDown } from 'lucide-react';

interface ContactSelectProps extends React.SelectHTMLAttributes<HTMLSelectElement> {
  label: string;
  required?: boolean;
  options: { label: string; value: string }[];
}

const ContactSelect: React.FC<ContactSelectProps> = ({ label, required, options, ...props }) => {
  return (
    <div className="flex flex-col gap-2 w-full relative">
      <label className="text-[13px] font-black text-[#111827] uppercase tracking-wider">
        {label} {required && <span className="text-[#FF4D4F]">*</span>}
      </label>
      <div className="relative">
        <select
          {...props}
          className="w-full bg-white border border-[#ECECEC] rounded-xl px-5 py-3 text-sm font-bold text-[#111827] outline-none focus:border-[#FF6B2C] transition-all appearance-none cursor-pointer shadow-sm"
        >
          <option value="" disabled>Select a {label.toLowerCase()}</option>
          {options.map((opt) => (
            <option key={opt.value} value={opt.value}>
              {opt.label}
            </option>
          ))}
        </select>
        <ChevronDown size={18} className="absolute right-5 top-1/2 -translate-y-1/2 text-gray-400 pointer-events-none" />
      </div>
    </div>
  );
};

export default ContactSelect;
