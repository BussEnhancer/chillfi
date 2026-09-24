import React, { useState, useEffect } from 'react';
import AdminLayout from '../../../components/admin/AdminLayout';
import { Plus, Edit2, Trash2, ToggleLeft, ToggleRight, X, Check, Loader2, Tag } from 'lucide-react';
import { apiGet, apiPost, apiPut, apiDelete } from '../../../utils/api';

interface ApiBrand {
  id: string;
  name: string;
  logo_url?: string;
  is_active?: boolean;
  product_count?: number | string;
}

interface Brand {
  id: string;
  name: string;
  logo_url: string;
  is_active: boolean;
  product_count: number;
}

const normalizeBrand = (b: ApiBrand): Brand => ({
  id: b.id,
  name: b.name || '',
  logo_url: b.logo_url || '',
  is_active: b.is_active !== undefined ? b.is_active : true,
  product_count: Number(b.product_count || 0),
});

const Toast: React.FC<{ msg: string; onClose: () => void }> = ({ msg, onClose }) => (
  <div className="fixed bottom-6 right-6 z-[100] flex items-center gap-3 bg-[#121212] text-white px-5 py-3.5 rounded-2xl shadow-2xl">
    <div className="w-6 h-6 bg-green-500 rounded-full flex items-center justify-center shrink-0"><Check size={13} /></div>
    <span className="text-sm font-bold">{msg}</span>
    <button onClick={onClose} className="ml-2 text-white/50 hover:text-white"><X size={14} /></button>
  </div>
);

const BrandForm: React.FC<{
  initial: Partial<Brand>;
  onSave: (b: Brand) => Promise<void>;
  onClose: () => void;
  isEdit: boolean;
  saving: boolean;
}> = ({ initial, onSave, onClose, isEdit, saving }) => {
  const [form, setForm] = useState<Brand>({
    id: '', name: '', logo_url: '', is_active: true, product_count: 0,
    ...initial,
  });
  const set = (k: keyof Brand, v: string | boolean | number) => setForm(f => ({ ...f, [k]: v }));

  return (
    <div className="fixed inset-0 bg-black/40 backdrop-blur-sm z-50 flex items-center justify-center p-4">
      <div className="bg-white rounded-2xl shadow-2xl w-full max-w-md">
        <div className="flex items-center justify-between px-6 py-4 border-b border-[#F8F7FC]">
          <h3 className="text-lg font-black text-[#111827]">{isEdit ? 'Edit Brand' : 'Add New Brand'}</h3>
          <button onClick={onClose} disabled={saving} className="w-8 h-8 rounded-xl bg-[#F8F7FC] flex items-center justify-center hover:bg-red-50 hover:text-red-500 transition-colors"><X size={16} /></button>
        </div>
        <div className="p-6 space-y-4">
          <div>
            <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Brand Name *</label>
            <input
              value={form.name}
              onChange={e => set('name', e.target.value)}
              placeholder="e.g. Samsung"
              className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C]"
            />
          </div>
          <div>
            <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Logo URL</label>
            <input
              value={form.logo_url}
              onChange={e => set('logo_url', e.target.value)}
              placeholder="https://example.com/logo.png"
              className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C]"
            />
            {form.logo_url && (
              <div className="mt-2 w-16 h-16 rounded-xl border border-[#ECECEC] overflow-hidden flex items-center justify-center bg-gray-50">
                <img src={form.logo_url} alt="preview" className="max-w-full max-h-full object-contain p-1" onError={e => (e.currentTarget.style.display = 'none')} />
              </div>
            )}
          </div>
          <div className="flex items-center justify-between p-3 bg-[#F8F7FC] rounded-xl">
            <span className="text-sm font-black text-[#111827]">Active Status</span>
            <button onClick={() => set('is_active', !form.is_active)} className={form.is_active ? 'text-[#FF6B2C]' : 'text-gray-300'}>
              {form.is_active ? <ToggleRight size={28} /> : <ToggleLeft size={28} />}
            </button>
          </div>
        </div>
        <div className="flex gap-3 px-6 py-4 border-t border-[#F8F7FC]">
          <button onClick={onClose} disabled={saving} className="flex-1 border-2 border-[#ECECEC] text-gray-600 py-2.5 rounded-xl font-black text-sm disabled:opacity-50">Cancel</button>
          <button
            onClick={() => form.name && onSave(form)}
            disabled={saving || !form.name}
            className="flex-1 bg-[#FF6B2C] text-white py-2.5 rounded-xl font-black text-sm shadow-lg shadow-[#FF6B2C]/20 hover:bg-[#E05520] disabled:opacity-60 flex items-center justify-center gap-2"
          >
            {saving ? <><Loader2 size={14} className="animate-spin" />Saving...</> : isEdit ? 'Save Changes' : 'Add Brand'}
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
      <h3 className="text-lg font-black text-[#111827] mb-2">Delete Brand?</h3>
      <p className="text-sm font-bold text-gray-400 mb-6">Delete <span className="text-[#111827]">"{name}"</span>? Products under this brand will become unbranded.</p>
      <div className="flex gap-3">
        <button onClick={onCancel} className="flex-1 border-2 border-[#ECECEC] text-gray-600 py-2.5 rounded-xl font-black text-sm">Cancel</button>
        <button onClick={onConfirm} className="flex-1 bg-red-500 text-white py-2.5 rounded-xl font-black text-sm hover:bg-red-600">Delete</button>
      </div>
    </div>
  </div>
);

