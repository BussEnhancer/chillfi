import React from 'react';
import Header from '../../components/navigation/Header';
import TopBar from '../../components/navigation/TopBar';
import Footer from '../../components/navigation/Footer';
import Container from '../../components/common/Container';
import CheckoutStepper from '../../components/order/CheckoutStepper';
import AddressCard from '../../components/order/AddressCard';
import DeliveryOptionCard from '../../components/order/DeliveryOptionCard';
import PaymentMethodCard from '../../components/order/PaymentMethodCard';
import OrderSummaryCard from '../../sections/Checkout/OrderSummaryCard';
import CheckoutTrustStrip from '../../sections/Checkout/CheckoutTrustStrip';
import { Tag, Plus, CreditCard, Landmark, Wallet, Banknote, Smartphone } from 'lucide-react';

const CheckoutPage: React.FC = () => {
  return (
    <div className="min-h-screen bg-white font-['Poppins']">
      <TopBar />
      <Header />

      <Container className="py-10">
        <CheckoutStepper />

        <div className="flex flex-col lg:flex-row gap-12 mt-4">
          {/* Left Column: Checkout Forms */}
          <div className="flex-1 space-y-12">

            {/* 1. Delivery Address */}
            <section>
              <div className="flex items-center justify-between mb-8">
                <div>
                  <h2 className="text-2xl font-black text-[#111827] mb-1">1. Delivery Address</h2>
                  <p className="text-sm font-bold text-gray-400">Choose where you want your order delivered</p>
                </div>
                <button className="flex items-center gap-2 text-[#6C2BFF] font-black text-sm hover:underline">
                  <Plus size={18} />
                  Add New Address
                </button>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                <AddressCard
                  type="Home"
                  name="Rohit Sharma"
                  address="123, Green Park Society, Indiranagar, Bengaluru, Karnataka - 560038"
                  phone="+91 98765 43210"
                  isSelected={true}
                  isDefault={true}
                />
                <AddressCard
                  type="Work"
                  name="Rohit Sharma"
                  address="Tech Park, Tower A, 4th Floor, Whitefield, Bengaluru, Karnataka - 560066"
                  phone="+91 98765 43210"
                />
                <AddressCard
                  type="Other"
                  name="Rohit Sharma"
                  address="45, 2nd Cross, Koramangala, Bengaluru, Karnataka - 560034"
                  phone="+91 98765 43210"
                />
              </div>
            </section>

            {/* 2. Delivery Options */}
            <section>
               <div className="mb-8">
                  <h2 className="text-2xl font-black text-[#111827] mb-1">2. Delivery Options</h2>
                  <p className="text-sm font-bold text-gray-400">Choose your preferred delivery method</p>
               </div>
               <div className="flex flex-col md:flex-row gap-6">
                  <DeliveryOptionCard
                    type="Standard"
                    duration="3-5 Business Days"
                    price="FREE"
                    oldPrice={49}
                    isSelected={true}
                  />
                  <DeliveryOptionCard
                    type="Express"
                    duration="1-2 Business Days"
                    price={79}
                  />
               </div>
            </section>

            {/* 3. Payment Method */}
            <section>
               <div className="mb-8">
                  <h2 className="text-2xl font-black text-[#111827] mb-1">3. Payment Method</h2>
                  <p className="text-sm font-bold text-gray-400">Select a payment option</p>
               </div>
               <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                  <PaymentMethodCard
                    label="UPI"
                    icon={<Smartphone size={20} />}
                    isSelected={true}
                  />
                  <PaymentMethodCard
                    label="Credit / Debit Card"
                    icon={<CreditCard size={20} />}
                  />
                  <PaymentMethodCard
                    label="Net Banking"
                    icon={<Landmark size={20} />}
                  />
                  <PaymentMethodCard
                    label="Wallets"
                    icon={<Wallet size={20} />}
                  />
                  <PaymentMethodCard
                    label="Cash on Delivery"
                    icon={<Banknote size={20} />}
                    badge="Available"
                  />
               </div>
            </section>

            {/* Coupon Section */}
            <section className="bg-[#F8F7FC] rounded-[32px] p-8 border border-[#ECECEC] flex flex-col md:flex-row items-center justify-between gap-8 group">
               <div className="flex items-center gap-6">
                  <div className="w-14 h-14 bg-white rounded-2xl flex items-center justify-center text-[#6C2BFF] shadow-sm group-hover:scale-110 transition-transform">
                     <Tag size={28} />
                  </div>
                  <div>
                     <h3 className="text-lg font-black text-[#111827] mb-1">Have a coupon code?</h3>
                     <p className="text-sm font-bold text-gray-400">Apply coupon to get extra discounts on your order</p>
                  </div>
               </div>
               <div className="flex flex-1 max-w-[400px] w-full bg-white p-1.5 rounded-xl border border-[#ECECEC] focus-within:border-[#6C2BFF] transition-all">
                  <input
                    type="text"
                    placeholder="Enter coupon code"
                    className="flex-1 bg-transparent px-4 text-sm font-bold outline-none uppercase placeholder:normal-case"
                  />
                  <button className="bg-[#6C2BFF] text-white px-8 py-3 rounded-lg font-black text-sm hover:bg-[#5A24D6] transition-all">
                     Apply
                  </button>
               </div>
            </section>

          </div>

          {/* Right Column: Order Summary */}
          <div className="lg:w-[380px] shrink-0">
             <OrderSummaryCard />
          </div>
        </div>

        {/* Global Trust Section */}
        <CheckoutTrustStrip />
      </Container>

      <Footer />
    </div>
  );
};

export default CheckoutPage;
