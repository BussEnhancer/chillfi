import React, { useEffect, useState } from 'react';
import Header from '../../components/navigation/Header';
import TopBar from '../../components/navigation/TopBar';
import CategoryNav from '../../components/navigation/CategoryNav';
import Footer from '../../components/navigation/Footer';
import Container from '../../components/common/Container';
import Breadcrumb from '../../components/common/Breadcrumb';
import AccountSidebar from '../../components/profile/AccountSidebar';
import CheckoutTrustStrip from '../../sections/Checkout/CheckoutTrustStrip';
import WishlistSuggestions from '../../sections/Wishlist/WishlistSuggestions';
import WishlistSummary from '../../sections/Wishlist/WishlistSummary';
import WishlistPromo from '../../sections/Wishlist/WishlistPromo';
import { Share2, ShoppingBag, Heart, Loader2, Trash2 } from 'lucide-react';
import { apiGet, apiDelete } from '../../utils/api';
import { useStore } from '../../context/StoreContext';
import { friendlyError } from '../../utils/api';

interface ApiWishlistItem {
  id: string;
  product_id: string;
  name: string;
  price: number;
  old_price: number;
  rating: number;
  stock: number;
  status: string;
  image: string;
}

const WishlistPage: React.FC = () => {
  const { addToCart, cart } = useStore();
  const [items, setItems] = useState<ApiWishlistItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [removing, setRemoving] = useState<string | null>(null);

  const breadcrumbItems = [
    { label: 'My Account', href: '/account' },
    { label: 'Wishlist' }
  ];

  const loadWishlist = async () => {
    setLoading(true); setError('');
    try {
      const res = await apiGet<{ success: boolean; data: ApiWishlistItem[] }>('/wishlist');
      setItems(res.data || []);
    } catch (e: any) {
      setError(friendlyError(e, 'Failed to load wishlist'));
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { loadWishlist(); }, []);

  const handleRemove = async (id: string) => {
    setRemoving(id);
    try {
      await apiDelete(`/wishlist/${id}`);
      setItems(prev => prev.filter(i => i.id !== id));
    } catch {}
    setRemoving(null);
  };

  const handleMoveToCart = (item: ApiWishlistItem) => {
    addToCart({
      id: item.product_id,
      name: item.name,
      img: item.image,
      price: item.price,
      oldPrice: item.old_price || 0,
      brand: '',
      category: '',
      qty: 1,
    });
    handleRemove(item.id);
  };

  const handleMoveAllToCart = () => {
    items.filter(i => i.status !== 'Out of Stock').forEach(item => handleMoveToCart(item));
  };

  const stockLabel = (item: ApiWishlistItem): 'In Stock' | 'Low Stock' | 'Out of Stock' => {
    if (item.status === 'Out of Stock' || item.stock === 0) return 'Out of Stock';
    if (item.stock <= 5) return 'Low Stock';
    return 'In Stock';
  };

  return (
    <div className="min-h-screen bg-white font-['Poppins']">
      <TopBar />
      <Header />
      <CategoryNav />
      <Breadcrumb items={breadcrumbItems} />

      <Container className="py-10">
        <div className="flex flex-col md:flex-row items-center justify-between gap-6 mb-10">
          <div>
            <h1 className="text-3xl font-black text-[#111827] mb-1">
              My Wishlist <span className="text-gray-400 font-bold">({items.length})</span>
            </h1>
            <p className="text-sm font-bold text-gray-400 uppercase tracking-widest">Items you love, saved for later</p>
          </div>
          <div className="flex items-center gap-4">
            <button className="flex items-center gap-2 border-2 border-[#ECECEC] text-[#111827] px-6 py-2.5 rounded-xl font-black text-sm hover:border-[#FF6B2C] hover:text-[#FF6B2C] transition-all">
              <Share2 size={18} />
              Share Wishlist
            </button>
            <button
              onClick={handleMoveAllToCart}
              disabled={items.length === 0}
              className="flex items-center gap-2 bg-[#FF6B2C] text-white px-6 py-2.5 rounded-xl font-black text-sm hover:bg-[#E05520] shadow-lg shadow-[#FF6B2C]/20 transition-all disabled:opacity-50"
            >
              <ShoppingBag size={18} />
              Move All to Bag
            </button>
          </div>
        </div>

        <div className="flex flex-col lg:flex-row gap-10">
          <AccountSidebar activeId="wishlist" />

          <div className="flex-1 min-w-0">
            {loading ? (
              <div className="flex items-center justify-center py-20">
                <Loader2 size={32} className="animate-spin text-[#FF6B2C]" />
              </div>
            ) : error ? (
              <div className="py-16 text-center">
                <p className="text-red-500 font-bold mb-4">{error}</p>
                <button onClick={loadWishlist} className="text-[#FF6B2C] font-black text-sm hover:underline">Try again</button>
              </div>
            ) : items.length === 0 ? (
              <div className="py-20 text-center">
                <Heart size={48} className="mx-auto text-gray-200 mb-4" />
                <h3 className="text-lg font-black text-[#111827] mb-2">Your wishlist is empty</h3>
                <p className="text-sm font-bold text-gray-400">Save items you love to your wishlist</p>
              </div>
            ) : (
              <div className="space-y-4">
                {items.map(item => (
                  <div key={item.id} className="bg-white rounded-[20px] p-6 border border-[#ECECEC] hover:shadow-xl hover:border-[#FF6B2C]/10 transition-all group relative">
                    <div className="flex items-center gap-5">
                      <div className="w-20 h-20 rounded-xl overflow-hidden bg-[#F8F7FC] border border-[#ECECEC] shrink-0">
                        <img src={item.image} alt={item.name} className="w-full h-full object-cover" />
                      </div>
                      <div className="flex-1 min-w-0">
                        <p className="text-sm font-black text-[#111827] truncate mb-1">{item.name}</p>
                        <div className="flex items-center gap-3 mb-2">
                          <span className="text-lg font-black text-[#FF6B2C]">₹{Number(item.price).toLocaleString()}</span>
                          {item.old_price > item.price && (
                            <span className="text-xs text-gray-400 line-through">₹{Number(item.old_price).toLocaleString()}</span>
                          )}
                        </div>
                        <span className={`text-[10px] font-black uppercase tracking-wider px-2 py-0.5 rounded-full ${
                          stockLabel(item) === 'In Stock' ? 'bg-green-50 text-green-600' :
                          stockLabel(item) === 'Low Stock' ? 'bg-amber-50 text-amber-600' :
                          'bg-red-50 text-red-500'
                        }`}>
                          {stockLabel(item)}{item.stock > 0 && item.stock <= 5 ? ` — ${item.stock} left` : ''}
                        </span>
                      </div>
                      <div className="flex flex-col gap-2 shrink-0">
                        <button
                          onClick={() => handleMoveToCart(item)}
                          disabled={item.stock === 0 || item.status === 'Out of Stock'}
                          className="flex items-center gap-2 bg-[#FF6B2C] text-white px-4 py-2 rounded-xl font-black text-xs hover:bg-[#E05520] disabled:opacity-50 disabled:cursor-not-allowed"
                        >
                          <ShoppingBag size={14} />
                          Add to Cart
                        </button>
                        <button
                          onClick={() => handleRemove(item.id)}
                          disabled={removing === item.id}
                          className="flex items-center gap-2 text-red-400 hover:text-red-600 text-xs font-black justify-center disabled:opacity-50"
                        >
                          {removing === item.id ? <Loader2 size={12} className="animate-spin" /> : <Trash2 size={12} />}
                          Remove
                        </button>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>

          <div className="lg:w-[320px] shrink-0 space-y-8">
            <WishlistSuggestions />
            <WishlistSummary
              totalItems={items.length}
              totalValue={items.reduce((s, i) => s + Number(i.price), 0)}
              itemsInBag={items.filter(i => cart.some(c => c.id === i.product_id)).length}
            />
            <WishlistPromo />
          </div>
        </div>

        <CheckoutTrustStrip />
      </Container>

      <Footer />
    </div>
  );
};

export default WishlistPage;
