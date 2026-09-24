import React, { useEffect, useState, useCallback } from 'react';
import { useSearchParams, Link } from 'react-router-dom';
import Header from '../../components/navigation/Header';
import TopBar from '../../components/navigation/TopBar';
import CategoryNav from '../../components/navigation/CategoryNav';
import Footer from '../../components/navigation/Footer';
import Container from '../../components/common/Container';
import ProductCardPLP from '../../components/product/ProductCardPLP';
import { apiGet } from '../../utils/api';
import { Loader2, PackageOpen, Search } from 'lucide-react';

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
}

interface SearchResponse {
  products: ApiProduct[];
  total: number;
  query: string;
}

const SearchPage: React.FC = () => {
  const [searchParams, setSearchParams] = useSearchParams();
  const q = searchParams.get('q') || '';
  const [inputValue, setInputValue] = useState(q);
  const [results, setResults] = useState<ApiProduct[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(false);

  const doSearch = useCallback(async (query: string) => {
    if (!query.trim()) { setResults([]); setTotal(0); return; }
    setLoading(true);
    try {
      const res = await apiGet<{ success: boolean; data: SearchResponse }>(
        `/search?q=${encodeURIComponent(query)}&limit=40`
      );
      setResults(res.data.products || []);
      setTotal(res.data.total || 0);
    } catch {
      setResults([]);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { doSearch(q); }, [q, doSearch]);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (inputValue.trim()) setSearchParams({ q: inputValue.trim() });
  };

  const discount = (p: ApiProduct) =>
    p.old_price > p.price
      ? `-${Math.round((p.old_price - p.price) / p.old_price * 100)}%`
      : undefined;

  return (
    <div className="min-h-screen bg-white font-['Poppins']">
      <TopBar />
      <Header />
      <CategoryNav />

      <Container className="py-10">
        {/* Search input */}
        <form onSubmit={handleSubmit} className="flex gap-3 max-w-2xl mb-10">
          <div className="flex-1 min-w-0 flex items-center gap-3 bg-gray-50 border border-[#ECECEC] rounded-2xl px-4 sm:px-5 py-3.5 focus-within:border-[#FF6B2C] transition-all">
            <Search size={18} className="text-gray-400 shrink-0" />
            <input
              type="text"
              value={inputValue}
              onChange={e => setInputValue(e.target.value)}
              placeholder="Search for products, brands and more..."
              className="flex-1 bg-transparent outline-none text-sm font-bold"
              autoFocus
            />
          </div>
          <button
            type="submit"
            className="shrink-0 bg-[#FF6B2C] text-white px-5 sm:px-8 py-3.5 rounded-2xl font-black shadow-lg shadow-[#FF6B2C]/20 hover:scale-105 active:scale-95 transition-all"
          >
            Search
          </button>
        </form>

        {q && (
          <p className="text-[11px] font-black text-gray-400 uppercase tracking-widest mb-8">
            {loading ? 'Searching…' : `${total} result${total !== 1 ? 's' : ''} for "${q}"`}
          </p>
        )}

        {loading ? (
          <div className="flex items-center justify-center py-32">
            <Loader2 size={36} className="animate-spin text-[#FF6B2C]" />
          </div>
        ) : !q ? (
          <div className="py-32 text-center">
            <Search size={48} className="mx-auto text-gray-200 mb-4" />
            <h3 className="text-xl font-black text-[#111827] mb-2">What are you looking for?</h3>
            <p className="text-sm font-bold text-gray-400 mb-6">Search for products, brands or categories</p>
            <Link to="/products" className="inline-block bg-[#FF6B2C] text-white px-8 py-3 rounded-xl font-black shadow-lg shadow-[#FF6B2C]/20">
              Browse All Products
            </Link>
          </div>
        ) : results.length === 0 ? (
          <div className="py-32 text-center">
            <PackageOpen size={48} className="mx-auto text-gray-200 mb-4" />
            <h3 className="text-xl font-black text-[#111827] mb-2">No results for "{q}"</h3>
            <p className="text-sm font-bold text-gray-400 mb-6">Try different keywords or browse all products.</p>
            <Link to="/products" className="inline-block bg-[#FF6B2C] text-white px-8 py-3 rounded-xl font-black shadow-lg shadow-[#FF6B2C]/20">
              Browse All Products
            </Link>
          </div>
        ) : (
          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-6">
            {results.map(p => (
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
              />
            ))}
          </div>
        )}
      </Container>

      <Footer />
    </div>
  );
};

export default SearchPage;
