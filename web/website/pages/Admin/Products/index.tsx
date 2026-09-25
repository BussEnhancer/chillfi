import React, { useState, useEffect, useRef } from 'react';
import { useSearchParams } from 'react-router-dom';
import AdminLayout from '../../../components/admin/AdminLayout';
import { Plus, Search, Edit2, Trash2, Eye, ChevronLeft, ChevronRight, Star, X, Check, Package, Upload, Loader2 } from 'lucide-react';
import { apiGet, apiPost, apiPut, apiDelete, uploadImage, friendlyError } from '../../../utils/api';
import { Product } from '../../../context/StoreContext';

const statusStyle: Record<string, string> = { Active: 'bg-green-50 text-green-600', 'Out of Stock': 'bg-red-50 text-red-500', 'Low Stock': 'bg-amber-50 text-amber-600', Inactive: 'bg-gray-100 text-gray-500' };

const emptyForm: Product = { id: '', name: '', category: 'Smartphones', brand: '', price: 0, oldPrice: 0, stock: 0, rating: 4.5, reviews: 0, status: 'Active', img: '', description: '', isFeatured: false, isFlashSale: false };

interface ApiProduct {
  id: string; name: string; category_name?: string; category?: string; brand_name?: string;
  price: string | number; old_price?: string | number; stock?: number; rating?: string | number;
  review_count?: number; status?: string; primary_image?: string; image?: string; description?: string;
  brand?: string; category_id?: string; brand_id?: string; is_featured?: boolean; is_flash_sale?: boolean; hsn_code?: string | null;
}

const normalizeApiProduct = (p: ApiProduct): Product => ({
  id: p.id,
  name: p.name,
  category: (p.category_name || p.category || '') as string,
  brand: (p.brand_name || p.brand || '') as string,
  price: Number(p.price),
  oldPrice: Number(p.old_price || 0),
  stock: Number(p.stock || 0),
  rating: Number(p.rating || 0),
  reviews: Number(p.review_count || 0),
  status: (p.status || 'Active') as string,
  img: (p.primary_image || p.image || '') as string,
  description: (p.description || '') as string,
  isFeatured: !!p.is_featured,
  isFlashSale: !!p.is_flash_sale,
  hsn: (p.hsn_code || '') as string,
});

const Toast: React.FC<{ msg: string; onClose: () => void }> = ({ msg, onClose }) => (
  <div className="fixed bottom-6 right-6 z-[100] flex items-center gap-3 bg-[#121212] text-white px-5 py-3.5 rounded-2xl shadow-2xl animate-fade-in">
    <div className="w-6 h-6 bg-green-500 rounded-full flex items-center justify-center shrink-0"><Check size={13} /></div>
    <span className="text-sm font-bold">{msg}</span>
    <button onClick={onClose} className="ml-2 text-white/50 hover:text-white"><X size={14} /></button>
  </div>
);

const DeleteConfirm: React.FC<{ name: string; onConfirm: () => void; onCancel: () => void }> = ({ name, onConfirm, onCancel }) => (
  <div className="fixed inset-0 bg-black/40 backdrop-blur-sm z-50 flex items-center justify-center p-4">
    <div className="bg-white rounded-2xl shadow-2xl w-full max-w-sm p-6 text-center">
      <div className="w-14 h-14 bg-red-50 rounded-full flex items-center justify-center mx-auto mb-4">
        <Trash2 size={24} className="text-red-500" />
      </div>
      <h3 className="text-lg font-black text-[#111827] mb-2">Deactivate Product?</h3>
      <p className="text-sm font-bold text-gray-400 mb-6"><span className="text-[#111827]">"{name}"</span> will be hidden from the store. Past orders keep it, and you can make it Active again anytime.</p>
      <div className="flex gap-3">
        <button onClick={onCancel} className="flex-1 border-2 border-[#ECECEC] text-gray-600 py-2.5 rounded-xl font-black text-sm hover:border-gray-400">Cancel</button>
        <button onClick={onConfirm} className="flex-1 bg-red-500 text-white py-2.5 rounded-xl font-black text-sm hover:bg-red-600">Deactivate</button>
      </div>
    </div>
  </div>
);

