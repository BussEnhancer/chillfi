import React, { useState, useEffect } from 'react';
import AdminLayout from '../../../components/admin/AdminLayout';
import { Plus, Edit2, Trash2, ToggleLeft, ToggleRight, X, Check, Loader2 } from 'lucide-react';
import { apiGet, apiPost, apiPut, apiDelete } from '../../../utils/api';
import { showErrorDialog } from '../../../components/feedback/ErrorDialog';
import { Category } from '../../../context/StoreContext';

const iconOptions = ['📱', '💻', '🎧', '📺', '⌨️', '📷', '🎮', '⌚', '🖱️', '🖥️', '🔋', '📡', '🎵', '🖨️', '💾'];

interface ApiCategory {
  id: string; name?: string; icon?: string; description?: string;
  is_active?: boolean; status?: boolean; product_count?: number | string;
}

const normalizeApiCat = (c: ApiCategory): Category => ({
  id: c.id,
  name: c.name || '',
  icon: c.icon || '🛍️',
  products: Number(c.product_count || 0),
  orders: 0,
  revenue: '₹0',
  status: c.is_active !== undefined ? c.is_active : (c.status !== undefined ? c.status : true),
  description: c.description || '',
});

const Toast: React.FC<{ msg: string; onClose: () => void }> = ({ msg, onClose }) => (
  <div className="fixed bottom-6 right-6 z-[100] flex items-center gap-3 bg-[#121212] text-white px-5 py-3.5 rounded-2xl shadow-2xl">
    <div className="w-6 h-6 bg-green-500 rounded-full flex items-center justify-center shrink-0"><Check size={13} /></div>
    <span className="text-sm font-bold">{msg}</span>
    <button onClick={onClose} className="ml-2 text-white/50 hover:text-white"><X size={14} /></button>
  </div>
);

const CategoryForm: React.FC<{ initial: Partial<Category>; onSave: (c: Category) => Promise<void>; onClose: () => void; isEdit: boolean; saving: boolean }> = ({ initial, onSave, onClose, isEdit, saving }) => {
  const [form, setForm] = useState<Category>({ id: '', name: '', icon: '📱', products: 0, orders: 0, revenue: '₹0', status: true, description: '', ...initial });
  const set = (k: keyof Category, v: any) => setForm(f => ({ ...f, [k]: v }));

  return (
    <div className="fixed inset-0 bg-black/40 backdrop-blur-sm z-50 flex items-center justify-center p-4">
      <div className="bg-white rounded-2xl shadow-2xl w-full max-w-md">
        <div className="flex items-center justify-between px-6 py-4 border-b border-[#F8F7FC]">
          <h3 className="text-lg font-black text-[#111827]">{isEdit ? 'Edit Category' : 'Add New Category'}</h3>
          <button onClick={onClose} disabled={saving} className="w-8 h-8 rounded-xl bg-[#F8F7FC] flex items-center justify-center hover:bg-red-50 hover:text-red-500 transition-colors"><X size={16} /></button>
        </div>
        <div className="p-6 space-y-4">
          <div>
            <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Category Name *</label>
            <input value={form.name} onChange={e => set('name', e.target.value)} placeholder="e.g. Smartphones" className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C]" />
          </div>
          <div>
            <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Icon</label>
            <div className="flex flex-wrap gap-2">
              {iconOptions.map(icon => (
                <button key={icon} onClick={() => set('icon', icon)}
                  className={`w-10 h-10 text-xl rounded-xl flex items-center justify-center transition-all ${form.icon === icon ? 'bg-[#FF6B2C]/10 ring-2 ring-[#FF6B2C]' : 'bg-[#F8F7FC] hover:bg-[#FFF3ED]'}`}
                >{icon}</button>
              ))}
              <input value={form.icon} onChange={e => set('icon', e.target.value)} placeholder="or type emoji" className="flex-1 min-w-[80px] border border-[#ECECEC] rounded-xl px-3 py-2 text-sm font-bold outline-none focus:border-[#FF6B2C]" />
            </div>
          </div>
          <div>
            <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Description</label>
            <textarea rows={2} value={form.description} onChange={e => set('description', e.target.value)} className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C] resize-none" />
          </div>
          <div className="flex items-center justify-between p-3 bg-[#F8F7FC] rounded-xl">
            <span className="text-sm font-black text-[#111827]">Active Status</span>
            <button onClick={() => set('status', !form.status)} className={form.status ? 'text-[#FF6B2C]' : 'text-gray-300'}>
              {form.status ? <ToggleRight size={28} /> : <ToggleLeft size={28} />}
            </button>
          </div>
        </div>
        <div className="flex gap-3 px-6 py-4 border-t border-[#F8F7FC]">
          <button onClick={onClose} disabled={saving} className="flex-1 border-2 border-[#ECECEC] text-gray-600 py-2.5 rounded-xl font-black text-sm disabled:opacity-50">Cancel</button>
          <button onClick={() => form.name && onSave(form)} disabled={saving || !form.name} className="flex-1 bg-[#FF6B2C] text-white py-2.5 rounded-xl font-black text-sm shadow-lg shadow-[#FF6B2C]/20 hover:bg-[#E05520] disabled:opacity-60 flex items-center justify-center gap-2">
            {saving ? <><Loader2 size={14} className="animate-spin" />Saving...</> : isEdit ? 'Save Changes' : 'Add Category'}
          </button>
        </div>
      </div>
    </div>
  );
};

