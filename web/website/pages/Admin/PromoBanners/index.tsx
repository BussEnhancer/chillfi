import React, { useState, useEffect, useRef } from 'react';
import AdminLayout from '../../../components/admin/AdminLayout';
import { Plus, Edit2, Trash2, ToggleLeft, ToggleRight, X, Check, Loader2, Zap, Upload } from 'lucide-react';
import { apiGet, apiPost, apiPut, apiDelete, uploadImage } from '../../../utils/api';
import { showErrorDialog } from '../../../components/feedback/ErrorDialog';

interface PromoBanner {
  id: string;
  title: string;
  subtitle?: string;
  image_url?: string;
  link?: string;
  background_color?: string;
  sort_order: number;
  is_active: boolean;
}

interface PromoForm {
  title: string;
  subtitle: string;
  image_url: string;
  link: string;
  background_color: string;
  sort_order: number;
  is_active: boolean;
}

const EMPTY_FORM: PromoForm = {
  title: '', subtitle: '', image_url: '', link: '',
  background_color: '', sort_order: 0, is_active: true,
};

const Toast: React.FC<{ msg: string; onClose: () => void }> = ({ msg, onClose }) => (
  <div className="fixed bottom-6 right-6 z-[100] flex items-center gap-3 bg-[#121212] text-white px-5 py-3.5 rounded-2xl shadow-2xl">
    <div className="w-6 h-6 bg-green-500 rounded-full flex items-center justify-center shrink-0"><Check size={13} /></div>
    <span className="text-sm font-bold">{msg}</span>
    <button onClick={onClose} className="ml-2 text-white/50 hover:text-white"><X size={14} /></button>
  </div>
);

const PromoFormModal: React.FC<{
  initial: PromoForm;
  isEdit: boolean;
  saving: boolean;
  onSave: (f: PromoForm, imageFile?: File) => void;
  onClose: () => void;
}> = ({ initial, isEdit, saving, onSave, onClose }) => {
  const [form, setForm] = useState<PromoForm>(initial);
  const [imageFile, setImageFile] = useState<File | null>(null);
  const [imagePreview, setImagePreview] = useState(initial.image_url);
  const fileRef = useRef<HTMLInputElement>(null);
  const set = (k: keyof PromoForm, v: any) => setForm(f => ({ ...f, [k]: v }));

  const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    setImageFile(file);
    setImagePreview(URL.createObjectURL(file));
  };

  return (
    <div className="fixed inset-0 bg-black/40 backdrop-blur-sm z-50 flex items-center justify-center p-4">
      <div className="bg-white rounded-2xl shadow-2xl w-full max-w-lg max-h-[90vh] flex flex-col">
        <div className="flex items-center justify-between px-6 py-4 border-b border-[#F8F7FC] shrink-0">
          <h3 className="text-lg font-black text-[#111827]">{isEdit ? 'Edit Promo Banner' : 'Add New Promo Banner'}</h3>
          <button onClick={onClose} disabled={saving} className="w-8 h-8 rounded-xl bg-[#F8F7FC] flex items-center justify-center hover:bg-red-50 hover:text-red-500 transition-colors">
            <X size={16} />
          </button>
        </div>

        <div className="overflow-y-auto p-6 space-y-4">
          <div>
            <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Title *</label>
            <input value={form.title} onChange={e => set('title', e.target.value)} placeholder="e.g. Get 10% Off First Order" className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C]" />
          </div>
          <div>
            <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Subtitle</label>
            <textarea value={form.subtitle} onChange={e => set('subtitle', e.target.value)} placeholder="Brief description" rows={2} className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C] resize-none" />
          </div>
          <div>
            <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Banner Image</label>
            <div className="w-full h-32 rounded-xl overflow-hidden bg-[#F8F7FC] border-2 border-dashed border-[#ECECEC] flex items-center justify-center mb-2">
              {imagePreview ? <img src={imagePreview} alt="Preview" className="w-full h-full object-cover" /> : <Zap size={24} className="text-gray-300" />}
            </div>
            <input ref={fileRef} type="file" accept="image/*" onChange={handleImageChange} className="hidden" />
            <button type="button" onClick={() => fileRef.current?.click()} className="flex items-center gap-2 px-4 py-2 border-2 border-dashed border-[#ECECEC] rounded-xl text-sm font-bold text-gray-500 hover:border-[#FF6B2C] hover:text-[#FF6B2C] transition-colors w-full justify-center">
              <Upload size={14} /> Upload Image
            </button>
            <p className="text-[10px] font-bold text-gray-400 mt-1.5 text-center">JPG, PNG, WebP • Max 5MB</p>
          </div>
          <div>
            <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Link URL</label>
            <input value={form.link} onChange={e => set('link', e.target.value)} placeholder="/products or https://..." className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C]" />
          </div>
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Background Color</label>
              <div className="flex gap-2 items-center">
                <input type="color" value={form.background_color || '#FF6B2C'} onChange={e => set('background_color', e.target.value)} className="w-10 h-10 rounded-lg border border-[#ECECEC] cursor-pointer p-1" />
                <input value={form.background_color} onChange={e => set('background_color', e.target.value)} placeholder="#FF6B2C" className="flex-1 border border-[#ECECEC] rounded-xl px-3 py-2 text-sm font-bold outline-none focus:border-[#FF6B2C]" />
              </div>
            </div>
            <div>
              <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Sort Order</label>
              <input type="number" value={form.sort_order} onChange={e => set('sort_order', +e.target.value)} min={0} className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C]" />
            </div>
          </div>
          <label className="flex items-center gap-3 cursor-pointer">
            <button type="button" onClick={() => set('is_active', !form.is_active)} className="shrink-0">
              {form.is_active
                ? <ToggleRight size={28} className="text-green-500" />
                : <ToggleLeft size={28} className="text-gray-300" />}
            </button>
            <span className="text-sm font-black text-[#111827]">{form.is_active ? 'Active — visible on homepage' : 'Inactive — hidden'}</span>
          </label>
        </div>

        <div className="px-6 py-4 border-t border-[#F8F7FC] shrink-0 flex justify-end gap-3">
          <button onClick={onClose} disabled={saving} className="px-5 py-2.5 rounded-xl border border-[#ECECEC] text-sm font-black text-gray-600 hover:bg-gray-50 disabled:opacity-50">Cancel</button>
          <button
            onClick={() => onSave(form, imageFile || undefined)}
            disabled={saving || !form.title.trim()}
            className="px-6 py-2.5 rounded-xl bg-[#FF6B2C] text-white text-sm font-black shadow-lg shadow-[#FF6B2C]/20 hover:scale-105 active:scale-95 transition-all disabled:opacity-50 disabled:scale-100 flex items-center gap-2"
          >
            {saving && <Loader2 size={14} className="animate-spin" />}
            {isEdit ? 'Save Changes' : 'Create Promo Banner'}
          </button>
        </div>
      </div>
    </div>
  );
};

