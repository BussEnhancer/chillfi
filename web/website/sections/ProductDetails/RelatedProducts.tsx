import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { ChevronRight } from 'lucide-react';
import ProductCardPLP from '../../components/product/ProductCardPLP';
import { apiGet } from '../../utils/api';
import { productDiscount } from '../../context/StoreContext';

interface ApiProduct {
  id: string;
  name: string;
  price: number;
  old_price: number;
  rating: number;
  review_count: number;
  primary_image: string;
  brand_name: string;
  status: string;
}

interface RelatedProductsProps {
  currentId?: string;
  categoryId?: string;
}

const RelatedProducts: React.FC<RelatedProductsProps> = ({ currentId, categoryId }) => {
  const [products, setProducts] = useState<ApiProduct[]>([]);

  useEffect(() => {
    const url = categoryId
      ? `/products?category_id=${categoryId}&limit=7`
      : `/products/trending?limit=7`;

    apiGet<{ success: boolean; data: { products?: ApiProduct[]; trending?: ApiProduct[] } }>(url)
      .then(res => {
        const list = res.data.products || res.data.trending || (Array.isArray(res.data) ? res.data as unknown as ApiProduct[] : []);
        setProducts(list.filter((p: ApiProduct) => p.id !== currentId && p.status === 'Active').slice(0, 6));
      })
      .catch(() => {});
  }, [currentId, categoryId]);

  if (products.length === 0) return null;

  const discount = (p: ApiProduct) =>
    p.old_price > p.price
      ? `-${Math.round((p.old_price - p.price) / p.old_price * 100)}%`
      : undefined;

  return (
    <section className="mt-20">
      <div className="flex items-center justify-between mb-8">
        <h2 className="text-2xl font-black text-[#111827]">You may also like</h2>
        <Link to="/products" className="flex items-center gap-1 text-[#FF6B2C] font-black text-sm hover:underline">
          View All <ChevronRight size={16} />
        </Link>
      </div>
      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-6">
        {products.map(p => (
          <ProductCardPLP
            key={p.id}
            id={p.id}
            image={p.primary_image}
            name={p.name}
            brand={p.brand_name}
            price={p.price}
            oldPrice={p.old_price || undefined}
            discount={discount(p) || undefined}
            rating={p.rating}
            reviews={p.review_count}
          />
        ))}
      </div>
    </section>
  );
};

export default RelatedProducts;
