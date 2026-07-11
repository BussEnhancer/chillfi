import React, { useState, useEffect } from 'react';
import AdminLayout from '../../../components/admin/AdminLayout';
import { Search, Trash2, Mail, ChevronLeft, ChevronRight, X, Check, ShieldOff, ShieldCheck, Eye, Loader2, Headset } from 'lucide-react';
import { apiGet, apiPut } from '../../../utils/api';
import { useStore, StoreUser as User } from '../../../context/StoreContext';

const statusStyle: Record<string, string> = {
  Active: 'bg-green-50 text-green-600',
  Inactive: 'bg-gray-100 text-gray-500',
  Blocked: 'bg-red-50 text-red-500',
};

interface ApiUser {
  id: string; name?: string; email?: string; phone?: string;
  role?: string; status?: string; created_at?: string;
  order_count?: number | string; total_spent?: number | string;
}

const normalizeApiUser = (u: ApiUser): User => ({
  id: u.id,
  name: u.name || 'Unknown',
  email: u.email || '',
  phone: u.phone || '',
  orders: Number(u.order_count || 0),
  spent: Number(u.total_spent || 0),
  joined: u.created_at ? new Date(u.created_at).toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' }) : '',
  status: (u.status || 'Active') as string,
  city: '',
  role: u.role || 'customer',
});

const Toast: React.FC<{ msg: string; onClose: () => void }> = ({ msg, onClose }) => (
  <div className="fixed bottom-6 right-6 z-[100] flex items-center gap-3 bg-[#121212] text-white px-5 py-3.5 rounded-2xl shadow-2xl">
    <div className="w-6 h-6 bg-green-500 rounded-full flex items-center justify-center shrink-0"><Check size={13} /></div>
    <span className="text-sm font-bold">{msg}</span>
    <button onClick={onClose} className="ml-2 text-white/50 hover:text-white"><X size={14} /></button>
  </div>
);

const UserDetailModal: React.FC<{ user: User; onClose: () => void; onBlock: () => void }> = ({ user, onClose, onBlock }) => (
  <div className="fixed inset-0 bg-black/40 backdrop-blur-sm z-50 flex items-center justify-center p-4">
    <div className="bg-white rounded-2xl shadow-2xl w-full max-w-md">
      <div className="flex items-center justify-between px-6 py-4 border-b border-[#F8F7FC]">
        <h3 className="text-lg font-black text-[#111827]">User Profile</h3>
        <button onClick={onClose} className="w-8 h-8 rounded-xl bg-[#F8F7FC] flex items-center justify-center hover:bg-red-50 hover:text-red-500 transition-colors"><X size={16} /></button>
      </div>
      <div className="p-6">
        <div className="flex items-center gap-4 mb-6">
          <div className="w-16 h-16 rounded-2xl bg-[#FF6B2C] flex items-center justify-center text-white font-black text-xl shadow-lg shadow-[#FF6B2C]/20">
            {user.name.split(' ').map(n => n[0]).join('').slice(0, 2)}
          </div>
          <div>
            <h4 className="text-lg font-black text-[#111827]">{user.name}</h4>
            <span className={`text-[10px] font-black px-2.5 py-1 rounded-lg uppercase tracking-wide inline-block mt-1 ${statusStyle[user.status]}`}>{user.status}</span>
          </div>
        </div>

        <div className="grid grid-cols-2 gap-3 mb-5">
          {[
            { label: 'Email', value: user.email },
            { label: 'Phone', value: user.phone || 'N/A' },
            { label: 'Member Since', value: user.joined },
            { label: 'User ID', value: user.id.slice(0, 12) + '...' },
            { label: 'Total Orders', value: user.orders.toString() },
            { label: 'Total Spent', value: `₹${user.spent.toLocaleString()}` },
          ].map((f, i) => (
            <div key={i} className="bg-[#F8F7FC] rounded-xl p-3">
              <p className="text-[9px] font-black text-gray-400 uppercase tracking-widest mb-1">{f.label}</p>
              <p className="text-sm font-black text-[#111827] truncate">{f.value}</p>
            </div>
          ))}
        </div>

        <div className="flex gap-2">
          <button
            onClick={() => { onBlock(); onClose(); }}
            className={`flex-1 flex items-center justify-center gap-2 py-2.5 rounded-xl font-black text-sm border-2 transition-all ${user.status === 'Blocked' ? 'border-green-500 text-green-600 hover:bg-green-50' : 'border-amber-400 text-amber-600 hover:bg-amber-50'}`}
          >
            {user.status === 'Blocked' ? <><ShieldCheck size={15} />Unblock</> : <><ShieldOff size={15} />Block</>}
          </button>
          <button onClick={() => { window.open(`mailto:${user.email}`); }} className="flex-1 flex items-center justify-center gap-2 py-2.5 rounded-xl font-black text-sm border-2 border-[#FF6B2C] text-[#FF6B2C] hover:bg-[#FFF3ED] transition-all">
            <Mail size={15} />Email
          </button>
        </div>
      </div>
    </div>
  </div>
);

