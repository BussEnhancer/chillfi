import React, { useState, useEffect } from 'react';
import AdminLayout from '../../../components/admin/AdminLayout';
import { Trash2, Mail, MailOpen, X, Check, Loader2, Phone, Reply, Send, Info } from 'lucide-react';
import { apiGet, apiPut, apiPost, apiDelete } from '../../../utils/api';

interface ApiMessage {
  id: string;
  name: string;
  email: string;
  phone?: string;
  subject: string;
  message: string;
  is_read: boolean;
  reply?: string;
  replied_at?: string;
  created_at: string;
}

const Toast: React.FC<{ msg: string; onClose: () => void }> = ({ msg, onClose }) => (
  <div className="fixed bottom-6 right-6 z-[100] flex items-center gap-3 bg-[#121212] text-white px-5 py-3.5 rounded-2xl shadow-2xl">
    <div className="w-6 h-6 bg-green-500 rounded-full flex items-center justify-center shrink-0"><Check size={13} /></div>
    <span className="text-sm font-bold">{msg}</span>
    <button onClick={onClose} className="ml-2 text-white/50 hover:text-white"><X size={14} /></button>
  </div>
);

const DeleteConfirm: React.FC<{ name: string; onConfirm: () => void; onCancel: () => void }> = ({ name, onConfirm, onCancel }) => (
  <div className="fixed inset-0 bg-black/40 backdrop-blur-sm z-50 flex items-center justify-center p-4">
    <div className="bg-white rounded-2xl shadow-2xl w-full max-w-sm p-6 text-center">
      <div className="w-14 h-14 bg-red-50 rounded-full flex items-center justify-center mx-auto mb-4"><Trash2 size={24} className="text-red-500" /></div>
      <h3 className="text-lg font-black text-[#111827] mb-2">Delete Message?</h3>
      <p className="text-sm font-bold text-gray-400 mb-6">Delete the message from <span className="text-[#111827] font-black">{name}</span>?</p>
      <div className="flex gap-3">
        <button onClick={onCancel} className="flex-1 border-2 border-[#ECECEC] text-gray-600 py-2.5 rounded-xl font-black text-sm">Cancel</button>
        <button onClick={onConfirm} className="flex-1 bg-red-500 text-white py-2.5 rounded-xl font-black text-sm hover:bg-red-600">Delete</button>
      </div>
    </div>
  </div>
);

