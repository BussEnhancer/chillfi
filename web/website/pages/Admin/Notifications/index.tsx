import React, { useState } from 'react';
import AdminLayout from '../../../components/admin/AdminLayout';
import { Send, Check, X, Loader2, Users, User, Search } from 'lucide-react';
import { apiGet, apiPost } from '../../../utils/api';

interface AdminUser {
  id: string;
  name: string;
  email?: string;
  phone?: string;
}

const Toast: React.FC<{ msg: string; isError?: boolean; onClose: () => void }> = ({ msg, isError, onClose }) => (
  <div className="fixed bottom-6 right-6 z-[100] flex items-center gap-3 bg-[#121212] text-white px-5 py-3.5 rounded-2xl shadow-2xl">
    <div className={`w-6 h-6 rounded-full flex items-center justify-center shrink-0 ${isError ? 'bg-red-500' : 'bg-green-500'}`}>
      <Check size={13} />
    </div>
    <span className="text-sm font-bold">{msg}</span>
    <button onClick={onClose} className="ml-2 text-white/50 hover:text-white"><X size={14} /></button>
  </div>
);

const AdminNotifications: React.FC = () => {
  const [audience, setAudience] = useState<'all' | 'single'>('all');
  const [title, setTitle] = useState('');
  const [body, setBody] = useState('');
  const [userSearch, setUserSearch] = useState('');
  const [users, setUsers] = useState<AdminUser[]>([]);
  const [selectedUser, setSelectedUser] = useState<AdminUser | null>(null);
  const [searching, setSearching] = useState(false);
  const [sending, setSending] = useState(false);
  const [toast, setToast] = useState('');
  const [toastError, setToastError] = useState(false);
  const [lastResult, setLastResult] = useState<{ devicesTargeted: number; delivered: number; failed: number } | null>(null);

  const showToast = (msg: string, isError = false) => {
    setToast(msg); setToastError(isError); setTimeout(() => setToast(''), 4000);
  };

  const searchUsers = async (q: string) => {
    setUserSearch(q);
    if (!q.trim()) { setUsers([]); return; }
    setSearching(true);
    try {
      const res = await apiGet<{ success: boolean; data: { users: AdminUser[] } }>(`/admin/users?search=${encodeURIComponent(q)}&limit=8`);
      setUsers(res.data?.users || []);
    } catch {
      setUsers([]);
    } finally {
      setSearching(false);
    }
  };

  const handleSend = async () => {
    if (!title.trim() || !body.trim()) return;
    if (audience === 'single' && !selectedUser) return;
    setSending(true);
    setLastResult(null);
    try {
      const res = await apiPost<{ success: boolean; message: string; data: { devicesTargeted: number; delivered: number; failed: number } }>('/admin/notify', {
        title: title.trim(),
        body: body.trim(),
        ...(audience === 'single' && selectedUser ? { user_id: selectedUser.id } : {}),
      });
      setLastResult(res.data);
      showToast(res.message || 'Notification sent');
      setTitle(''); setBody(''); setSelectedUser(null); setUserSearch(''); setUsers([]);
    } catch (e: any) {
      showToast(e.message || 'Failed to send notification', true);
    } finally {
      setSending(false);
    }
  };

  return (
    <AdminLayout title="Notifications" subtitle="Send push notifications to your customers">
      <div className="max-w-2xl bg-white rounded-2xl border border-[#ECECEC] p-6 shadow-sm">
        <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-2">Audience</label>
        <div className="grid grid-cols-2 gap-3 mb-5">
          <button
            onClick={() => { setAudience('all'); setSelectedUser(null); }}
            className={`flex items-center gap-2 justify-center px-4 py-3 rounded-xl border-2 font-black text-sm transition-colors ${audience === 'all' ? 'border-[#FF6B2C] bg-[#FFF3ED] text-[#FF6B2C]' : 'border-[#ECECEC] text-gray-500'}`}
          >
            <Users size={16} /> All Customers
          </button>
          <button
            onClick={() => setAudience('single')}
            className={`flex items-center gap-2 justify-center px-4 py-3 rounded-xl border-2 font-black text-sm transition-colors ${audience === 'single' ? 'border-[#FF6B2C] bg-[#FFF3ED] text-[#FF6B2C]' : 'border-[#ECECEC] text-gray-500'}`}
          >
            <User size={16} /> Single User
          </button>
        </div>

        {audience === 'single' && (
          <div className="mb-5">
            <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Find User</label>
            {selectedUser ? (
              <div className="flex items-center justify-between px-4 py-2.5 rounded-xl border border-[#ECECEC] bg-[#F8F7FC]">
                <div>
                  <p className="text-sm font-black text-[#111827]">{selectedUser.name}</p>
                  <p className="text-xs font-bold text-gray-400">{selectedUser.phone || selectedUser.email}</p>
                </div>
                <button onClick={() => setSelectedUser(null)} className="text-gray-400 hover:text-red-500"><X size={16} /></button>
              </div>
            ) : (
              <div className="relative">
                <div className="relative">
                  <Search size={16} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-400" />
                  <input
                    value={userSearch}
                    onChange={e => searchUsers(e.target.value)}
                    placeholder="Search by name, email, or phone..."
                    className="w-full border border-[#ECECEC] rounded-xl pl-10 pr-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C]"
                  />
                </div>
                {userSearch && (
                  <div className="mt-2 border border-[#ECECEC] rounded-xl max-h-48 overflow-y-auto bg-white shadow-sm">
                    {searching ? (
                      <div className="p-4 flex justify-center"><Loader2 size={16} className="animate-spin text-gray-400" /></div>
                    ) : users.length === 0 ? (
                      <p className="p-4 text-xs font-bold text-gray-400 text-center">No users found</p>
                    ) : (
                      users.map(u => (
                        <button
                          key={u.id}
                          onClick={() => { setSelectedUser(u); setUserSearch(''); setUsers([]); }}
                          className="w-full text-left px-4 py-2.5 hover:bg-[#F8F7FC] flex flex-col"
                        >
                          <span className="text-sm font-bold text-[#111827]">{u.name}</span>
                          <span className="text-xs font-bold text-gray-400">{u.phone || u.email}</span>
                        </button>
                      ))
                    )}
                  </div>
                )}
              </div>
            )}
          </div>
        )}

        <div className="mb-4">
          <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Title *</label>
          <input
            value={title}
            onChange={e => setTitle(e.target.value)}
            placeholder="e.g. Flash Sale is Live!"
            maxLength={100}
            className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C]"
          />
        </div>
        <div className="mb-6">
          <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Message *</label>
          <textarea
            value={body}
            onChange={e => setBody(e.target.value)}
            placeholder="Get up to 70% off on electronics, today only."
            rows={3}
            maxLength={300}
            className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C] resize-none"
          />
        </div>

        <button
          onClick={handleSend}
          disabled={sending || !title.trim() || !body.trim() || (audience === 'single' && !selectedUser)}
          className="w-full flex items-center justify-center gap-2 bg-[#FF6B2C] text-white py-3 rounded-xl font-black text-sm shadow-lg shadow-[#FF6B2C]/20 hover:scale-[1.02] active:scale-95 transition-all disabled:opacity-50 disabled:scale-100"
        >
          {sending ? <Loader2 size={16} className="animate-spin" /> : <Send size={16} />}
          {sending ? 'Sending...' : audience === 'all' ? 'Send to All Customers' : 'Send to User'}
        </button>

        {lastResult && (
          <div className="mt-5 grid grid-cols-3 gap-3">
            <div className="bg-[#F8F7FC] rounded-xl p-3 text-center">
              <p className="text-lg font-black text-[#111827]">{lastResult.devicesTargeted}</p>
              <p className="text-[10px] font-bold text-gray-400 uppercase tracking-wider">Devices</p>
            </div>
            <div className="bg-green-50 rounded-xl p-3 text-center">
              <p className="text-lg font-black text-green-600">{lastResult.delivered}</p>
              <p className="text-[10px] font-bold text-gray-400 uppercase tracking-wider">Delivered</p>
            </div>
            <div className="bg-red-50 rounded-xl p-3 text-center">
              <p className="text-lg font-black text-red-500">{lastResult.failed}</p>
              <p className="text-[10px] font-bold text-gray-400 uppercase tracking-wider">Failed</p>
            </div>
          </div>
        )}
      </div>

      {toast && <Toast msg={toast} isError={toastError} onClose={() => setToast('')} />}
    </AdminLayout>
  );
};

export default AdminNotifications;
