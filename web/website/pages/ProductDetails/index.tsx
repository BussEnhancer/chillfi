import React from 'react';
import Header from '../../components/navigation/Header';
import TopBar from '../../components/navigation/TopBar';
import CategoryNav from '../../components/navigation/CategoryNav';
import Footer from '../../components/navigation/Footer';
import Container from '../../components/common/Container';
import Breadcrumb from '../../components/common/Breadcrumb';

import ProductGallery from '../../components/product/ProductGallery';
import OfferCard from '../../components/product/OfferCard';
import ColorSelector from '../../components/product/ColorSelector';
import SizeSelector from '../../components/product/SizeSelector';
import SellerCard from '../../components/product/SellerCard';
import ProductTabs from '../../components/common/ProductTabs';
import DeliveryActionCard from '../../sections/ProductDetails/DeliveryActionCard';
import RelatedProducts from '../../sections/ProductDetails/RelatedProducts';
import Badge from '../../components/common/Badge';

import { Star, Shield, Info, Activity } from 'lucide-react';

const ProductDetailsPage: React.FC = () => {
  const breadcrumbItems = [
    { label: 'Men', href: '#' },
    { label: 'Footwear', href: '#' },
    { label: 'Sneakers', href: '#' },
    { label: "Nike Air Max Excee Men's Sneakers" }
  ];

  return (
    <div className="min-h-screen bg-white font-['Poppins']">
      <TopBar />
      <Header />
      <CategoryNav />
      <Breadcrumb items={breadcrumbItems} />

      <Container className="py-10">
        <div className="flex flex-col lg:flex-row gap-12">
          {/* Left Column: Gallery */}
          <div className="lg:w-[50%]">
            <ProductGallery />

            {/* Desktop Tabs */}
            <div className="hidden lg:block mt-20">
              <ProductTabs />
              <div className="text-gray-600 space-y-6 leading-relaxed">
                <p className="font-medium">
                  Inspired by the Nike Air Max 90, the Nike Air Max Excee celebrates a classic through a new lens.
                  Elongated design lines and distorted proportions on the upper bring a fresh look to an icon.
                  Visible Air unit adds an eye-catching element.
                </p>
                <div className="flex flex-wrap gap-10 py-6 border-y border-[#F8F7FC]">
                   {[
                     { icon: <Activity size={20} />, text: 'Visible Air Cushioning' },
                     { icon: <Activity size={20} />, text: 'Foam Midsole' },
                     { icon: <Shield size={20} />, text: 'Rubber Outsole' },
                     { icon: <Info size={20} />, text: 'Padded Collar' },
                     { icon: <Activity size={20} />, text: 'Lace-up Closure' },
                   ].map((feat, i) => (
                     <div key={i} className="flex items-center gap-3">
                        <div className="w-10 h-10 bg-gray-50 rounded-full flex items-center justify-center text-[#6C2BFF]">
                           {feat.icon}
                        </div>
                        <span className="text-xs font-black text-[#111827] uppercase tracking-wider">{feat.text}</span>
                     </div>
                   ))}
                </div>
              </div>
            </div>
          </div>

          {/* Center Column: Info */}
          <div className="flex-1">
             <div className="mb-6">
                <Badge text="Best Seller" className="bg-green-600 inline-block mb-4" />
                <h1 className="text-3xl md:text-4xl font-black text-[#111827] mb-2">Nike Air Max Excee <br />Men's Sneakers</h1>

                <div className="flex items-center gap-4">
                   <div className="flex items-center gap-1 bg-green-50 px-2 py-1 rounded-lg">
                      <span className="text-sm font-black text-green-600">4.5</span>
                      <Star size={14} className="fill-green-600 text-green-600" />
                   </div>
                   <span className="text-sm font-bold text-gray-400">(980 Ratings)</span>
                </div>
             </div>

             <div className="mb-8 p-6 bg-[#F8F7FC] rounded-3xl border border-[#ECECEC]">
                <div className="flex items-baseline gap-4 mb-1">
                   <span className="text-4xl font-black text-[#111827]">₹5,999</span>
                   <span className="text-lg text-gray-400 line-through font-bold">₹7,999</span>
                   <Badge text="-25% OFF" className="bg-[#FF4D4F] text-sm" />
                </div>
                <p className="text-[11px] font-bold text-gray-400 uppercase tracking-widest">Inclusive of all taxes</p>
             </div>

             {/* Offers */}
             <div className="mb-10">
                <h3 className="text-[11px] font-black text-gray-500 uppercase tracking-widest mb-4">Offers for you</h3>
                <div className="flex flex-wrap gap-4 mb-4">
                   <OfferCard
                     title="10% Instant Discount"
                     desc="on HDFC Bank Credit Cards. Max discount up to ₹1,500."
                   />
                   <OfferCard
                     title="5% Unlimited Cashback"
                     desc="on chillFi Axis Bank Credit Card. No upper limit."
                   />
                </div>
                <button className="text-[11px] font-black text-[#6C2BFF] uppercase tracking-widest hover:underline">+ 3 More Offers</button>
             </div>

             <ColorSelector />
             <SizeSelector />

             <SellerCard />

             {/* Mobile Tabs (Mobile Only) */}
             <div className="lg:hidden mt-10">
                <ProductTabs />
             </div>
          </div>

          {/* Right Column: Actions */}
          <div className="lg:w-[320px] shrink-0">
             <DeliveryActionCard />
          </div>
        </div>

        {/* Related Products */}
        <RelatedProducts />
      </Container>

      <Footer />
    </div>
  );
};

export default ProductDetailsPage;
