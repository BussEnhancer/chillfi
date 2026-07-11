import React, { useState, useEffect } from 'react';
import AdminLayout from '../../../components/admin/AdminLayout';
import { Plus, Edit2, Trash2, Copy, Tag, ToggleLeft, ToggleRight, X, Check, Loader2 } from 'lucide-react';
import { apiGet, apiPost, apiPut, apiDelete } from '../../../utils/api';
import { Coupon } from '../../../context/StoreContext';

const types = ['Percentage', 'Flat', 'Free Shipping'];

interface ApiCoupon {
  id: string; code?: string; type?: string; value?: number | string;
  min_order?: number | string; max_discount?: number | string;
  used_count?: number | string; total_uses?: number | string; usage_limit?: number | string;
  expires_at?: string; is_active?: boolean;
}

const normalizeApiCoupon = (c: ApiCoupon): Coupon => ({
  id: c.id,
  code: c.code || '',
  type: c.type === 'percentage' ? 'Percentage' : c.type === 'flat' ? 'Flat' : c.type === 'free_shipping' ? 'Free Shipping' : (c.type || 'Percentage'),
  value: Number(c.value || 0),
  minOrder: Number(c.min_order || 0),
  maxDiscount: Number(c.max_discount || 0),
  used: Number(c.used_count || 0),
  total: Number(c.usage_limit ?? c.total_uses ?? 1000),
  expiry: c.expires_at ? c.expires_at.slice(0, 10) : '',
  status: c.is_active !== undefined ? c.is_active : true,
});

const apiTypeMap: Record<string, string> = { 'Percentage': 'percentage', 'Flat': 'flat', 'Free Shipping': 'free_shipping' };

const Toast: React.FC<{ msg: string; onClose: () => void }> = ({ msg, onClose }) => (
  <div className="fixed bottom-6 right-6 z-[100] flex items-center gap-3 bg-[#121212] text-white px-5 py-3.5 rounded-2xl shadow-2xl">
    <div className="w-6 h-6 bg-green-500 rounded-full flex items-center justify-center shrink-0"><Check size={13} /></div>
    <span className="text-sm font-bold">{msg}</span>
    <button onClick={onClose} className="ml-2 text-white/50 hover:text-white"><X size={14} /></button>
  </div>
);

