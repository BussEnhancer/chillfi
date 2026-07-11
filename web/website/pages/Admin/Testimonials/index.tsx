import React, { useState, useEffect, useRef } from 'react';
import AdminLayout from '../../../components/admin/AdminLayout';
import { Plus, Edit2, Trash2, ToggleLeft, ToggleRight, X, Check, Loader2, Star, User, Upload } from 'lucide-react';
import { apiGet, apiPost, apiPut, apiDelete, uploadImage } from '../../../utils/api';

interface Testimonial {
  id: string;
  customer_name: string;
  avatar_url?: string;
  rating: number;
  quote: string;
  sort_order: number;
  is_active: boolean;
}

interface TestimonialForm {
  customer_name: string;
  avatar_url: string;
  rating: number;
  quote: string;
  sort_order: number;
  is_active: boolean;
}

const EMPTY_FORM: TestimonialForm = {
  customer_name: '', avatar_url: '', rating: 5, quote: '', sort_order: 0, is_active: true,
};

const Toast: React.FC<{ msg: string; onClose: () => void }> = ({ msg, onClose }) => (
  <div className="fixed bottom-6 right-6 z-[100] flex items-center gap-3 bg-[#121212] text-white px-5 py-3.5 rounded-2xl shadow-2xl">
    <div className="w-6 h-6 bg-green-500 rounded-full flex items-center justify-center shrink-0"><Check size={13} /></div>
    <span className="text-sm font-bold">{msg}</span>
    <button onClick={onClose} className="ml-2 text-white/50 hover:text-white"><X size={14} /></button>
  </div>
);

const TestimonialFormModal: React.FC<{
  initial: TestimonialForm;
  isEdit: boolean;
  saving: boolean;
  onSave: (f: TestimonialForm, avatarFile?: File) => void;
  onClose: () => void;
}> = ({ initial, isEdit, saving, onSave, onClose }) => {
  const [form, setForm] = useState<TestimonialForm>(initial);
  const [avatarFile, setAvatarFile] = useState<File | null>(null);
  const [avatarPreview, setAvatarPreview] = useState(initial.avatar_url);
  const fileRef = useRef<HTMLInputElement>(null);
  const set = (k: keyof TestimonialForm, v: any) => setForm(f => ({ ...f, [k]: v }));

  const handleAvatarChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    setAvatarFile(file);
    setAvatarPreview(URL.createObjectURL(file));
  };

  return (
    <div className="fixed inset-0 bg-black/40 backdrop-blur-sm z-50 flex items-center justify-center p-4">
      <div className="bg-white rounded-2xl shadow-2xl w-full max-w-lg max-h-[90vh] flex flex-col">
        <div className="flex items-center justify-between px-6 py-4 border-b border-[#F8F7FC] shrink-0">
          <h3 className="text-lg font-black text-[#111827]">{isEdit ? 'Edit Testimonial' : 'Add New Testimonial'}</h3>
          <button onClick={onClose} disabled={saving} className="w-8 h-8 rounded-xl bg-[#F8F7FC] flex items-center justify-center hover:bg-red-50 hover:text-red-500 transition-colors">
            <X size={16} />
          </button>
        </div>

        <div className="overflow-y-auto p-6 space-y-4">
          <div>
            <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Customer Name *</label>
            <input value={form.customer_name} onChange={e => set('customer_name', e.target.value)} placeholder="e.g. Priya Sharma" className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C]" />
          </div>
          <div>
            <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Avatar</label>
            <div className="flex items-center gap-4">
              <div className="w-16 h-16 rounded-full overflow-hidden bg-[#F8F7FC] border-2 border-dashed border-[#ECECEC] flex items-center justify-center shrink-0">
                {avatarPreview ? <img src={avatarPreview} alt="Preview" className="w-full h-full object-cover" /> : <User size={22} className="text-gray-300" />}
              </div>
              <div className="flex-1">
                <input ref={fileRef} type="file" accept="image/*" onChange={handleAvatarChange} className="hidden" />
                <button type="button" onClick={() => fileRef.current?.click()} className="flex items-center gap-2 px-4 py-2 border-2 border-dashed border-[#ECECEC] rounded-xl text-sm font-bold text-gray-500 hover:border-[#FF6B2C] hover:text-[#FF6B2C] transition-colors w-full justify-center">
                  <Upload size={14} /> Upload Avatar
                </button>
                <p className="text-[10px] font-bold text-gray-400 mt-1.5 text-center">JPG, PNG, WebP • Max 5MB</p>
              </div>
            </div>
          </div>
          <div>
            <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Rating</label>
            <div className="flex items-center gap-1">
              {[1, 2, 3, 4, 5].map(n => (
                <button key={n} type="button" onClick={() => set('rating', n)}>
                  <Star size={26} className={n <= form.rating ? 'fill-amber-400 text-amber-400' : 'text-gray-200'} />
                </button>
              ))}
            </div>
          </div>
          <div>
            <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Quote *</label>
            <textarea value={form.quote} onChange={e => set('quote', e.target.value)} placeholder="What the customer said..." rows={3} className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C] resize-none" />
          </div>
          <div>
            <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Sort Order</label>
            <input type="number" value={form.sort_order} onChange={e => set('sort_order', +e.target.value)} min={0} className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C]" />
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
            onClick={() => onSave(form, avatarFile || undefined)}
            disabled={saving || !form.customer_name.trim() || !form.quote.trim()}
            className="px-6 py-2.5 rounded-xl bg-[#FF6B2C] text-white text-sm font-black shadow-lg shadow-[#FF6B2C]/20 hover:scale-105 active:scale-95 transition-all disabled:opacity-50 disabled:scale-100 flex items-center gap-2"
          >
            {saving && <Loader2 size={14} className="animate-spin" />}
            {isEdit ? 'Save Changes' : 'Create Testimonial'}
          </button>
        </div>
      </div>
    </div>
  );
};

