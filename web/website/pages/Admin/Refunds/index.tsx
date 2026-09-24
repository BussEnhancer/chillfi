import React, { useState, useEffect } from 'react';
import AdminLayout from '../../../components/admin/AdminLayout';
import { Check, X, Loader2, RotateCcw, IndianRupee } from 'lucide-react';
import { apiGet, apiPut, friendlyError } from '../../../utils/api';

interface ApiRefundRequest {
  id: string;
  order_id: string;
  order_number: string;
  order_total: string;
  order_status: string;
  customer_name: string;
  customer_phone: string;
  customer_email: string;
  type: 'Refund' | 'Return' | 'Exchange';
  reason: string;
  status: 'Requested' | 'Approved' | 'Rejected' | 'Refunded';
  refund_amount?: string;
  admin_notes?: string;
  created_at: string;
}

const statusStyle: Record<string, string> = {
  Requested: 'bg-amber-50 text-amber-600',
  Approved: 'bg-blue-50 text-blue-600',
  Rejected: 'bg-red-50 text-red-500',
  Refunded: 'bg-green-50 text-green-600',
};

const Toast: React.FC<{ msg: string; onClose: () => void }> = ({ msg, onClose }) => (
  <div className="fixed bottom-6 right-6 z-[100] flex items-center gap-3 bg-[#121212] text-white px-5 py-3.5 rounded-2xl shadow-2xl">
    <div className="w-6 h-6 bg-green-500 rounded-full flex items-center justify-center shrink-0"><Check size={13} /></div>
    <span className="text-sm font-bold">{msg}</span>
    <button onClick={onClose} className="ml-2 text-white/50 hover:text-white"><X size={14} /></button>
  </div>
);

