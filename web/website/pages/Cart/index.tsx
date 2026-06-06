import React from 'react';
import Header from '../../components/navigation/Header';
import TopBar from '../../components/navigation/TopBar';
import CategoryNav from '../../components/navigation/CategoryNav';
import Footer from '../../components/navigation/Footer';
import Container from '../../components/common/Container';
import TrustStripSmall from '../../components/common/TrustStripSmall';
import CartTable from '../../components/product/CartTable';
import PriceSummaryCard from '../../sections/Cart/PriceSummaryCard';
import ProductCardPLP from '../../components/product/ProductCardPLP';
import { ChevronRight, Sparkles, Truck, RotateCcw, ShieldCheck, Headphones } from 'lucide-react';

const mockRecommendations = [
  {
    image: 'https://images.unsplash.com/photo-1484704849700-f032a568e944?auto=format&fit=crop&q=80&w=400',
    name: 'boAt Rockerz 450 Wireless Headphones',
    brand: 'boAt',
    price: 1499,
    oldPrice: 3990,
    discount: '-62%',
    rating: 4.3,
    reviews: 45000,
  },
  {
    image: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&q=80&w=400',
    name: 'Adidas Grand Court Base Sneakers',
    brand: 'Adidas',
    price: 3199,
    oldPrice: 4999,
    discount: '-30%',
    rating: 4.4,
    reviews: 750,
  },
  {
    image: 'https://images.unsplash.com/photo-1549463595-b093057de965?auto=format&fit=crop&q=80&w=400',
    name: 'Wildcraft Wolf Laptop Backpack',
    brand: 'Wildcraft',
    price: 1899,
    oldPrice: 2499,
    discount: '-24%',
    rating: 4.5,
    reviews: 2100,
  },
  {
    image: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&q=80&w=400',
    name: 'boAt Airdopes 141 Wireless Earbuds',
    brand: 'boAt',
    price: 1299,
    oldPrice: 2990,
    discount: '-55%',
    rating: 4.3,
    reviews: 850,
  },
];

const CartPage: React.FC = () => {
  return (
    <div className="min-h-screen bg-white font-['Poppins']">
      <TopBar />
      <Header />
      <CategoryNav />

      <Container className="py-10">
        <div className="flex items-center justify-between mb-8">
           <div>
              <h1 className="text-3xl font-black text-[#111827] mb-2">My Cart <span className="text-gray-400 font-bold">(4 Items)</span></h1>
              <div className="flex items-center gap-2 bg-green-50 px-4 py-2 rounded-full border border-green-100">
                 <Sparkles size={14} className="text-green-600" />
                 <span className="text-xs font-black text-green-600 uppercase tracking-wider">Yay! You are saving ₹1,948 on this order</span>
              </div>
           </div>
           <div className="hidden lg:block">
              <TrustStripSmall />
           </div>
        </div>

        <div className="flex flex-col lg:flex-row gap-10">
           {/* Left: Cart Contents */}
           <div className="flex-1 overflow-hidden">
              <CartTable />
           </div>

           {/* Right: Price Summary */}
           <div className="lg:w-[350px] shrink-0">
              <PriceSummaryCard />
           </div>
        </div>

        {/* Recommendations */}
        <div className="mt-20">
           <div className="flex items-center justify-between mb-8">
              <h2 className="text-2xl font-black text-[#111827]">You may also like</h2>
              <button className="flex items-center gap-1 text-[#6C2BFF] font-black text-sm hover:underline">
                 View All <ChevronRight size={16} />
              </button>
           </div>
           <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-6">
              {mockRecommendations.map((p, i) => (
                <ProductCardPLP key={i} {...p} />
              ))}
           </div>
        </div>

        {/* Bottom Trust Strip */}
        <div className="mt-20 py-12 border-t border-[#F8F7FC] grid grid-cols-2 lg:grid-cols-4 gap-8">
           {[
             { icon: <Truck size={24} />, title: 'Free Delivery', desc: 'On orders above ₹499' },
             { icon: <RotateCcw size={24} />, title: 'Easy Returns', desc: 'Within 7 days' },
             { icon: <ShieldCheck size={24} />, title: 'Secure Payments', desc: '100% secure payments' },
             { icon: <Headphones size={24} />, title: '24/7 Support', desc: "We're here to help" },
           ].map((item, i) => (
             <div key={i} className="flex flex-col items-center text-center group cursor-default">
                <div className="w-14 h-14 bg-[#F8F7FC] rounded-2xl flex items-center justify-center text-[#6C2BFF] mb-4 group-hover:scale-110 transition-transform">
                   {item.icon}
                </div>
                <h4 className="text-sm font-black text-[#111827] uppercase tracking-wider mb-1">{item.title}</h4>
                <p className="text-[11px] font-bold text-gray-400">{item.desc}</p>
             </div>
           ))}
        </div>
      </Container>

      <Footer />
    </div>
  );
};

export default CartPage;
