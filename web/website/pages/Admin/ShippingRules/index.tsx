import React, { useState, useEffect } from 'react';
import AdminLayout from '../../../components/admin/AdminLayout';
import { Plus, Edit2, Trash2, ToggleLeft, ToggleRight, X, Check, Loader2, Truck } from 'lucide-react';
import { apiGet, apiPost, apiPut, apiDelete } from '../../../utils/api';
import { showErrorDialog } from '../../../components/feedback/ErrorDialog';

interface ShippingRule {
  id: string;
  pincode_prefix: string;
  fee: string;
  free_above?: string;
  cod_available: boolean;
  estimated_days: number;
  is_active: boolean;
}

interface RuleForm {
  pincode_prefix: string;
  fee: string;
  free_above: string;
  cod_available: boolean;
  estimated_days: string;
  is_active: boolean;
}

const EMPTY_FORM: RuleForm = {
  pincode_prefix: '', fee: '0', free_above: '', cod_available: true, estimated_days: '5', is_active: true,
};

const Toast: React.FC<{ msg: string; onClose: () => void }> = ({ msg, onClose }) => (
  <div className="fixed bottom-6 right-6 z-[100] flex items-center gap-3 bg-[#121212] text-white px-5 py-3.5 rounded-2xl shadow-2xl">
    <div className="w-6 h-6 bg-green-500 rounded-full flex items-center justify-center shrink-0"><Check size={13} /></div>
    <span className="text-sm font-bold">{msg}</span>
    <button onClick={onClose} className="ml-2 text-white/50 hover:text-white"><X size={14} /></button>
  </div>
);

const RuleFormModal: React.FC<{
  initial: RuleForm;
  isEdit: boolean;
  saving: boolean;
  onSave: (f: RuleForm) => void;
  onClose: () => void;
}> = ({ initial, isEdit, saving, onSave, onClose }) => {
  const [form, setForm] = useState<RuleForm>(initial);
  const set = (k: keyof RuleForm, v: any) => setForm(f => ({ ...f, [k]: v }));

  return (
    <div className="fixed inset-0 bg-black/40 backdrop-blur-sm z-50 flex items-center justify-center p-4">
      <div className="bg-white rounded-2xl shadow-2xl w-full max-w-md max-h-[90vh] flex flex-col">
        <div className="flex items-center justify-between px-6 py-4 border-b border-[#F8F7FC] shrink-0">
          <h3 className="text-lg font-black text-[#111827]">{isEdit ? 'Edit Shipping Rule' : 'Add Shipping Rule'}</h3>
          <button onClick={onClose} disabled={saving} className="w-8 h-8 rounded-xl bg-[#F8F7FC] flex items-center justify-center hover:bg-red-50 hover:text-red-500 transition-colors"><X size={16} /></button>
        </div>

        <div className="overflow-y-auto p-6 space-y-4">
          <div>
            <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Pincode Prefix *</label>
            <input value={form.pincode_prefix} onChange={e => set('pincode_prefix', e.target.value)} placeholder="e.g. 1100 or 560" className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C]" />
            <p className="text-[10px] font-bold text-gray-400 mt-1">Matches any pincode starting with this. Longer prefixes win over shorter ones.</p>
          </div>
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Delivery Fee (₹) *</label>
              <input type="number" value={form.fee} onChange={e => set('fee', e.target.value)} min={0} className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C]" />
            </div>
            <div>
              <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Free Above (₹)</label>
              <input type="number" value={form.free_above} onChange={e => set('free_above', e.target.value)} min={0} placeholder="Optional" className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C]" />
            </div>
          </div>
          <div>
            <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Estimated Delivery Days</label>
            <input type="number" value={form.estimated_days} onChange={e => set('estimated_days', e.target.value)} min={1} className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C]" />
          </div>
          <label className="flex items-center gap-3 cursor-pointer">
            <button type="button" onClick={() => set('cod_available', !form.cod_available)} className="shrink-0">
              {form.cod_available ? <ToggleRight size={28} className="text-green-500" /> : <ToggleLeft size={28} className="text-gray-300" />}
            </button>
            <span className="text-sm font-black text-[#111827]">{form.cod_available ? 'COD available in this zone' : 'COD not available'}</span>
          </label>
          <label className="flex items-center gap-3 cursor-pointer">
            <button type="button" onClick={() => set('is_active', !form.is_active)} className="shrink-0">
              {form.is_active ? <ToggleRight size={28} className="text-green-500" /> : <ToggleLeft size={28} className="text-gray-300" />}
            </button>
            <span className="text-sm font-black text-[#111827]">{form.is_active ? 'Active' : 'Inactive'}</span>
          </label>
        </div>

        <div className="px-6 py-4 border-t border-[#F8F7FC] shrink-0 flex justify-end gap-3">
          <button onClick={onClose} disabled={saving} className="px-5 py-2.5 rounded-xl border border-[#ECECEC] text-sm font-black text-gray-600 hover:bg-gray-50 disabled:opacity-50">Cancel</button>
          <button
            onClick={() => onSave(form)}
            disabled={saving || !form.pincode_prefix.trim()}
            className="px-6 py-2.5 rounded-xl bg-[#FF6B2C] text-white text-sm font-black shadow-lg shadow-[#FF6B2C]/20 hover:scale-105 active:scale-95 transition-all disabled:opacity-50 disabled:scale-100 flex items-center gap-2"
          >
            {saving && <Loader2 size={14} className="animate-spin" />}
            {isEdit ? 'Save Changes' : 'Create Rule'}
          </button>
        </div>
      </div>
    </div>
  );
};

