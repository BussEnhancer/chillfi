import React from 'react';
import { Mail, Clock } from 'lucide-react';
import { useStoreContact } from '../../utils/useStoreContact';

const OfficeInfoCard: React.FC = () => {
  const contact = useStoreContact();
  return (
    <div className="bg-white border border-[#ECECEC] rounded-[24px] p-8 shadow-sm h-full">
      <h3 className="text-sm font-black text-[#111827] uppercase tracking-wider mb-8">Support Hours</h3>

      {/* TODO(owner): add a registered office address here once confirmed. */}
      <div className="space-y-8">
        <div className="flex gap-4">
          <Mail size={24} className="text-[#FF6B2C] shrink-0 mt-1" />
          <div>
            <h4 className="text-sm font-black text-[#111827] mb-2 uppercase tracking-wider">Email</h4>
            {contact.email
              ? <a href={`mailto:${contact.email}`} className="text-xs font-bold text-gray-500 hover:text-[#FF6B2C]">{contact.email}</a>
              : <p className="text-xs font-bold text-gray-500">Use the contact form</p>}
          </div>
        </div>

        <div className="flex gap-4">
          <Clock size={24} className="text-[#FF6B2C] shrink-0 mt-1" />
          <div>
            <h4 className="text-sm font-black text-[#111827] mb-2 uppercase tracking-wider">Business Hours</h4>
            <p className="text-xs font-bold text-gray-500">
              Mon – Sun: 9:00 AM – 9:00 PM
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default OfficeInfoCard;
