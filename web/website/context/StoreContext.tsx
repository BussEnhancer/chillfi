import React, { createContext, useContext, useState, useEffect, useCallback, useRef } from 'react';
import { apiGet, apiPost, saveTokens, clearTokens, getAccessToken } from '../utils/api';

// ── Types ────────────────────────────────────────────────────────────────────

export interface Product {
  id: string; name: string; category: string; price: number; oldPrice: number;
  stock: number; rating: number; reviews: number; status: string;
  img: string; description: string; brand: string;
  isFeatured?: boolean; isFlashSale?: boolean;
}

export interface Category {
  id: string; name: string; icon: string; products: number;
  orders: number; revenue: string; status: boolean; description: string;
}

export interface Coupon {
  id: string; code: string; type: string; value: number;
  minOrder: number; maxDiscount: number; used: number;
  total: number; expiry: string; status: boolean;
}

export interface Order {
  id: string; customer: string; email: string; phone: string;
  product: string; qty: number; amount: number; payment: string;
  status: string; date: string; address: string; img: string;
  orderNumber?: string;
}

export interface StoreUser {
  id: string; name: string; email: string; phone: string;
  orders: number; spent: number; joined: string; status: string; city: string;
  role?: string;
}

export interface StoreSettings {
  name: string; email: string; phone: string; gst: string;
  url: string; supportEmail: string; address: string;
  freeThreshold: string; standardFee: string; expressFee: string; maxDays: string;
  freeShipping: boolean; express: boolean; cod: boolean;
}

export interface CartItem {
  id: string; name: string; img: string; price: number; oldPrice: number;
  brand: string; category: string; qty: number;
}

export interface WishlistItem {
  id: string; name: string; img: string; price: number; oldPrice: number;
  brand: string; category: string; rating: number; reviews: number; stock: number;
}

// ── Initial Data ─────────────────────────────────────────────────────────────

