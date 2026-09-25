import React, { useEffect, useState } from 'react';
import TopBar from '../../components/navigation/TopBar';
import Header from '../../components/navigation/Header';
import CategoryNav from '../../components/navigation/CategoryNav';
import Footer from '../../components/navigation/Footer';

import HeroSection, { ApiBanner } from '../../sections/Home/HeroSection';
import TrustBar from '../../sections/Home/TrustBar';
import ShopByCategory from '../../sections/Home/ShopByCategory';
import FlashSale, { ApiFlashProduct } from '../../sections/Home/FlashSale';
import TrendingNow, { ApiTrendingProduct } from '../../sections/Home/TrendingNow';
import PromoBanners, { ApiPromoBanner } from '../../sections/Home/PromoBanners';
import TopBrands, { ApiBrand } from '../../sections/Home/TopBrands';
import Testimonials, { ApiTestimonial } from '../../sections/Home/Testimonials';
import Newsletter from '../../sections/Home/Newsletter';
import { apiGet } from '../../utils/api';

interface HomeData {
  banners: ApiBanner[];
  flash_sale: ApiFlashProduct[];
  trending: ApiTrendingProduct[];
  brands: ApiBrand[];
  testimonials: ApiTestimonial[];
  promo_banners: ApiPromoBanner[];
}

const HomePage: React.FC = () => {
  const [home, setHome] = useState<HomeData | null>(null);

  useEffect(() => {
    apiGet<{ success: boolean; data: HomeData }>('/home')
      .then(res => setHome(res.data))
      .catch(() => {});
  }, []);

  return (
    <div className="min-h-screen bg-white font-['Poppins']">
      <TopBar />
      <Header />
      <CategoryNav />

      <div className="animate-page-in">
        <HeroSection banners={home?.banners} />
        <TrustBar />
        <ShopByCategory />
        <FlashSale products={home?.flash_sale} />
        <TrendingNow products={home?.trending} />
        <PromoBanners promos={home?.promo_banners} />
        <TopBrands brands={home?.brands} />
        <Testimonials testimonials={home?.testimonials} />
        <Newsletter />
      </div>
      <Footer />
    </div>
  );
};

export default HomePage;
