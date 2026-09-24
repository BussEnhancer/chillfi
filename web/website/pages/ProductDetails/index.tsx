import React, { useEffect, useState } from 'react';
import { useParams, Link } from 'react-router-dom';
import Header from '../../components/navigation/Header';
import TopBar from '../../components/navigation/TopBar';
import CategoryNav from '../../components/navigation/CategoryNav';
import Footer from '../../components/navigation/Footer';
import Container from '../../components/common/Container';
import Breadcrumb from '../../components/common/Breadcrumb';

import ProductGallery from '../../components/product/ProductGallery';
import OfferCard from '../../components/product/OfferCard';
import SellerCard from '../../components/product/SellerCard';
import ProductTabs from '../../components/common/ProductTabs';
import DeliveryActionCard from '../../sections/ProductDetails/DeliveryActionCard';
import RelatedProducts from '../../sections/ProductDetails/RelatedProducts';
import Badge from '../../components/common/Badge';

import { Star, Loader2, PackageOpen } from 'lucide-react';
import { apiGet, apiPost } from '../../utils/api';
import { useStore } from '../../context/StoreContext';

interface ApiProduct {
  id: string;
  name: string;
  description: string;
  price: number;
  old_price: number;
  stock: number;
  status: string;
  rating: number;
  review_count: number;
  brand_name: string;
  brand_id: string;
  category_name: string;
  category_id: string;
  is_featured: boolean;
  is_flash_sale: boolean;
  images: { url: string; is_primary: boolean }[];
}

