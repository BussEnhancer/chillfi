import React from 'react';
import Header from '../../components/navigation/Header';
import TopBar from '../../components/navigation/TopBar';
import CategoryNav from '../../components/navigation/CategoryNav';
import Footer from '../../components/navigation/Footer';
import Container from '../../components/common/Container';
import Breadcrumb from '../../components/common/Breadcrumb';
import ContactInput from '../../components/forms/ContactInput';
import ContactSelect from '../../components/forms/ContactSelect';
import ContactTextarea from '../../components/forms/ContactTextarea';
import ContactCheckbox from '../../components/forms/ContactCheckbox';
import ContactInfoCard from '../../components/support/ContactInfoCard';
import OfficeInfoCard from '../../components/support/OfficeInfoCard';
import StaticMapCard from '../../components/support/StaticMapCard';
import HelpCenterBanner from '../../components/support/HelpCenterBanner';
import CheckoutTrustStrip from '../../sections/Checkout/CheckoutTrustStrip';

import { Send, Headphones, Phone, MessageSquare, Mail } from 'lucide-react';

const ContactUsPage: React.FC = () => {
  const breadcrumbItems = [
    { label: 'Contact Us' }
  ];

  const subjectOptions = [
    { label: 'General Inquiry', value: 'general' },
    { label: 'Order Related', value: 'order' },
    { label: 'Refund Request', value: 'refund' },
    { label: 'Technical Support', value: 'tech' },
    { label: 'Partnership', value: 'partnership' },
    { label: 'Other', value: 'other' },
  ];

  return (
    <div className="min-h-screen bg-white font-['Poppins']">
      <TopBar />
      <Header />
      <CategoryNav />
      <Breadcrumb items={breadcrumbItems} />

      <Container className="py-12 md:py-16">
        <div className="mb-12">
          <h1 className="text-4xl font-black text-[#111827] mb-2 uppercase tracking-tight">Contact Us</h1>
          <p className="text-sm font-bold text-gray-400 uppercase tracking-widest">We're here to help! Reach out to us anytime.</p>
        </div>

        <div className="flex flex-col lg:flex-row gap-12">
          {/* Left: Contact Form */}
          <div className="flex-[1.5]">
             <div className="bg-white rounded-[32px] border border-[#ECECEC] p-8 md:p-10 shadow-sm">
                <div className="flex items-center gap-4 mb-8">
                   <div className="w-12 h-12 bg-[#6C2BFF]/10 rounded-2xl flex items-center justify-center text-[#6C2BFF]">
                      <MessageSquare size={24} />
                   </div>
                   <div>
                      <h2 className="text-2xl font-black text-[#111827]">Send Us a Message</h2>
                      <p className="text-sm font-bold text-gray-400">Fill out the form and our support team will get back to you shortly.</p>
                   </div>
                </div>

                <div className="space-y-8">
                   <ContactInput
                     label="Full Name"
                     placeholder="Enter your full name"
                     required
                   />

                   <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                      <ContactInput
                        label="Email Address"
                        type="email"
                        placeholder="Enter your email address"
                        required
                      />
                      <ContactInput
                        label="Phone Number"
                        type="tel"
                        placeholder="Enter your phone number"
                      />
                   </div>

                   <ContactSelect
                     label="Subject"
                     options={subjectOptions}
                     required
                   />

                   <ContactTextarea
                     label="Message"
                     placeholder="Type your message here..."
                     required
                   />

                   <ContactCheckbox
                     label={
                       <span>
                         I agree to the <a href="#" className="text-[#6C2BFF] hover:underline">Privacy Policy</a> and <a href="#" className="text-[#6C2BFF] hover:underline">Terms & Conditions</a>
                       </span>
                     }
                   />

                   <button className="w-full bg-gradient-to-r from-[#6C2BFF] to-[#8B5CFF] text-white py-4 rounded-2xl font-black text-sm uppercase tracking-widest flex items-center justify-center gap-3 shadow-xl shadow-[#6C2BFF]/20 hover:scale-[1.02] active:scale-[0.98] transition-all">
                      <Send size={18} />
                      Send Message
                   </button>
                </div>
             </div>
          </div>

          {/* Right: Contact Info & Office */}
          <div className="flex-1 space-y-12">
             <div className="bg-[#F8F5FF] rounded-[32px] border border-[#ECECEC] p-8 md:p-10">
                <h3 className="text-sm font-black text-[#111827] uppercase tracking-wider mb-8 border-b border-[#ECECEC] pb-4">Get in Touch</h3>
                <div className="grid grid-cols-2 gap-6">
                   <ContactInfoCard
                     icon={<Headphones size={24} />}
                     title="24/7 Support"
                     desc="We're always here"
                     detail="support@chillfi.com"
                   />
                   <ContactInfoCard
                     icon={<Phone size={24} />}
                     title="Call Us"
                     desc="Mon – Sun | 9-9"
                     detail="+91 98765 43210"
                   />
                   <ContactInfoCard
                     icon={<MessageSquare size={24} />}
                     title="WhatsApp"
                     desc="Chat with us"
                     detail="+91 98765 43210"
                     color="#22C55E"
                   />
                   <ContactInfoCard
                     icon={<Mail size={24} />}
                     title="Email Us"
                     desc="Reply in 24h"
                     detail="support@chillfi.com"
                   />
                </div>
             </div>

             <div className="grid grid-cols-1 xl:grid-cols-2 gap-8 items-stretch">
                <OfficeInfoCard />
                <StaticMapCard />
             </div>
          </div>
        </div>

        {/* Bottom Help Center CTA */}
        <HelpCenterBanner />

        {/* Global Trust Section */}
        <CheckoutTrustStrip />
      </Container>

      <Footer />
    </div>
  );
};

export default ContactUsPage;
