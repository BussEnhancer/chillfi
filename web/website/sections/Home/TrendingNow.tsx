import React from 'react';
import { Link } from 'react-router-dom';
import Container from '../../components/common/Container';
import ProductCard from '../../components/product/ProductCard';

export interface ApiTrendingProduct {
  id: string;
  name: string;
  price: number;
  old_price: number;
  rating: number;
  review_count: number;
  brand_name?: string;
  primary_image?: string;
}

interface TrendingNowProps {
  products?: ApiTrendingProduct[];
}

const TrendingNow: React.FC<TrendingNowProps> = ({ products }) => {
  const items = products && products.length > 0 ? products : null;

  return (
    <section className="py-16">
      <Container>
        <div className="flex items-center justify-between mb-10">
          <h2 className="text-2xl font-bold text-gray-900">Trending Now</h2>
          <Link to="/products" className="text-[#FF6B2C] font-bold text-sm hover:underline">View All ›</Link>
        </div>

        {items ? (
          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-6">
            {items.slice(0, 5).map(p => {
              const discount = p.old_price > p.price
                ? `-${Math.round((p.old_price - p.price) / p.old_price * 100)}%`
                : undefined;
              return (
                <ProductCard
                  key={p.id}
                  id={p.id}
                  image={p.primary_image || ''}
                  name={p.name}
                  price={Number(p.price)}
                  oldPrice={Number(p.old_price) || undefined}
                  discount={discount}
                  rating={Number(p.rating || 0)}
                  reviews={Number(p.review_count || 0)}
                />
              );
            })}
          </div>
        ) : (
          <div className="py-10 text-center text-gray-400 font-bold text-sm">
            No trending products available right now.
          </div>
        )}
      </Container>
    </section>
  );
};

export default TrendingNow;
