import React, { useState } from 'react';
import { ChevronDown, ChevronUp } from 'lucide-react';

interface FaqItem {
  question: string;
  answer: string;
}

const faqs: FaqItem[] = [
  { question: 'How can I track my order?', answer: 'You can track your order using the Order ID provided in your confirmation email or by visiting the "Track Order" section in your account dashboard.' },
  { question: 'What is your return policy?', answer: 'We offer a 7-day easy return policy for most products. The items must be unused and in their original packaging.' },
  { question: 'How long does delivery take?', answer: 'Standard delivery usually takes 3-5 business days. Express delivery (available in selected cities) takes 1-2 business days.' },
  { question: 'How can I cancel or modify my order?', answer: 'You can cancel your order from the "My Orders" section before it has been shipped. Modifying an order is not possible once placed.' },
  { question: 'Which payment methods do you accept?', answer: 'We accept all major Credit/Debit cards, Net Banking, UPI (PhonePe, Google Pay), Wallets, and Cash on Delivery.' },
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
