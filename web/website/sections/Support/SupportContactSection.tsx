import React from 'react';
import SupportContactCard from '../../components/support/SupportContactCard';
import { MessageSquare, Phone, MessageCircle, Mail, ChevronRight, HelpCircle } from 'lucide-react';

const SupportContactSection: React.FC = () => {
  return (
    <section className="py-12">
      <div className="flex flex-col lg:flex-row gap-10">

        {/* Left: Get in Touch Cards */}
        <div className="flex-[2]">
           <div className="mb-8">
              <h2 className="text-2xl font-black text-[#111827] mb-1">Get in Touch</h2>
              <p className="text-sm font-bold text-gray-400">Choose the best way to reach us</p>
           </div>
           <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <SupportContactCard
                icon={<MessageSquare size={24} />}
                title="Live Support (9 AM – 9 PM)"
                desc="Chat with our support team anytime"
                buttonText="Chat Now"
              />
              <SupportContactCard
                icon={<Phone size={24} />}
                title="Call Us"
                desc="Mon – Sun | 9 AM – 9 PM"
                detail="+91 98765 43210"
                buttonText="Call Now"
              />
              <SupportContactCard
                icon={<MessageCircle size={24} />}
                title="WhatsApp Us"
                desc="Chat on WhatsApp for quick help"
                buttonText="Chat on WhatsApp"
                color="#22C55E"
              />
              <SupportContactCard
                icon={<Mail size={24} />}
                title="Email Us"
                desc="Response within 24 hours"
                detail="support@chillfi.com"
                buttonText="Email Us"
              />
           </div>
        </div>

        {/* Right: Quick Links / Before Contact Us */}
        <div className="flex-1 shrink-0">
           <div className="bg-[#FFF8F5] rounded-[32px] border border-[#ECECEC] p-8 h-full shadow-sm relative overflow-hidden group">
              <div className="relative z-10">
                 <h3 className="text-sm font-black text-[#111827] uppercase tracking-wider mb-8">Before You Contact Us</h3>
                 <div className="space-y-4">
                    {[
                      'How do I track my order?',
                      'How can I return a product?',
                      'How long does delivery take?',
                      'Which payment methods do you accept?',
                      'How do I cancel my order?',
                    ].map((q, i) => (
                      <button key={i} className="w-full flex items-center justify-between text-left group/link">
                         <span className="text-xs font-bold text-gray-500 group-hover/link:text-[#111827] transition-colors">{q}</span>
                         <ChevronRight size={14} className="text-gray-300 group-hover/link:text-[#FF6B2C] transition-all group-hover/link:translate-x-1" />
                      </button>
                    ))}
                 </div>
                 <button className="mt-10 flex items-center gap-2 text-[11px] font-black text-[#FF6B2C] uppercase tracking-widest hover:underline">
                    View All FAQs
                    <ChevronRight size={14} />
                 </button>
              </div>
              <div className="absolute -bottom-4 -right-4 opacity-[0.05] group-hover:scale-110 transition-transform duration-700">
                 <HelpCircle size={150} />
              </div>
           </div>
        </div>

      </div>
    </section>
  );
};

export default SupportContactSection;
