import React from 'react';
import TopBar from '../../components/navigation/TopBar';
import Header from '../../components/navigation/Header';
import CategoryNav from '../../components/navigation/CategoryNav';
import Footer from '../../components/navigation/Footer';

import HeroSection from '../../sections/Home/HeroSection';
import TrustBar from '../../sections/Home/TrustBar';
import ShopByCategory from '../../sections/Home/ShopByCategory';
import FlashSale from '../../sections/Home/FlashSale';
import TrendingNow from '../../sections/Home/TrendingNow';
import PromoBanners from '../../sections/Home/PromoBanners';
import TopBrands from '../../sections/Home/TopBrands';
import Testimonials from '../../sections/Home/Testimonials';
import Newsletter from '../../sections/Home/Newsletter';

const HomePage: React.FC = () => {
  return (
    <div className="min-h-screen bg-white font-['Poppins']">
      {/* Navigation Layer */}
      <TopBar />
      <Header />
      <CategoryNav />

      {/* Hero Section */}
      <HeroSection />

      {/* Trust Features */}
      <TrustBar />

      {/* Category Selection */}
      <ShopByCategory />

      {/* Flash Sales with Countdown */}
      <FlashSale />

      {/* Trending Products Grid */}
      <TrendingNow />

      {/* Marketing Banners */}
      <PromoBanners />

      {/* Brand Partners */}
      <TopBrands />

      {/* Customer Feedback */}
      <Testimonials />

      {/* Subscription Block */}
      <Newsletter />

      {/* Global Footer */}
      <Footer />
    </div>
  );
};

export default HomePage;
