import React from 'react';
import { ChevronRight } from 'lucide-react';
import ProductCardPLP from '../../components/product/ProductCardPLP';

const mockProducts = [
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
    image: 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?auto=format&fit=crop&q=80&w=400',
    name: 'Skechers Go Walk Max Sneakers',
    brand: 'Skechers',
    price: 3299,
    oldPrice: 3999,
    discount: '-18%',
    rating: 4.6,
    reviews: 1100,
  },
  {
    image: 'https://images.unsplash.com/photo-1605348532760-6753d2c43329?auto=format&fit=crop&q=80&w=400',
    name: 'Puma X-Ray 2 Square Sneakers',
    brand: 'Puma',
    price: 3499,
    oldPrice: 6499,
    discount: '-42%',
    rating: 4.5,
    reviews: 420,
  },
  {
    image: 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?auto=format&fit=crop&q=80&w=400',
    name: 'Nike Court Vision Low Sneakers',
    brand: 'Nike',
    price: 4299,
    oldPrice: 5699,
    discount: '-24%',
    rating: 4.7,
    reviews: 890,
  },
];

const RelatedProducts: React.FC = () => {
  return (
    <section className="mt-20">
      <div className="flex items-center justify-between mb-8">
        <h2 className="text-2xl font-black text-[#111827]">You may also like</h2>
        <button className="flex items-center gap-1 text-[#6C2BFF] font-black text-sm hover:underline">
          View All <ChevronRight size={16} />
        </button>
      </div>

      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-6">
        {mockProducts.map((p, i) => (
          <ProductCardPLP key={i} {...p} />
        ))}
      </div>
    </section>
  );
};

export default RelatedProducts;
