import React, { useState, useEffect } from 'react';
import AdminLayout from '../../../components/admin/AdminLayout';
import { Trash2, Star, X, Check, Loader2, MessageSquareText, ShieldCheck, ShieldOff } from 'lucide-react';
import { apiGet, apiDelete, apiPut } from '../../../utils/api';

interface ApiReview {
  id: string;
  rating: number;
  title?: string;
  body?: string;
  is_verified: boolean;
  created_at: string;
  user_id: string;
  user_name: string;
  product_id: string;
  product_name: string;
}

const Toast: React.FC<{ msg: string; onClose: () => void }> = ({ msg, onClose }) => (
  <div className="fixed bottom-6 right-6 z-[100] flex items-center gap-3 bg-[#121212] text-white px-5 py-3.5 rounded-2xl shadow-2xl">
    <div className="w-6 h-6 bg-green-500 rounded-full flex items-center justify-center shrink-0"><Check size={13} /></div>
    <span className="text-sm font-bold">{msg}</span>
    <button onClick={onClose} className="ml-2 text-white/50 hover:text-white"><X size={14} /></button>
  </div>
);

const DeleteConfirm: React.FC<{ title: string; onConfirm: () => void; onCancel: () => void }> = ({ title, onConfirm, onCancel }) => (
  <div className="fixed inset-0 bg-black/40 backdrop-blur-sm z-50 flex items-center justify-center p-4">
    <div className="bg-white rounded-2xl shadow-2xl w-full max-w-sm p-6 text-center">
      <div className="w-14 h-14 bg-red-50 rounded-full flex items-center justify-center mx-auto mb-4"><Trash2 size={24} className="text-red-500" /></div>
      <h3 className="text-lg font-black text-[#111827] mb-2">Delete Review?</h3>
      <p className="text-sm font-bold text-gray-400 mb-6">Delete review <span className="text-[#111827] font-black">"{title}"</span>? This recalculates the product's rating.</p>
      <div className="flex gap-3">
        <button onClick={onCancel} className="flex-1 border-2 border-[#ECECEC] text-gray-600 py-2.5 rounded-xl font-black text-sm">Cancel</button>
        <button onClick={onConfirm} className="flex-1 bg-red-500 text-white py-2.5 rounded-xl font-black text-sm hover:bg-red-600">Delete</button>
      </div>
    </div>
  </div>
);