const AdminRefunds: React.FC = () => {
  const [requests, setRequests] = useState<ApiRefundRequest[]>([]);
  const [filter, setFilter] = useState<'all' | 'Requested' | 'Approved' | 'Rejected' | 'Refunded'>('all');
  const [loading, setLoading] = useState(true);
  const [updating, setUpdating] = useState<string | null>(null);
  const [toast, setToast] = useState('');
  const [notesDraft, setNotesDraft] = useState<Record<string, string>>({});

  const showToast = (msg: string) => { setToast(msg); setTimeout(() => setToast(''), 3000); };

  const load = async (status = filter) => {
    setLoading(true);
    try {
      const res = await apiGet<{ success: boolean; data: { requests: ApiRefundRequest[] } }>(`/admin/refund-requests?limit=100${status !== 'all' ? `&status=${status}` : ''}`);
      setRequests(res.data?.requests || []);
    } catch (e) {
      showToast(friendlyError(e, "Couldn't load refund requests"));
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { load(filter); }, [filter]);

  const handleUpdate = async (r: ApiRefundRequest, status: ApiRefundRequest['status']) => {
    setUpdating(r.id);
    try {
      const res = await apiPut<{ success: boolean; data: ApiRefundRequest }>(`/admin/refund-requests/${r.id}`, {
        status,
        admin_notes: notesDraft[r.id] ?? r.admin_notes,
      });
      setRequests(prev => prev.map(x => x.id === r.id ? { ...x, ...res.data } : x));
      showToast(`Request marked ${status}`);
    } catch (e: any) {
      showToast(friendlyError(e, 'Failed to update request'));
    } finally {
      setUpdating(null);
    }
  };

  const counts = {
    all: requests.length,
    Requested: requests.filter(r => r.status === 'Requested').length,
    Approved: requests.filter(r => r.status === 'Approved').length,
    Refunded: requests.filter(r => r.status === 'Refunded').length,
  };

  return (
    <AdminLayout title="Refunds & Returns" subtitle="Manage customer refund, return, and exchange requests">
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        {[
          { label: 'Total Requests', value: counts.all, color: '#FF6B2C' },
          { label: 'Pending', value: counts.Requested, color: '#F59E0B' },
          { label: 'Approved', value: counts.Approved, color: '#3B82F6' },
          { label: 'Refunded', value: counts.Refunded, color: '#10B981' },
        ].map((s, i) => (
          <div key={i} className="bg-white rounded-2xl p-4 border border-[#ECECEC] shadow-sm">
            <p className="text-2xl font-black mb-1" style={{ color: s.color }}>{s.value}</p>
            <p className="text-xs font-bold text-gray-400">{s.label}</p>
          </div>
        ))}
      </div>

      <div className="flex gap-2 mb-4">
        {(['all', 'Requested', 'Approved', 'Rejected', 'Refunded'] as const).map(f => (
          <button key={f} onClick={() => setFilter(f)} className={`px-4 py-2 rounded-xl text-xs font-black transition-all ${filter === f ? 'bg-[#FF6B2C] text-white shadow-lg shadow-[#FF6B2C]/20' : 'bg-white border border-[#ECECEC] text-gray-500 hover:border-[#FF6B2C] hover:text-[#FF6B2C]'}`}>
            {f === 'all' ? 'All' : f}
          </button>
        ))}
      </div>

      {loading ? (
        <div className="flex items-center justify-center py-12 gap-2 text-gray-400">
          <Loader2 size={18} className="animate-spin" />
          <span className="text-sm font-bold">Loading requests...</span>
        </div>
      ) : (
        <div className="space-y-4">
          {requests.map(r => (
            <div key={r.id} className="bg-white rounded-2xl border border-[#ECECEC] shadow-sm p-5">
              <div className="flex items-start justify-between gap-4 flex-wrap mb-3">
                <div>
                  <div className="flex items-center gap-2 mb-1">
                    <span className="text-sm font-black text-[#111827]">#{r.order_number}</span>
                    <span className="text-[9px] font-black px-2 py-0.5 rounded-full bg-[#F8F7FC] text-gray-500 uppercase tracking-wide">{r.type}</span>
                    <span className={`text-[10px] font-black px-2.5 py-1 rounded-lg uppercase tracking-wide ${statusStyle[r.status]}`}>{r.status}</span>
                  </div>
                  <p className="text-xs font-bold text-gray-400">{r.customer_name} · {r.customer_phone || r.customer_email}</p>
                </div>
                <div className="text-right">
                  <p className="text-lg font-black text-[#111827] flex items-center gap-0.5 justify-end"><IndianRupee size={14} />{Number(r.refund_amount ?? r.order_total).toLocaleString()}</p>
                  <p className="text-[10px] font-bold text-gray-400">{new Date(r.created_at).toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' })}</p>
                </div>
              </div>

              <p className="text-sm font-bold text-gray-600 bg-[#F8F7FC] rounded-xl p-3 mb-3">{r.reason}</p>

              <textarea
                value={notesDraft[r.id] ?? r.admin_notes ?? ''}
                onChange={e => setNotesDraft(prev => ({ ...prev, [r.id]: e.target.value }))}
                placeholder="Internal notes (optional)"
                rows={2}
                className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C] resize-none mb-3"
              />

              <div className="flex flex-wrap gap-2">
                {r.status === 'Requested' && (
                  <>
                    <button onClick={() => handleUpdate(r, 'Approved')} disabled={updating === r.id} className="px-4 py-2 rounded-xl bg-blue-500 text-white text-xs font-black disabled:opacity-50">Approve</button>
                    <button onClick={() => handleUpdate(r, 'Rejected')} disabled={updating === r.id} className="px-4 py-2 rounded-xl border-2 border-red-200 text-red-500 text-xs font-black disabled:opacity-50">Reject</button>
                  </>
                )}
                {r.status === 'Approved' && (
                  <button onClick={() => handleUpdate(r, 'Refunded')} disabled={updating === r.id} className="flex items-center gap-1.5 px-4 py-2 rounded-xl bg-green-500 text-white text-xs font-black disabled:opacity-50">
                    {updating === r.id ? <Loader2 size={12} className="animate-spin" /> : <RotateCcw size={12} />}
                    Mark Refunded
                  </button>
                )}
              </div>
            </div>
          ))}
          {requests.length === 0 && (
            <div className="py-20 text-center text-sm font-bold text-gray-400 bg-white rounded-2xl border border-[#ECECEC]">No refund/return requests found</div>
          )}
        </div>
      )}

      {toast && <Toast msg={toast} onClose={() => setToast('')} />}
    </AdminLayout>
  );
};

export default AdminRefunds;