const PAGE_SIZE = 10;

const AdminUsers: React.FC = () => {
  const { users, setUsers } = useStore();
  const [search, setSearch] = useState('');
  const [viewing, setViewing] = useState<User | null>(null);
  const [toast, setToast] = useState('');
  const [loading, setLoading] = useState(false);
  const [page, setPage] = useState(1);

  const showToast = (msg: string) => { setToast(msg); setTimeout(() => setToast(''), 3000); };

  const loadUsers = async (q = '') => {
    setLoading(true);
    try {
      const res = await apiGet<{ success: boolean; data: { users: ApiUser[]; total: number } }>(`/admin/users?limit=200${q ? `&search=${encodeURIComponent(q)}` : ''}`);
      if (res.data?.users) setUsers(res.data.users.map(normalizeApiUser));
    } catch {
      // keep existing
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { loadUsers(); }, []);

  const handleBlock = async (id: string) => {
    const u = users.find(x => x.id === id);
    if (!u) return;
    const newStatus = u.status === 'Blocked' ? 'Active' : 'Blocked';
    setUsers(prev => prev.map(x => x.id === id ? { ...x, status: newStatus } : x));
    try {
      await apiPut(`/admin/users/${id}/status`, { status: newStatus });
      showToast(`${u.name} ${newStatus === 'Blocked' ? 'blocked' : 'unblocked'} successfully!`);
    } catch (e: any) {
      // revert
      setUsers(prev => prev.map(x => x.id === id ? { ...x, status: u.status } : x));
      showToast(e.message || 'Failed to update user status');
    }
  };

  const handleRoleToggle = async (id: string) => {
    const u = users.find(x => x.id === id);
    if (!u || u.role === 'admin') return;
    const newRole = u.role === 'support_staff' ? 'customer' : 'support_staff';
    setUsers(prev => prev.map(x => x.id === id ? { ...x, role: newRole } : x));
    try {
      await apiPut(`/admin/users/${id}/role`, { role: newRole });
      showToast(`${u.name} is ${newRole === 'support_staff' ? 'now Support Staff' : 'no longer Support Staff'}`);
    } catch (e: any) {
      setUsers(prev => prev.map(x => x.id === id ? { ...x, role: u.role } : x));
      showToast(e.message || 'Failed to update role');
    }
  };

  const filtered = users.filter(u =>
    u.name.toLowerCase().includes(search.toLowerCase()) ||
    u.email.toLowerCase().includes(search.toLowerCase())
  );

  const totalPages = Math.max(1, Math.ceil(filtered.length / PAGE_SIZE));
  const paginated = filtered.slice((page - 1) * PAGE_SIZE, page * PAGE_SIZE);

  return (
    <AdminLayout title="Users" subtitle={`${users.length} registered users`}>
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        {[
          { label: 'Total', value: users.length, color: '#FF6B2C' },
          { label: 'Active', value: users.filter(u => u.status === 'Active').length, color: '#10B981' },
          { label: 'Inactive', value: users.filter(u => u.status === 'Inactive').length, color: '#9CA3AF' },
          { label: 'Blocked', value: users.filter(u => u.status === 'Blocked').length, color: '#EF4444' },
        ].map((s, i) => (
          <div key={i} className="bg-white rounded-2xl p-4 border border-[#ECECEC] shadow-sm">
            <p className="text-2xl font-black mb-1" style={{ color: s.color }}>{s.value}</p>
            <p className="text-xs font-bold text-gray-400">{s.label} Users</p>
          </div>
        ))}
      </div>

      <div className="flex flex-wrap items-center justify-between gap-4 mb-4">
        <div className="relative">
          <input
            value={search}
            onChange={e => { setSearch(e.target.value); setPage(1); }}
            type="text" placeholder="Search by name or email..."
            className="w-72 bg-white border border-[#ECECEC] rounded-xl pl-9 pr-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C] shadow-sm"
          />
          <Search size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
        </div>
      </div>

      <div className="bg-white rounded-2xl border border-[#ECECEC] shadow-sm overflow-hidden">
        {loading ? (
          <div className="flex items-center justify-center py-8 gap-2 text-gray-400">
            <Loader2 size={18} className="animate-spin" />
            <span className="text-sm font-bold">Loading users...</span>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="bg-[#F8F7FC] border-b border-[#ECECEC]">
                  {['User', 'Contact', 'Role', 'Orders', 'Total Spent', 'Joined', 'Status', 'Actions'].map(h => (
                    <th key={h} className="px-4 py-3 text-left text-[10px] font-black text-gray-400 uppercase tracking-widest whitespace-nowrap">{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody className="divide-y divide-[#F8F7FC]">
                {paginated.map((u) => (
                  <tr key={u.id} className="hover:bg-[#FFF8F5] transition-colors group">
                    <td className="px-4 py-3.5">
                      <div className="flex items-center gap-3">
                        <div className="w-9 h-9 rounded-xl bg-[#FF6B2C] flex items-center justify-center text-white font-black text-xs shrink-0">
                          {u.name.split(' ').map(n => n[0]).join('').slice(0, 2)}
                        </div>
                        <div>
                          <p className="text-sm font-black text-[#111827] whitespace-nowrap">{u.name}</p>
                          <p className="text-[10px] font-bold text-gray-400 max-w-[120px] truncate">{u.id}</p>
                        </div>
                      </div>
                    </td>
                    <td className="px-4 py-3.5 whitespace-nowrap">
                      <p className="text-xs font-bold text-gray-700">{u.email}</p>
                      <p className="text-[10px] font-bold text-gray-400">{u.phone || '—'}</p>
                    </td>
                    <td className="px-4 py-3.5 whitespace-nowrap">
                      {u.role === 'admin' ? (
                        <span className="text-[10px] font-black px-2.5 py-1 rounded-lg uppercase tracking-wide bg-purple-50 text-purple-600">Admin</span>
                      ) : u.role === 'support_staff' ? (
                        <span className="text-[10px] font-black px-2.5 py-1 rounded-lg uppercase tracking-wide bg-blue-50 text-blue-600">Support Staff</span>
                      ) : (
                        <span className="text-[10px] font-black px-2.5 py-1 rounded-lg uppercase tracking-wide bg-gray-100 text-gray-500">Customer</span>
                      )}
                    </td>
                    <td className="px-4 py-3.5 text-xs font-bold text-gray-600 whitespace-nowrap">{u.orders}</td>
                    <td className="px-4 py-3.5 text-sm font-black text-[#111827] whitespace-nowrap">₹{u.spent.toLocaleString()}</td>
                    <td className="px-4 py-3.5 text-xs font-bold text-gray-400 whitespace-nowrap">{u.joined}</td>
                    <td className="px-4 py-3.5 whitespace-nowrap">
                      <span className={`text-[10px] font-black px-2.5 py-1 rounded-lg uppercase tracking-wide ${statusStyle[u.status] || 'bg-gray-100 text-gray-500'}`}>{u.status}</span>
                    </td>
                    <td className="px-4 py-3.5">
                      <div className="flex items-center gap-1.5">
                        <button onClick={() => setViewing(u)} className="w-7 h-7 rounded-lg bg-[#F8F7FC] flex items-center justify-center text-gray-500 hover:bg-[#FFF3ED] hover:text-[#FF6B2C] transition-colors" title="View"><Eye size={13} /></button>
                        {u.role !== 'admin' && (
                          <button onClick={() => handleRoleToggle(u.id)} className={`w-7 h-7 rounded-lg flex items-center justify-center transition-colors ${u.role === 'support_staff' ? 'bg-blue-50 text-blue-600 hover:bg-blue-100' : 'bg-[#F8F7FC] text-gray-500 hover:bg-blue-50 hover:text-blue-600'}`} title={u.role === 'support_staff' ? 'Revoke Support Staff' : 'Make Support Staff'}>
                            <Headset size={13} />
                          </button>
                        )}
                        <button onClick={() => handleBlock(u.id)} className={`w-7 h-7 rounded-lg flex items-center justify-center transition-colors ${u.status === 'Blocked' ? 'bg-green-50 text-green-600 hover:bg-green-100' : 'bg-amber-50 text-amber-500 hover:bg-amber-100'}`} title={u.status === 'Blocked' ? 'Unblock' : 'Block'}>
                          {u.status === 'Blocked' ? <ShieldCheck size={13} /> : <ShieldOff size={13} />}
                        </button>
                        <button onClick={() => window.open(`mailto:${u.email}`)} className="w-7 h-7 rounded-lg bg-[#F8F7FC] flex items-center justify-center text-gray-500 hover:bg-[#FFF3ED] hover:text-[#FF6B2C] transition-colors" title="Email"><Mail size={13} /></button>
                        <button onClick={async () => { try { await apiPut(`/admin/users/${u.id}/status`, { status: 'Blocked' }); } catch {} setUsers(prev => prev.filter(x => x.id !== u.id)); showToast(`User ${u.name} deactivated`); }} className="w-7 h-7 rounded-lg bg-[#F8F7FC] flex items-center justify-center text-gray-500 hover:bg-red-50 hover:text-red-500 transition-colors" title="Remove"><Trash2 size={13} /></button>
                      </div>
                    </td>
                  </tr>
                ))}
                {paginated.length === 0 && (
                  <tr><td colSpan={8} className="px-4 py-12 text-center text-sm font-bold text-gray-400">No users found</td></tr>
                )}
              </tbody>
            </table>
          </div>
        )}
        <div className="flex items-center justify-between px-6 py-4 border-t border-[#F8F7FC]">
          <p className="text-xs font-bold text-gray-400">Showing {Math.min((page-1)*PAGE_SIZE+1, filtered.length)}–{Math.min(page*PAGE_SIZE, filtered.length)} of {filtered.length} users</p>
          <div className="flex items-center gap-2">
            <button onClick={() => setPage(p => Math.max(1, p-1))} disabled={page === 1} className="w-8 h-8 flex items-center justify-center rounded-lg border border-[#ECECEC] text-gray-400 disabled:opacity-40"><ChevronLeft size={14} /></button>
            {Array.from({ length: Math.min(5, totalPages) }, (_, i) => {
              const pg = Math.max(1, page-2) + i;
              return pg <= totalPages ? (
                <button key={pg} onClick={() => setPage(pg)} className={`w-8 h-8 flex items-center justify-center rounded-lg text-xs font-black ${pg === page ? 'bg-[#FF6B2C] text-white' : 'text-gray-500 hover:bg-gray-50'}`}>{pg}</button>
              ) : null;
            })}
            <button onClick={() => setPage(p => Math.min(totalPages, p+1))} disabled={page === totalPages} className="w-8 h-8 flex items-center justify-center rounded-lg border border-[#ECECEC] text-gray-400 disabled:opacity-40"><ChevronRight size={14} /></button>
          </div>
        </div>
      </div>

      {viewing && <UserDetailModal user={viewing} onClose={() => setViewing(null)} onBlock={() => handleBlock(viewing.id)} />}
      {toast && <Toast msg={toast} onClose={() => setToast('')} />}
    </AdminLayout>
  );
};

export default AdminUsers;