const AdminShippingRules: React.FC = () => {
  const [rules, setRules] = useState<ShippingRule[]>([]);
  const [loading, setLoading] = useState(true);
  const [modal, setModal] = useState<{ open: boolean; editing: ShippingRule | null }>({ open: false, editing: null });
  const [saving, setSaving] = useState(false);
  const [deleting, setDeleting] = useState<string | null>(null);
  const [toast, setToast] = useState('');

  const showToast = (msg: string) => { setToast(msg); setTimeout(() => setToast(''), 3000); };

  const load = () => {
    setLoading(true);
    apiGet<{ success: boolean; data: ShippingRule[] }>('/admin/shipping-rules')
      .then(res => setRules(res.data || []))
      .catch((e) => showErrorDialog({ title: "Couldn't load shipping rules", error: e }))
      .finally(() => setLoading(false));
  };

  useEffect(load, []);

  const openAdd = () => setModal({ open: true, editing: null });
  const openEdit = (r: ShippingRule) => setModal({ open: true, editing: r });
  const closeModal = () => setModal({ open: false, editing: null });

  const handleSave = async (form: RuleForm) => {
    setSaving(true);
    try {
      const payload = {
        pincode_prefix: form.pincode_prefix.trim(),
        fee: Number(form.fee),
        free_above: form.free_above.trim() ? Number(form.free_above) : null,
        cod_available: form.cod_available,
        estimated_days: Number(form.estimated_days),
        is_active: form.is_active,
      };
      if (modal.editing) {
        await apiPut(`/admin/shipping-rules/${modal.editing.id}`, payload);
        showToast('Shipping rule updated');
      } else {
        await apiPost('/admin/shipping-rules', payload);
        showToast('Shipping rule created');
      }
      closeModal();
      load();
    } catch (e: any) {
      showErrorDialog({ title: 'Couldn’t save rule', error: e });
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async (id: string) => {
    if (!confirm('Delete this shipping rule?')) return;
    setDeleting(id);
    try {
      await apiDelete(`/admin/shipping-rules/${id}`);
      showToast('Shipping rule deleted');
      load();
    } catch (e: any) {
      showErrorDialog({ title: "Couldn't update", error: e });
    } finally {
      setDeleting(null);
    }
  };

  const handleToggle = async (r: ShippingRule) => {
    try {
      await apiPut(`/admin/shipping-rules/${r.id}`, { is_active: !r.is_active });
      setRules(prev => prev.map(x => x.id === r.id ? { ...x, is_active: !x.is_active } : x));
      showToast(r.is_active ? 'Rule deactivated' : 'Rule activated');
    } catch (e: any) {
      showErrorDialog({ title: "Couldn't update", error: e });
    }
  };

  const formInitial = modal.editing
    ? {
        pincode_prefix: modal.editing.pincode_prefix,
        fee: String(modal.editing.fee),
        free_above: modal.editing.free_above != null ? String(modal.editing.free_above) : '',
        cod_available: modal.editing.cod_available,
        estimated_days: String(modal.editing.estimated_days),
        is_active: modal.editing.is_active,
      }
    : EMPTY_FORM;

  return (
    <AdminLayout title="Shipping Rules" subtitle="Per-pincode delivery fees, COD availability, and ETAs">
      <div className="flex items-center justify-between mb-8">
        <p className="text-xs font-bold text-gray-400 max-w-md">Pincodes that don't match any active rule fall back to the flat delivery fee configured in Settings → Shipping.</p>
        <button
          onClick={openAdd}
          className="flex items-center gap-2 bg-[#FF6B2C] text-white px-5 py-2.5 rounded-xl font-black shadow-lg shadow-[#FF6B2C]/20 hover:scale-105 active:scale-95 transition-all text-sm shrink-0"
        >
          <Plus size={16} /> Add Rule
        </button>
      </div>

      {loading ? (
        <div className="flex items-center justify-center py-32">
          <Loader2 size={36} className="animate-spin text-[#FF6B2C]" />
        </div>
      ) : rules.length === 0 ? (
        <div className="py-32 text-center bg-white rounded-2xl border border-[#ECECEC]">
          <Truck size={48} className="mx-auto text-gray-200 mb-4" />
          <h3 className="text-xl font-black text-[#111827] mb-2">No shipping rules yet</h3>
          <p className="text-sm font-bold text-gray-400 mb-6">All orders use the flat delivery fee until you add pincode-specific rules</p>
          <button onClick={openAdd} className="inline-flex items-center gap-2 bg-[#FF6B2C] text-white px-6 py-3 rounded-xl font-black shadow-lg shadow-[#FF6B2C]/20">
            <Plus size={16} /> Add Rule
          </button>
        </div>
      ) : (
        <div className="bg-white rounded-2xl border border-[#ECECEC] shadow-sm overflow-hidden">
          <table className="w-full">
            <thead>
              <tr className="bg-[#F8F7FC] border-b border-[#ECECEC]">
                {['Pincode Prefix', 'Fee', 'Free Above', 'COD', 'ETA', 'Status', 'Actions'].map(h => (
                  <th key={h} className="px-4 py-3 text-left text-[10px] font-black text-gray-400 uppercase tracking-widest whitespace-nowrap">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody className="divide-y divide-[#F8F7FC]">
              {rules.map(r => (
                <tr key={r.id} className="hover:bg-[#FFF8F5] transition-colors">
                  <td className="px-4 py-3.5 text-sm font-black text-[#111827] whitespace-nowrap">{r.pincode_prefix}*</td>
                  <td className="px-4 py-3.5 text-sm font-bold text-gray-600 whitespace-nowrap">{Number(r.fee) === 0 ? 'FREE' : `₹${Number(r.fee).toLocaleString()}`}</td>
                  <td className="px-4 py-3.5 text-xs font-bold text-gray-400 whitespace-nowrap">{r.free_above ? `₹${Number(r.free_above).toLocaleString()}` : '—'}</td>
                  <td className="px-4 py-3.5 text-xs font-bold whitespace-nowrap">{r.cod_available ? <span className="text-green-600">Yes</span> : <span className="text-red-500">No</span>}</td>
                  <td className="px-4 py-3.5 text-xs font-bold text-gray-400 whitespace-nowrap">{r.estimated_days} days</td>
                  <td className="px-4 py-3.5 whitespace-nowrap">
                    <button onClick={() => handleToggle(r)} title={r.is_active ? 'Deactivate' : 'Activate'}>
                      {r.is_active ? <ToggleRight size={26} className="text-green-500 hover:text-green-600" /> : <ToggleLeft size={26} className="text-gray-300 hover:text-gray-400" />}
                    </button>
                  </td>
                  <td className="px-4 py-3.5">
                    <div className="flex items-center gap-1.5">
                      <button onClick={() => openEdit(r)} className="w-7 h-7 rounded-lg bg-[#F8F7FC] flex items-center justify-center text-gray-500 hover:bg-[#FFF3ED] hover:text-[#FF6B2C] transition-colors"><Edit2 size={13} /></button>
                      <button onClick={() => handleDelete(r.id)} disabled={deleting === r.id} className="w-7 h-7 rounded-lg bg-[#F8F7FC] flex items-center justify-center text-gray-500 hover:bg-red-50 hover:text-red-500 transition-colors disabled:opacity-50">
                        {deleting === r.id ? <Loader2 size={13} className="animate-spin" /> : <Trash2 size={13} />}
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {modal.open && (
        <RuleFormModal
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

export default AdminShippingRules;
