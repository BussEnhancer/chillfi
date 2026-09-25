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

import { RotateCcw, Mail, Phone, MapPin, PackageOpen } from 'lucide-react';
import { useStoreContact } from '../../utils/useStoreContact';

const ReturnPolicyPage: React.FC = () => {
  const contact = useStoreContact();
  const breadcrumbItems = [
    { label: 'Return Policy' }
  ];

  return (
    <div className="min-h-screen bg-white font-['Poppins']">
      <TopBar />
      <Header />
      <CategoryNav />
      <Breadcrumb items={breadcrumbItems} />

      <Container className="py-10">
        <div className="flex flex-col lg:flex-row gap-10">
          <AccountSidebar activeId="return" />

          <div className="flex-1 min-w-0">
            <div className="mb-10">
              <h1 className="text-3xl font-black text-[#111827] mb-1">Return Policy</h1>
              <p className="text-sm font-bold text-gray-400">Last Updated: 15 May 2025</p>
            </div>

            <PrivacyInfoBanner
              icon={<RotateCcw size={32} />}
              title="7 days, no-hassle returns."
              desc="This Return Policy explains which items are eligible for return, the return window, and how to start one."
            />

            <div className="mt-10">
              <PrivacySection title="1. Return Window">
                <p>Most products purchased on ChillFi can be returned within <strong>7 days of delivery</strong>. The exact return window for your order is also shown on the Product Details page and on your Order Details screen, since a small number of categories carry a different window.</p>
              </PrivacySection>

              <PrivacySection title="2. Eligibility for Return">
                <p>To be eligible for a return, an item must generally be:</p>
                <ul className="list-disc pl-5 space-y-2">
                  <li>Unused, unworn, and in the same condition you received it</li>
                  <li>In its original packaging, with all accessories, manuals, freebies, and tags intact</li>
                  <li>Accompanied by the original invoice</li>
                  <li>Not physically damaged due to misuse after delivery</li>
                </ul>
              </PrivacySection>

              <PrivacySection title="3. Non-Returnable Items">
                <p>For hygiene, safety, or activation reasons, the following are generally not eligible for return once delivered, unless the item itself is defective or materially different from what was ordered:</p>
                <ul className="list-disc pl-5 space-y-2">
                  <li>Earphones, earbuds, and other in-ear audio products once the seal is opened</li>
                  <li>Products explicitly marked "Non-Returnable" on the Product Details page</li>
                  <li>Items that have been activated, registered, or have a SIM/eSIM engaged (where applicable)</li>
                  <li>Free promotional items included with an order</li>
                </ul>
              </PrivacySection>

              <PrivacySection title="4. Reasons You Can Return an Item">
                <ul className="list-disc pl-5 space-y-2">
                  <li>Item received is defective, damaged, or not working (DOA — dead on arrival)</li>
                  <li>Wrong product, size, colour, or variant delivered</li>
                  <li>Item significantly different from what was shown/described on the listing</li>
                  <li>Missing parts, accessories, or components that should have been included</li>
                  <li>Simply changed your mind — allowed within the return window for eligible items, as long as the condition requirements in Section 2 are met</li>
                </ul>
              </PrivacySection>

              <PrivacySection title="5. How to Start a Return">
                <p>Returns are initiated entirely from your account:</p>
                <ul className="list-disc pl-5 space-y-2">
                  <li>Go to <strong>My Orders</strong> and open the relevant order</li>
                  <li>Select the item(s) you want to return and choose a reason</li>
                  <li>Our team reviews the request, usually within 24–48 hours</li>
                  <li>Once approved, a pickup is scheduled by our courier partner (for most pincodes), or you may be asked to self-ship for certain locations</li>
                </ul>
              </PrivacySection>

              <PrivacySection title="6. Return Pickup & Inspection">
                <p>Please keep the item packed and ready with all original contents for pickup. Once we receive the item back at our warehouse, it goes through a quality check. If it doesn't meet the eligibility conditions in Section 2, we'll contact you — it may be sent back to you instead of being accepted for return.</p>
              </PrivacySection>

              <PrivacySection title="7. Refunds & Replacements">
                <p>Once your return is received and passes inspection, you can choose (where available) a refund or a replacement. See our <a href="/refund-policy" className="text-[#FF6B2C] font-bold hover:underline">Refund Policy</a> for how and when refunds are processed.</p>
              </PrivacySection>

              <PrivacySection title="8. Cancelling Instead of Returning">
                <p>If your order hasn't been shipped yet, you can cancel it directly from My Orders instead of waiting for delivery and returning it — this is faster and simpler for both sides.</p>
              </PrivacySection>

              <PrivacySection title="9. Contact Us">
                <p>Need help with a return? Reach out to us:</p>
                <div className="flex flex-wrap gap-4 mt-6">
                  <PrivacyContactCard icon={<Mail size={20} />} label="Email Us" detail={contact.email || 'Use the contact form'} />
                  <PrivacyContactCard icon={<Phone size={20} />} label="Call Us" detail={contact.phone || '—'} />
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
                icon={<PackageOpen size={32} />}
                title="We want you to love what you ordered."
                desc="If something isn't right, our return process is built to make it easy to fix."
              />
            </div>
          </div>
        </div>

        <CheckoutTrustStrip />
      </Container>

      <Footer />
    </div>
  );
};

export default ReturnPolicyPage;
