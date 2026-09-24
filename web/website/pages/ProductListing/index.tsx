import React, { useEffect, useState, useCallback } from 'react';
import { useSearchParams } from 'react-router-dom';
import Header from '../../components/navigation/Header';
import TopBar from '../../components/navigation/TopBar';
import CategoryNav from '../../components/navigation/CategoryNav';
import Footer from '../../components/navigation/Footer';
import Container from '../../components/common/Container';
import Breadcrumb from '../../components/common/Breadcrumb';
import ProductFilterSidebar from '../../components/navigation/ProductFilterSidebar';
import PLP_HeroBanner from '../../sections/ProductListing/PLP_HeroBanner';
import ProductCardPLP from '../../components/product/ProductCardPLP';
import { apiGet } from '../../utils/api';
import { ChevronDown, Loader2, PackageOpen, ChevronLeft, ChevronRight } from 'lucide-react';

interface ApiProduct {
  id: string;
  name: string;
  price: number;
  old_price: number;
  rating: number;
  review_count: number;
  primary_image?: string;
  brand_name?: string;
  category_name?: string;
  status: string;
}

const SORT_OPTIONS = [
  { label: 'Newest', value: 'newest' },
  { label: 'Price: Low to High', value: 'price_asc' },
  { label: 'Price: High to Low', value: 'price_desc' },
  { label: 'Top Rated', value: 'rating' },
];

const PAGE_SIZE = 20;

