import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import Container from '../../components/common/Container';
import ProductCard from '../../components/product/ProductCard';

export interface ApiFlashProduct {
  id: string;
  name: string;
  price: number;
  old_price: number;
  discount_pct?: number;
  primary_image?: string;
  flash_sale_ends_at?: string;
  rating?: number;
  review_count?: number;
}

interface FlashSaleProps {
  products?: ApiFlashProduct[];
}

const useCountdown = (endsAt?: string) => {
  // Only count down to a real end time set by the admin — never a made-up timer.
  const target = endsAt ? new Date(endsAt).getTime() : 0;
  const [remaining, setRemaining] = useState(() => Math.max(0, target - Date.now()));

  useEffect(() => {
    const t = setInterval(() => setRemaining(Math.max(0, target - Date.now())), 1000);
    return () => clearInterval(t);
  }, [target]);

  const h = String(Math.floor(remaining / 3600000)).padStart(2, '0');
  const m = String(Math.floor((remaining % 3600000) / 60000)).padStart(2, '0');
  const s = String(Math.floor((remaining % 60000) / 1000)).padStart(2, '0');
  return { h, m, s };
};

const FlashSale: React.FC<FlashSaleProps> = ({ products }) => {
  // Earliest real end time among the flash products (if the admin set one)
  const endDate = (products || []).map((p) => p.flash_sale_ends_at).filter(Boolean).sort()[0];
  const { h, m, s } = useCountdown(endDate);

  const items = products && products.length > 0 ? products : null;

  return (
    <section className="py-16 bg-white border-y border-gray-100">
      <Container className="flex flex-col lg:flex-row gap-12">
        <div className="lg:w-[350px] shrink-0">
          <div className="flex items-center gap-3 mb-4">
            <h2 className="text-4xl font-black text-gray-900">Flash Sale</h2>
            <span className="text-3xl">⚡</span>
          </div>
          <p className="text-gray-500 font-medium mb-10 leading-relaxed">
            {endDate ? 'Limited time offer! Grab your favorite products at unbeatable prices.' : 'Great prices on selected products.'}
          </p>

          {endDate && <div className="flex gap-4 mb-10">
            {[{ val: h, unit: 'Hours' }, { val: m, unit: 'Min' }, { val: s, unit: 'Sec' }].map((t, i) => (
              <div key={i} className="flex flex-col items-center">
                <div className="w-16 h-16 bg-[#121212] rounded-2xl flex items-center justify-center text-white text-2xl font-black mb-2 shadow-lg shadow-gray-200">
                  {t.val}
                </div>
                <span className="text-[10px] font-bold uppercase tracking-widest text-gray-400">{t.unit}</span>
              </div>
            ))}
          </div>}

          <Link to="/offers" className="inline-block bg-[#FF6B2C] text-white px-8 py-4 rounded-xl font-bold shadow-xl shadow-[#FF6B2C]/20 hover:scale-105 transition-all">
            Shop All Deals
          </Link>
        </div>

        <div className="flex-1 grid grid-cols-2 md:grid-cols-4 gap-6">
          {items ? items.slice(0, 4).map(p => {
            const discount = p.discount_pct
              ? `-${Math.round(Number(p.discount_pct))}%`
              : p.old_price > p.price
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
                rating={Number(p.rating) || 0}
                reviews={Number(p.review_count) || 0}
              />
            );
          }) : (
            <div className="col-span-4 py-10 text-center text-gray-400 font-bold text-sm">
              No flash sale products right now. Check back soon!
            </div>
          )}
        </div>
      </Container>
    </section>
  );
};

export default FlashSale;