const AdminPromoBanners: React.FC = () => {
  const [promos, setPromos] = useState<PromoBanner[]>([]);
  const [loading, setLoading] = useState(true);
  const [modal, setModal] = useState<{ open: boolean; editing: PromoBanner | null }>({ open: false, editing: null });
  const [saving, setSaving] = useState(false);
  const [deleting, setDeleting] = useState<string | null>(null);
  const [toast, setToast] = useState('');

  const showToast = (msg: string) => { setToast(msg); setTimeout(() => setToast(''), 3000); };

  const load = () => {
    setLoading(true);
    apiGet<{ success: boolean; data: PromoBanner[] }>('/admin/promo-banners')
      .then(res => setPromos(res.data || []))
      .catch((e) => showErrorDialog({ title: "Couldn't load promo banners", error: e }))
      .finally(() => setLoading(false));
  };

  useEffect(load, []);

  const openAdd = () => setModal({ open: true, editing: null });
  const openEdit = (p: PromoBanner) => setModal({ open: true, editing: p });
  const closeModal = () => setModal({ open: false, editing: null });

  const handleSave = async (form: PromoForm, imageFile?: File) => {
    setSaving(true);
    try {
      let image_url = form.image_url;
      if (imageFile) {
        image_url = await uploadImage(imageFile, 'chillfi/promo-banners');
      }
      const payload = { ...form, image_url };

      if (modal.editing) {
        await apiPut(`/admin/promo-banners/${modal.editing.id}`, payload);
        showToast('Promo banner updated');
      } else {
        await apiPost('/admin/promo-banners', payload);
        showToast('Promo banner created');
      }
      closeModal();
      load();
    } catch (e: any) {
      showErrorDialog({ title: 'Couldn’t save promo banner', error: e });
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async (id: string) => {
    if (!confirm('Delete this promo banner?')) return;
    setDeleting(id);
    try {
      await apiDelete(`/admin/promo-banners/${id}`);
      showToast('Promo banner deleted');
      load();
    } catch (e: any) {
      showErrorDialog({ title: "Couldn't update", error: e });
    } finally {
      setDeleting(null);
    }
  };

  const handleToggle = async (p: PromoBanner) => {
    try {
      await apiPut(`/admin/promo-banners/${p.id}`, { is_active: !p.is_active });
      setPromos(prev => prev.map(x => x.id === p.id ? { ...x, is_active: !x.is_active } : x));
      showToast(p.is_active ? 'Promo banner deactivated' : 'Promo banner activated');
    } catch (e: any) {
      showErrorDialog({ title: "Couldn't update", error: e });
    }
  };

  const formInitial = modal.editing
    ? {
        title: modal.editing.title || '',
        subtitle: modal.editing.subtitle || '',
        image_url: modal.editing.image_url || '',
        link: modal.editing.link || '',
        background_color: modal.editing.background_color || '',
        sort_order: modal.editing.sort_order || 0,
        is_active: modal.editing.is_active,
      }
    : EMPTY_FORM;

  return (
    <AdminLayout title="Promo Banners" subtitle="Manage homepage promo strip">
      <div className="flex items-center justify-between mb-8">
        <div />
        <button
          onClick={openAdd}
          className="flex items-center gap-2 bg-[#FF6B2C] text-white px-5 py-2.5 rounded-xl font-black shadow-lg shadow-[#FF6B2C]/20 hover:scale-105 active:scale-95 transition-all text-sm"
        >
          <Plus size={16} /> Add Promo Banner
        </button>
      </div>

      {loading ? (
        <div className="flex items-center justify-center py-32">
          <Loader2 size={36} className="animate-spin text-[#FF6B2C]" />
        </div>
      ) : promos.length === 0 ? (
        <div className="py-32 text-center bg-white rounded-2xl border border-[#ECECEC]">
          <Zap size={48} className="mx-auto text-gray-200 mb-4" />
          <h3 className="text-xl font-black text-[#111827] mb-2">No promo banners yet</h3>
          <p className="text-sm font-bold text-gray-400 mb-6">Add your first homepage promo</p>
          <button onClick={openAdd} className="inline-flex items-center gap-2 bg-[#FF6B2C] text-white px-6 py-3 rounded-xl font-black shadow-lg shadow-[#FF6B2C]/20">
            <Plus size={16} /> Add Promo Banner
          </button>
        </div>
      ) : (
        <div className="space-y-4">
          {promos.map(p => (
            <div key={p.id} className="bg-white rounded-2xl border border-[#ECECEC] p-4 flex gap-6 items-center shadow-sm">
              <div className="w-40 h-24 rounded-xl overflow-hidden bg-gray-100 shrink-0 border border-[#ECECEC]">
                {p.image_url ? (
                  <img src={p.image_url} alt={p.title} className="w-full h-full object-cover" />
                ) : (
                  <div className="w-full h-full flex items-center justify-center" style={{ background: p.background_color || '#FF6B2C' }}>
                    <Zap size={24} className="text-white/50" />
                  </div>
                )}
              </div>

              <div className="flex-1 min-w-0">
                <h4 className="text-sm font-black text-[#111827] truncate mb-1">{p.title}</h4>
                {p.subtitle && <p className="text-xs font-bold text-gray-400 truncate mb-2">{p.subtitle}</p>}
                <div className="flex items-center gap-4">
                  {p.link && <span className="text-[10px] font-black text-[#FF6B2C] uppercase tracking-widest">{p.link}</span>}
                  <span className="text-[10px] font-bold text-gray-400">Order: {p.sort_order}</span>
                </div>
              </div>

              <div className="flex items-center gap-3 shrink-0">
                <button onClick={() => handleToggle(p)} title={p.is_active ? 'Deactivate' : 'Activate'}>
                  {p.is_active
                    ? <ToggleRight size={28} className="text-green-500 hover:text-green-600" />
                    : <ToggleLeft size={28} className="text-gray-300 hover:text-gray-400" />}
                </button>
                <span className={`text-[10px] font-black uppercase tracking-widest px-2.5 py-1 rounded-lg ${p.is_active ? 'bg-green-50 text-green-600' : 'bg-gray-100 text-gray-400'}`}>
                  {p.is_active ? 'Active' : 'Inactive'}
                </span>
                <button
                  onClick={() => openEdit(p)}
                  className="w-8 h-8 rounded-xl bg-[#F8F7FC] flex items-center justify-center hover:bg-[#FF6B2C]/10 hover:text-[#FF6B2C] transition-colors"
                >
                  <Edit2 size={14} />
                </button>
                <button
                  onClick={() => handleDelete(p.id)}
                  disabled={deleting === p.id}
                  className="w-8 h-8 rounded-xl bg-[#F8F7FC] flex items-center justify-center hover:bg-red-50 hover:text-red-500 transition-colors disabled:opacity-50"
                >
                  {deleting === p.id ? <Loader2 size={14} className="animate-spin" /> : <Trash2 size={14} />}
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      {modal.open && (
        <PromoFormModal
          initial={formInitial}
          isEdit={!!modal.editing}
          saving={saving}
          onSave={handleSave}
          onClose={closeModal}
        />
      )}

      {toast && <Toast msg={toast} onClose={() => setToast('')} />}
    </AdminLayout>
  );
};

export default AdminPromoBanners;
