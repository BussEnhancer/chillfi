import React from 'react';

interface ContactCheckboxProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label: React.ReactNode;
}

const ContactCheckbox: React.FC<ContactCheckboxProps> = ({ label, ...props }) => {
  return (
    <label className="flex items-center gap-3 cursor-pointer group">
      <input
        {...props}
        type="checkbox"
        className="w-5 h-5 rounded border-[#ECECEC] text-[#FF6B2C] focus:ring-[#FF6B2C] transition-all"
      />
      <span className="text-xs font-bold text-gray-500 group-hover:text-[#111827] transition-all leading-tight">
        {label}
      </span>
    </label>
  );
};

export default ContactCheckbox;