const ViewModal: React.FC<{ product: Product; onClose: () => void }> = ({ product, onClose }) => (
  <div className="fixed inset-0 bg-black/40 backdrop-blur-sm z-50 flex items-center justify-center p-4">
    <div className="bg-white rounded-2xl shadow-2xl w-full max-w-lg">
      <div className="flex items-center justify-between px-6 py-4 border-b border-[#F8F7FC]">
        <h3 className="text-lg font-black text-[#111827]">Product Details</h3>
        <button onClick={onClose} className="w-8 h-8 rounded-xl bg-[#F8F7FC] flex items-center justify-center hover:bg-red-50 hover:text-red-500 transition-colors"><X size={16} /></button>
      </div>
      <div className="p-6">
        <div className="flex gap-5 mb-6">
          <div className="w-24 h-24 rounded-2xl overflow-hidden bg-[#F8F7FC] border border-[#ECECEC] shrink-0">
            {product.img ? <img src={product.img} alt={product.name} className="w-full h-full object-cover" /> : <Package size={32} className="m-auto mt-4 text-gray-300" />}
          </div>
          <div>
            <span className={`text-[10px] font-black px-2.5 py-1 rounded-lg uppercase tracking-wide mb-2 inline-block ${statusStyle[product.status]}`}>{product.status}</span>
            <h4 className="text-lg font-black text-[#111827] mb-1">{product.name}</h4>
            <p className="text-sm font-bold text-gray-400">{product.brand} • {product.category}</p>
          </div>
        </div>
        <div className="grid grid-cols-2 gap-4 mb-4">
          {[
            { label: 'Price', value: `₹${product.price.toLocaleString()}` },
            { label: 'Stock', value: product.stock.toString() },
            { label: 'Rating', value: `${product.rating} ⭐ (${product.reviews.toLocaleString()} reviews)` },
            { label: 'Product ID', value: product.id },
          ].map((f, i) => (
            <div key={i} className="bg-[#F8F7FC] rounded-xl p-3">
              <p className="text-[10px] font-black text-gray-400 uppercase tracking-widest mb-1">{f.label}</p>
              <p className="text-sm font-black text-[#111827]">{f.value}</p>
            </div>
          ))}
        </div>
        <div className="bg-[#F8F7FC] rounded-xl p-3">
          <p className="text-[10px] font-black text-gray-400 uppercase tracking-widest mb-1">Description</p>
          <p className="text-sm font-bold text-gray-600">{product.description}</p>
        </div>
      </div>
    </div>
  </div>
);