const AdminReviews: React.FC = () => {
  const [reviews, setReviews] = useState<ApiReview[]>([]);
  const [ratingFilter, setRatingFilter] = useState('All');
  const [deleting, setDeleting] = useState<ApiReview | null>(null);
  const [toast, setToast] = useState('');
  const [loading, setLoading] = useState(false);

  const showToast = (msg: string) => { setToast(msg); setTimeout(() => setToast(''), 3000); };

  const loadReviews = async () => {
    setLoading(true);
    try {
      const res = await apiGet<{ success: boolean; data: { reviews: ApiReview[]; total: number } }>('/admin/reviews?limit=200');
      setReviews(res.data?.reviews || []);
    } catch {
      // keep existing
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { loadReviews(); }, []);

  const filtered = ratingFilter === 'All' ? reviews : reviews.filter(r => String(r.rating) === ratingFilter);

  const handleDelete = async () => {
    if (!deleting) return;
    try {
      await apiDelete(`/admin/reviews/${deleting.id}`);
      setReviews(prev => prev.filter(r => r.id !== deleting.id));
      showToast('Review deleted!');
    } catch (e: any) {
      showToast(e.message || 'Failed to delete review');
    } finally {
      setDeleting(null);
    }
  };

  const handleToggleVerify = async (r: ApiReview) => {
    try {
      const res = await apiPut<{ success: boolean; data: { is_verified: boolean } }>(`/admin/reviews/${r.id}/verify`, {});
      setReviews(prev => prev.map(x => x.id === r.id ? { ...x, is_verified: res.data.is_verified } : x));
      showToast(res.data.is_verified ? 'Marked as Verified' : 'Verification removed');
    } catch (e: any) {
      showToast(e.message || 'Failed to update');
    }
  };

  const avgRating = reviews.length ? (reviews.reduce((s, r) => s + r.rating, 0) / reviews.length).toFixed(1) : '0.0';
  const lowRatingCount = reviews.filter(r => r.rating <= 2).length;

  return (
    <AdminLayout title="Reviews" subtitle={`${reviews.length} reviews`}>
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        {[
          { label: 'Total Reviews', value: reviews.length, color: '#FF6B2C' },
          { label: 'Avg Rating', value: `${avgRating} ★`, color: '#10B981' },
          { label: 'Verified Purchases', value: reviews.filter(r => r.is_verified).length, color: '#0EA5E9' },
          { label: '1-2★ Reviews', value: lowRatingCount, color: '#EF4444' },
        ].map((s, i) => (
          <div key={i} className="bg-white rounded-2xl p-4 border border-[#ECECEC] shadow-sm">
            <p className="text-2xl font-black mb-1" style={{ color: s.color }}>{s.value}</p>
            <p className="text-xs font-bold text-gray-400">{s.label}</p>
          </div>
        ))}
      </div>

      <div className="flex items-center justify-between mb-4">
        <h3 className="text-sm font-black text-[#111827]">All Reviews</h3>
        <select value={ratingFilter} onChange={e => setRatingFilter(e.target.value)} className="px-4 py-2.5 bg-white border border-[#ECECEC] rounded-xl text-sm font-bold text-gray-600 outline-none focus:border-[#FF6B2C] shadow-sm">
          <option>All</option>
          {[5, 4, 3, 2, 1].map(r => <option key={r} value={r}>{r} Star</option>)}
        </select>
      </div>

      {loading ? (
        <div className="flex items-center justify-center py-12 gap-2 text-gray-400">
          <Loader2 size={18} className="animate-spin" />
          <span className="text-sm font-bold">Loading reviews...</span>
        </div>
      ) : (
        <div className="bg-white rounded-2xl border border-[#ECECEC] shadow-sm divide-y divide-[#F8F7FC]">
          {filtered.map(r => (
            <div key={r.id} className="p-5 flex items-start gap-4">
              <div className="w-10 h-10 rounded-xl bg-[#F8F7FC] flex items-center justify-center text-gray-400 shrink-0">
                <MessageSquareText size={18} />
              </div>
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2 mb-1 flex-wrap">
                  <span className="text-sm font-black text-[#111827]">{r.user_name}</span>
                  <span className="text-xs font-bold text-gray-400">on</span>
                  <span className="text-xs font-black text-[#FF6B2C]">{r.product_name}</span>
                  {r.is_verified && <span className="text-[9px] font-black px-2 py-0.5 rounded-full bg-green-50 text-green-600 uppercase tracking-wide">Verified</span>}
                </div>
                <div className="flex items-center gap-1 mb-1.5">
                  {Array.from({ length: 5 }).map((_, i) => (
                    <Star key={i} size={12} className={i < r.rating ? 'fill-amber-400 text-amber-400' : 'text-gray-200'} />
                  ))}
                </div>
                {r.title && <p className="text-sm font-black text-[#111827]">{r.title}</p>}
                {r.body && <p className="text-sm font-bold text-gray-500">{r.body}</p>}
                <p className="text-[10px] font-bold text-gray-400 mt-1.5">{new Date(r.created_at).toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' })}</p>
              </div>
              <div className="flex items-center gap-2 shrink-0">
                <button onClick={() => handleToggleVerify(r)} className={`w-8 h-8 rounded-lg flex items-center justify-center transition-colors ${r.is_verified ? 'bg-green-50 text-green-600 hover:bg-green-100' : 'bg-[#F8F7FC] text-gray-400 hover:bg-green-50 hover:text-green-600'}`} title={r.is_verified ? 'Remove verification' : 'Mark as verified'}>
                  {r.is_verified ? <ShieldCheck size={14} /> : <ShieldOff size={14} />}
                </button>
                <button onClick={() => setDeleting(r)} className="w-8 h-8 rounded-lg bg-[#F8F7FC] flex items-center justify-center text-gray-500 hover:bg-red-50 hover:text-red-500 transition-colors" title="Delete">
                  <Trash2 size={14} />
                </button>
              </div>
            </div>
          ))}
          {filtered.length === 0 && (
            <div className="py-12 text-center text-sm font-bold text-gray-400">No reviews found</div>
          )}
        </div>
      )}

      {deleting && <DeleteConfirm title={deleting.title || deleting.body || 'this review'} onConfirm={handleDelete} onCancel={() => setDeleting(null)} />}
      {toast && <Toast msg={toast} onClose={() => setToast('')} />}
    </AdminLayout>
  );
};

export default AdminReviews;
