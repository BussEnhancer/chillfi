import React from 'react';
import Header from '../../components/navigation/Header';
import TopBar from '../../components/navigation/TopBar';
import CategoryNav from '../../components/navigation/CategoryNav';
import Footer from '../../components/navigation/Footer';
import Container from '../../components/common/Container';
import Breadcrumb from '../../components/common/Breadcrumb';
import SupportSidebar from '../../components/support/SupportSidebar';
import SupportHero from '../../sections/Support/SupportHero';
import SupportTopicsGrid from '../../sections/Support/SupportTopicsGrid';
import SupportContactSection from '../../sections/Support/SupportContactSection';
import SupportFaqAccordion from '../../components/support/SupportFaqAccordion';
import SupportHelpCard from '../../components/support/SupportHelpCard';
import CheckoutTrustStrip from '../../sections/Checkout/CheckoutTrustStrip';

const SupportPage: React.FC = () => {
  const breadcrumbItems = [
    { label: 'Support' }
  ];

  return (
    <div className="min-h-screen bg-white font-['Poppins']">
      <TopBar />
      <Header />
      <CategoryNav />
      <Breadcrumb items={breadcrumbItems} />

      <Container className="py-12 md:py-16 animate-page-in">
        <div className="mb-12">
          <h1 className="text-3xl font-black text-[#111827] mb-2">Support Center</h1>
          <p className="text-sm font-bold text-gray-400">We're here to help! Find answers, track your orders, and get the support you need.</p>
        </div>

        <div className="flex flex-col lg:flex-row gap-12">
          {/* Left: Sidebar */}
          <SupportSidebar />

          {/* Right: Content */}
          <div className="flex-1 min-w-0">
             <SupportHero />

             <SupportTopicsGrid />

             <SupportContactSection />

             <div className="py-12">
                <div className="flex items-center justify-between mb-8">
                   <h2 className="text-2xl font-black text-[#111827]">Frequently Asked Questions</h2>
                </div>
                <div className="flex flex-col xl:flex-row gap-10">
                   <div className="flex-[2]">
                      <SupportFaqAccordion />
                   </div>
                   <div className="flex-1">
                      <SupportHelpCard />
                   </div>
                </div>
             </div>
          </div>
        </div>

        {/* Global Trust Strip */}
        <div className="mt-20">
          <CheckoutTrustStrip />
        </div>
      </Container>

      <Footer />
    </div>
  );
};

export default SupportPage;
