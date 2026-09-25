import React, { useEffect, useState } from 'react';
import { apiGet } from '../../utils/api';
import { Link } from 'react-router-dom';
import Header from '../../components/navigation/Header';
import TopBar from '../../components/navigation/TopBar';
import CategoryNav from '../../components/navigation/CategoryNav';
import Footer from '../../components/navigation/Footer';
import Container from '../../components/common/Container';
import TrustStripSmall from '../../components/common/TrustStripSmall';
import ProductCardPLP from '../../components/product/ProductCardPLP';
import { ChevronRight, Sparkles, Truck, RotateCcw, ShieldCheck, Headphones, Trash2, Plus, Minus } from 'lucide-react';
import { useStore, productDiscount } from '../../context/StoreContext';

const CartPage: React.FC = () => {
  const { cart, products, removeFromCart, updateCartQty, cartTotal, cartCount } = useStore();

  const savings = cart.reduce((s, i) => s + (i.oldPrice - i.price) * i.qty, 0);

  // Same rules the server uses when the order is placed (pincode-specific rules are applied at checkout).
  const [pricing, setPricing] = useState({ freeEnabled: true, threshold: 499, fee: 49, gstRate: 18 });
  useEffect(() => {
    apiGet<{ data: { free_shipping_enabled: boolean; free_shipping_threshold: number; standard_shipping_fee: number; gst_rate: number } }>('/app-config')
      .then((r) => setPricing({
        freeEnabled: r.data.free_shipping_enabled !== false,
        threshold: Number(r.data.free_shipping_threshold ?? 499),
        fee: Number(r.data.standard_shipping_fee ?? 49),
        gstRate: Number(r.data.gst_rate ?? 18),
      }))
      .catch(() => { /* keep defaults */ });
  }, []);
  const deliveryFee = cartTotal === 0 || (pricing.freeEnabled && cartTotal >= pricing.threshold) ? 0 : pricing.fee;
  // Prices are GST-inclusive: GST is shown as the part already inside the price, never added.
  const gst = Math.round((cartTotal * pricing.gstRate / (100 + pricing.gstRate)) * 100) / 100;
  const estimatedTotal = cartTotal + deliveryFee;
  const recommendations = products.filter(p => p.status === 'Active' && !cart.find(c => c.id === p.id)).slice(0, 4);

  return (
    <div className="min-h-screen bg-white font-['Poppins']">
      <TopBar />
      <Header />
      <CategoryNav />

      <Container className="py-10">
        <div className="flex items-center justify-between mb-8">
          <div>
            <h1 className="text-3xl font-black text-[#111827] mb-2">My Cart <span className="text-gray-400 font-bold">({cartCount} Item{cartCount !== 1 ? 's' : ''})</span></h1>
            {savings > 0 && (
              <div className="flex items-center gap-2 bg-green-50 px-4 py-2 rounded-full border border-green-100">
                <Sparkles size={14} className="text-green-600" />
                <span className="text-xs font-black text-green-600 uppercase tracking-wider">You are saving ₹{savings.toLocaleString()} on this order</span>
              </div>
            )}
          </div>
          <div className="hidden lg:block"><TrustStripSmall /></div>
        </div>

        {cart.length === 0 ? (
          <div className="py-24 text-center">
            <p className="text-5xl mb-4">🛒</p>
            <h2 className="text-2xl font-black text-[#111827] mb-2">Your cart is empty</h2>
            <p className="text-gray-400 font-bold mb-6">Add products from the store to get started</p>
            <Link to="/products" className="inline-block bg-[#FF6B2C] text-white px-8 py-3 rounded-xl font-black shadow-lg shadow-[#FF6B2C]/20 hover:bg-[#E05520]">Shop Now</Link>
          </div>
        ) : (
          <div className="flex flex-col lg:flex-row gap-10">
            {/* Cart Items */}
            <div className="flex-1">
              <div className="bg-white rounded-2xl border border-[#ECECEC] shadow-sm overflow-hidden">
                <div className="px-6 py-4 border-b border-[#F8F7FC] flex items-center justify-between">
                  <h3 className="text-sm font-black text-[#111827] uppercase tracking-wider">{cartCount} Item{cartCount !== 1 ? 's' : ''} in Cart</h3>
                </div>
                <div className="divide-y divide-[#F8F7FC]">
                  {cart.map((item) => (
                    <div key={item.id} className="flex flex-wrap sm:flex-nowrap items-center gap-3 sm:gap-5 p-4 sm:p-5 hover:bg-[#FFF8F5]/50 transition-colors">
                      <div className="w-20 h-20 rounded-xl overflow-hidden bg-[#F8F7FC] border border-[#ECECEC] shrink-0">
                        <img src={item.img} alt={item.name} className="w-full h-full object-cover" />
                      </div>
                      <div className="flex-1 min-w-[140px]">
                        <p className="text-sm font-black text-[#111827] line-clamp-2 sm:truncate">{item.name}</p>
                        <p className="text-xs font-bold text-gray-400 mb-2">{item.brand} • {item.category}</p>
                        <div className="flex items-center gap-3">
                          <span className="text-lg font-black text-[#FF6B2C]">₹{item.price.toLocaleString()}</span>
                          {item.oldPrice > item.price && <span className="text-xs text-gray-400 line-through">₹{item.oldPrice.toLocaleString()}</span>}
                        </div>
                      </div>
                      <div className="flex items-center gap-2 shrink-0 ml-[92px] sm:ml-0">
                        <button onClick={() => updateCartQty(item.id, item.qty - 1)} className="w-8 h-8 rounded-lg border border-[#ECECEC] flex items-center justify-center text-gray-500 hover:border-[#FF6B2C] hover:text-[#FF6B2C]"><Minus size={14} /></button>
                        <span className="w-8 text-center text-sm font-black">{item.qty}</span>
                        <button onClick={() => updateCartQty(item.id, item.qty + 1)} className="w-8 h-8 rounded-lg border border-[#ECECEC] flex items-center justify-center text-gray-500 hover:border-[#FF6B2C] hover:text-[#FF6B2C]"><Plus size={14} /></button>
                      </div>
                      <div className="text-right shrink-0 ml-auto sm:ml-0">
                        <p className="text-base font-black text-[#111827]">₹{(item.price * item.qty).toLocaleString()}</p>
                        <button onClick={() => removeFromCart(item.id)} className="text-red-400 hover:text-red-600 mt-1"><Trash2 size={14} /></button>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>

            {/* Price Summary */}
            <div className="lg:w-[350px] shrink-0">
              <div className="sticky top-32 bg-white rounded-2xl border border-[#ECECEC] shadow-sm p-6">
                <h3 className="text-sm font-black text-[#111827] uppercase tracking-wider mb-5 pb-4 border-b border-[#F8F7FC]">Price Summary</h3>
                <div className="space-y-4 mb-6">
                  <div className="flex justify-between text-sm font-bold text-gray-500">
                    <span>Price ({cartCount} item{cartCount !== 1 ? 's' : ''})</span>
                    <span className="text-[#111827]">₹{(cartTotal + savings).toLocaleString()}</span>
                  </div>
                  {savings > 0 && (
                    <div className="flex justify-between text-sm font-bold">
                      <span className="text-gray-500">Discount</span>
                      <span className="text-green-600">- ₹{savings.toLocaleString()}</span>
                    </div>
                  )}
                  <div className="flex justify-between text-sm font-bold">
                    <span className="text-gray-500">Delivery</span>
                    {deliveryFee === 0
                      ? <span className="text-green-600 font-black text-xs uppercase">Free</span>
                      : <span className="text-[#111827]">₹{deliveryFee}</span>}
                  </div>
                  {gst > 0 && (
                    <div className="flex justify-between text-sm font-bold">
                      <span className="text-gray-500">Includes GST ({pricing.gstRate}%)</span>
                      <span className="text-gray-500">₹{gst.toLocaleString()}</span>
                    </div>
                  )}
                  {deliveryFee > 0 && pricing.freeEnabled && (
                    <p className="text-[11px] font-bold text-gray-400">Add ₹{Math.ceil(pricing.threshold - cartTotal).toLocaleString()} more for free delivery.</p>
                  )}
                </div>
                {savings > 0 && (
                  <div className="bg-green-50 px-4 py-2 rounded-xl border border-green-100 mb-5">
                    <p className="text-[11px] font-black text-green-600 uppercase tracking-wider text-center">You save ₹{savings.toLocaleString()} on this order</p>
                  </div>
                )}
                <div className="flex justify-between items-center mb-6">
                  <span className="text-lg font-black text-[#111827]">Total Amount</span>
                  <span className="text-2xl font-black text-[#111827]">₹{estimatedTotal.toLocaleString()}</span>
                </div>
                <p className="-mt-4 mb-5 text-[11px] font-bold text-gray-400">Final amount (delivery for your pincode and any coupon) is confirmed at checkout.</p>
                <Link to="/checkout" className="block w-full bg-[#FF6B2C] text-white py-4 rounded-xl font-black text-center shadow-xl shadow-[#FF6B2C]/20 hover:bg-[#E05520] transition-colors">
                  Proceed to Checkout <ChevronRight size={16} className="inline" />
                </Link>
              </div>
            </div>
          </div>
        )}

        {/* Recommendations */}
        {recommendations.length > 0 && (
          <div className="mt-20">
            <div className="flex items-center justify-between mb-8">
              <h2 className="text-2xl font-black text-[#111827]">You may also like</h2>
              <Link to="/products" className="flex items-center gap-1 text-[#FF6B2C] font-black text-sm hover:underline">View All <ChevronRight size={16} /></Link>
            </div>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
              {recommendations.map((p) => (
                <ProductCardPLP key={p.id} id={p.id} image={p.img} name={p.name} brand={p.brand} price={p.price} oldPrice={p.oldPrice || undefined} discount={productDiscount(p) || undefined} rating={p.rating} reviews={p.reviews} />
              ))}
            </div>
          </div>
        )}

        <div className="mt-20 py-12 border-t border-[#F8F7FC] grid grid-cols-2 lg:grid-cols-4 gap-8">
          {[
            { icon: <Truck size={24} />, title: 'Free Delivery', desc: 'On orders above ₹499' },
            { icon: <RotateCcw size={24} />, title: 'Easy Returns', desc: 'Within 7 days' },
            { icon: <ShieldCheck size={24} />, title: 'Secure Payments', desc: '100% secure payments' },
            { icon: <Headphones size={24} />, title: 'Daily Support', desc: "We're here to help" },
          ].map((item, i) => (
            <div key={i} className="flex flex-col items-center text-center group cursor-default">
              <div className="w-14 h-14 bg-[#F8F7FC] rounded-2xl flex items-center justify-center text-[#FF6B2C] mb-4 group-hover:scale-110 transition-transform">{item.icon}</div>
              <h4 className="text-sm font-black text-[#111827] uppercase tracking-wider mb-1">{item.title}</h4>
              <p className="text-[11px] font-bold text-gray-400">{item.desc}</p>
            </div>
          ))}
        </div>
      </Container>

      <Footer />
    </div>
  );
};

export default CartPage;
