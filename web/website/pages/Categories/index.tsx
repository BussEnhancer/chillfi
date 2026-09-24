import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import Header from '../../components/navigation/Header';
import TopBar from '../../components/navigation/TopBar';
import CategoryNav from '../../components/navigation/CategoryNav';
import Footer from '../../components/navigation/Footer';
import Container from '../../components/common/Container';
import Breadcrumb from '../../components/common/Breadcrumb';
import CategorySidebar from '../../components/navigation/CategorySidebar';
import CategoryHeroBanner from '../../sections/Categories/CategoryHeroBanner';
import CategoryCard from '../../components/product/CategoryCard';
import PopularBrandsSection from '../../sections/Categories/PopularBrands';
import { ChevronRight } from 'lucide-react';
import { useStore } from '../../context/StoreContext';

const categoryImages: Record<string, string> = {
  Smartphones: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&q=80&w=200',
  Laptops: 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?auto=format&fit=crop&q=80&w=200',
  Audio: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&q=80&w=200',
  'Smart TVs': 'https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?auto=format&fit=crop&q=80&w=200',
  Tablets: 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?auto=format&fit=crop&q=80&w=200',
  Cameras: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&q=80&w=200',
  Gaming: 'https://images.unsplash.com/photo-1550745165-9bc0b252726f?auto=format&fit=crop&q=80&w=200',
  Wearables: 'https://images.unsplash.com/photo-1508685096489-7aac2715a99a?auto=format&fit=crop&q=80&w=200',
  Accessories: 'https://images.unsplash.com/photo-1587829741301-dc798b83add3?auto=format&fit=crop&q=80&w=200',
  'Computer Accessories': 'https://images.unsplash.com/photo-1527814050087-3793815479db?auto=format&fit=crop&q=80&w=200',
};
const categoryColors: Record<string, string> = {
  Smartphones: '#E3F2FD', Laptops: '#F3E5F5', Audio: '#E8F5E9',
  'Smart TVs': '#FCE4EC', Tablets: '#EFEBE9', Cameras: '#FFF3E0',
  Gaming: '#F1F8E9', Wearables: '#E0F2F1', Accessories: '#FFFDE7',
  'Computer Accessories': '#E8EAF6',
};

const CategoriesPage: React.FC = () => {
  const { categories } = useStore();
  const active = categories.filter(c => c.status);
  const [showMobileFilter, setShowMobileFilter] = useState(false);

  return (
    <div className="min-h-screen bg-white font-['Poppins']">
      <TopBar />
      <Header />
      <CategoryNav />
      <Breadcrumb />

      <Container className="flex gap-10 py-10">
        <CategorySidebar />

        <div className="flex-1 min-w-0">
          <CategoryHeroBanner />

          <div className="mt-12 grid grid-cols-1 md:grid-cols-2 xl:grid-cols-5 gap-6">
            {active.map((cat) => (
              <Link key={cat.id} to={`/products?category=${cat.id}`}>
                <CategoryCard
                  name={cat.name}
                  image={categoryImages[cat.name] || 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&q=80&w=200'}
                  count={cat.products.toLocaleString()}
                  discount={`Up to ${Math.floor(20 + cat.orders / 100)}% Off`}
                  bgColor={categoryColors[cat.name] || '#F3F4F6'}
                />
              </Link>
            ))}
            {active.length === 0 && (
              <div className="col-span-5 py-16 text-center text-gray-400 font-bold">No active categories. Add from Admin → Categories.</div>
            )}
          </div>

          <PopularBrandsSection />
        </div>
      </Container>

      <Footer />

      <div className="lg:hidden fixed bottom-6 left-1/2 -translate-x-1/2 z-50">
        <button
          onClick={() => setShowMobileFilter(true)}
          className="bg-[#FF6B2C] text-white px-8 py-3.5 rounded-full font-black shadow-2xl flex items-center gap-3"
        >
          <span>Filter Categories</span>
          <div className="bg-white/20 p-1 rounded-md"><ChevronRight size={14} /></div>
        </button>
      </div>

      {showMobileFilter && (
        <div className="lg:hidden fixed inset-0 z-[60] flex items-end" onClick={() => setShowMobileFilter(false)}>
          <div className="absolute inset-0 bg-black/40" />
          <div
            className="relative w-full bg-white rounded-t-[24px] p-6 max-h-[75vh] overflow-y-auto"
            onClick={e => e.stopPropagation()}
          >
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-xl font-black text-[#111827]">Categories</h2>
              <button onClick={() => setShowMobileFilter(false)} className="text-gray-400 font-black text-sm">Close</button>
            </div>
            <div className="space-y-1">
              <Link to="/categories" onClick={() => setShowMobileFilter(false)} className="block px-4 py-3 rounded-xl font-bold text-sm text-[#FF6B2C] bg-[#FF6B2C]/10">
                All Categories
              </Link>
              {active.map(cat => (
                <Link
                  key={cat.id}
                  to={`/products?category=${cat.id}`}
                  onClick={() => setShowMobileFilter(false)}
                  className="flex items-center justify-between px-4 py-3 rounded-xl text-sm font-bold text-[#6B7280] hover:bg-[#F8F7FC]"
                >
                  {cat.name}
                  <ChevronRight size={16} className="text-[#ECECEC]" />
                </Link>
              ))}
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default CategoriesPage;