const ProductDetailsPage: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const { isLoggedIn } = useStore();

  const [product, setProduct] = useState<ApiProduct | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [wishlisted, setWishlisted] = useState(false);
  const [checkingWishlist, setCheckingWishlist] = useState(false);

  useEffect(() => {
    if (!id) return;
    setLoading(true); setError('');
    apiGet<{ success: boolean; data: { product: ApiProduct } }>(`/products/${id}`)
      .then(res => {
        setProduct(res.data.product);
        // Log recently viewed if logged in
        if (isLoggedIn) {
          apiPost(`/products/${id}/recently-viewed`, {}).catch(() => {});
        }
      })
      .catch(e => setError(e.message || 'Product not found'))
      .finally(() => setLoading(false));
  }, [id, isLoggedIn]);

  // Check wishlist status
  useEffect(() => {
    if (!id || !isLoggedIn) return;
    setCheckingWishlist(true);
    apiGet<{ success: boolean; data: { wishlisted: boolean } }>(`/wishlist/check/${id}`)
      .then(res => setWishlisted(res.data.wishlisted))
      .catch(() => {})
      .finally(() => setCheckingWishlist(false));
  }, [id, isLoggedIn]);

  const handleWishlistToggle = async () => {
    if (!id) return;
    try {
      const res = await apiPost<{ success: boolean; data: { wishlisted: boolean } }>(
        '/wishlist/toggle', { product_id: id }
      );
      setWishlisted(res.data.wishlisted);
    } catch {}
  };

  const images = product?.images?.map(i => i.url) || [];
  const primaryImage = product?.images?.find(i => i.is_primary)?.url || images[0] || '';
  const discount = product && product.old_price > product.price
    ? Math.round((product.old_price - product.price) / product.old_price * 100)
    : 0;

  const breadcrumbItems = [
    { label: 'Products', href: '/products' },
    ...(product?.category_name ? [{ label: product.category_name, href: `/products?category=${product.category_id}` }] : []),
    { label: product?.name || '...' },
  ];

  if (loading) return (
    <div className="min-h-screen bg-white font-['Poppins']">
      <TopBar /><Header /><CategoryNav />
      <div className="flex items-center justify-center py-40">
        <Loader2 size={40} className="animate-spin text-[#FF6B2C]" />
      </div>
      <Footer />
    </div>
  );

  if (error || !product) return (
    <div className="min-h-screen bg-white font-['Poppins']">
      <TopBar /><Header /><CategoryNav />
      <Container className="py-32 text-center">
        <PackageOpen size={48} className="mx-auto text-gray-200 mb-4" />
        <h2 className="text-2xl font-black text-[#111827] mb-2">Product not found</h2>
        <p className="text-gray-400 font-bold mb-6">{error}</p>
        <Link to="/products" className="inline-block bg-[#FF6B2C] text-white px-8 py-3 rounded-xl font-black shadow-lg shadow-[#FF6B2C]/20">
          Browse Products
        </Link>
      </Container>
      <Footer />
    </div>
  );

  const productForCart = {
    id: product.id,
    name: product.name,
    price: Number(product.price),
    oldPrice: Number(product.old_price || 0),
    stock: product.stock,
    img: primaryImage,
    brand: product.brand_name || '',
    category: product.category_name || '',
  };

  return (
    <div className="min-h-screen bg-white font-['Poppins']">
      <TopBar />
      <Header />
      <CategoryNav />
      <Breadcrumb items={breadcrumbItems} />

      <Container className="py-10">
        <div className="flex flex-col lg:flex-row gap-12">
          {/* Left: Gallery */}
          <div className="lg:w-[50%]">
            <ProductGallery
              images={images}
              isWishlisted={wishlisted}
              onWishlistToggle={handleWishlistToggle}
            />

            {/* Description — desktop */}
            <div className="hidden lg:block mt-20">
              <ProductTabs
                productId={id}
                reviewCount={product.review_count}
                description={product.description}
                specs={[
                  { label: 'Brand', value: product.brand_name || '—' },
                  { label: 'Category', value: product.category_name || '—' },
                  { label: 'Rating', value: `${Number(product.rating).toFixed(1)} ★ (${Number(product.review_count || 0).toLocaleString()} ratings)` },
                  { label: 'Stock', value: `${product.stock} units available` },
                  ...(product.is_featured ? [{ label: 'Badge', value: 'Featured Product' }] : []),
                  ...(product.is_flash_sale ? [{ label: 'Offer', value: 'Flash Sale Active' }] : []),
                ]}
                isLoggedIn={isLoggedIn}
              />
            </div>
          </div>

          {/* Center: Product Info */}
          <div className="flex-1">
            <div className="mb-6">
              {product.is_featured && <Badge text="Featured" className="bg-green-600 inline-block mb-3" />}
              {product.is_flash_sale && <Badge text="Flash Sale" className="bg-red-500 inline-block mb-3 ml-2" />}
              <h1 className="text-2xl md:text-3xl font-black text-[#111827] mb-3">{product.name}</h1>

              <div className="flex items-center gap-4 mb-2">
                <div className="flex items-center gap-1 bg-green-50 px-2.5 py-1 rounded-lg">
                  <span className="text-sm font-black text-green-600">{Number(product.rating).toFixed(1)}</span>
                  <Star size={14} className="fill-green-600 text-green-600" />
                </div>
                <span className="text-sm font-bold text-gray-400">
                  ({Number(product.review_count || 0).toLocaleString()} Ratings)
                </span>
                {product.brand_name && (
                  <span className="text-xs font-black text-gray-400 bg-gray-50 px-2 py-1 rounded-lg">
                    by {product.brand_name}
                  </span>
                )}
              </div>
            </div>

            {/* Pricing */}
            <div className="mb-8 p-6 bg-[#F8F7FC] rounded-3xl border border-[#ECECEC]">
              <div className="flex items-baseline gap-4 mb-1">
                <span className="text-4xl font-black text-[#111827]">₹{Number(product.price).toLocaleString()}</span>
                {product.old_price > product.price && (
                  <>
                    <span className="text-lg text-gray-400 line-through font-bold">₹{Number(product.old_price).toLocaleString()}</span>
                    <Badge text={`-${discount}% OFF`} className="bg-[#FF4D4F] text-sm" />
                  </>
                )}
              </div>
              <p className="text-[11px] font-bold text-gray-400 uppercase tracking-widest">Inclusive of all taxes</p>
              {product.old_price > product.price && (
                <p className="text-xs font-black text-green-600 mt-1">
                  You save ₹{(Number(product.old_price) - Number(product.price)).toLocaleString()}
                </p>
              )}
            </div>

            {/* Description — mobile (kept as preview above the tabs) */}
            <div className="lg:hidden mb-6">
              <p className="text-sm font-medium text-gray-600 leading-relaxed line-clamp-3">{product.description}</p>
            </div>

            {/* Offers */}
            <div className="mb-8">
              <h3 className="text-[11px] font-black text-gray-500 uppercase tracking-widest mb-4">Shop with confidence</h3>
              <div className="flex flex-wrap gap-4">
                <OfferCard title="Secure Payments" desc="Pay via PhonePe — UPI, cards or netbanking." />
                <OfferCard title="Pay on Delivery" desc="Available on eligible pincodes." />
                <OfferCard title="7-Day Returns" desc="Return within 7 days of delivery." />
              </div>
            </div>

            <SellerCard />

            {/* Specs — mobile */}
            <div className="lg:hidden mt-6">
              <ProductTabs
                productId={id}
                reviewCount={product.review_count}
                description={product.description}
                specs={[
                  { label: 'Brand', value: product.brand_name || '—' },
                  { label: 'Category', value: product.category_name || '—' },
                  { label: 'Rating', value: `${Number(product.rating).toFixed(1)} ★ (${Number(product.review_count || 0).toLocaleString()} ratings)` },
                  { label: 'Stock', value: `${product.stock} units available` },
                  ...(product.is_featured ? [{ label: 'Badge', value: 'Featured Product' }] : []),
                  ...(product.is_flash_sale ? [{ label: 'Offer', value: 'Flash Sale Active' }] : []),
                ]}
                isLoggedIn={isLoggedIn}
              />
            </div>
          </div>

          {/* Right: Actions */}
          <div className="lg:w-[320px] shrink-0">
            <DeliveryActionCard
              product={productForCart}
              isWishlisted={wishlisted}
              onWishlistToggle={handleWishlistToggle}
            />
          </div>
        </div>

        <RelatedProducts currentId={product.id} categoryId={product.category_id} />
      </Container>

      <Footer />
    </div>
  );
};

export default ProductDetailsPage;
