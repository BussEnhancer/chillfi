import React from 'react';
import Header from '../../components/navigation/Header';
import TopBar from '../../components/navigation/TopBar';
import CategoryNav from '../../components/navigation/CategoryNav';
import Footer from '../../components/navigation/Footer';
import Container from '../../components/common/Container';
import Breadcrumb from '../../components/common/Breadcrumb';
import ProductFilterSidebar from '../../components/navigation/ProductFilterSidebar';
import PLP_HeroBanner from '../../sections/ProductListing/PLP_HeroBanner';
import ProductSortBar from '../../components/product/ProductSortBar';
import FilterChip from '../../components/product/FilterChip';
import ProductCardPLP from '../../components/product/ProductCardPLP';
import Pagination from '../../components/common/Pagination';

const mockProducts = [
  {
    image: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&q=80&w=400',
    name: 'Puma Smashic Unisex Sneakers',
    brand: 'Puma',
    price: 2799,
    oldPrice: 3999,
    discount: '-30%',
    rating: 4.8,
    reviews: 1250,
    colors: 4,
    isBestSeller: true
  },
  {
    image: 'https://images.unsplash.com/photo-1512374382149-233c42b6a83b?auto=format&fit=crop&q=80&w=400',
    name: 'Nike Air Max Excee Men\'s Sneakers',
    brand: 'Nike',
    price: 5999,
    oldPrice: 7999,
    discount: '-25%',
    rating: 4.5,
    reviews: 980,
    colors: 3
  },
  {
    image: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&q=80&w=400',
    name: 'Adidas Grand Court Base Men\'s Sneakers',
    brand: 'Adidas',
    price: 3599,
    oldPrice: 4499,
    discount: '-20%',
    rating: 4.2,
    reviews: 750,
    colors: 2
  },
  {
    image: 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?auto=format&fit=crop&q=80&w=400',
    name: 'Skechers Go Walk Max Men\'s Sneakers',
    brand: 'Skechers',
    price: 3299,
    oldPrice: 3999,
    discount: '-18%',
    rating: 4.6,
    reviews: 1100,
    colors: 4,
    isBestSeller: true
  },
  {
    image: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&q=80&w=400',
    name: 'Reebok Royal Glide Unisex Sneakers',
    brand: 'Reebok',
    price: 2699,
    oldPrice: 3499,
    discount: '-22%',
    rating: 4.0,
    reviews: 340,
    colors: 2
  },
  {
    image: 'https://images.unsplash.com/photo-1605348532760-6753d2c43329?auto=format&fit=crop&q=80&w=400',
    name: 'Puma Ferrari Drift Cat Decima Sneakers',
    brand: 'Puma',
    price: 4299,
    oldPrice: 5699,
    discount: '-24%',
    rating: 4.7,
    reviews: 320,
    colors: 3
  },
];

// Fill more products to show grid
const displayProducts = [...mockProducts, ...mockProducts, ...mockProducts, ...mockProducts];

const ProductListingPage: React.FC = () => {
  const breadcrumbItems = [
    { label: 'Categories', href: '/categories' },
    { label: 'Men' },
    { label: 'Footwear' },
    { label: 'Sneakers' }
  ];

  return (
    <div className="min-h-screen bg-white font-['Poppins']">
      <TopBar />
      <Header />
      <CategoryNav />
      <Breadcrumb items={breadcrumbItems} />

      <Container className="flex gap-10 py-10">
        {/* Left Filter Sidebar */}
        <ProductFilterSidebar />

        {/* Main Product Area */}
        <div className="flex-1">
          <PLP_HeroBanner />

          <ProductSortBar />

          {/* Active Filter Chips */}
          <div className="flex flex-wrap items-center gap-3 mb-10">
             <FilterChip label="Puma" />
             <FilterChip label="Nike" />
             <FilterChip label="Men" />
             <FilterChip label="Sneakers" />
             <button className="text-[11px] font-black text-[#6C2BFF] uppercase tracking-widest hover:underline ml-2">Clear All</button>
          </div>

          {/* Product Grid - 6 Columns on Desktop */}
          <div className="grid grid-cols-2 md:grid-cols-3 xl:grid-cols-6 gap-6">
            {displayProducts.map((product, i) => (
              <ProductCardPLP key={i} {...product} />
            ))}
          </div>

          <Pagination />
        </div>
      </Container>

      <Footer />
    </div>
  );
};

export default ProductListingPage;
