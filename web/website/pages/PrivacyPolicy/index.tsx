import React from 'react';
import Header from '../../components/navigation/Header';
import TopBar from '../../components/navigation/TopBar';
import CategoryNav from '../../components/navigation/CategoryNav';
import Footer from '../../components/navigation/Footer';
import Container from '../../components/common/Container';
import Breadcrumb from '../../components/common/Breadcrumb';
import AccountSidebar from '../../components/profile/AccountSidebar';
import CheckoutTrustStrip from '../../sections/Checkout/CheckoutTrustStrip';
import PrivacyInfoBanner from '../../components/legal/PrivacyInfoBanner';
import PrivacySection from '../../components/legal/PrivacySection';
import PrivacyContactCard from '../../components/legal/PrivacyContactCard';

import { ShieldCheck, Mail, Phone, MapPin, Lock } from 'lucide-react';
import { useStoreContact } from '../../utils/useStoreContact';

const PrivacyPolicyPage: React.FC = () => {
  const contact = useStoreContact();
  const breadcrumbItems = [
    { label: 'Privacy Policy' }
  ];

  return (
    <div className="min-h-screen bg-white font-['Poppins']">
      <TopBar />
      <Header />
      <CategoryNav />
      <Breadcrumb items={breadcrumbItems} />

      <Container className="py-10 animate-page-in">
        <div className="flex flex-col lg:flex-row gap-10">
          {/* Left: Sidebar */}
          <AccountSidebar activeId="privacy" />

          {/* Right: Content */}
          <div className="flex-1 min-w-0">
             <div className="mb-10">
                <h1 className="text-3xl font-black text-[#111827] mb-1">Privacy Policy</h1>
                <p className="text-sm font-bold text-gray-400">Last Updated: 15 May 2025</p>
             </div>

             <PrivacyInfoBanner
               icon={<ShieldCheck size={32} />}
               title="At chillFi, your privacy is important to us."
               desc="This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you visit our website or use our services."
             />

             <div className="mt-10">
                <PrivacySection title="1. Information We Collect">
                   <p>We collect information that you provide directly to us, such as when you create an account, place an order, subscribe to our newsletter, or contact customer support.</p>
                   <p>This may include your name, email address, phone number, shipping address, payment information, and order history.</p>
                </PrivacySection>

                <PrivacySection title="2. How We Use Your Information">
                   <p>We use the information we collect to:</p>
                   <ul className="list-disc pl-5 space-y-2">
                      <li>Process and deliver your orders</li>
                      <li>Manage your account and preferences</li>
                      <li>Provide customer support</li>
                      <li>Send you updates, offers, and promotional communications (with your consent)</li>
                      <li>Improve our website, products, and services</li>
                      <li>Detect and prevent fraud or other illegal activities</li>
                   </ul>
                </PrivacySection>

                <PrivacySection title="3. Sharing Your Information">
                   <p>We do not sell, trade, or rent your personal information to third parties.</p>
                   <p>We may share your information only in the following cases:</p>
                   <ul className="list-disc pl-5 space-y-2">
                      <li>With trusted service providers</li>
                      <li>To comply with legal obligations</li>
                      <li>To protect our rights and customers</li>
                   </ul>
                </PrivacySection>

                <PrivacySection title="4. Cookies and Tracking Technologies">
                   <p>We use cookies and similar technologies to improve browsing experience, analyze site traffic, and personalize content.</p>
                   <p>Users can manage cookies through browser settings.</p>
                </PrivacySection>

                <PrivacySection title="5. Data Security">
                   <p>We implement appropriate technical and organizational measures to protect your personal information from unauthorized access, disclosure, alteration, or destruction.</p>
                </PrivacySection>

                <PrivacySection title="6. Your Rights">
                   <p>Users have the right to:</p>
                   <ul className="list-disc pl-5 space-y-2">
                      <li>Access information</li>
                      <li>Update information</li>
                      <li>Delete information</li>
                      <li>Opt out of promotional communication</li>
                   </ul>
                </PrivacySection>

                <PrivacySection title="7. Changes to This Policy">
                   <p>We may update this Privacy Policy from time to time.</p>
                   <p>Users will be notified by updating the Last Updated date on this page.</p>
                </PrivacySection>

                <PrivacySection title="8. Contact Us">
                   <p>If you have any questions or concerns about this Privacy Policy, please contact us:</p>
                   <div className="flex flex-wrap gap-4 mt-6">
                      <PrivacyContactCard
                        icon={<Mail size={20} />}
                        label="Email Us"
                        detail={contact.email || 'Use the contact form'}
                      />
                      <PrivacyContactCard
                        icon={<Phone size={20} />}
                        label="Call Us"
                        detail={contact.phone || '—'}
                      />
                      <PrivacyContactCard
                        icon={<MapPin size={20} />}
                        label="Our Office"
                        detail={
                          <span>
                            123, Green Park Society, <br />
                            Indiranagar, Bengaluru, <br />
                            Karnataka - 560038, India
                          </span>
                        }
                      />
                   </div>
                </PrivacySection>
             </div>

             <div className="mt-12">
                <PrivacyInfoBanner
                  icon={<Lock size={32} />}
                  title="Your trust matters to us."
                  desc="We are committed to protecting your privacy and ensuring a safe shopping experience."
                />
             </div>
          </div>
        </div>

        {/* Global Trust Strip */}
        <CheckoutTrustStrip />
      </Container>

      <Footer />
    </div>
  );
};

export default PrivacyPolicyPage;