const ProductListingPage: React.FC = () => {
  const [searchParams, setSearchParams] = useSearchParams();
  const category = searchParams.get('category') || '';
  const brand = searchParams.get('brand') || '';
  const q = searchParams.get('q') || '';
  const sort = searchParams.get('sort') || 'newest';
  const page = Number(searchParams.get('page') || 1);
  const minPrice = searchParams.get('min_price') ? Number(searchParams.get('min_price')) : undefined;
  const maxPrice = searchParams.get('max_price') ? Number(searchParams.get('max_price')) : undefined;

  const [products, setProducts] = useState<ApiProduct[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(true);

  const setParam = (key: string, value: string) => {
    const p = new URLSearchParams(searchParams);
    if (value) p.set(key, value); else p.delete(key);
    if (key !== 'page') p.delete('page');
    setSearchParams(p);
  };

  const setPage = (n: number) => {
    const p = new URLSearchParams(searchParams);
    p.set('page', String(n));
    setSearchParams(p);
  };

  const setPriceRange = (min: number, max: number) => {
    const p = new URLSearchParams(searchParams);
    if (min > 0) p.set('min_price', String(min)); else p.delete('min_price');
    if (max < 100000) p.set('max_price', String(max)); else p.delete('max_price');
    p.delete('page');
    setSearchParams(p);
  };

  const fetchProducts = useCallback(async () => {
    setLoading(true);
    try {
      const params = new URLSearchParams();
      params.set('page', String(page));
      params.set('limit', String(PAGE_SIZE));
      if (category) params.set('category', category);
      if (brand) params.set('brand', brand);
      if (q) params.set('search', q);
      if (minPrice !== undefined) params.set('min_price', String(minPrice));
      if (maxPrice !== undefined) params.set('max_price', String(maxPrice));

      const [sortField, sortDir] = sort === 'price_asc'
        ? ['price', 'ASC']
        : sort === 'price_desc'
        ? ['price', 'DESC']
        : sort === 'rating'
        ? ['rating', 'DESC']
        : ['newest', 'DESC'];
      params.set('sort', sortField);
      params.set('order', sortDir);

      const res = await apiGet<{ success: boolean; data: { products: ApiProduct[]; total: number } }>(
        `/products?${params.toString()}`
      );
      setProducts(res.data.products || []);
      setTotal(res.data.total || 0);
    } catch {
      setProducts([]);
    } finally {
      setLoading(false);
    }
  }, [category, brand, q, sort, page, minPrice, maxPrice]);

  useEffect(() => { fetchProducts(); }, [fetchProducts]);

  const totalPages = Math.max(1, Math.ceil(total / PAGE_SIZE));
  const categoryLabel = category ? (products[0]?.category_name || 'Category') : '';

  const breadcrumbItems = [
    ...(categoryLabel ? [{ label: categoryLabel }] : [{ label: 'All Products' }]),
  ];

  const discount = (p: ApiProduct) =>
    p.old_price > p.price
      ? `-${Math.round((p.old_price - p.price) / p.old_price * 100)}%`
      : undefined;

  return (
    <div className="min-h-screen bg-white font-['Poppins']">
      <TopBar />
      <Header />
      <CategoryNav />
      <Breadcrumb items={breadcrumbItems} />

      <Container className="flex gap-10 py-10">
        <ProductFilterSidebar
          selectedCategory={category}
          onCategoryChange={v => setParam('category', v)}
          selectedBrand={brand}
          onBrandChange={v => setParam('brand', v)}
          minPrice={minPrice}
          maxPrice={maxPrice}
          onPriceChange={setPriceRange}
        />

        <div className="flex-1">
          <PLP_HeroBanner />

          {/* Sort bar */}
          <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-8">
            <div>
              <h2 className="text-2xl font-black text-[#111827] mb-1">
                {categoryLabel || (q ? `"${q}"` : 'All Products')}
              </h2>
              <p className="text-[12px] font-bold text-gray-400 uppercase tracking-widest">
                {loading ? 'Loading…' : `Showing ${Math.min((page - 1) * PAGE_SIZE + 1, total)}–${Math.min(page * PAGE_SIZE, total)} of ${total} products`}
              </p>
            </div>
            <div className="flex items-center gap-3">
              <span className="text-sm font-bold text-gray-500">Sort:</span>
              <div className="relative">
                <select
                  value={sort}
                  onChange={e => setParam('sort', e.target.value)}
                  className="appearance-none bg-white border border-[#ECECEC] rounded-xl pl-4 pr-10 py-2 text-sm font-black text-[#111827] outline-none focus:border-[#FF6B2C] cursor-pointer"
                >
                  {SORT_OPTIONS.map(o => (
                    <option key={o.value} value={o.value}>{o.label}</option>
                  ))}
                </select>
                <ChevronDown size={16} className="absolute right-3 top-1/2 -translate-y-1/2 text-[#FF6B2C] pointer-events-none" />
              </div>
              {(category || brand || q || minPrice !== undefined || maxPrice !== undefined) && (
                <button
                  onClick={() => setSearchParams(new URLSearchParams())}
                  className="text-[11px] font-black text-[#FF6B2C] uppercase tracking-widest hover:underline"
                >
                  Clear All
                </button>
              )}
            </div>
          </div>

          {/* Active filter chips */}
          {(category || brand || q || minPrice !== undefined || maxPrice !== undefined) && (
            <div className="flex flex-wrap gap-2 mb-6">
              {category && (
                <span className="flex items-center gap-2 bg-[#FFF3ED] text-[#FF6B2C] px-3 py-1.5 rounded-full text-xs font-black">
                  {categoryLabel}
                  <button onClick={() => setParam('category', '')} className="hover:text-red-500">×</button>
                </span>
              )}
              {brand && (
                <span className="flex items-center gap-2 bg-[#FFF3ED] text-[#FF6B2C] px-3 py-1.5 rounded-full text-xs font-black">
                  {brand}
                  <button onClick={() => setParam('brand', '')} className="hover:text-red-500">×</button>
                </span>
              )}
              {q && (
                <span className="flex items-center gap-2 bg-[#FFF3ED] text-[#FF6B2C] px-3 py-1.5 rounded-full text-xs font-black">
                  Search: {q}
                  <button onClick={() => setParam('q', '')} className="hover:text-red-500">×</button>
                </span>
              )}
              {(minPrice !== undefined || maxPrice !== undefined) && (
                <span className="flex items-center gap-2 bg-[#FFF3ED] text-[#FF6B2C] px-3 py-1.5 rounded-full text-xs font-black">
                  ₹{minPrice ?? 0} – ₹{maxPrice ?? 100000}
                  <button onClick={() => setPriceRange(0, 100000)} className="hover:text-red-500">×</button>
                </span>
              )}
            </div>
          )}

          {/* Grid */}
          {loading ? (
            <div className="flex items-center justify-center py-32">
              <Loader2 size={36} className="animate-spin text-[#FF6B2C]" />
            </div>
          ) : products.length === 0 ? (
            <div className="py-32 text-center">
              <PackageOpen size={48} className="mx-auto text-gray-200 mb-4" />
              <h3 className="text-xl font-black text-[#111827] mb-2">No products found</h3>
              <p className="text-sm font-bold text-gray-400">Try adjusting your filters or search query.</p>
            </div>
          ) : (
            <div className="grid grid-cols-2 md:grid-cols-3 xl:grid-cols-4 gap-6">
              {products.map(p => (
                <ProductCardPLP
                  key={p.id}
                  id={p.id}
                  image={p.primary_image || ''}
                  name={p.name}
                  brand={p.brand_name || ''}
                  price={Number(p.price)}
                  oldPrice={p.old_price ? Number(p.old_price) : undefined}
                  discount={discount(p)}
                  rating={Number(p.rating || 0)}
                  reviews={Number(p.review_count || 0)}
                  isBestSeller={Number(p.review_count) > 20000}
                />
              ))}
            </div>
          )}

          {/* Pagination */}
          {!loading && totalPages > 1 && (
            <div className="flex items-center justify-center gap-3 mt-12">
              <button
                onClick={() => setPage(page - 1)}
                disabled={page <= 1}
                className="w-10 h-10 rounded-xl border border-[#ECECEC] flex items-center justify-center hover:border-[#FF6B2C] hover:text-[#FF6B2C] disabled:opacity-30 disabled:cursor-not-allowed transition-all"
              >
                <ChevronLeft size={18} />
              </button>
              {Array.from({ length: Math.min(totalPages, 7) }, (_, i) => {
                const n = totalPages <= 7 ? i + 1 : page <= 4 ? i + 1 : page >= totalPages - 3 ? totalPages - 6 + i : page - 3 + i;
                return (
                  <button
                    key={n}
                    onClick={() => setPage(n)}
                    className={`w-10 h-10 rounded-xl font-black text-sm transition-all ${n === page ? 'bg-[#FF6B2C] text-white shadow-lg shadow-[#FF6B2C]/20' : 'border border-[#ECECEC] hover:border-[#FF6B2C] hover:text-[#FF6B2C]'}`}
                  >
                    {n}
                  </button>
                );
              })}
              <button
                onClick={() => setPage(page + 1)}
                disabled={page >= totalPages}
                className="w-10 h-10 rounded-xl border border-[#ECECEC] flex items-center justify-center hover:border-[#FF6B2C] hover:text-[#FF6B2C] disabled:opacity-30 disabled:cursor-not-allowed transition-all"
              >
                <ChevronRight size={18} />
              </button>
            </div>
          )}
        </div>
      </Container>

      <Footer />
    </div>
  );
};

export default ProductListingPage;
