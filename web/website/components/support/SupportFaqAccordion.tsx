import React, { useState } from 'react';
import { ChevronDown, ChevronUp } from 'lucide-react';

interface FaqItem {
  question: string;
  answer: string;
}

const faqs: FaqItem[] = [
  { question: 'How can I track my order?', answer: 'Go to My Account → My Orders and open your order. Once it is shipped, you will see live Delhivery tracking there.' },
  { question: 'What is your return policy?', answer: 'You can request a return within 7 days of delivery from the order page in My Orders. See our Return Policy for eligibility details.' },
  { question: 'How long do refunds take?', answer: 'Refunds are usually credited within 5–7 business days after the return or cancellation is approved.' },
  { question: 'How can I cancel my order?', answer: 'You can cancel from the order page in My Orders until the courier picks up the package. Paid orders are refunded automatically.' },
  { question: 'Which payment methods do you accept?', answer: 'We accept UPI, credit/debit cards and netbanking via PhonePe, and Pay on Delivery on eligible pincodes.' },
];

const SupportFaqAccordion: React.FC = () => {
  const [openIndex, setOpenIndex] = useState<number | null>(null);

  const toggle = (index: number) => {
    setOpenIndex(openIndex === index ? null : index);
  };

  return (
    <div className="space-y-4">
      {faqs.map((faq, i) => (
        <div key={i} className="bg-white border border-[#ECECEC] rounded-2xl overflow-hidden shadow-sm hover:border-[#FF6B2C]/30 transition-all">
          <button
            onClick={() => toggle(i)}
            className="w-full flex items-center justify-between p-6 text-left"
          >
            <span className="text-sm font-black text-[#111827]">{faq.question}</span>
            <div className={`w-8 h-8 rounded-lg flex items-center justify-center transition-all ${
              openIndex === i ? 'bg-[#FF6B2C] text-white' : 'bg-gray-50 text-gray-400'
            }`}>
              {openIndex === i ? <ChevronUp size={16} /> : <ChevronDown size={16} />}
            </div>
          </button>
          <div
            className={`transition-all duration-300 ease-in-out overflow-hidden ${
              openIndex === i ? 'max-h-[200px] opacity-100' : 'max-h-0 opacity-0'
            }`}
          >
            <div className="px-6 pb-6 text-xs font-bold text-gray-500 leading-relaxed">
               {faq.answer}
            </div>
          </div>
        </div>
      ))}
    </div>
  );
};

export default SupportFaqAccordion;