const AdminMessages: React.FC = () => {
  const [messages, setMessages] = useState<ApiMessage[]>([]);
  const [filter, setFilter] = useState<'All' | 'Unread' | 'Read'>('All');
  const [deleting, setDeleting] = useState<ApiMessage | null>(null);
  const [toast, setToast] = useState('');
  const [loading, setLoading] = useState(false);
  const [replying, setReplying] = useState<string | null>(null);
  const [replyText, setReplyText] = useState('');
  const [sendingReply, setSendingReply] = useState(false);

  const showToast = (msg: string) => { setToast(msg); setTimeout(() => setToast(''), 3000); };

  const loadMessages = async () => {
    setLoading(true);
    try {
      const res = await apiGet<{ success: boolean; data: { messages: ApiMessage[]; total: number } }>('/admin/messages?limit=200');
      setMessages(res.data?.messages || []);
    } catch {
      // keep existing
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { loadMessages(); }, []);

  const filtered = messages.filter(m => filter === 'All' || (filter === 'Unread' ? !m.is_read : m.is_read));

  const handleToggleRead = async (m: ApiMessage) => {
    const newRead = !m.is_read;
    setMessages(prev => prev.map(x => x.id === m.id ? { ...x, is_read: newRead } : x));
    try {
      await apiPut(`/admin/messages/${m.id}/read`, { is_read: newRead });
    } catch {
      setMessages(prev => prev.map(x => x.id === m.id ? { ...x, is_read: m.is_read } : x));
    }
  };

  const handleDelete = async () => {
    if (!deleting) return;
    try {
      await apiDelete(`/admin/messages/${deleting.id}`);
      setMessages(prev => prev.filter(m => m.id !== deleting.id));
      showToast('Message deleted!');
    } catch (e: any) {
      showToast(e.message || 'Failed to delete message');
    } finally {
      setDeleting(null);
    }
  };

  const openReply = (m: ApiMessage) => {
    setReplying(m.id);
    setReplyText(m.reply || '');
  };

  const handleSendReply = async (m: ApiMessage) => {
    if (!replyText.trim()) return;
    setSendingReply(true);
    try {
      const res = await apiPost<{ success: boolean; data: ApiMessage }>(`/admin/messages/${m.id}/reply`, { reply: replyText.trim() });
      setMessages(prev => prev.map(x => x.id === m.id ? { ...x, ...res.data } : x));
      showToast('Reply saved');
      setReplying(null);
    } catch (e: any) {
      showToast(e.message || 'Failed to save reply');
    } finally {
      setSendingReply(false);
    }
  };

  const unreadCount = messages.filter(m => !m.is_read).length;
  const thisWeekCount = messages.filter(m => Date.now() - new Date(m.created_at).getTime() < 7 * 24 * 60 * 60 * 1000).length;

  return (
    <AdminLayout title="Messages" subtitle={`${messages.length} contact messages`}>
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        {[
          { label: 'Total', value: messages.length, color: '#FF6B2C' },
          { label: 'Unread', value: unreadCount, color: '#EF4444' },
          { label: 'Read', value: messages.length - unreadCount, color: '#10B981' },
          { label: 'This Week', value: thisWeekCount, color: '#0EA5E9' },
        ].map((s, i) => (
          <div key={i} className="bg-white rounded-2xl p-4 border border-[#ECECEC] shadow-sm">
            <p className="text-2xl font-black mb-1" style={{ color: s.color }}>{s.value}</p>
            <p className="text-xs font-bold text-gray-400">{s.label}</p>
          </div>
        ))}
      </div>

      <div className="flex items-center justify-between mb-4">
        <h3 className="text-sm font-black text-[#111827]">All Messages</h3>
        <div className="flex gap-2">
          {(['All', 'Unread', 'Read'] as const).map(f => (
            <button key={f} onClick={() => setFilter(f)} className={`px-4 py-2 rounded-xl text-xs font-black transition-all ${filter === f ? 'bg-[#FF6B2C] text-white shadow-lg shadow-[#FF6B2C]/20' : 'bg-white border border-[#ECECEC] text-gray-500 hover:border-[#FF6B2C] hover:text-[#FF6B2C]'}`}>
              {f}
            </button>
          ))}
        </div>
      </div>

      {loading ? (
        <div className="flex items-center justify-center py-12 gap-2 text-gray-400">
          <Loader2 size={18} className="animate-spin" />
          <span className="text-sm font-bold">Loading messages...</span>
        </div>
      ) : (
        <div className="bg-white rounded-2xl border border-[#ECECEC] shadow-sm divide-y divide-[#F8F7FC]">
          {filtered.map(m => (
            <div key={m.id} className={`p-5 flex items-start gap-4 ${!m.is_read ? 'bg-[#FFF8F5]' : ''}`}>
              <button onClick={() => handleToggleRead(m)} className="w-10 h-10 rounded-xl bg-[#F8F7FC] flex items-center justify-center text-gray-400 shrink-0 hover:bg-[#FFF3ED] hover:text-[#FF6B2C] transition-colors" title={m.is_read ? 'Mark as unread' : 'Mark as read'}>
                {m.is_read ? <MailOpen size={18} /> : <Mail size={18} />}
              </button>
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2 mb-1 flex-wrap">
                  <span className="text-sm font-black text-[#111827]">{m.name}</span>
                  <span className="text-xs font-bold text-gray-400">{m.email}</span>
                  {m.phone && <span className="text-xs font-bold text-gray-400 flex items-center gap-1"><Phone size={10} />{m.phone}</span>}
                  {!m.is_read && <span className="text-[9px] font-black px-2 py-0.5 rounded-full bg-[#FF6B2C]/10 text-[#FF6B2C] uppercase tracking-wide">New</span>}
                </div>
                <p className="text-sm font-black text-[#111827] capitalize">{m.subject}</p>
                <p className="text-sm font-bold text-gray-500">{m.message}</p>
                <p className="text-[10px] font-bold text-gray-400 mt-1.5">{new Date(m.created_at).toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' })}</p>

                {m.reply && replying !== m.id && (
                  <div className="mt-3 bg-[#F8F7FC] rounded-xl p-3 border-l-2 border-[#FF6B2C]">
                    <p className="text-[10px] font-black text-[#FF6B2C] uppercase tracking-wide mb-1">Your Reply</p>
                    <p className="text-xs font-bold text-gray-600">{m.reply}</p>
                  </div>
                )}

                {replying === m.id ? (
                  <div className="mt-3">
                    <textarea
                      value={replyText}
                      onChange={e => setReplyText(e.target.value)}
                      placeholder={`Write a reply to ${m.name}...`}
                      rows={3}
                      className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C] resize-none"
                    />
                    <div className="flex items-center gap-2 mt-2 text-[10px] font-bold text-gray-400">
                      <Info size={12} /> Reply is saved for record-keeping. Email delivery isn't configured yet — contact the customer directly if needed.
                    </div>
                    <div className="flex justify-end gap-2 mt-2">
                      <button onClick={() => setReplying(null)} className="px-4 py-2 rounded-xl border border-[#ECECEC] text-xs font-black text-gray-600">Cancel</button>
                      <button
                        onClick={() => handleSendReply(m)}
                        disabled={sendingReply || !replyText.trim()}
                        className="flex items-center gap-1.5 px-4 py-2 rounded-xl bg-[#FF6B2C] text-white text-xs font-black shadow-lg shadow-[#FF6B2C]/20 disabled:opacity-50"
                      >
                        {sendingReply ? <Loader2 size={12} className="animate-spin" /> : <Send size={12} />}
                        Save Reply
                      </button>
                    </div>
                  </div>
                ) : (
                  <button onClick={() => openReply(m)} className="mt-2 flex items-center gap-1.5 text-xs font-black text-[#FF6B2C] hover:text-[#E05520]">
                    <Reply size={12} /> {m.reply ? 'Edit Reply' : 'Reply'}
                  </button>
                )}
              </div>
              <button onClick={() => setDeleting(m)} className="w-8 h-8 rounded-lg bg-[#F8F7FC] flex items-center justify-center text-gray-500 hover:bg-red-50 hover:text-red-500 transition-colors shrink-0" title="Delete">
                <Trash2 size={14} />
              </button>
            </div>
          ))}
          {filtered.length === 0 && (
            <div className="py-12 text-center text-sm font-bold text-gray-400">No messages found</div>
          )}
        </div>
      )}

      {deleting && <DeleteConfirm name={deleting.name} onConfirm={handleDelete} onCancel={() => setDeleting(null)} />}
      {toast && <Toast msg={toast} onClose={() => setToast('')} />}
    </AdminLayout>
  );
};

export default AdminMessages;
