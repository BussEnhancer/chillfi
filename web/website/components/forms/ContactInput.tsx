import React from 'react';

interface ContactInputProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label: string;
  required?: boolean;
}

const ContactInput: React.FC<ContactInputProps> = ({ label, required, ...props }) => {
  return (
    <div className="flex flex-col gap-2 w-full">
      <label className="text-[13px] font-black text-[#111827] uppercase tracking-wider">
        {label} {required && <span className="text-[#FF4D4F]">*</span>}
      </label>
      <input
        {...props}
        className="bg-white border border-[#ECECEC] rounded-xl px-5 py-3 text-sm font-bold text-[#111827] outline-none focus:border-[#6C2BFF] transition-all placeholder:text-gray-300 shadow-sm"
      />
    </div>
  );
};

export default ContactInput;