const ProductForm: React.FC<{ initial: Product; categories: string[]; onSave: (p: Product, imageFile?: File) => Promise<void>; onClose: () => void; isEdit: boolean; saving: boolean }> = ({ initial, categories, onSave, onClose, isEdit, saving }) => {
  const [form, setForm] = useState<Product>(initial);
  const [imageFile, setImageFile] = useState<File | null>(null);
  const [imagePreview, setImagePreview] = useState(initial.img);
  const fileRef = useRef<HTMLInputElement>(null);
  const set = (k: keyof Product, v: any) => setForm(f => ({ ...f, [k]: v }));

  const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    setImageFile(file);
    setImagePreview(URL.createObjectURL(file));
  };

  return (
    <div className="fixed inset-0 bg-black/40 backdrop-blur-sm z-50 flex items-center justify-center p-4">
      <div className="bg-white rounded-2xl shadow-2xl w-full max-w-2xl max-h-[90vh] flex flex-col">
        <div className="flex items-center justify-between px-6 py-4 border-b border-[#F8F7FC] shrink-0">
          <h3 className="text-lg font-black text-[#111827]">{isEdit ? 'Edit Product' : 'Add New Product'}</h3>
          <button onClick={onClose} disabled={saving} className="w-8 h-8 rounded-xl bg-[#F8F7FC] flex items-center justify-center hover:bg-red-50 hover:text-red-500 transition-colors"><X size={16} /></button>
        </div>
        <div className="overflow-y-auto p-6 space-y-4">
          {/* Image Upload */}
          <div>
            <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Product Image</label>
            <div className="flex items-center gap-4">
              <div className="w-20 h-20 rounded-xl overflow-hidden bg-[#F8F7FC] border-2 border-dashed border-[#ECECEC] flex items-center justify-center shrink-0">
                {imagePreview ? <img src={imagePreview} alt="Preview" className="w-full h-full object-cover" /> : <Package size={24} className="text-gray-300" />}
              </div>
              <div className="flex-1">
                <input ref={fileRef} type="file" accept="image/*" onChange={handleImageChange} className="hidden" />
                <button onClick={() => fileRef.current?.click()} className="flex items-center gap-2 px-4 py-2 border-2 border-dashed border-[#ECECEC] rounded-xl text-sm font-bold text-gray-500 hover:border-[#FF6B2C] hover:text-[#FF6B2C] transition-colors w-full justify-center">
                  <Upload size={14} /> Upload Image
                </button>
                <p className="text-[10px] font-bold text-gray-400 mt-1.5 text-center">JPG, PNG, WebP • Max 5MB</p>
              </div>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div className="col-span-2">
              <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Product Name *</label>
              <input value={form.name} onChange={e => set('name', e.target.value)} placeholder="e.g. Samsung Galaxy S24 FE" className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C]" />
            </div>
            <div>
              <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Brand *</label>
              <input value={form.brand} onChange={e => set('brand', e.target.value)} placeholder="e.g. Samsung" className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C]" />
            </div>
            <div>
              <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Category *</label>
              <select value={form.category} onChange={e => set('category', e.target.value)} className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C]">
                {categories.map(c => <option key={c}>{c}</option>)}
              </select>
            </div>
            <div>
              <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Sale Price (₹) *</label>
              <input type="number" value={form.price} onChange={e => set('price', +e.target.value)} className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C]" />
            </div>
            <div>
              <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">MRP / Old Price (₹)</label>
              <input type="number" value={form.oldPrice} onChange={e => set('oldPrice', +e.target.value)} className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C]" />
            </div>
            <div>
              <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Stock Qty *</label>
              <input type="number" value={form.stock} onChange={e => set('stock', +e.target.value)} className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C]" />
            </div>
            <div>
              <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">HSN Code (for GST invoice)</label>
              <input value={form.hsn || ''} onChange={e => set('hsn', e.target.value.replace(/\D/g, '').slice(0, 8))} placeholder="e.g. 8518 (4, 6 or 8 digits)" className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C]" />
            </div>
            <div>
              <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Status</label>
              <select value={form.status} onChange={e => set('status', e.target.value)} className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C]">
                {['Active', 'Inactive', 'Out of Stock', 'Low Stock'].map(s => <option key={s}>{s}</option>)}
              </select>
            </div>
            <div className="col-span-2 flex items-center gap-6">
              <label className="flex items-center gap-2 cursor-pointer">
                <input type="checkbox" checked={!!form.isFeatured} onChange={e => set('isFeatured', e.target.checked)} className="w-4 h-4 accent-[#FF6B2C]" />
                <span className="text-sm font-bold text-gray-600">Featured Product</span>
              </label>
              <label className="flex items-center gap-2 cursor-pointer">
                <input type="checkbox" checked={!!form.isFlashSale} onChange={e => set('isFlashSale', e.target.checked)} className="w-4 h-4 accent-[#FF6B2C]" />
                <span className="text-sm font-bold text-gray-600">Flash Sale</span>
              </label>
            </div>
            <div className="col-span-2">
              <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Description</label>
              <textarea rows={2} value={form.description} onChange={e => set('description', e.target.value)} className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C] resize-none" />
            </div>
          </div>
        </div>
        <div className="flex gap-3 px-6 py-4 border-t border-[#F8F7FC] shrink-0">
          <button onClick={onClose} disabled={saving} className="flex-1 border-2 border-[#ECECEC] text-gray-600 py-2.5 rounded-xl font-black text-sm hover:border-gray-400 disabled:opacity-50">Cancel</button>
          <button onClick={() => onSave(form, imageFile || undefined)} disabled={saving || !form.name} className="flex-1 bg-[#FF6B2C] text-white py-2.5 rounded-xl font-black text-sm shadow-lg shadow-[#FF6B2C]/20 hover:bg-[#E05520] disabled:opacity-60 flex items-center justify-center gap-2">
            {saving ? <><Loader2 size={14} className="animate-spin" />Saving...</> : isEdit ? 'Save Changes' : 'Add Product'}
          </button>
        </div>
      </div>
    </div>
  );
};

const PAGE_SIZE = 10;

