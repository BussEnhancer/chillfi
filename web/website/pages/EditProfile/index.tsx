import React, { useEffect, useState } from 'react';
import Header from '../../components/navigation/Header';
import TopBar from '../../components/navigation/TopBar';
import CategoryNav from '../../components/navigation/CategoryNav';
import Footer from '../../components/navigation/Footer';
import Container from '../../components/common/Container';
import Breadcrumb from '../../components/common/Breadcrumb';
import AccountSidebar from '../../components/profile/AccountSidebar';
import { Loader2, CheckCircle2, User, Mail, Phone } from 'lucide-react';
import { apiGet, apiPut } from '../../utils/api';

interface ApiProfile {
  id: string;
  name: string;
  email?: string;
  phone: string;
  avatar_url?: string;
}

const EditProfilePage: React.FC = () => {
  const breadcrumbItems = [{ label: 'My Account', href: '/account' }, { label: 'Account Settings' }];

  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [saved, setSaved] = useState(false);
  const [error, setError] = useState('');
  const [form, setForm] = useState({ name: '', email: '' });
  const [phone, setPhone] = useState('');

  useEffect(() => {
    apiGet<{ success: boolean; data: ApiProfile }>('/profile')
      .then(res => {
        setForm({ name: res.data.name || '', email: res.data.email || '' });
        setPhone(res.data.phone);
      })
      .catch(() => {})
      .finally(() => setLoading(false));
  }, []);

  const handleSave = async () => {
    if (!form.name.trim()) { setError('Name is required'); return; }
    setSaving(true); setError(''); setSaved(false);
    try {
      await apiPut('/profile', { name: form.name, email: form.email || null });
      setSaved(true);
    } catch (e: any) {
      setError(e.message || 'Failed to update profile');
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="min-h-screen bg-white font-['Poppins']">
      <TopBar />
      <Header />
      <CategoryNav />
      <Breadcrumb items={breadcrumbItems} />

      <Container className="py-10">
        <div className="flex flex-col lg:flex-row gap-10">
          <AccountSidebar activeId="settings" />

          <div className="flex-1 max-w-xl">
            <h1 className="text-3xl font-black text-[#111827] mb-8">Account Settings</h1>

            {loading ? (
              <div className="flex items-center gap-3 text-gray-400">
                <Loader2 size={20} className="animate-spin text-[#FF6B2C]" />
                <span className="text-sm font-bold">Loading profile...</span>
              </div>
            ) : (
              <div className="bg-white rounded-[24px] border border-[#ECECEC] p-8 space-y-6">
                {saved && (
                  <div className="flex items-center gap-3 bg-green-50 text-green-700 px-5 py-3 rounded-2xl text-sm font-bold">
                    <CheckCircle2 size={18} /> Profile updated successfully
                  </div>
                )}
                {error && <div className="bg-red-50 text-red-600 px-5 py-3 rounded-2xl text-sm font-bold">{error}</div>}

                <div>
                  <label className="text-[13px] font-black text-[#111827] uppercase tracking-wider flex items-center gap-2 mb-2">
                    <User size={14} /> Full Name
                  </label>
                  <input
                    value={form.name}
                    onChange={e => { setForm(p => ({ ...p, name: e.target.value })); setSaved(false); }}
                    className="w-full border border-[#ECECEC] rounded-xl px-4 py-3 text-sm font-bold outline-none focus:border-[#FF6B2C]"
                  />
                </div>

                <div>
                  <label className="text-[13px] font-black text-[#111827] uppercase tracking-wider flex items-center gap-2 mb-2">
                    <Mail size={14} /> Email Address
                  </label>
                  <input
                    type="email"
                    value={form.email}
                    onChange={e => { setForm(p => ({ ...p, email: e.target.value })); setSaved(false); }}
                    className="w-full border border-[#ECECEC] rounded-xl px-4 py-3 text-sm font-bold outline-none focus:border-[#FF6B2C]"
                  />
                </div>

                <div>
                  <label className="text-[13px] font-black text-[#111827] uppercase tracking-wider flex items-center gap-2 mb-2">
                    <Phone size={14} /> Phone Number
                  </label>
                  <input
                    value={phone}
                    disabled
                    className="w-full border border-[#ECECEC] rounded-xl px-4 py-3 text-sm font-bold bg-gray-50 text-gray-400"
                  />
                  <p className="text-xs font-bold text-gray-400 mt-1">Phone number is used for login and cannot be changed here.</p>
                </div>

                <button
                  onClick={handleSave}
                  disabled={saving}
                  className="bg-[#FF6B2C] text-white px-6 py-3 rounded-xl font-black text-sm hover:bg-[#E05520] disabled:opacity-60 flex items-center gap-2"
                >
                  {saving && <Loader2 size={14} className="animate-spin" />}
                  Save Changes
                </button>
              </div>
            )}
          </div>
        </div>
      </Container>

      <Footer />
    </div>
  );
};

export default EditProfilePage;