const CouponForm: React.FC<{ initial: Partial<Coupon>; onSave: (c: Coupon) => Promise<void>; onClose: () => void; isEdit: boolean; saving: boolean }> = ({ initial, onSave, onClose, isEdit, saving }) => {
  const [form, setForm] = useState<Coupon>({ id: '', code: '', type: 'Percentage', value: 0, minOrder: 0, maxDiscount: 0, used: 0, total: 1000, expiry: '', status: true, ...initial });
  const set = (k: keyof Coupon, v: any) => setForm(f => ({ ...f, [k]: v }));

  return (
    <div className="fixed inset-0 bg-black/40 backdrop-blur-sm z-50 flex items-center justify-center p-4">
      <div className="bg-white rounded-2xl shadow-2xl w-full max-w-md max-h-[90vh] flex flex-col">
        <div className="flex items-center justify-between px-6 py-4 border-b border-[#F8F7FC] shrink-0">
          <h3 className="text-lg font-black text-[#111827]">{isEdit ? 'Edit Coupon' : 'Create New Coupon'}</h3>
          <button onClick={onClose} disabled={saving} className="w-8 h-8 rounded-xl bg-[#F8F7FC] flex items-center justify-center hover:bg-red-50 hover:text-red-500 transition-colors"><X size={16} /></button>
        </div>
        <div className="overflow-y-auto p-6 space-y-4">
          <div>
            <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Coupon Code *</label>
            <input value={form.code} onChange={e => set('code', e.target.value.toUpperCase())} placeholder="e.g. SAVE20" className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-black uppercase tracking-widest outline-none focus:border-[#FF6B2C]" />
          </div>
          <div>
            <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Discount Type</label>
            <select value={form.type} onChange={e => set('type', e.target.value)} className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C]">
              {types.map(t => <option key={t}>{t}</option>)}
            </select>
          </div>
          <div className="grid grid-cols-2 gap-3">
            {form.type !== 'Free Shipping' && (
              <div>
                <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">
                  {form.type === 'Percentage' ? 'Discount %' : 'Flat Amount (₹)'}
                </label>
                <input type="number" value={form.value} onChange={e => set('value', +e.target.value)} className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C]" />
              </div>
            )}
            <div>
              <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Min. Order (₹)</label>
              <input type="number" value={form.minOrder} onChange={e => set('minOrder', +e.target.value)} className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C]" />
            </div>
            <div>
              <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Max Discount (₹)</label>
              <input type="number" value={form.maxDiscount} onChange={e => set('maxDiscount', +e.target.value)} className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C]" />
            </div>
            <div>
              <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Usage Limit</label>
              <input type="number" value={form.total} onChange={e => set('total', +e.target.value)} className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C]" />
            </div>
          </div>
          <div>
            <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Expiry Date</label>
            <input type="date" value={form.expiry} onChange={e => set('expiry', e.target.value)} className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C]" />
          </div>
          <div className="flex items-center justify-between p-3 bg-[#F8F7FC] rounded-xl">
            <span className="text-sm font-black text-[#111827]">Active</span>
            <button onClick={() => set('status', !form.status)} className={form.status ? 'text-[#FF6B2C]' : 'text-gray-300'}>
              {form.status ? <ToggleRight size={28} /> : <ToggleLeft size={28} />}
            </button>
          </div>
        </div>
        <div className="flex gap-3 px-6 py-4 border-t border-[#F8F7FC] shrink-0">
          <button onClick={onClose} disabled={saving} className="flex-1 border-2 border-[#ECECEC] text-gray-600 py-2.5 rounded-xl font-black text-sm disabled:opacity-50">Cancel</button>
          <button onClick={() => form.code && onSave(form)} disabled={saving || !form.code} className="flex-1 bg-[#FF6B2C] text-white py-2.5 rounded-xl font-black text-sm shadow-lg shadow-[#FF6B2C]/20 hover:bg-[#E05520] disabled:opacity-60 flex items-center justify-center gap-2">
            {saving ? <><Loader2 size={14} className="animate-spin" />Saving...</> : isEdit ? 'Save Changes' : 'Create Coupon'}
          </button>
        </div>
      </div>
    </div>
  );
};

const DeleteConfirm: React.FC<{ code: string; onConfirm: () => void; onCancel: () => void }> = ({ code, onConfirm, onCancel }) => (
  <div className="fixed inset-0 bg-black/40 backdrop-blur-sm z-50 flex items-center justify-center p-4">
    <div className="bg-white rounded-2xl shadow-2xl w-full max-w-sm p-6 text-center">
      <div className="w-14 h-14 bg-red-50 rounded-full flex items-center justify-center mx-auto mb-4"><Trash2 size={24} className="text-red-500" /></div>
      <h3 className="text-lg font-black text-[#111827] mb-2">Delete Coupon?</h3>
      <p className="text-sm font-bold text-gray-400 mb-6">Delete coupon <span className="text-[#111827] font-black">{code}</span>? Active users won't be able to use it.</p>
      <div className="flex gap-3">
        <button onClick={onCancel} className="flex-1 border-2 border-[#ECECEC] text-gray-600 py-2.5 rounded-xl font-black text-sm">Cancel</button>
        <button onClick={onConfirm} className="flex-1 bg-red-500 text-white py-2.5 rounded-xl font-black text-sm hover:bg-red-600">Delete</button>
      </div>
    </div>
  </div>
);

