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

import { Truck, Mail, Phone, MapPin, PackageCheck } from 'lucide-react';

const ShippingPolicyPage: React.FC = () => {
  const breadcrumbItems = [
    { label: 'Shipping Policy' }
  ];

  return (
    <div className="min-h-screen bg-white font-['Poppins']">
      <TopBar />
      <Header />
      <CategoryNav />
      <Breadcrumb items={breadcrumbItems} />

      <Container className="py-10">
        <div className="flex flex-col lg:flex-row gap-10">
          <AccountSidebar activeId="shipping" />

          <div className="flex-1 min-w-0">
            <div className="mb-10">
              <h1 className="text-3xl font-black text-[#111827] mb-1">Shipping Policy</h1>
              <p className="text-sm font-bold text-gray-400">Last Updated: 15 May 2025</p>
            </div>

            <PrivacyInfoBanner
              icon={<Truck size={32} />}
              title="Fast, trackable delivery across India."
              desc="This Shipping Policy explains how we process, dispatch, and deliver your orders, and what to expect at each step."
            />

            <div className="mt-10">
              <PrivacySection title="1. Delivery Coverage">
                <p>We currently ship to most serviceable pincodes across India through our logistics partner Delhivery. Serviceability for your exact pincode is checked automatically at checkout — if we can't deliver to your address, you'll see this before placing the order.</p>
              </PrivacySection>

              <PrivacySection title="2. Processing Time">
                <p>Orders are typically processed and handed over to our courier partner within 24–48 hours of confirmation, excluding Sundays and public holidays.</p>
                <p>Orders placed during sales/flash-deal periods may take slightly longer to process due to higher volumes.</p>
              </PrivacySection>

              <PrivacySection title="3. Delivery Timelines">
                <p>Once shipped, standard delivery typically takes:</p>
                <ul className="list-disc pl-5 space-y-2">
                  <li>Metro cities: 2–4 business days</li>
                  <li>Other cities and towns: 4–7 business days</li>
                  <li>Remote / hard-to-reach areas: 7–10 business days</li>
                </ul>
                <p>These are estimates, not guarantees — actual delivery time can vary due to courier delays, weather, local restrictions, or incorrect/incomplete addresses.</p>
              </PrivacySection>

              <PrivacySection title="4. Shipping Charges">
                <p>Delivery is <strong>free on orders above the free-shipping threshold shown in your cart</strong> (currently ₹499). Orders below this amount are charged a flat delivery fee, shown clearly at checkout before you pay — never added as a surprise afterward.</p>
                <p>Delivery fees may vary slightly by pincode where we have specific courier-zone pricing in place.</p>
              </PrivacySection>

              <PrivacySection title="5. Order Tracking">
                <p>Once your order is shipped, you'll receive a tracking ID and can follow its live status any time from <strong>My Orders → Track Order</strong> on the website or app. If tracking hasn't updated in a while, please allow 24–48 hours before reaching out, as courier scans can occasionally lag behind the physical movement of the package.</p>
              </PrivacySection>

              <PrivacySection title="6. Failed / Delayed Delivery Attempts">
                <p>Our courier partners typically attempt delivery up to 2–3 times. If delivery fails each time (e.g. no one available, incorrect address, gate/society access issues), the shipment may be returned to us. In that case we'll contact you to arrange re-shipping (additional delivery charges may apply) or process a refund for prepaid orders.</p>
              </PrivacySection>

              <PrivacySection title="7. Damaged or Incorrect Shipments">
                <p>Please inspect your package at the time of delivery where possible. If a package arrives visibly damaged, tampered with, or you receive the wrong product, contact our support team within 48 hours of delivery with photos of the item and packaging — see our <a href="/refund-policy" className="text-[#FF6B2C] font-bold hover:underline">Refund Policy</a> and <a href="/return-policy" className="text-[#FF6B2C] font-bold hover:underline">Return Policy</a> for how we resolve this.</p>
              </PrivacySection>

              <PrivacySection title="8. Address Changes">
                <p>If you need to change your delivery address, contact us as soon as possible after placing your order. Once an order has been handed over to our courier partner, we may not be able to modify the delivery address, and any re-routing done by the courier is at their discretion and may incur additional charges.</p>
              </PrivacySection>

              <PrivacySection title="9. Contact Us">
                <p>Questions about a shipment or this policy? Reach out to us:</p>
                <div className="flex flex-wrap gap-4 mt-6">
                  <PrivacyContactCard icon={<Mail size={20} />} label="Email Us" detail="support@chillfi.com" />
                  <PrivacyContactCard icon={<Phone size={20} />} label="Call Us" detail="+91 98765 43210" />
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
                icon={<PackageCheck size={32} />}
                title="Every order, tracked door to door."
                desc="We work with trusted courier partners so you always know exactly where your order is."
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

export default ShippingPolicyPage;