const AdminProducts: React.FC = () => {
  const [products, setProducts] = useState<Product[]>([]);
  const [categories, setCategories] = useState<string[]>([]);
  const [searchParams] = useSearchParams();
  const [search, setSearch] = useState(searchParams.get('search') || '');
  // Header search navigates here with ?search= — also when this page is already open.
  useEffect(() => { const q = searchParams.get('search'); if (q !== null) { setSearch(q); setPage(1); } }, [searchParams]);
  const [catFilter, setCatFilter] = useState('All');
  const [showForm, setShowForm] = useState(false);
  const [editing, setEditing] = useState<Product | null>(null);
  const [viewing, setViewing] = useState<Product | null>(null);
  const [deleting, setDeleting] = useState<Product | null>(null);
  const [toast, setToast] = useState('');
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [page, setPage] = useState(1);

  const showToast = (msg: string) => { setToast(msg); setTimeout(() => setToast(''), 3000); };

  const loadProducts = async () => {
    setLoading(true);
    try {
      // Admin list includes Inactive products (the public list hides them)
      const res = await apiGet<{ success: boolean; data: { products: ApiProduct[] } }>('/admin/products?limit=1000&status=all');
      if (res.data?.products) setProducts(res.data.products.map(normalizeApiProduct));
    } catch (e) {
      showToast(friendlyError(e, "Couldn't load products"));
    } finally {
      setLoading(false);
    }
  };

  const loadCategories = async () => {
    try {
      const res = await apiGet<{ success: boolean; data: { categories: Array<{ name: string }> } }>('/categories');
      const names = (res.data?.categories || []).map((c: { name: string }) => c.name);
      if (names.length) setCategories(names);
    } catch { /* keep empty */ }
  };

  useEffect(() => { loadProducts(); loadCategories(); }, []);

  const filtered = products.filter(p =>
    (catFilter === 'All' || p.category === catFilter) &&
    (p.name.toLowerCase().includes(search.toLowerCase()) || p.brand.toLowerCase().includes(search.toLowerCase()))
  );

  const totalPages = Math.max(1, Math.ceil(filtered.length / PAGE_SIZE));
  const paginated = filtered.slice((page - 1) * PAGE_SIZE, page * PAGE_SIZE);

  const handleSave = async (p: Product, imageFile?: File) => {
    if (!p.name) return;
    setSaving(true);
    try {
      let imageUrl = p.img;
      if (imageFile) {
        imageUrl = await uploadImage(imageFile, 'chillfi/products');
      }

      const payload = {
        name: p.name,
        description: p.description,
        price: p.price,
        old_price: p.oldPrice,
        stock: p.stock,
        status: p.status,
        brand_name: p.brand,
        category_name: p.category,
        is_featured: !!p.isFeatured,
        is_flash_sale: !!p.isFlashSale,
        hsn_code: p.hsn || '',
        ...(imageUrl ? { image: imageUrl, images: [{ url: imageUrl, is_primary: true }] } : {}),
      };

      if (editing) {
        await apiPut(`/products/${editing.id}`, payload);
        await loadProducts();
        showToast('Product updated successfully!');
      } else {
        await apiPost<{ success: boolean; data: { product: ApiProduct } }>('/products', payload);
        await loadProducts(); // reload so brand/category names come from the server

        showToast('Product added successfully!');
      }
      setShowForm(false); setEditing(null);
    } catch (e: any) {
      showToast(friendlyError(e, 'Failed to save product'));
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async () => {
    if (!deleting) return;
    try {
      await apiDelete(`/products/${deleting.id}`);
      setProducts(prev => prev.map(x => x.id === deleting.id ? { ...x, status: 'Inactive' } : x));
      showToast('Product deactivated — hidden from the store. Set it Active to restore.');
    } catch (e: any) {
      showToast(friendlyError(e, 'Failed to deactivate product'));
    } finally {
      setDeleting(null);
    }
  };

  const handleStatusChange = async (id: string, status: string) => {
    setProducts(prev => prev.map(x => x.id === id ? { ...x, status } : x));
    try {
      await apiPut(`/products/${id}`, { status });
    } catch {
      // revert on error
      loadProducts();
    }
  };

  const handleStockChange = async (id: string, stock: number) => {
    setProducts(prev => prev.map(x => x.id === id ? { ...x, stock } : x));
    try {
      await apiPut(`/products/${id}`, { stock });
    } catch {
      loadProducts();
    }
  };

  return (
    <AdminLayout title="Products" subtitle={`${products.length} total products`}>
      {/* Toolbar */}
      <div className="flex flex-wrap items-center justify-between gap-4 mb-6">
        <div className="flex items-center gap-3 flex-wrap">
          <div className="relative">
            <input value={search} onChange={e => { setSearch(e.target.value); setPage(1); }} type="text" placeholder="Search products..." className="w-60 bg-white border border-[#ECECEC] rounded-xl pl-9 pr-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C] shadow-sm" />
            <Search size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
          </div>
          <select value={catFilter} onChange={e => { setCatFilter(e.target.value); setPage(1); }} className="px-4 py-2.5 bg-white border border-[#ECECEC] rounded-xl text-sm font-bold text-gray-600 outline-none focus:border-[#FF6B2C] shadow-sm">
            <option>All</option>
            {categories.map(c => <option key={c}>{c}</option>)}
          </select>
        </div>
        <button onClick={() => { setEditing(null); setShowForm(true); }} className="flex items-center gap-2 bg-[#FF6B2C] text-white px-5 py-2.5 rounded-xl font-black text-sm shadow-lg shadow-[#FF6B2C]/20 hover:bg-[#E05520]">
          <Plus size={16} /> Add Product
        </button>
      </div>

      {/* Summary row */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3 mb-5">
        {[
          { label: 'Total', value: products.length, color: '#FF6B2C' },
          { label: 'Active', value: products.filter(p => p.status === 'Active').length, color: '#10B981' },
          { label: 'Low Stock', value: products.filter(p => p.status === 'Low Stock').length, color: '#F59E0B' },
          { label: 'Out of Stock', value: products.filter(p => p.status === 'Out of Stock').length, color: '#EF4444' },
        ].map((s, i) => (
          <div key={i} className="bg-white rounded-xl px-4 py-3 border border-[#ECECEC] shadow-sm flex items-center justify-between">
            <span className="text-xs font-bold text-gray-400">{s.label}</span>
            <span className="text-xl font-black" style={{ color: s.color }}>{s.value}</span>
          </div>
        ))}
      </div>

      {/* Table */}
      <div className="bg-white rounded-2xl border border-[#ECECEC] shadow-sm overflow-hidden">
        {loading && (
          <div className="flex items-center justify-center py-8 gap-2 text-gray-400">
            <Loader2 size={18} className="animate-spin" />
            <span className="text-sm font-bold">Loading products...</span>
          </div>
        )}
        {!loading && (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="bg-[#F8F7FC] border-b border-[#ECECEC]">
                  {['Product', 'Brand', 'Category', 'Price', 'Stock', 'Rating', 'Status', 'Actions'].map(h => (
                    <th key={h} className="px-4 py-3 text-left text-[10px] font-black text-gray-400 uppercase tracking-widest whitespace-nowrap">{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody className="divide-y divide-[#F8F7FC]">
                {paginated.map((p) => (
                  <tr key={p.id} className="hover:bg-[#FFF8F5] transition-colors group">
                    <td className="px-4 py-3.5">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-xl overflow-hidden bg-[#F8F7FC] border border-[#ECECEC] shrink-0">
                          {p.img ? <img src={p.img} alt={p.name} className="w-full h-full object-cover" /> : <Package size={20} className="m-auto mt-2.5 text-gray-300" />}
                        </div>
                        <div>
                          <p className="text-sm font-black text-[#111827] whitespace-nowrap max-w-[180px] truncate">{p.name}</p>
                          <p className="text-[10px] font-bold text-gray-400">{p.id}</p>
                        </div>
                      </div>
                    </td>
                    <td className="px-4 py-3.5 text-xs font-bold text-gray-500 whitespace-nowrap">{p.brand}</td>
                    <td className="px-4 py-3.5 text-xs font-bold text-gray-500 whitespace-nowrap">{p.category}</td>
                    <td className="px-4 py-3.5 text-sm font-black text-[#111827] whitespace-nowrap">₹{p.price.toLocaleString()}</td>
                    <td className="px-4 py-3.5">
                      <input
                        type="number"
                        value={p.stock}
                        onChange={e => handleStockChange(p.id, +e.target.value)}
                        className="w-16 border border-[#ECECEC] rounded-lg px-2 py-1 text-xs font-bold text-center outline-none focus:border-[#FF6B2C]"
                      />
                    </td>
                    <td className="px-4 py-3.5 whitespace-nowrap">
                      <div className="flex items-center gap-1">
                        <Star size={11} className="fill-amber-400 text-amber-400" />
                        <span className="text-xs font-black text-[#111827]">{p.rating}</span>
                      </div>
                    </td>
                    <td className="px-4 py-3.5 whitespace-nowrap">
                      <select
                        value={p.status}
                        onChange={e => handleStatusChange(p.id, e.target.value)}
                        className={`text-[10px] font-black px-2 py-1 rounded-lg border-0 outline-none cursor-pointer ${statusStyle[p.status]}`}
                      >
                        {['Active', 'Inactive', 'Out of Stock', 'Low Stock'].map(s => <option key={s} value={s}>{s}</option>)}
                      </select>
                    </td>
                    <td className="px-4 py-3.5">
                      <div className="flex items-center gap-1.5">
                        <button onClick={() => setViewing(p)} className="w-7 h-7 rounded-lg bg-[#F8F7FC] flex items-center justify-center text-gray-500 hover:bg-[#FFF3ED] hover:text-[#FF6B2C] transition-colors" title="View"><Eye size={13} /></button>
                        <button onClick={() => { setEditing(p); setShowForm(true); }} className="w-7 h-7 rounded-lg bg-[#F8F7FC] flex items-center justify-center text-gray-500 hover:bg-[#FFF3ED] hover:text-[#FF6B2C] transition-colors" title="Edit"><Edit2 size={13} /></button>
                        <button onClick={() => setDeleting(p)} className="w-7 h-7 rounded-lg bg-[#F8F7FC] flex items-center justify-center text-gray-500 hover:bg-red-50 hover:text-red-500 transition-colors" title="Deactivate" aria-label="Deactivate product"><Trash2 size={13} /></button>
                      </div>
                    </td>
                  </tr>
                ))}
                {paginated.length === 0 && (
                  <tr><td colSpan={8} className="px-4 py-12 text-center text-sm font-bold text-gray-400">No products found</td></tr>
                )}
              </tbody>
            </table>
          </div>
        )}
        <div className="flex items-center justify-between px-6 py-4 border-t border-[#F8F7FC]">
          <p className="text-xs font-bold text-gray-400">Showing {(page - 1) * PAGE_SIZE + 1}–{Math.min(page * PAGE_SIZE, filtered.length)} of {filtered.length} products</p>
          <div className="flex items-center gap-2">
            <button onClick={() => setPage(p => Math.max(1, p - 1))} disabled={page === 1} className="w-8 h-8 flex items-center justify-center rounded-lg border border-[#ECECEC] text-gray-400 disabled:opacity-40"><ChevronLeft size={14} /></button>
            {Array.from({ length: Math.min(5, totalPages) }, (_, i) => {
              const pg = totalPages <= 5 ? i + 1 : Math.max(1, page - 2) + i;
              return pg <= totalPages ? (
                <button key={pg} onClick={() => setPage(pg)} className={`w-8 h-8 flex items-center justify-center rounded-lg text-xs font-black ${pg === page ? 'bg-[#FF6B2C] text-white' : 'text-gray-500 hover:bg-gray-50'}`}>{pg}</button>
              ) : null;
            })}
            <button onClick={() => setPage(p => Math.min(totalPages, p + 1))} disabled={page === totalPages} className="w-8 h-8 flex items-center justify-center rounded-lg border border-[#ECECEC] text-gray-400 disabled:opacity-40"><ChevronRight size={14} /></button>
          </div>
        </div>
      </div>

      {showForm && <ProductForm initial={editing || { ...emptyForm, category: categories[0] || '' }} categories={categories} onSave={handleSave} onClose={() => { setShowForm(false); setEditing(null); }} isEdit={!!editing} saving={saving} />}
      {viewing && <ViewModal product={viewing} onClose={() => setViewing(null)} />}
      {deleting && <DeleteConfirm name={deleting.name} onConfirm={handleDelete} onCancel={() => setDeleting(null)} />}
      {toast && <Toast msg={toast} onClose={() => setToast('')} />}
    </AdminLayout>
  );
};

export default AdminProducts;