const AdminCoupons: React.FC = () => {
  const [coupons, setCoupons] = useState<Coupon[]>([]);
  const [showForm, setShowForm] = useState(false);
  const [editing, setEditing] = useState<Coupon | null>(null);
  const [deleting, setDeleting] = useState<Coupon | null>(null);
  const [toast, setToast] = useState('');
  const [copiedId, setCopiedId] = useState('');
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);

  const showToast = (msg: string) => { setToast(msg); setTimeout(() => setToast(''), 3000); };

  const loadCoupons = async () => {
    setLoading(true);
    try {
      const res = await apiGet<{ success: boolean; data: ApiCoupon[] }>('/admin/coupons');
      if (res.data) setCoupons(res.data.map(normalizeApiCoupon));
    } catch {
      // keep existing
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { loadCoupons(); }, []);

  const handleCopy = (code: string, id: string) => {
    navigator.clipboard.writeText(code).catch(() => {});
    setCopiedId(id);
    showToast(`"${code}" copied to clipboard!`);
    setTimeout(() => setCopiedId(''), 2000);
  };

  const handleToggle = async (id: string) => {
    const c = coupons.find(x => x.id === id);
    if (!c) return;
    const newStatus = !c.status;
    setCoupons(prev => prev.map(x => x.id === id ? { ...x, status: newStatus } : x));
    try {
      await apiPut(`/admin/coupons/${id}`, { is_active: newStatus });
      showToast('Coupon status updated!');
    } catch {
      setCoupons(prev => prev.map(x => x.id === id ? { ...x, status: c.status } : x));
    }
  };

  const handleSave = async (c: Coupon) => {
    setSaving(true);
    try {
      const payload = {
        code: c.code,
        type: c.type,
        value: c.value,
        min_order: c.minOrder,
        max_discount: c.maxDiscount,
        usage_limit: c.total || null,
        expires_at: c.expiry || null,
        is_active: c.status,
      };

      if (editing) {
        const res = await apiPut<{ success: boolean; data: ApiCoupon }>(`/admin/coupons/${editing.id}`, payload);
        setCoupons(prev => prev.map(x => x.id === editing.id ? normalizeApiCoupon(res.data) : x));
        showToast('Coupon updated successfully!');
      } else {
        const res = await apiPost<{ success: boolean; data: ApiCoupon }>('/admin/coupons', payload);
        setCoupons(prev => [...prev, normalizeApiCoupon(res.data)]);
        showToast('Coupon created successfully!');
      }
      setShowForm(false); setEditing(null);
    } catch (e: any) {
      showToast(e.message || 'Failed to save coupon');
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async () => {
    if (!deleting) return;
    try {
      await apiDelete(`/admin/coupons/${deleting.id}`);
      setCoupons(prev => prev.filter(c => c.id !== deleting.id));
      showToast('Coupon deleted!');
    } catch (e: any) {
      showToast(e.message || 'Failed to delete coupon');
    } finally {
      setDeleting(null);
    }
  };

  const formatExpiry = (d: string) => {
    if (!d) return 'No expiry';
    try { return new Date(d).toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' }); } catch { return d; }
  };

  return (
    <AdminLayout title="Coupons" subtitle={`${coupons.length} coupons`}>
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        {[
          { label: 'Total Coupons', value: coupons.length, color: '#FF6B2C' },
          { label: 'Active', value: coupons.filter(c => c.status).length, color: '#10B981' },
          { label: 'Inactive', value: coupons.filter(c => !c.status).length, color: '#9CA3AF' },
          { label: 'Total Used', value: coupons.reduce((a, c) => a + c.used, 0).toLocaleString(), color: '#0EA5E9' },
        ].map((s, i) => (
          <div key={i} className="bg-white rounded-2xl p-4 border border-[#ECECEC] shadow-sm">
            <p className="text-2xl font-black mb-1" style={{ color: s.color }}>{s.value}</p>
            <p className="text-xs font-bold text-gray-400">{s.label}</p>
          </div>
        ))}
      </div>

      <div className="flex items-center justify-between mb-4">
        <h3 className="text-sm font-black text-[#111827]">All Coupons</h3>
        <button onClick={() => { setEditing(null); setShowForm(true); }} className="flex items-center gap-2 bg-[#FF6B2C] text-white px-5 py-2.5 rounded-xl font-black text-sm shadow-lg shadow-[#FF6B2C]/20 hover:bg-[#E05520]">
          <Plus size={16} /> Create Coupon
        </button>
      </div>

      {loading ? (
        <div className="flex items-center justify-center py-12 gap-2 text-gray-400">
          <Loader2 size={18} className="animate-spin" />
          <span className="text-sm font-bold">Loading coupons...</span>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
          {coupons.map((c) => (
            <div key={c.id} className={`bg-white rounded-2xl border shadow-sm overflow-hidden hover:shadow-md transition-shadow group ${c.status ? 'border-[#ECECEC]' : 'border-dashed border-gray-200 opacity-70'}`}>
              <div className="bg-gradient-to-r from-[#FF6B2C] to-[#9B59FF] p-4 flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <Tag size={15} className="text-white/70" />
                  <span className="text-base font-black text-white tracking-widest">{c.code}</span>
                </div>
                <button
                  onClick={() => handleCopy(c.code, c.id)}
                  className="w-7 h-7 bg-white/20 rounded-lg flex items-center justify-center text-white hover:bg-white/30 transition-colors"
                  title="Copy code"
                >
                  {copiedId === c.id ? <Check size={13} /> : <Copy size={13} />}
                </button>
              </div>

              <div className="p-4">
                <div className="flex items-center justify-between mb-3">
                  <div>
                    <p className="text-xl font-black text-[#111827]">
                      {c.type === 'Percentage' ? `${c.value}% OFF` : c.type === 'Flat' ? `₹${c.value} OFF` : 'FREE SHIPPING'}
                    </p>
                    <p className="text-[10px] font-bold text-gray-400">Min. ₹{c.minOrder} • Max ₹{c.maxDiscount}</p>
                  </div>
                  <button onClick={() => handleToggle(c.id)} className={c.status ? 'text-[#FF6B2C]' : 'text-gray-300'}>
                    {c.status ? <ToggleRight size={26} /> : <ToggleLeft size={26} />}
                  </button>
                </div>

                {c.total > 0 && (
                  <div className="mb-3">
                    <div className="flex justify-between text-[10px] font-bold text-gray-400 mb-1">
                      <span>{c.used} used</span>
                      <span>{c.total} limit</span>
                    </div>
                    <div className="w-full bg-[#F8F7FC] rounded-full h-1.5">
                      <div className="h-1.5 rounded-full bg-[#FF6B2C] transition-all" style={{ width: `${Math.min((c.used / c.total) * 100, 100)}%` }} />
                    </div>
                  </div>
                )}

                <div className="flex items-center justify-between">
                  <span className="text-[10px] font-bold text-gray-400">Expires {formatExpiry(c.expiry)}</span>
                  <div className="flex items-center gap-1.5">
                    <button onClick={() => { setEditing(c); setShowForm(true); }} className="w-7 h-7 rounded-lg bg-[#F8F7FC] flex items-center justify-center text-gray-500 hover:bg-[#FFF3ED] hover:text-[#FF6B2C] transition-colors"><Edit2 size={12} /></button>
                    <button onClick={() => setDeleting(c)} className="w-7 h-7 rounded-lg bg-[#F8F7FC] flex items-center justify-center text-gray-500 hover:bg-red-50 hover:text-red-500 transition-colors"><Trash2 size={12} /></button>
                  </div>
                </div>
              </div>
            </div>
          ))}
          {coupons.length === 0 && (
            <div className="col-span-3 py-12 text-center text-sm font-bold text-gray-400">No coupons yet</div>
          )}
        </div>
      )}

      {showForm && <CouponForm initial={editing || {}} onSave={handleSave} onClose={() => { setShowForm(false); setEditing(null); }} isEdit={!!editing} saving={saving} />}
      {deleting && <DeleteConfirm code={deleting.code} onConfirm={handleDelete} onCancel={() => setDeleting(null)} />}
      {toast && <Toast msg={toast} onClose={() => setToast('')} />}
    </AdminLayout>
  );
};

export default AdminCoupons;
