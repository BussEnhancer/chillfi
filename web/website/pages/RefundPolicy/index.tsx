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

import { Banknote, Mail, Phone, MapPin, Wallet } from 'lucide-react';
import { useStoreContact } from '../../utils/useStoreContact';

const RefundPolicyPage: React.FC = () => {
  const contact = useStoreContact();
  const breadcrumbItems = [
    { label: 'Refund Policy' }
  ];

  return (
    <div className="min-h-screen bg-white font-['Poppins']">
      <TopBar />
      <Header />
      <CategoryNav />
      <Breadcrumb items={breadcrumbItems} />

      <Container className="py-10 animate-page-in">
        <div className="flex flex-col lg:flex-row gap-10">
          <AccountSidebar activeId="refund" />

          <div className="flex-1 min-w-0">
            <div className="mb-10">
              <h1 className="text-3xl font-black text-[#111827] mb-1">Refund Policy</h1>
              <p className="text-sm font-bold text-gray-400">Last Updated: 15 May 2025</p>
            </div>

            <PrivacyInfoBanner
              icon={<Banknote size={32} />}
              title="Refunds, processed quickly and transparently."
              desc="This Refund Policy explains when you're eligible for a refund, how it's calculated, and how long it takes to reach you."
            />

            <div className="mt-10">
              <PrivacySection title="1. When You're Eligible for a Refund">
                <ul className="list-disc pl-5 space-y-2">
                  <li>Your approved <a href="/return-policy" className="text-[#FF6B2C] font-bold hover:underline">return</a> has been received and passed our quality check</li>
                  <li>You cancelled an order that was already paid for (prepaid — UPI/card/wallet)</li>
                  <li>An order failed, was undeliverable, and no replacement/re-shipment was requested</li>
                  <li>A duplicate or excess payment was charged due to a technical/payment gateway error</li>
                  <li>A Cash on Delivery order is later determined to be a case where we owe you money back (e.g. partial cancellation after part-payment)</li>
                </ul>
              </PrivacySection>

              <PrivacySection title="2. Refund Method">
                <p>Refunds are made to the <strong>original payment method</strong> wherever possible:</p>
                <ul className="list-disc pl-5 space-y-2">
                  <li><strong>UPI / Card / Net Banking / Wallet payments:</strong> refunded to the same source used for payment</li>
                  <li><strong>Cash on Delivery orders:</strong> refunded via bank transfer or UPI to the details you provide, since there's no original digital payment to reverse</li>
                </ul>
                <p>We never ask for your card number, CVV, or UPI PIN over phone, email, or chat to process a refund — if anyone contacts you asking for these "to process your refund," please do not share them and report it to us immediately.</p>
              </PrivacySection>

              <PrivacySection title="3. Refund Amount">
                <p>Refunds cover the price paid for the item(s) being refunded, including any tax (GST) charged on them. Delivery charges are refunded in full only if the return/cancellation is due to our error (wrong/defective/damaged item) or a failed delivery on our end — in change-of-mind returns, the original delivery charge (if any was paid) is generally not refunded, though the product amount is.</p>
                <p>Where a coupon or discount was applied to the order, the refund is calculated on the actual amount you paid after that discount, not the original listed price.</p>
              </PrivacySection>

              <PrivacySection title="4. Refund Timeline">
                <p>Once a refund is approved and initiated on our end:</p>
                <ul className="list-disc pl-5 space-y-2">
                  <li>UPI: typically 2–4 business days to reflect</li>
                  <li>Credit/Debit Card: typically 5–7 business days, depending on your bank</li>
                  <li>Net Banking / Wallets: typically 3–5 business days</li>
                  <li>Bank transfer (for COD refunds): typically 5–7 business days after we receive your correct bank details</li>
                </ul>
                <p>These timelines start once we've initiated the refund on our side — banks and payment providers occasionally take a little longer during their own processing, which is outside our control.</p>
              </PrivacySection>

              <PrivacySection title="5. Tracking Your Refund">
                <p>You can check the status of any refund from <strong>My Orders → Order Details</strong> for the relevant order — it will show as Pending, Processed, or Completed. If a refund shows Completed on our end but hasn't reached you after the timelines above, please contact your bank first, then reach out to us with your order ID.</p>
              </PrivacySection>

              <PrivacySection title="6. Partial Refunds">
                <p>For orders with multiple items, if only some items are returned or cancelled, we refund only the amount corresponding to those specific items (plus applicable tax), recalculated against any order-level discount that applied.</p>
              </PrivacySection>

              <PrivacySection title="7. Contact Us">
                <p>Questions about a specific refund? Reach out with your Order ID so we can look into it faster:</p>
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
                icon={<Wallet size={32} />}
                title="Your money, back where it belongs."
                desc="We process every eligible refund promptly to the original payment method."
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

export default RefundPolicyPage;
