import React from 'react';

interface ContactTextareaProps extends React.TextareaHTMLAttributes<HTMLTextAreaElement> {
  label: string;
  required?: boolean;
}

const ContactTextarea: React.FC<ContactTextareaProps> = ({ label, required, ...props }) => {
  return (
    <div className="flex flex-col gap-2 w-full">
      <label className="text-[13px] font-black text-[#111827] uppercase tracking-wider">
        {label} {required && <span className="text-[#FF4D4F]">*</span>}
      </label>
      <textarea
        {...props}
        className="bg-white border border-[#ECECEC] rounded-xl px-5 py-3 text-sm font-bold text-[#111827] outline-none focus:border-[#FF6B2C] transition-all placeholder:text-gray-300 shadow-sm min-h-[120px] resize-none"
      />
    </div>
  );
};

export default ContactTextarea;
