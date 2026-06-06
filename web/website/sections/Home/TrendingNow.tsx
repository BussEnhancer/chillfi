import React from 'react';
import Container from '../../components/common/Container';
import ProductCard from '../../components/product/ProductCard';

const products = [
  {
    image: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&q=80&w=400',
    name: 'realme Narzo 70 Pro 5G (8GB RAM | 128GB)',
    price: 18999,
    oldPrice: 24999,
    discount: '-25%',
    rating: 4.6,
    reviews: 540,
  },
  {
    image: 'https://images.unsplash.com/photo-1508685096489-7aac2715a99a?auto=format&fit=crop&q=80&w=400',
    name: 'Noise ColorFit Pulse 3 Smart Watch',
    price: 1949,
    oldPrice: 4999,
    discount: '-60%',
    rating: 4.4,
    reviews: 12800,
  },
  {
    image: 'https://images.unsplash.com/photo-1484704849700-f032a568e944?auto=format&fit=crop&q=80&w=400',
    name: 'boAt Rockerz 450 Wireless Headphones',
    price: 1499,
    oldPrice: 3990,
    discount: '-62%',
    rating: 4.3,
    reviews: 45000,
  },
  {
    image: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&q=80&w=400',
    name: 'Beardo Whisky Smoke Eau De Parfum',
    price: 799,
    oldPrice: 1200,
    discount: '-30%',
    rating: 4.5,
    reviews: 3200,
  },
  {
    image: 'https://images.unsplash.com/photo-1595428774223-ef52624120d2?auto=format&fit=crop&q=80&w=400',
    name: 'Nilkamal Plastic Storage Cabinet',
    price: 2549,
    oldPrice: 3899,
    discount: '-35%',
    rating: 4.1,
    reviews: 890,
  },
];

const TrendingNow: React.FC = () => {
  return (
    <section className="py-16">
      <Container>
        <div className="flex items-center justify-between mb-10">
          <h2 className="text-2xl font-bold text-gray-900">Trending Now</h2>
          <button className="text-[#6C2BFF] font-bold text-sm hover:underline">View All ›</button>
        </div>

        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-6">
          {products.map((p, i) => (
            <ProductCard key={i} {...p} />
          ))}
        </div>
      </Container>
    </section>
  );
};

export default TrendingNow;
