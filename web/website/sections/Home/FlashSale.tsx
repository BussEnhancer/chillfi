import React from 'react';
import Container from '../../components/common/Container';
import ProductCard from '../../components/product/ProductCard';

const products = [
  {
    image: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&q=80&w=400',
    name: 'Fastrack Men Black Analog Watch',
    price: 2495,
    oldPrice: 3500,
    discount: '-30%',
    rating: 4.5,
    reviews: 1250,
  },
  {
    image: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&q=80&w=400',
    name: 'Puma Smashic Unisex Sneakers',
    price: 2299,
    oldPrice: 4499,
    discount: '-45%',
    rating: 4.8,
    reviews: 2100,
  },
  {
    image: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&q=80&w=400',
    name: 'boAt Airdopes 141 Wireless Earbuds',
    price: 1299,
    oldPrice: 2990,
    discount: '-55%',
    rating: 4.3,
    reviews: 850,
  },
  {
    image: 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?auto=format&fit=crop&q=80&w=400',
    name: 'Lavie Women Green Satchel Bag',
    price: 1799,
    oldPrice: 3999,
    discount: '-20%',
    rating: 4.2,
    reviews: 420,
  },
];

const FlashSale: React.FC = () => {
  return (
    <section className="py-16 bg-white border-y border-gray-100">
      <Container className="flex flex-col lg:flex-row gap-12">
        {/* Left Side: Info */}
        <div className="lg:w-[350px] shrink-0">
          <div className="flex items-center gap-3 mb-4">
             <h2 className="text-4xl font-black text-gray-900">Flash Sale</h2>
             <span className="text-3xl">⚡</span>
          </div>
          <p className="text-gray-500 font-medium mb-10 leading-relaxed">
            Limited time offer! Grab your favorite products at unbeatable prices.
          </p>

          <div className="flex gap-4 mb-10">
            {[
              { val: '02', unit: 'Hours' },
              { val: '45', unit: 'Min' },
              { val: '30', unit: 'Sec' }
            ].map((t, i) => (
              <div key={i} className="flex flex-col items-center">
                <div className="w-16 h-16 bg-[#121212] rounded-2xl flex items-center justify-center text-white text-2xl font-black mb-2 shadow-lg shadow-gray-200">
                  {t.val}
                </div>
                <span className="text-[10px] font-bold uppercase tracking-widest text-gray-400">{t.unit}</span>
              </div>
            ))}
          </div>

          <button className="bg-[#6C2BFF] text-white px-8 py-4 rounded-xl font-bold shadow-xl shadow-[#6C2BFF]/20 hover:scale-105 transition-all">
            Shop All Deals
          </button>
        </div>

        {/* Right Side: Grid */}
        <div className="flex-1 grid grid-cols-2 md:grid-cols-4 gap-6">
          {products.map((p, i) => (
            <ProductCard key={i} {...p} />
          ))}
        </div>
      </Container>
    </section>
  );
};

export default FlashSale;
