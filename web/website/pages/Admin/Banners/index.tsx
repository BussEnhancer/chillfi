import React, { useState, useEffect } from 'react';
import AdminLayout from '../../../components/admin/AdminLayout';
import { Plus, Edit2, Trash2, ToggleLeft, ToggleRight, X, Check, Loader2, Image } from 'lucide-react';
import { apiGet, apiPost, apiPut, apiDelete } from '../../../utils/api';

interface Banner {
  id: string;
  title?: string;
  subtitle?: string;
  image_url: string;
  link?: string;
  background_color?: string;
  sort_order: number;
  is_active: boolean;
}

interface BannerForm {
  title: string;
  subtitle: string;
  image_url: string;
  link: string;
  background_color: string;
  sort_order: number;
  is_active: boolean;
}

const EMPTY_FORM: BannerForm = {
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

const BannerFormModal: React.FC<{
  initial: BannerForm;
  isEdit: boolean;
  saving: boolean;
  onSave: (f: BannerForm) => void;
  onClose: () => void;
}> = ({ initial, isEdit, saving, onSave, onClose }) => {
  const [form, setForm] = useState<BannerForm>(initial);
  const set = (k: keyof BannerForm, v: any) => setForm(f => ({ ...f, [k]: v }));

  return (
    <div className="fixed inset-0 bg-black/40 backdrop-blur-sm z-50 flex items-center justify-center p-4">
      <div className="bg-white rounded-2xl shadow-2xl w-full max-w-lg max-h-[90vh] flex flex-col">
        <div className="flex items-center justify-between px-6 py-4 border-b border-[#F8F7FC] shrink-0">
          <h3 className="text-lg font-black text-[#111827]">{isEdit ? 'Edit Banner' : 'Add New Banner'}</h3>
          <button onClick={onClose} disabled={saving} className="w-8 h-8 rounded-xl bg-[#F8F7FC] flex items-center justify-center hover:bg-red-50 hover:text-red-500 transition-colors">
            <X size={16} />
          </button>
        </div>

        <div className="overflow-y-auto p-6 space-y-4">
          <div>
            <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Title</label>
            <input value={form.title} onChange={e => set('title', e.target.value)} placeholder="e.g. Biggest Sale of the Season" className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C]" />
          </div>
          <div>
            <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Subtitle</label>
            <textarea value={form.subtitle} onChange={e => set('subtitle', e.target.value)} placeholder="Brief description shown under the title" rows={2} className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C] resize-none" />
          </div>
          <div>
            <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Image URL *</label>
            <input value={form.image_url} onChange={e => set('image_url', e.target.value)} placeholder="https://..." className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C]" />
            {form.image_url && (
              <img src={form.image_url} alt="Preview" className="mt-2 w-full h-32 object-cover rounded-xl border border-[#ECECEC]" onError={e => { (e.target as HTMLImageElement).style.display = 'none'; }} />
            )}
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
            onClick={() => onSave(form)}
            disabled={saving || !form.image_url.trim()}
            className="px-6 py-2.5 rounded-xl bg-[#FF6B2C] text-white text-sm font-black shadow-lg shadow-[#FF6B2C]/20 hover:scale-105 active:scale-95 transition-all disabled:opacity-50 disabled:scale-100 flex items-center gap-2"
          >
            {saving && <Loader2 size={14} className="animate-spin" />}
            {isEdit ? 'Save Changes' : 'Create Banner'}
          </button>
        </div>
      </div>
    </div>
  );
};

