import React, { useEffect, useState } from 'react';
import Header from '../../components/navigation/Header';
import TopBar from '../../components/navigation/TopBar';
import CategoryNav from '../../components/navigation/CategoryNav';
import Footer from '../../components/navigation/Footer';
import Container from '../../components/common/Container';
import Breadcrumb from '../../components/common/Breadcrumb';
import AccountSidebar from '../../components/profile/AccountSidebar';
import { MapPin, Plus, Loader2, Pencil, Trash2, Star } from 'lucide-react';
import { apiGet, apiPost, apiPut, apiDelete } from '../../utils/api';
import { showErrorDialog } from '../../components/feedback/ErrorDialog';

interface Address {
  id: string;
  label: string;
  name: string;
  phone: string;
  line1: string;
  line2?: string;
  city: string;
  state: string;
  pincode: string;
  is_default: boolean;
}

const emptyForm = { label: 'Home', name: '', phone: '', line1: '', line2: '', city: '', state: '', pincode: '' };

const SavedAddressesPage: React.FC = () => {
  const breadcrumbItems = [{ label: 'My Account', href: '/account' }, { label: 'Saved Addresses' }];

  const [addresses, setAddresses] = useState<Address[]>([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [form, setForm] = useState(emptyForm);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');

  const load = () => {
    setLoading(true);
    apiGet<{ success: boolean; data: { addresses: Address[] } }>('/addresses')
      .then(res => setAddresses(res.data.addresses || []))
      .catch(() => {})
      .finally(() => setLoading(false));
  };

  useEffect(() => { load(); }, []);

  const startAdd = () => { setEditingId(null); setForm(emptyForm); setShowForm(true); setError(''); };
  const startEdit = (addr: Address) => {
    setEditingId(addr.id);
    setForm({ label: addr.label, name: addr.name, phone: addr.phone, line1: addr.line1, line2: addr.line2 || '', city: addr.city, state: addr.state, pincode: addr.pincode });
    setShowForm(true); setError('');
  };

  const handleSave = async () => {
    if (!form.name || !form.phone || !form.line1 || !form.city || !form.state || !form.pincode) {
      setError('Please fill all required fields'); return;
    }
    setSaving(true); setError('');
    try {
      if (editingId) {
        await apiPut(`/addresses/${editingId}`, form);
      } else {
        await apiPost('/addresses', form);
      }
      setShowForm(false);
      setForm(emptyForm);
      setEditingId(null);
      load();
    } catch (e: any) {
      showErrorDialog({ title: "Couldn't save address", error: e, fallback: 'Failed to save address. Please try again.' });
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async (id: string) => {
    if (!window.confirm('Delete this address?')) return;
    try {
      await apiDelete(`/addresses/${id}`);
      setAddresses(prev => prev.filter(a => a.id !== id));
    } catch {}
  };

  const handleSetDefault = async (id: string) => {
    try {
      await apiPut(`/addresses/${id}/set-default`, {});
      load();
    } catch {}
  };

  return (
    <div className="min-h-screen bg-white font-['Poppins']">
      <TopBar />
      <Header />
      <CategoryNav />
      <Breadcrumb items={breadcrumbItems} />

      <Container className="py-10 animate-page-in">
        <div className="flex flex-col lg:flex-row gap-10">
          <AccountSidebar activeId="addresses" />

          <div className="flex-1">
            <div className="flex items-center justify-between mb-8">
              <h1 className="text-3xl font-black text-[#111827]">Saved Addresses</h1>
              <button
                onClick={startAdd}
                className="flex items-center gap-2 bg-[#FF6B2C] text-white px-5 py-2.5 rounded-xl font-black text-sm hover:bg-[#E05520] active:scale-[0.98] transition-all"
              >
                <Plus size={18} /> Add New Address
              </button>
            </div>

            {showForm && (
              <div className="bg-[#F8F7FC] rounded-2xl p-6 border border-[#ECECEC] mb-8 space-y-4">
                <h3 className="text-sm font-black text-[#111827] uppercase tracking-wider">{editingId ? 'Edit Address' : 'New Address'}</h3>
                {error && <div className="bg-red-50 text-red-600 px-4 py-2 rounded-xl text-sm font-bold">{error}</div>}
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  {([
                    ['label', 'Label (Home/Work)'],
                    ['name', 'Full Name *'],
                    ['phone', 'Phone *'],
                    ['line1', 'Address Line 1 *'],
                    ['line2', 'Address Line 2'],
                    ['city', 'City *'],
                    ['state', 'State *'],
                    ['pincode', 'Pincode *'],
                  ] as [keyof typeof form, string][]).map(([field, label]) => (
                    <input
                      key={field}
                      placeholder={label}
                      value={form[field]}
                      onChange={e => setForm(p => ({ ...p, [field]: e.target.value }))}
                      className="border border-[#ECECEC] rounded-xl px-4 py-3 text-sm font-bold outline-none focus:border-[#FF6B2C] bg-white"
                    />
                  ))}
                </div>
                <div className="flex gap-3">
                  <button
                    onClick={handleSave}
                    disabled={saving}
                    className="bg-[#FF6B2C] text-white px-6 py-2.5 rounded-xl font-black text-sm hover:bg-[#E05520] disabled:opacity-60 flex items-center gap-2 active:scale-[0.98] transition-all"
                  >
                    {saving && <Loader2 size={14} className="animate-spin" />}
                    Save Address
                  </button>
                  <button onClick={() => setShowForm(false)} className="text-gray-400 font-black text-sm hover:text-[#111827]">
                    Cancel
                  </button>
                </div>
              </div>
            )}

            {loading ? (
              <div className="flex items-center gap-3 text-gray-400">
                <Loader2 size={20} className="animate-spin text-[#FF6B2C]" />
                <span className="text-sm font-bold">Loading addresses...</span>
              </div>
            ) : addresses.length === 0 ? (
              <div className="py-16 text-center text-gray-400">
                <MapPin size={40} className="mx-auto mb-4 text-gray-200" />
                <p className="text-sm font-bold">No addresses saved yet. Add one above.</p>
              </div>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {addresses.map(addr => (
                  <div key={addr.id} className="p-5 rounded-2xl border-2 border-[#ECECEC] hover:border-[#FF6B2C]/40 transition-all">
                    <div className="flex items-center justify-between mb-3">
                      <span className="text-[10px] font-black bg-gray-100 text-gray-500 px-2 py-0.5 rounded-full uppercase tracking-wider">{addr.label}</span>
                      {addr.is_default && <span className="text-[9px] font-black text-[#FF6B2C] uppercase tracking-wider">Default</span>}
                    </div>
                    <p className="text-sm font-black text-[#111827] mb-1">{addr.name}</p>
                    <p className="text-xs font-bold text-gray-500 leading-relaxed mb-1">
                      {addr.line1}{addr.line2 ? `, ${addr.line2}` : ''}, {addr.city}, {addr.state} - {addr.pincode}
                    </p>
                    <p className="text-xs font-bold text-gray-400 mb-4">{addr.phone}</p>
                    <div className="flex items-center gap-4 pt-3 border-t border-[#ECECEC]">
                      <button onClick={() => startEdit(addr)} className="flex items-center gap-1 text-xs font-black text-gray-500 hover:text-[#FF6B2C]">
                        <Pencil size={14} /> Edit
                      </button>
                      <button onClick={() => handleDelete(addr.id)} className="flex items-center gap-1 text-xs font-black text-gray-500 hover:text-red-500">
                        <Trash2 size={14} /> Delete
                      </button>
                      {!addr.is_default && (
                        <button onClick={() => handleSetDefault(addr.id)} className="flex items-center gap-1 text-xs font-black text-gray-500 hover:text-[#FF6B2C]">
                          <Star size={14} /> Set Default
                        </button>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </Container>

      <Footer />
    </div>
  );
};

export default SavedAddressesPage;