const DeleteConfirm: React.FC<{ name: string; onConfirm: () => void; onCancel: () => void }> = ({ name, onConfirm, onCancel }) => (
  <div className="fixed inset-0 bg-black/40 backdrop-blur-sm z-50 flex items-center justify-center p-4">
    <div className="bg-white rounded-2xl shadow-2xl w-full max-w-sm p-6 text-center">
      <div className="w-14 h-14 bg-red-50 rounded-full flex items-center justify-center mx-auto mb-4"><Trash2 size={24} className="text-red-500" /></div>
      <h3 className="text-lg font-black text-[#111827] mb-2">Delete Category?</h3>
      <p className="text-sm font-bold text-gray-400 mb-6">Delete <span className="text-[#111827]">"{name}"</span>? All products in this category will become uncategorized.</p>
      <div className="flex gap-3">
        <button onClick={onCancel} className="flex-1 border-2 border-[#ECECEC] text-gray-600 py-2.5 rounded-xl font-black text-sm">Cancel</button>
        <button onClick={onConfirm} className="flex-1 bg-red-500 text-white py-2.5 rounded-xl font-black text-sm hover:bg-red-600">Delete</button>
      </div>
    </div>
  </div>
);

const AdminCategories: React.FC = () => {
  const [categories, setCategories] = useState<Category[]>([]);
  const [showForm, setShowForm] = useState(false);
  const [editing, setEditing] = useState<Category | null>(null);
  const [deleting, setDeleting] = useState<Category | null>(null);
  const [toast, setToast] = useState('');
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);

  const showToast = (msg: string) => { setToast(msg); setTimeout(() => setToast(''), 3000); };

  const loadCategories = async () => {
    setLoading(true);
    try {
      const res = await apiGet<{ success: boolean; data: { categories: ApiCategory[] } }>('/admin/categories');
      if (res.data?.categories) setCategories(res.data.categories.map(normalizeApiCat));
    } catch (e: any) {
      showErrorDialog({ title: 'Couldn’t load coupons', error: e });
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { loadCategories(); }, []);

  const handleToggle = async (id: string) => {
    const cat = categories.find(c => c.id === id);
    if (!cat) return;
    const newStatus = !cat.status;
    setCategories(prev => prev.map(c => c.id === id ? { ...c, status: newStatus } : c));
    try {
      await apiPut(`/admin/categories/${id}`, { is_active: newStatus });
      showToast('Category status updated!');
    } catch {
      setCategories(prev => prev.map(c => c.id === id ? { ...c, status: cat.status } : c));
    }
  };

  const handleSave = async (c: Category) => {
    setSaving(true);
    try {
      const payload = { name: c.name, icon: c.icon, description: c.description, is_active: c.status };
      if (editing) {
        await apiPut(`/admin/categories/${editing.id}`, payload);
        setCategories(prev => prev.map(x => x.id === editing.id ? { ...x, ...c } : x));
        showToast('Category updated successfully!');
      } else {
        const res = await apiPost<{ success: boolean; data: { category: ApiCategory } }>('/admin/categories', payload);
        setCategories(prev => [...prev, normalizeApiCat(res.data?.category ?? (res as any).data)]);
        showToast('Category added successfully!');
      }
      setShowForm(false); setEditing(null);
    } catch (e: any) {
      showErrorDialog({ title: 'Couldn’t save category', error: e });
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async () => {
    if (!deleting) return;
    try {
      await apiDelete(`/admin/categories/${deleting.id}`);
      setCategories(prev => prev.filter(c => c.id !== deleting.id));
      showToast('Category deleted!');
    } catch (e: any) {
      showErrorDialog({ title: 'Couldn’t delete category', error: e });
    } finally {
      setDeleting(null);
    }
  };

  return (
    <AdminLayout title="Categories" subtitle={`${categories.length} categories`}>
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        {[
          { label: 'Total', value: categories.length, color: '#FF6B2C' },
          { label: 'Active', value: categories.filter(c => c.status).length, color: '#10B981' },
          { label: 'Inactive', value: categories.filter(c => !c.status).length, color: '#9CA3AF' },
          { label: 'Total Products', value: categories.reduce((a, c) => a + c.products, 0).toLocaleString(), color: '#0EA5E9' },
        ].map((s, i) => (
          <div key={i} className="bg-white rounded-2xl p-4 border border-[#ECECEC] shadow-sm">
            <p className="text-2xl font-black mb-1" style={{ color: s.color }}>{s.value}</p>
            <p className="text-xs font-bold text-gray-400">{s.label}</p>
          </div>
        ))}
      </div>

      <div className="flex items-center justify-between mb-4">
        <h3 className="text-sm font-black text-[#111827]">All Categories</h3>
        <button onClick={() => { setEditing(null); setShowForm(true); }} className="flex items-center gap-2 bg-[#FF6B2C] text-white px-5 py-2.5 rounded-xl font-black text-sm shadow-lg shadow-[#FF6B2C]/20 hover:bg-[#E05520]">
          <Plus size={16} /> Add Category
        </button>
      </div>

      {loading ? (
        <div className="flex items-center justify-center py-12 gap-2 text-gray-400">
          <Loader2 size={18} className="animate-spin" />
          <span className="text-sm font-bold">Loading categories...</span>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
          {categories.map((cat) => (
            <div key={cat.id} className={`bg-white rounded-2xl border shadow-sm p-5 hover:shadow-md transition-shadow group ${cat.status ? 'border-[#ECECEC]' : 'border-dashed border-gray-200 opacity-70'}`}>
              <div className="flex items-start justify-between mb-4">
                <div className="flex items-center gap-3">
                  <div className="w-12 h-12 bg-[#FFF8F5] rounded-2xl flex items-center justify-center text-2xl">{cat.icon}</div>
                  <div>
                    <h4 className="text-sm font-black text-[#111827]">{cat.name}</h4>
                    <p className="text-[10px] font-bold text-gray-400">{cat.description}</p>
                  </div>
                </div>
                <button onClick={() => handleToggle(cat.id)} className={cat.status ? 'text-[#FF6B2C]' : 'text-gray-300'}>
                  {cat.status ? <ToggleRight size={24} /> : <ToggleLeft size={24} />}
                </button>
              </div>

              <div className="grid grid-cols-2 gap-3 py-4 border-y border-[#F8F7FC] mb-4">
                <div className="text-center">
                  <p className="text-lg font-black text-[#111827]">{cat.products}</p>
                  <p className="text-[9px] font-bold text-gray-400 uppercase tracking-widest">Products</p>
                </div>
                <div className="text-center border-l border-[#F8F7FC]">
                  <p className="text-xs font-black text-[#FF6B2C]">{cat.revenue}</p>
                  <p className="text-[9px] font-bold text-gray-400 uppercase tracking-widest">Revenue</p>
                </div>
              </div>

              <div className="flex items-center justify-between">
                <span className={`text-[10px] font-black px-2.5 py-1 rounded-lg uppercase tracking-wide ${cat.status ? 'bg-green-50 text-green-600' : 'bg-gray-100 text-gray-500'}`}>
                  {cat.status ? 'Active' : 'Inactive'}
                </span>
                <div className="flex items-center gap-2">
                  <button onClick={() => { setEditing(cat); setShowForm(true); }} className="w-7 h-7 rounded-lg bg-[#F8F7FC] flex items-center justify-center text-gray-500 hover:bg-[#FFF3ED] hover:text-[#FF6B2C] transition-colors"><Edit2 size={13} /></button>
                  <button onClick={() => setDeleting(cat)} className="w-7 h-7 rounded-lg bg-[#F8F7FC] flex items-center justify-center text-gray-500 hover:bg-red-50 hover:text-red-500 transition-colors"><Trash2 size={13} /></button>
                </div>
              </div>
            </div>
          ))}
          {categories.length === 0 && (
            <div className="col-span-3 py-12 text-center text-sm font-bold text-gray-400">No categories yet</div>
          )}
        </div>
      )}

      {showForm && <CategoryForm initial={editing || {}} onSave={handleSave} onClose={() => { setShowForm(false); setEditing(null); }} isEdit={!!editing} saving={saving} />}
      {deleting && <DeleteConfirm name={deleting.name} onConfirm={handleDelete} onCancel={() => setDeleting(null)} />}
      {toast && <Toast msg={toast} onClose={() => setToast('')} />}
    </AdminLayout>
  );
};

export default AdminCategories;
