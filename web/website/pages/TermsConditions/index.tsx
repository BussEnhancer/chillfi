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

import { FileText, Mail, Phone, MapPin, Scale } from 'lucide-react';

const TermsConditionsPage: React.FC = () => {
  const breadcrumbItems = [
    { label: 'Terms & Conditions' }
  ];

  return (
    <div className="min-h-screen bg-white font-['Poppins']">
      <TopBar />
      <Header />
      <CategoryNav />
      <Breadcrumb items={breadcrumbItems} />

      <Container className="py-10">
        <div className="flex flex-col lg:flex-row gap-10">
          {/* Left: Sidebar */}
          <AccountSidebar activeId="terms" />

          {/* Right: Content */}
          <div className="flex-1 min-w-0">
             <div className="mb-10">
                <h1 className="text-3xl font-black text-[#111827] mb-1">Terms & Conditions</h1>
                <p className="text-sm font-bold text-gray-400">Last Updated: 15 May 2025</p>
             </div>

             <PrivacyInfoBanner
               icon={<FileText size={32} />}
               title="Welcome to chillFi!"
               desc="These Terms & Conditions govern your use of our website, mobile application, and services. By accessing or using chillFi, you agree to be bound by these terms."
             />

             <div className="mt-10">
                <PrivacySection title="1. Acceptance of Terms">
                   <p>By accessing or using the chillFi website or app, you agree to comply with and be bound by these Terms & Conditions.</p>
                   <p>If you do not agree with any part of these terms, please do not use our services.</p>
                </PrivacySection>

                <PrivacySection title="2. Use of Our Services">
                   <p>You must be at least 18 years old to use chillFi.</p>
                   <p>You agree to provide accurate, current, and complete information during registration and to keep your account information updated.</p>
                </PrivacySection>

                <PrivacySection title="3. Products & Pricing">
                   <p>We strive to display accurate product information and pricing. However, errors may occur.</p>
                   <p>We reserve the right to correct any errors and cancel orders if the product is unavailable or incorrectly priced.</p>
                   <p>All prices are in INR and inclusive/exclusive of applicable taxes as mentioned.</p>
                </PrivacySection>

                <PrivacySection title="4. Orders & Payments">
                   <p>By placing an order, you are making an offer to purchase.</p>
                   <p>We reserve the right to accept or decline your order for any reason.</p>
                   <p>Payments must be made in full at the time of placing an order using available payment methods.</p>
                </PrivacySection>

                <PrivacySection title="5. Shipping & Delivery">
                   <p>We deliver to addresses within India.</p>
                   <p>Delivery timelines are estimates and may vary based on location and product availability.</p>
                   <p>Risk of loss and title for items purchased pass to you upon delivery.</p>
                </PrivacySection>

                <PrivacySection title="6. Returns & Refunds">
                   <p>Our Returns & Refunds Policy is available on our website.</p>
                   <p>Please review it to understand your rights and obligations.</p>
                </PrivacySection>

                <PrivacySection title="7. User Conduct">
                   <p>You agree not to use our services for any unlawful purpose.</p>
                   <p>You must not attempt to gain unauthorized access, interfere with security, or disrupt platform functionality.</p>
                </PrivacySection>

                <PrivacySection title="8. Intellectual Property">
                   <p>All content on chillFi, including text, graphics, logos, images, and software, is the property of chillFi and protected by intellectual property laws.</p>
                   <p>You may not use any content without prior written consent.</p>
                </PrivacySection>

                <PrivacySection title="9. Limitation of Liability">
                   <p>chillFi shall not be liable for indirect, incidental, or consequential damages arising out of the use or inability to use services or products.</p>
                </PrivacySection>

                <PrivacySection title="10. Changes to Terms">
                   <p>We may update these Terms & Conditions from time to time.</p>
                   <p>Changes will be posted on this page with an updated Last Updated date.</p>
                </PrivacySection>

                <PrivacySection title="11. Contact Us">
                   <p>If you have any questions about these Terms & Conditions, please reach out to us:</p>
                   <div className="flex flex-wrap gap-4 mt-6">
                      <PrivacyContactCard
                        icon={<Mail size={20} />}
                        label="Email Us"
                        detail="support@chillfi.com"
                      />
                      <PrivacyContactCard
                        icon={<Phone size={20} />}
                        label="Call Us"
                        detail="+91 98765 43210"
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
                  icon={<Scale size={32} />}
                  title="By using chillFi, you agree to these Terms & Conditions."
                  desc="Please read them carefully to understand your rights and responsibilities."
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

export default TermsConditionsPage;
