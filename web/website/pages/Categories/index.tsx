import React from 'react';
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

const categoryData = [
  { name: 'Fashion', image: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&q=80&w=200', count: '25,342', discount: 'Up to 70% Off', color: '#F3E5F5' },
  { name: 'Electronics', image: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&q=80&w=200', count: '18,965', discount: 'Up to 60% Off', color: '#E3F2FD' },
  { name: 'Home & Living', image: 'https://images.unsplash.com/photo-1556228453-efd6c1ff04f6?auto=format&fit=crop&q=80&w=200', count: '12,543', discount: 'Up to 50% Off', color: '#E8F5E9' },
  { name: 'Beauty', image: 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?auto=format&fit=crop&q=80&w=200', count: '8,752', discount: 'Up to 60% Off', color: '#FCE4EC' },
  { name: 'Men', image: 'https://images.unsplash.com/photo-1516259762381-22954d7d3ad2?auto=format&fit=crop&q=80&w=200', count: '15,642', discount: 'Up to 60% Off', color: '#EFEBE9' },
  { name: 'Women', image: 'https://images.unsplash.com/photo-1567401893414-76b7b1e5a7a5?auto=format&fit=crop&q=80&w=200', count: '20,935', discount: 'Up to 70% Off', color: '#FFF3E0' },
  { name: 'Sports', image: 'https://images.unsplash.com/photo-1517649763962-0c6234978a0b?auto=format&fit=crop&q=80&w=200', count: '7,654', discount: 'Up to 50% Off', color: '#F1F8E9' },
  { name: 'Toys & Games', image: 'https://images.unsplash.com/photo-1532330393533-443990a51d10?auto=format&fit=crop&q=80&w=200', count: '6,321', discount: 'Up to 50% Off', color: '#E0F2F1' },
  { name: 'Grocery', image: 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&q=80&w=200', count: '10,875', discount: 'Up to 40% Off', color: '#FFFDE7' },
  { name: 'Health & Personal Care', image: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?auto=format&fit=crop&q=80&w=200', count: '9,421', discount: 'Up to 40% Off', color: '#E8EAF6' },
];

const CategoriesPage: React.FC = () => {
  return (
    <div className="min-h-screen bg-white font-['Poppins']">
      <TopBar />
      <Header />
      <CategoryNav />
      <Breadcrumb />

      <Container className="flex gap-10 py-10">
        {/* Left Sidebar */}
        <CategorySidebar />

        {/* Main Content */}
        <div className="flex-1">
          {/* Hero Banner */}
          <CategoryHeroBanner />

          {/* Grid Section */}
          <div className="mt-12 grid grid-cols-1 md:grid-cols-2 xl:grid-cols-5 gap-6">
            {categoryData.map((category, index) => (
              <CategoryCard
                key={index}
                name={category.name}
                image={category.image}
                count={category.count}
                discount={category.discount}
                bgColor={category.color}
              />
            ))}
          </div>

          {/* Brands Section */}
          <PopularBrandsSection />
        </div>
      </Container>

      <Footer />

      {/* Mobile Sticky Filter Button (UI Only) */}
      <div className="lg:hidden fixed bottom-6 left-1/2 -translate-x-1/2 z-50">
         <button className="bg-[#6C2BFF] text-white px-8 py-3.5 rounded-full font-black shadow-2xl flex items-center gap-3">
            <span>Filter Categories</span>
            <div className="bg-white/20 p-1 rounded-md">
               <ChevronRight size={14} />
            </div>
         </button>
      </div>
    </div>
  );
};

export default CategoriesPage;