export const initialProducts: Product[] = [
  { id: 'PRD001', name: 'Samsung Galaxy S24 FE 5G', category: 'Smartphones', brand: 'Samsung', price: 39999, oldPrice: 54999, stock: 142, rating: 4.7, reviews: 12400, status: 'Active', img: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&q=80&w=400', description: '6.7" Dynamic AMOLED, 50MP camera, 4600mAh, 5G' },
  { id: 'PRD002', name: 'Sony WH-1000XM5 Headphones', category: 'Audio', brand: 'Sony', price: 24990, oldPrice: 34990, stock: 67, rating: 4.8, reviews: 8900, status: 'Active', img: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&q=80&w=400', description: 'Industry-leading noise cancellation, 30hr battery' },
  { id: 'PRD003', name: 'Lenovo IdeaPad Slim 3 (i5)', category: 'Laptops', brand: 'Lenovo', price: 52999, oldPrice: 64999, stock: 34, rating: 4.5, reviews: 3200, status: 'Active', img: 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?auto=format&fit=crop&q=80&w=400', description: 'Intel i5 12th Gen, 16GB RAM, 512GB SSD' },
  { id: 'PRD004', name: 'Apple AirPods Pro 2nd Gen', category: 'Audio', brand: 'Apple', price: 19900, oldPrice: 26900, stock: 0, rating: 4.9, reviews: 34500, status: 'Out of Stock', img: 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?auto=format&fit=crop&q=80&w=400', description: 'Active noise cancellation, Adaptive Audio, USB-C' },
  { id: 'PRD005', name: 'Noise ColorFit Ultra 3', category: 'Wearables', brand: 'Noise', price: 2999, oldPrice: 7999, stock: 289, rating: 4.4, reviews: 28000, status: 'Active', img: 'https://images.unsplash.com/photo-1508685096489-7aac2715a99a?auto=format&fit=crop&q=80&w=400', description: '1.96" AMOLED, BT calling, SpO2 monitor' },
  { id: 'PRD006', name: 'Samsung 55" Crystal 4K TV', category: 'Smart TVs', brand: 'Samsung', price: 42999, oldPrice: 69990, stock: 18, rating: 4.6, reviews: 6700, status: 'Active', img: 'https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?auto=format&fit=crop&q=80&w=400', description: '4K UHD, Tizen OS, HDR10+, 55 inch' },
  { id: 'PRD007', name: 'boAt Airdopes 141 TWS', category: 'Audio', brand: 'boAt', price: 1299, oldPrice: 2990, stock: 540, rating: 4.3, reviews: 45000, status: 'Active', img: 'https://images.unsplash.com/photo-1484704849700-f032a568e944?auto=format&fit=crop&q=80&w=400', description: '42hr total playback, IPX4, BT 5.3' },
  { id: 'PRD008', name: 'Mi Smart Band 8 Pro', category: 'Wearables', brand: 'Mi', price: 2499, oldPrice: 3999, stock: 5, rating: 4.5, reviews: 19800, status: 'Low Stock', img: 'https://images.unsplash.com/photo-1508685096489-7aac2715a99a?auto=format&fit=crop&q=80&w=400', description: '1.74" AMOLED, GPS, 14 day battery' },
];

export const initialCategories: Category[] = [
  { id: 'CAT001', name: 'Smartphones', icon: '📱', products: 342, orders: 1284, revenue: '₹4,82,34,580', status: true, description: 'Android, iOS, and feature phones' },
  { id: 'CAT002', name: 'Laptops', icon: '💻', products: 128, orders: 486, revenue: '₹2,14,28,486', status: true, description: 'Gaming, business, and ultrabooks' },
  { id: 'CAT003', name: 'Audio', icon: '🎧', products: 284, orders: 2140, revenue: '₹89,42,060', status: true, description: 'Headphones, earphones, speakers' },
  { id: 'CAT004', name: 'Smart TVs', icon: '📺', products: 64, orders: 218, revenue: '₹1,02,18,782', status: true, description: '4K, 8K, OLED, QLED televisions' },
  { id: 'CAT005', name: 'Tablets', icon: '⌨️', products: 48, orders: 124, revenue: '₹56,84,276', status: true, description: 'iPads, Android tablets, e-readers' },
  { id: 'CAT006', name: 'Cameras', icon: '📷', products: 92, orders: 96, revenue: '₹38,40,480', status: false, description: 'DSLR, mirrorless, action cameras' },
  { id: 'CAT007', name: 'Gaming', icon: '🎮', products: 156, orders: 384, revenue: '₹72,96,384', status: true, description: 'Consoles, controllers, gaming accessories' },
  { id: 'CAT008', name: 'Wearables', icon: '⌚', products: 112, orders: 842, revenue: '₹28,42,758', status: true, description: 'Smartwatches, fitness bands, glasses' },
  { id: 'CAT009', name: 'Accessories', icon: '🖱️', products: 426, orders: 3240, revenue: '₹42,84,760', status: true, description: 'Cables, chargers, cases, bags' },
  { id: 'CAT010', name: 'Computer Accessories', icon: '🖥️', products: 214, orders: 1680, revenue: '₹36,28,680', status: false, description: 'Keyboards, mice, monitors, webcams' },
];

export const initialCoupons: Coupon[] = [
  { id: 'CPN001', code: 'CHILLFI20', type: 'Percentage', value: 20, minOrder: 999, maxDiscount: 500, used: 842, total: 1000, expiry: '2026-06-30', status: true },
  { id: 'CPN002', code: 'FLAT200', type: 'Flat', value: 200, minOrder: 1499, maxDiscount: 200, used: 1284, total: 2000, expiry: '2026-07-15', status: true },
  { id: 'CPN003', code: 'NEWUSER50', type: 'Percentage', value: 50, minOrder: 499, maxDiscount: 250, used: 3420, total: 5000, expiry: '2026-12-31', status: true },
  { id: 'CPN004', code: 'SAMSUNG10', type: 'Percentage', value: 10, minOrder: 9999, maxDiscount: 2000, used: 284, total: 500, expiry: '2026-06-20', status: false },
  { id: 'CPN005', code: 'FREESHIP', type: 'Free Shipping', value: 0, minOrder: 299, maxDiscount: 99, used: 5842, total: 10000, expiry: '2026-08-31', status: true },
  { id: 'CPN006', code: 'AUDIO30', type: 'Percentage', value: 30, minOrder: 1999, maxDiscount: 800, used: 124, total: 300, expiry: '2026-06-25', status: false },
];

export const initialOrders: Order[] = [
  { id: '#CHI2345692', customer: 'Rahul Sharma', email: 'rahul@gmail.com', phone: '+91 98765 43210', product: 'Samsung Galaxy S24 FE 5G', qty: 1, amount: 39999, payment: 'UPI', status: 'Delivered', date: 'Jun 14, 2026', address: '12, Green Park, Delhi - 110016', img: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&q=80&w=80' },
  { id: '#CHI2345691', customer: 'Priya Mehta', email: 'priya@gmail.com', phone: '+91 87654 32109', product: 'Sony WH-1000XM5', qty: 1, amount: 24990, payment: 'Credit Card', status: 'Shipped', date: 'Jun 14, 2026', address: '45, Koramangala, Bengaluru - 560034', img: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&q=80&w=80' },
  { id: '#CHI2345690', customer: 'Amit Kumar', email: 'amit@gmail.com', phone: '+91 76543 21098', product: 'Apple AirPods Pro 2nd Gen', qty: 2, amount: 39800, payment: 'UPI', status: 'Processing', date: 'Jun 13, 2026', address: '7, Andheri West, Mumbai - 400053', img: 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?auto=format&fit=crop&q=80&w=80' },
  { id: '#CHI2345689', customer: 'Sneha Patel', email: 'sneha@gmail.com', phone: '+91 65432 10987', product: 'Lenovo IdeaPad Slim 3', qty: 1, amount: 52999, payment: 'EMI', status: 'Delivered', date: 'Jun 13, 2026', address: '34, Banjara Hills, Hyderabad - 500034', img: 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?auto=format&fit=crop&q=80&w=80' },
  { id: '#CHI2345688', customer: 'Vikram Singh', email: 'vikram@gmail.com', phone: '+91 54321 09876', product: 'boAt Airdopes 141 TWS', qty: 3, amount: 3897, payment: 'COD', status: 'Cancelled', date: 'Jun 12, 2026', address: '89, T Nagar, Chennai - 600017', img: 'https://images.unsplash.com/photo-1484704849700-f032a568e944?auto=format&fit=crop&q=80&w=80' },
  { id: '#CHI2345687', customer: 'Ananya Roy', email: 'ananya@gmail.com', phone: '+91 43210 98765', product: 'Mi Smart Band 8 Pro', qty: 2, amount: 4998, payment: 'Debit Card', status: 'Delivered', date: 'Jun 12, 2026', address: '2, Salt Lake, Kolkata - 700091', img: 'https://images.unsplash.com/photo-1508685096489-7aac2715a99a?auto=format&fit=crop&q=80&w=80' },
  { id: '#CHI2345686', customer: 'Karan Joshi', email: 'karan@gmail.com', phone: '+91 32109 87654', product: 'Samsung 55" 4K Smart TV', qty: 1, amount: 42999, payment: 'EMI', status: 'Shipped', date: 'Jun 11, 2026', address: '15, Satellite, Ahmedabad - 380015', img: 'https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?auto=format&fit=crop&q=80&w=80' },
  { id: '#CHI2345685', customer: 'Pooja Nair', email: 'pooja@gmail.com', phone: '+91 21098 76543', product: 'Noise ColorFit Ultra 3', qty: 1, amount: 2999, payment: 'UPI', status: 'Processing', date: 'Jun 11, 2026', address: '56, MG Road, Pune - 411001', img: 'https://images.unsplash.com/photo-1508685096489-7aac2715a99a?auto=format&fit=crop&q=80&w=80' },
];

export const initialUsers: StoreUser[] = [
  { id: 'USR001', name: 'Rahul Sharma', email: 'rahul@gmail.com', phone: '+91 98765 43210', orders: 12, spent: 184920, joined: 'Jan 5, 2024', status: 'Active', city: 'Delhi' },
  { id: 'USR002', name: 'Priya Mehta', email: 'priya@gmail.com', phone: '+91 87654 32109', orders: 8, spent: 72480, joined: 'Feb 12, 2024', status: 'Active', city: 'Mumbai' },
  { id: 'USR003', name: 'Amit Kumar', email: 'amit@gmail.com', phone: '+91 76543 21098', orders: 3, spent: 14900, joined: 'Mar 20, 2024', status: 'Active', city: 'Bengaluru' },
  { id: 'USR004', name: 'Sneha Patel', email: 'sneha@gmail.com', phone: '+91 65432 10987', orders: 21, spent: 328470, joined: 'Dec 1, 2023', status: 'Active', city: 'Hyderabad' },
  { id: 'USR005', name: 'Vikram Singh', email: 'vikram@gmail.com', phone: '+91 54321 09876', orders: 1, spent: 3897, joined: 'Jun 10, 2024', status: 'Blocked', city: 'Chennai' },
  { id: 'USR006', name: 'Ananya Roy', email: 'ananya@gmail.com', phone: '+91 43210 98765', orders: 6, spent: 49200, joined: 'Apr 3, 2024', status: 'Active', city: 'Kolkata' },
  { id: 'USR007', name: 'Karan Joshi', email: 'karan@gmail.com', phone: '+91 32109 87654', orders: 4, spent: 128960, joined: 'May 18, 2024', status: 'Inactive', city: 'Ahmedabad' },
  { id: 'USR008', name: 'Pooja Nair', email: 'pooja@gmail.com', phone: '+91 21098 76543', orders: 9, spent: 38720, joined: 'Jan 28, 2024', status: 'Active', city: 'Pune' },
];

const defaultSettings: StoreSettings = {
  name: 'chillFi', email: 'support@chillfi.in', phone: '+91 98765 43210',
  gst: '27AABCU9603R1ZM', url: 'https://chillfi.web.app', supportEmail: 'help@chillfi.in',
  address: '123, Tech Park, Whitefield, Bengaluru, Karnataka - 560066',
  freeThreshold: '499', standardFee: '49', expressFee: '99', maxDays: '7',
  freeShipping: true, express: true, cod: false,
};

const defaultCart: CartItem[] = [];

const defaultWishlist: WishlistItem[] = [];

// ── localStorage helper ───────────────────────────────────────────────────────

function useLocalState<T>(key: string, init: T): [T, React.Dispatch<React.SetStateAction<T>>] {
  const [state, setState] = useState<T>(() => {
    try {
      const stored = localStorage.getItem(`chillfi_${key}`);
      return stored ? JSON.parse(stored) : init;
    } catch { return init; }
  });
  useEffect(() => {
    try { localStorage.setItem(`chillfi_${key}`, JSON.stringify(state)); } catch {}
  }, [key, state]);
  return [state, setState];
}

// ── Context ───────────────────────────────────────────────────────────────────

interface StoreContextType {
  // Core data (admin manages, storefront reads)
  products: Product[];
  setProducts: React.Dispatch<React.SetStateAction<Product[]>>;
  categories: Category[];
  setCategories: React.Dispatch<React.SetStateAction<Category[]>>;
  coupons: Coupon[];
  setCoupons: React.Dispatch<React.SetStateAction<Coupon[]>>;
  orders: Order[];
  setOrders: React.Dispatch<React.SetStateAction<Order[]>>;
  users: StoreUser[];
  setUsers: React.Dispatch<React.SetStateAction<StoreUser[]>>;
  settings: StoreSettings;
  setSettings: React.Dispatch<React.SetStateAction<StoreSettings>>;
  apiLoading: boolean;
  refreshFromAPI: () => Promise<void>;
  // Auth helpers (website login)
  isLoggedIn: boolean;
  loginUser: (accessToken: string, refreshToken: string) => void;
  logoutUser: () => void;

  // Cart
  cart: CartItem[];
  addToCart: (product: Product | CartItem) => void;
  removeFromCart: (id: string) => void;
  updateCartQty: (id: string, qty: number) => void;
  clearCart: () => void;
  cartTotal: number;
  cartCount: number;

  // Wishlist
  wishlist: WishlistItem[];
  toggleWishlist: (product: Product) => void;
  isInWishlist: (id: string) => boolean;
  refreshWishlist: () => void;

  // Coupon validation
  applyCoupon: (code: string, cartTotal: number) => { discount: number; msg: string; ok: boolean };
}

const StoreContext = createContext<StoreContextType | null>(null);

export const StoreProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [products, setProducts] = useLocalState<Product[]>('products', []);
  const [categories, setCategories] = useLocalState<Category[]>('categories', []);
  const [coupons, setCoupons] = useLocalState<Coupon[]>('coupons', []);
  const [orders, setOrders] = useLocalState<Order[]>('orders', []);
  const [users, setUsers] = useLocalState<StoreUser[]>('users', []);
  const [settings, setSettings] = useLocalState<StoreSettings>('settings', defaultSettings);
  const [cart, setCart] = useLocalState<CartItem[]>('cart', defaultCart);
  const [wishlist, setWishlist] = useLocalState<WishlistItem[]>('wishlist', defaultWishlist);
  const [apiLoading, setApiLoading] = useState(false);
  const [isLoggedIn, setIsLoggedIn] = useState(() => !!getAccessToken());
  const hasFetched = useRef(false);

  const loginUser = useCallback((access: string, refresh: string) => {
    saveTokens(access, refresh);
    setIsLoggedIn(true);
  }, []);

  const logoutUser = useCallback(() => {
    const rt = localStorage.getItem('refresh_token');
    if (rt) {
      apiPost('/auth/logout', { refreshToken: rt }).catch(() => {});
    }
    clearTokens();
    setIsLoggedIn(false);
    // Don't leave the previous user's cart / wishlist in this browser.
    setCart([]);
    setWishlist([]);
  }, [setCart, setWishlist]);

  // Normalize API product → local Product shape
  const normalizeProduct = (p: Record<string, unknown>): Product => ({
    id: p.id as string,
    name: p.name as string,
    category: (p.category_name || p.category || '') as string,
    price: Number(p.price),
    oldPrice: Number(p.old_price || 0),
    stock: Number(p.stock || 0),
    rating: Number(p.rating || 0),
    reviews: Number(p.review_count || 0),
    status: (p.status || 'Active') as string,
    img: (p.primary_image || p.image || '') as string,
    description: (p.description || '') as string,
    brand: (p.brand_name || '') as string,
  });

  const normalizeOrder = (o: Record<string, unknown>): Order => ({
    id: (o.order_number || o.id) as string,
    customer: (o.customer_name || '') as string,
    email: (o.customer_email || '') as string,
    phone: (o.customer_phone || '') as string,
    product: Array.isArray(o.items) && o.items.length > 0
      ? (o.items[0] as Record<string, unknown>).product_name as string
      : 'Multiple items',
    qty: Number(o.item_count || 1),
    amount: Number(o.total || 0),
    payment: (o.payment_method || 'COD') as string,
    status: (o.status || 'Processing') as string,
    date: new Date(o.created_at as string).toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' }),
    address: (o.address_line1 || '') as string,
    img: '',
  });

  const refreshFromAPI = useCallback(async () => {
    setApiLoading(true);
    try {
      const [prodRes, catRes, adminRes, couponRes] = await Promise.allSettled([
        apiGet<{ success: boolean; data: { products: Record<string, unknown>[] } }>('/products?limit=100'),
        apiGet<{ success: boolean; data: { categories: Record<string, unknown>[] } }>('/categories'),
        getAccessToken()
          ? apiGet<{ success: boolean; data: Record<string, unknown> }>('/admin/dashboard')
          : Promise.reject('not admin'),
        apiGet<{ success: boolean; data: { coupons: Record<string, unknown>[] } }>('/cart/coupons'),
      ]);

      if (prodRes.status === 'fulfilled' && prodRes.value.data?.products) {
        setProducts(prodRes.value.data.products.map(normalizeProduct));
      }
      if (catRes.status === 'fulfilled' && catRes.value.data?.categories) {
        const cats = catRes.value.data.categories.map((c: Record<string, unknown>) => ({
          id: c.id as string,
          name: c.name as string,
          icon: (c.icon || '🛍️') as string,
          products: Number(c.product_count || 0),
          orders: 0,
          revenue: '₹0',
          status: c.is_active !== false,
          description: (c.description || '') as string,
        }));
        setCategories(cats);
      }
      if (adminRes.status === 'fulfilled') {
        const d = (adminRes.value as { data: Record<string, unknown> }).data;
        // Update orders from admin dashboard recent_orders
        if (Array.isArray(d.recent_orders)) {
          setOrders((d.recent_orders as Record<string, unknown>[]).map(normalizeOrder));
        }
      }
      if (couponRes.status === 'fulfilled' && couponRes.value.data?.coupons) {
        setCoupons(couponRes.value.data.coupons.map((c: Record<string, unknown>) => ({
          id: c.id as string,
          code: c.code as string,
          type: c.type as string,
          value: Number(c.value),
          minOrder: Number(c.min_order || 0),
          maxDiscount: Number(c.max_discount || 0),
          used: 0,
          total: 0,
          expiry: (c.expires_at || '') as string,
          status: true,
        })));
      }
    } catch (_) {
      // Network unavailable — keep cached data
    } finally {
      setApiLoading(false);
    }
  }, [setProducts, setCategories, setOrders]);

  // Fetch once on mount
  useEffect(() => {
    if (hasFetched.current) return;
    hasFetched.current = true;
    refreshFromAPI();
  }, [refreshFromAPI]);

  const cartTotal = cart.reduce((s, i) => s + i.price * i.qty, 0);
  const cartCount = cart.reduce((s, i) => s + i.qty, 0);

  const addToCart = useCallback((product: Product | CartItem) => {
    setCart(prev => {
      const existing = prev.find(i => i.id === product.id);
      if (existing) return prev.map(i => i.id === product.id ? { ...i, qty: i.qty + 1 } : i);
      const item: CartItem = {
        id: product.id, name: product.name, img: (product as Product).img || (product as CartItem).img,
        price: product.price, oldPrice: product.oldPrice || 0,
        brand: (product as Product).brand || (product as CartItem).brand || '',
        category: product.category, qty: 1,
      };
      return [...prev, item];
    });
  }, [setCart]);

  const removeFromCart = useCallback((id: string) => {
    setCart(prev => prev.filter(i => i.id !== id));
  }, [setCart]);

  const updateCartQty = useCallback((id: string, qty: number) => {
    if (qty <= 0) { removeFromCart(id); return; }
    setCart(prev => prev.map(i => i.id === id ? { ...i, qty } : i));
  }, [setCart, removeFromCart]);

  const clearCart = useCallback(() => { setCart([]); }, [setCart]);

  const toggleWishlist = useCallback((product: Product) => {
    setWishlist(prev => {
      const exists = prev.some(i => i.id === product.id);
      if (exists) return prev.filter(i => i.id !== product.id);
      return [...prev, {
        id: product.id, name: product.name, img: product.img,
        price: product.price, oldPrice: product.oldPrice,
        brand: product.brand, category: product.category,
        rating: product.rating, reviews: product.reviews, stock: product.stock,
      }];
    });
    if (getAccessToken()) {
      apiPost('/wishlist/toggle', { product_id: product.id }).catch(() => {});
    }
  }, [setWishlist]);

  const isInWishlist = useCallback((id: string) => wishlist.some(i => i.id === id), [wishlist]);

  // Logged-in wishlist lives on the server (shared with the app) — mirror it locally for badges/cards.
  const refreshWishlist = useCallback(() => {
    if (!getAccessToken()) return;
    apiGet<{ success: boolean; data: Record<string, unknown>[] }>('/wishlist')
      .then((res) => {
        const list = Array.isArray(res.data) ? res.data : [];
        setWishlist(list.map((w) => ({
          id: String(w.product_id), name: String(w.name ?? ''), img: String(w.image ?? ''),
          price: Number(w.price ?? 0), oldPrice: Number(w.old_price ?? w.price ?? 0),
          brand: String(w.brand_name ?? ''), category: String(w.category_name ?? ''),
          rating: Number(w.rating ?? 0), reviews: Number(w.review_count ?? 0), stock: Number(w.stock ?? 0),
        })));
      })
      .catch(() => {});
  }, [setWishlist]);
  useEffect(() => { if (isLoggedIn) refreshWishlist(); }, [isLoggedIn, refreshWishlist]);

  const applyCoupon = useCallback((code: string, total: number) => {
    const c = coupons.find(x => x.code === code.toUpperCase() && x.status);
    if (!c) return { discount: 0, msg: 'Invalid or expired coupon code', ok: false };
    if (total < c.minOrder) return { discount: 0, msg: `Minimum order of ₹${c.minOrder.toLocaleString()} required`, ok: false };
    let discount = 0;
    if (c.type === 'Percentage') discount = Math.min(total * c.value / 100, c.maxDiscount);
    else if (c.type === 'Flat') discount = c.value;
    else if (c.type === 'Free Shipping') discount = c.maxDiscount;
    return { discount, msg: `Coupon applied! You saved ₹${discount.toLocaleString()}`, ok: true };
  }, [coupons]);

  return (
    <StoreContext.Provider value={{
      products, setProducts, categories, setCategories,
      coupons, setCoupons, orders, setOrders, users, setUsers,
      settings, setSettings,
      apiLoading, refreshFromAPI,
      isLoggedIn, loginUser, logoutUser,
      cart, addToCart, removeFromCart, updateCartQty, clearCart, cartTotal, cartCount,
      wishlist, toggleWishlist, isInWishlist, refreshWishlist,
      applyCoupon,
    }}>
      {children}
    </StoreContext.Provider>
  );
};

export const useStore = (): StoreContextType => {
  const ctx = useContext(StoreContext);
  if (!ctx) throw new Error('useStore must be used inside StoreProvider');
  return ctx;
};

export const productDiscount = (p: Product): string =>
  p.oldPrice > p.price ? `-${Math.round((p.oldPrice - p.price) / p.oldPrice * 100)}%` : '';