const AdminBannersPage: React.FC = () => {
  const [banners, setBanners] = useState<Banner[]>([]);
  const [loading, setLoading] = useState(true);
  const [modal, setModal] = useState<{ open: boolean; editing: Banner | null }>({ open: false, editing: null });
  const [saving, setSaving] = useState(false);
  const [deleting, setDeleting] = useState<string | null>(null);
  const [toast, setToast] = useState('');

  const showToast = (msg: string) => { setToast(msg); setTimeout(() => setToast(''), 3000); };

  const load = () => {
    setLoading(true);
    apiGet<{ success: boolean; data: Banner[] }>('/admin/banners')
      .then(res => setBanners(res.data || []))
      .catch(() => {})
      .finally(() => setLoading(false));
  };

  useEffect(load, []);

  const openAdd = () => setModal({ open: true, editing: null });
  const openEdit = (b: Banner) => setModal({ open: true, editing: b });
  const closeModal = () => setModal({ open: false, editing: null });

  const handleSave = async (form: BannerForm) => {
    setSaving(true);
    try {
      if (modal.editing) {
        await apiPut(`/admin/banners/${modal.editing.id}`, form);
        showToast('Banner updated');
      } else {
        await apiPost('/admin/banners', form);
        showToast('Banner created');
      }
      closeModal();
      load();
    } catch (e: any) {
      showToast(e.message || 'Error saving banner');
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async (id: string) => {
    if (!confirm('Delete this banner?')) return;
    setDeleting(id);
    try {
      await apiDelete(`/admin/banners/${id}`);
      showToast('Banner deleted');
      load();
    } catch {
      showToast('Error deleting banner');
    } finally {
      setDeleting(null);
    }
  };

  const handleToggle = async (b: Banner) => {
    try {
      await apiPut(`/admin/banners/${b.id}`, { is_active: !b.is_active });
      setBanners(prev => prev.map(x => x.id === b.id ? { ...x, is_active: !x.is_active } : x));
      showToast(b.is_active ? 'Banner deactivated' : 'Banner activated');
    } catch {
      showToast('Error toggling banner');
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
    <AdminLayout title="Banners" subtitle="Manage homepage hero & promo banners">
      <div className="flex items-center justify-between mb-8">
        <div />
        <button
          onClick={openAdd}
          className="flex items-center gap-2 bg-[#FF6B2C] text-white px-5 py-2.5 rounded-xl font-black shadow-lg shadow-[#FF6B2C]/20 hover:scale-105 active:scale-95 transition-all text-sm"
        >
          <Plus size={16} /> Add Banner
        </button>
      </div>

      {loading ? (
        <div className="flex items-center justify-center py-32">
          <Loader2 size={36} className="animate-spin text-[#FF6B2C]" />
        </div>
      ) : banners.length === 0 ? (
        <div className="py-32 text-center bg-white rounded-2xl border border-[#ECECEC]">
          <Image size={48} className="mx-auto text-gray-200 mb-4" />
          <h3 className="text-xl font-black text-[#111827] mb-2">No banners yet</h3>
          <p className="text-sm font-bold text-gray-400 mb-6">Add your first homepage banner</p>
          <button onClick={openAdd} className="inline-flex items-center gap-2 bg-[#FF6B2C] text-white px-6 py-3 rounded-xl font-black shadow-lg shadow-[#FF6B2C]/20">
            <Plus size={16} /> Add Banner
          </button>
        </div>
      ) : (
        <div className="space-y-4">
          {banners.map(b => (
            <div key={b.id} className="bg-white rounded-2xl border border-[#ECECEC] p-4 flex gap-6 items-center shadow-sm">
              <div className="w-40 h-24 rounded-xl overflow-hidden bg-gray-100 shrink-0 border border-[#ECECEC]">
                {b.image_url ? (
                  <img src={b.image_url} alt={b.title || 'Banner'} className="w-full h-full object-cover" />
                ) : (
                  <div className="w-full h-full flex items-center justify-center" style={{ background: b.background_color || '#FF6B2C' }}>
                    <Image size={24} className="text-white/50" />
                  </div>
                )}
              </div>

              <div className="flex-1 min-w-0">
                <h4 className="text-sm font-black text-[#111827] truncate mb-1">{b.title || '(No title)'}</h4>
                {b.subtitle && <p className="text-xs font-bold text-gray-400 truncate mb-2">{b.subtitle}</p>}
                <div className="flex items-center gap-4">
                  {b.link && <span className="text-[10px] font-black text-[#FF6B2C] uppercase tracking-widest">{b.link}</span>}
                  <span className="text-[10px] font-bold text-gray-400">Order: {b.sort_order}</span>
                </div>
              </div>

              <div className="flex items-center gap-3 shrink-0">
                <button onClick={() => handleToggle(b)} title={b.is_active ? 'Deactivate' : 'Activate'}>
                  {b.is_active
                    ? <ToggleRight size={28} className="text-green-500 hover:text-green-600" />
                    : <ToggleLeft size={28} className="text-gray-300 hover:text-gray-400" />}
                </button>
                <span className={`text-[10px] font-black uppercase tracking-widest px-2.5 py-1 rounded-lg ${b.is_active ? 'bg-green-50 text-green-600' : 'bg-gray-100 text-gray-400'}`}>
                  {b.is_active ? 'Active' : 'Inactive'}
                </span>
                <button
                  onClick={() => openEdit(b)}
                  className="w-8 h-8 rounded-xl bg-[#F8F7FC] flex items-center justify-center hover:bg-[#FF6B2C]/10 hover:text-[#FF6B2C] transition-colors"
                >
                  <Edit2 size={14} />
                </button>
                <button
                  onClick={() => handleDelete(b.id)}
                  disabled={deleting === b.id}
                  className="w-8 h-8 rounded-xl bg-[#F8F7FC] flex items-center justify-center hover:bg-red-50 hover:text-red-500 transition-colors disabled:opacity-50"
                >
                  {deleting === b.id ? <Loader2 size={14} className="animate-spin" /> : <Trash2 size={14} />}
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      {modal.open && (
        <BannerFormModal
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

export default AdminBannersPage;
