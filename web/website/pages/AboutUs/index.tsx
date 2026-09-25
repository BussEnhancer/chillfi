import React from 'react';
import Header from '../../components/navigation/Header';
import TopBar from '../../components/navigation/TopBar';
import CategoryNav from '../../components/navigation/CategoryNav';
import Footer from '../../components/navigation/Footer';
import Container from '../../components/common/Container';
import Breadcrumb from '../../components/common/Breadcrumb';
import CheckoutTrustStrip from '../../sections/Checkout/CheckoutTrustStrip';

import AboutHero from '../../sections/AboutUs/AboutHero';
import AboutValues from '../../sections/AboutUs/AboutValues';
import AboutJourney from '../../sections/AboutUs/AboutJourney';

const AboutUsPage: React.FC = () => {
  const breadcrumbItems = [
    { label: 'About Us' }
  ];

  return (
    <div className="min-h-screen bg-white font-['Poppins']">
      <TopBar />
      <Header />
      <CategoryNav />
      <Breadcrumb items={breadcrumbItems} />

      <Container className="animate-page-in">
        {/* Hero Section */}
        <AboutHero />

        {/* Our Values Section */}
        <AboutValues />

        {/* Our Journey Section */}
        <AboutJourney />

        {/* Global Trust Section */}
        <CheckoutTrustStrip />
      </Container>

      <Footer />
    </div>
  );
};

export default AboutUsPage;