const AdminTestimonials: React.FC = () => {
  const [testimonials, setTestimonials] = useState<Testimonial[]>([]);
  const [loading, setLoading] = useState(true);
  const [modal, setModal] = useState<{ open: boolean; editing: Testimonial | null }>({ open: false, editing: null });
  const [saving, setSaving] = useState(false);
  const [deleting, setDeleting] = useState<string | null>(null);
  const [toast, setToast] = useState('');

  const showToast = (msg: string) => { setToast(msg); setTimeout(() => setToast(''), 3000); };

  const load = () => {
    setLoading(true);
    apiGet<{ success: boolean; data: Testimonial[] }>('/admin/testimonials')
      .then(res => setTestimonials(res.data || []))
      .catch(() => {})
      .finally(() => setLoading(false));
  };

  useEffect(load, []);

  const openAdd = () => setModal({ open: true, editing: null });
  const openEdit = (t: Testimonial) => setModal({ open: true, editing: t });
  const closeModal = () => setModal({ open: false, editing: null });

  const handleSave = async (form: TestimonialForm, avatarFile?: File) => {
    setSaving(true);
    try {
      let avatar_url = form.avatar_url;
      if (avatarFile) {
        avatar_url = await uploadImage(avatarFile, 'chillfi/testimonials');
      }
      const payload = { ...form, avatar_url };

      if (modal.editing) {
        await apiPut(`/admin/testimonials/${modal.editing.id}`, payload);
        showToast('Testimonial updated');
      } else {
        await apiPost('/admin/testimonials', payload);
        showToast('Testimonial created');
      }
      closeModal();
      load();
    } catch (e: any) {
      showToast(e.message || 'Error saving testimonial');
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async (id: string) => {
    if (!confirm('Delete this testimonial?')) return;
    setDeleting(id);
    try {
      await apiDelete(`/admin/testimonials/${id}`);
      showToast('Testimonial deleted');
      load();
    } catch {
      showToast('Error deleting testimonial');
    } finally {
      setDeleting(null);
    }
  };

  const handleToggle = async (t: Testimonial) => {
    try {
      await apiPut(`/admin/testimonials/${t.id}`, { is_active: !t.is_active });
      setTestimonials(prev => prev.map(x => x.id === t.id ? { ...x, is_active: !x.is_active } : x));
      showToast(t.is_active ? 'Testimonial deactivated' : 'Testimonial activated');
    } catch {
      showToast('Error toggling testimonial');
    }
  };

  const formInitial = modal.editing
    ? {
        customer_name: modal.editing.customer_name || '',
        avatar_url: modal.editing.avatar_url || '',
        rating: modal.editing.rating || 5,
        quote: modal.editing.quote || '',
        sort_order: modal.editing.sort_order || 0,
        is_active: modal.editing.is_active,
      }
    : EMPTY_FORM;

  return (
    <AdminLayout title="Testimonials" subtitle="Manage homepage customer testimonials">
      <div className="flex items-center justify-between mb-8">
        <div />
        <button
          onClick={openAdd}
          className="flex items-center gap-2 bg-[#FF6B2C] text-white px-5 py-2.5 rounded-xl font-black shadow-lg shadow-[#FF6B2C]/20 hover:scale-105 active:scale-95 transition-all text-sm"
        >
          <Plus size={16} /> Add Testimonial
        </button>
      </div>

      {loading ? (
        <div className="flex items-center justify-center py-32">
          <Loader2 size={36} className="animate-spin text-[#FF6B2C]" />
        </div>
      ) : testimonials.length === 0 ? (
        <div className="py-32 text-center bg-white rounded-2xl border border-[#ECECEC]">
          <Star size={48} className="mx-auto text-gray-200 mb-4" />
          <h3 className="text-xl font-black text-[#111827] mb-2">No testimonials yet</h3>
          <p className="text-sm font-bold text-gray-400 mb-6">Add your first customer testimonial</p>
          <button onClick={openAdd} className="inline-flex items-center gap-2 bg-[#FF6B2C] text-white px-6 py-3 rounded-xl font-black shadow-lg shadow-[#FF6B2C]/20">
            <Plus size={16} /> Add Testimonial
          </button>
        </div>
      ) : (
        <div className="space-y-4">
          {testimonials.map(t => (
            <div key={t.id} className="bg-white rounded-2xl border border-[#ECECEC] p-4 flex gap-6 items-center shadow-sm">
              <div className="w-14 h-14 rounded-full overflow-hidden bg-gray-100 shrink-0 border border-[#ECECEC] flex items-center justify-center">
                {t.avatar_url ? (
                  <img src={t.avatar_url} alt={t.customer_name} className="w-full h-full object-cover" />
                ) : (
                  <User size={22} className="text-gray-300" />
                )}
              </div>

              <div className="flex-1 min-w-0">
                <h4 className="text-sm font-black text-[#111827] mb-1">{t.customer_name}</h4>
                <div className="flex items-center gap-0.5 mb-1.5">
                  {Array.from({ length: 5 }).map((_, i) => (
                    <Star key={i} size={12} className={i < t.rating ? 'fill-amber-400 text-amber-400' : 'text-gray-200'} />
                  ))}
                </div>
                <p className="text-xs font-bold text-gray-400 truncate">{t.quote}</p>
                <span className="text-[10px] font-bold text-gray-400">Order: {t.sort_order}</span>
              </div>

              <div className="flex items-center gap-3 shrink-0">
                <button onClick={() => handleToggle(t)} title={t.is_active ? 'Deactivate' : 'Activate'}>
                  {t.is_active
                    ? <ToggleRight size={28} className="text-green-500 hover:text-green-600" />
                    : <ToggleLeft size={28} className="text-gray-300 hover:text-gray-400" />}
                </button>
                <span className={`text-[10px] font-black uppercase tracking-widest px-2.5 py-1 rounded-lg ${t.is_active ? 'bg-green-50 text-green-600' : 'bg-gray-100 text-gray-400'}`}>
                  {t.is_active ? 'Active' : 'Inactive'}
                </span>
                <button
                  onClick={() => openEdit(t)}
                  className="w-8 h-8 rounded-xl bg-[#F8F7FC] flex items-center justify-center hover:bg-[#FF6B2C]/10 hover:text-[#FF6B2C] transition-colors"
                >
                  <Edit2 size={14} />
                </button>
                <button
                  onClick={() => handleDelete(t.id)}
                  disabled={deleting === t.id}
                  className="w-8 h-8 rounded-xl bg-[#F8F7FC] flex items-center justify-center hover:bg-red-50 hover:text-red-500 transition-colors disabled:opacity-50"
                >
                  {deleting === t.id ? <Loader2 size={14} className="animate-spin" /> : <Trash2 size={14} />}
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      {modal.open && (
        <TestimonialFormModal
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

export default AdminTestimonials;
