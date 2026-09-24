import React, { useState } from 'react';
import SupportContactCard from '../../components/support/SupportContactCard';
import { Phone, MessageCircle, Mail, ChevronRight, HelpCircle } from 'lucide-react';

// TODO(owner): confirm real support phone (website shows +91 98765 43210, the app uses +91 90562 24993)
const SUPPORT_PHONE = '+91 98765 43210';
const SUPPORT_PHONE_DIGITS = SUPPORT_PHONE.replace(/\D/g, '');
const SUPPORT_EMAIL = 'support@chillfi.com';

const quickFaqs = [
  { q: 'How do I track my order?', a: 'Go to My Account → My Orders and open your order to see live Delhivery tracking once it has been shipped.' },
  { q: 'How can I return a product?', a: 'You can request a return within 7 days of delivery from the order page in My Orders.' },
  { q: 'How long does a refund take?', a: 'Refunds are usually credited within 5–7 business days after the return or cancellation is approved.' },
  { q: 'Which payment methods do you accept?', a: 'UPI, cards and netbanking via PhonePe, plus Pay on Delivery on eligible pincodes.' },
  { q: 'How do I cancel my order?', a: 'Orders can be cancelled from the order page until the courier picks them up. Paid orders are refunded automatically.' },
];

const SupportContactSection: React.FC = () => {
  const [openFaq, setOpenFaq] = useState<number | null>(null);

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
                icon={<Phone size={24} />}
                title="Call Us"
                desc="Mon – Sun | 9 AM – 9 PM"
                detail={SUPPORT_PHONE}
                buttonText="Call Now"
                href={`tel:+${SUPPORT_PHONE_DIGITS}`}
              />
              <SupportContactCard
                icon={<MessageCircle size={24} />}
                title="WhatsApp Us"
                desc="Chat on WhatsApp for quick help"
                buttonText="Chat on WhatsApp"
                href={`https://wa.me/${SUPPORT_PHONE_DIGITS}`}
                color="#22C55E"
              />
              <SupportContactCard
                icon={<Mail size={24} />}
                title="Email Us"
                desc="Response within 24 hours"
                detail={SUPPORT_EMAIL}
                buttonText="Email Us"
                href={`mailto:${SUPPORT_EMAIL}`}
              />
           </div>
        </div>

        {/* Right: Quick Links / Before Contact Us */}
        <div className="flex-1 shrink-0">
           <div className="bg-[#FFF8F5] rounded-[32px] border border-[#ECECEC] p-8 h-full shadow-sm relative overflow-hidden group">
              <div className="relative z-10">
                 <h3 className="text-sm font-black text-[#111827] uppercase tracking-wider mb-8">Before You Contact Us</h3>
                 <div className="space-y-4">
                    {quickFaqs.map(({ q, a }, i) => (
                      <div key={i}>
                        <button
                          type="button"
                          onClick={() => setOpenFaq(openFaq === i ? null : i)}
                          aria-expanded={openFaq === i}
                          className="w-full flex items-center justify-between text-left group/link"
                        >
                           <span className={`text-xs font-bold transition-colors ${openFaq === i ? 'text-[#111827]' : 'text-gray-500 group-hover/link:text-[#111827]'}`}>{q}</span>
                           <ChevronRight size={14} className={`shrink-0 transition-all ${openFaq === i ? 'rotate-90 text-[#FF6B2C]' : 'text-gray-300 group-hover/link:text-[#FF6B2C] group-hover/link:translate-x-1'}`} />
                        </button>
                        {openFaq === i && (
                          <p className="mt-2 text-[11px] font-bold text-gray-400 leading-relaxed">{a}</p>
                        )}
                      </div>
                    ))}
                 </div>
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