const AdminBrands: React.FC = () => {
  const [brands, setBrands] = useState<Brand[]>([]);
  const [showForm, setShowForm] = useState(false);
  const [editing, setEditing] = useState<Brand | null>(null);
  const [deleting, setDeleting] = useState<Brand | null>(null);
  const [toast, setToast] = useState('');
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);

  const showToast = (msg: string) => { setToast(msg); setTimeout(() => setToast(''), 3000); };

  const loadBrands = async () => {
    setLoading(true);
    try {
      const res = await apiGet<{ success: boolean; data: { brands: ApiBrand[] } }>('/admin/brands');
      if (res.data?.brands) setBrands(res.data.brands.map(normalizeBrand));
    } catch {
      // keep existing
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { loadBrands(); }, []);

  const handleToggle = async (id: string) => {
    const brand = brands.find(b => b.id === id);
    if (!brand) return;
    const newStatus = !brand.is_active;
    setBrands(prev => prev.map(b => b.id === id ? { ...b, is_active: newStatus } : b));
    try {
      await apiPut(`/admin/brands/${id}`, { is_active: newStatus });
      showToast('Brand status updated!');
    } catch {
      setBrands(prev => prev.map(b => b.id === id ? { ...b, is_active: brand.is_active } : b));
    }
  };

  const handleSave = async (b: Brand) => {
    setSaving(true);
    try {
      const payload = { name: b.name, logo_url: b.logo_url, is_active: b.is_active };
      if (editing) {
        await apiPut(`/admin/brands/${editing.id}`, payload);
        setBrands(prev => prev.map(x => x.id === editing.id ? { ...x, ...b } : x));
        showToast('Brand updated successfully!');
      } else {
        const res = await apiPost<{ success: boolean; data: { brand: ApiBrand } }>('/admin/brands', payload);
        setBrands(prev => [...prev, normalizeBrand(res.data?.brand ?? (res as any).data)]);
        showToast('Brand added successfully!');
      }
      setShowForm(false); setEditing(null);
    } catch (e: unknown) {
      showToast(e instanceof Error ? e.message : 'Failed to save brand');
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async () => {
    if (!deleting) return;
    try {
      await apiDelete(`/admin/brands/${deleting.id}`);
      setBrands(prev => prev.filter(b => b.id !== deleting.id));
      showToast('Brand deleted!');
    } catch (e: unknown) {
      showToast(e instanceof Error ? e.message : 'Failed to delete brand');
    } finally {
      setDeleting(null);
    }
  };

  return (
    <AdminLayout title="Brands" subtitle={`${brands.length} brands`}>
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        {[
          { label: 'Total', value: brands.length, color: '#FF6B2C' },
          { label: 'Active', value: brands.filter(b => b.is_active).length, color: '#10B981' },
          { label: 'Inactive', value: brands.filter(b => !b.is_active).length, color: '#9CA3AF' },
          { label: 'Total Products', value: brands.reduce((a, b) => a + b.product_count, 0).toLocaleString(), color: '#0EA5E9' },
        ].map((s, i) => (
          <div key={i} className="bg-white rounded-2xl p-4 border border-[#ECECEC] shadow-sm">
            <p className="text-2xl font-black mb-1" style={{ color: s.color }}>{s.value}</p>
            <p className="text-xs font-bold text-gray-400">{s.label}</p>
          </div>
        ))}
      </div>

      <div className="flex items-center justify-between mb-4">
        <h3 className="text-sm font-black text-[#111827]">All Brands</h3>
        <button onClick={() => { setEditing(null); setShowForm(true); }} className="flex items-center gap-2 bg-[#FF6B2C] text-white px-5 py-2.5 rounded-xl font-black text-sm shadow-lg shadow-[#FF6B2C]/20 hover:bg-[#E05520]">
          <Plus size={16} /> Add Brand
        </button>
      </div>

      {loading ? (
        <div className="flex items-center justify-center py-12 gap-2 text-gray-400">
          <Loader2 size={18} className="animate-spin" />
          <span className="text-sm font-bold">Loading brands...</span>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
          {brands.map(brand => (
            <div key={brand.id} className={`bg-white rounded-2xl border shadow-sm p-5 hover:shadow-md transition-shadow ${brand.is_active ? 'border-[#ECECEC]' : 'border-dashed border-gray-200 opacity-70'}`}>
              <div className="flex items-start justify-between mb-4">
                <div className="flex items-center gap-3">
                  <div className="w-12 h-12 bg-[#FFF8F5] rounded-2xl flex items-center justify-center overflow-hidden border border-[#ECECEC]">
                    {brand.logo_url
                      ? <img src={brand.logo_url} alt={brand.name} className="max-w-full max-h-full object-contain p-1" onError={e => { e.currentTarget.style.display = 'none'; }} />
                      : <Tag size={20} className="text-[#FF6B2C]" />}
                  </div>
                  <div>
                    <h4 className="text-sm font-black text-[#111827]">{brand.name}</h4>
                    <p className="text-[10px] font-bold text-gray-400">{brand.product_count} products</p>
                  </div>
                </div>
                <button onClick={() => handleToggle(brand.id)} className={brand.is_active ? 'text-[#FF6B2C]' : 'text-gray-300'}>
                  {brand.is_active ? <ToggleRight size={24} /> : <ToggleLeft size={24} />}
                </button>
              </div>

              <div className="flex items-center justify-between pt-4 border-t border-[#F8F7FC]">
                <span className={`text-[10px] font-black px-2.5 py-1 rounded-lg uppercase tracking-wide ${brand.is_active ? 'bg-green-50 text-green-600' : 'bg-gray-100 text-gray-500'}`}>
                  {brand.is_active ? 'Active' : 'Inactive'}
                </span>
                <div className="flex items-center gap-2">
                  <button onClick={() => { setEditing(brand); setShowForm(true); }} className="w-7 h-7 rounded-lg bg-[#F8F7FC] flex items-center justify-center text-gray-500 hover:bg-[#FFF3ED] hover:text-[#FF6B2C] transition-colors"><Edit2 size={13} /></button>
                  <button onClick={() => setDeleting(brand)} className="w-7 h-7 rounded-lg bg-[#F8F7FC] flex items-center justify-center text-gray-500 hover:bg-red-50 hover:text-red-500 transition-colors"><Trash2 size={13} /></button>
                </div>
              </div>
            </div>
          ))}
          {brands.length === 0 && (
            <div className="col-span-3 py-12 text-center text-sm font-bold text-gray-400">No brands yet. Add your first brand!</div>
          )}
        </div>
      )}

      {showForm && <BrandForm initial={editing || {}} onSave={handleSave} onClose={() => { setShowForm(false); setEditing(null); }} isEdit={!!editing} saving={saving} />}
      {deleting && <DeleteConfirm name={deleting.name} onConfirm={handleDelete} onCancel={() => setDeleting(null)} />}
      {toast && <Toast msg={toast} onClose={() => setToast('')} />}
    </AdminLayout>
  );
};

export default AdminBrands;
