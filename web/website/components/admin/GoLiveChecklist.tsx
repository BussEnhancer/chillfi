import React, { useEffect, useState } from 'react';
import { CheckCircle2, XCircle, Info, RefreshCw, ArrowRight } from 'lucide-react';
import { apiGet } from '../../utils/api';

export interface LaunchItem { key: string; title: string; done: boolean | null; detail: string; fix: string | null; optional?: boolean; manual?: boolean }
interface LaunchData { items: LaunchItem[]; server: { node: string; uptime_h: number; memory_free_mb: number; memory_total_mb: number; disk: { free_gb: number; total_gb: number } | null } }

let cache: LaunchData | null = null;
export const loadLaunchStatus = async (force = false) => {
  if (!cache || force) cache = (await apiGet<{ data: LaunchData }>('/admin/launch-status')).data;
  return cache;
};

// Where each item is fixed (Settings tab) and what to do there.
const HOW: Record<string, string> = {
  payments: 'API Keys → Payment Gateway: enter live Merchant ID + Salt Key, then set Environment = PRODUCTION.',
  shipping: 'API Keys → Shipping: enter the production API token + exact pickup location name, then set Environment = production.',
  cod: 'Shipping → COD Available. Keep ON only if Delhivery has enabled COD on your live account.',
  app: 'Store Info → Force Update + Minimum App Version = 1.0.3, once v1.0.3 is live on Google Play.',
  invoices: 'Store Info: enter your real GSTIN, legal name and address, then turn on "Issue GST Tax Invoices".',
  contact: 'Store Info: set the real phone, support email (and WhatsApp) customers should use.',
  email: 'API Keys → Email (SMTP): enter your provider\'s SMTP details, then "Send test email".',
  sms: 'API Keys → OTP / SMS: MSG91 key + DLT template ID, then SMS order updates = on.',
  backups: 'Runs automatically every night at 02:30 IST on the server.',
  uptime: 'Create a free UptimeRobot monitor for https://chillfi.in/api/health (keyword "ok").',
};

const GoLiveChecklist: React.FC<{ onGo: (tab: string) => void }> = ({ onGo }) => {
  const [data, setData] = useState<LaunchData | null>(cache);
  const [err, setErr] = useState('');
  const refresh = (force = true) => { setErr(''); loadLaunchStatus(force).then(setData).catch(() => setErr("Couldn't load the checklist.")); };
  useEffect(() => { refresh(true); }, []); // cached copy shows instantly, then re-checked live
  const required = data?.items.filter((i) => !i.optional && !i.manual) || [];
  const doneCount = required.filter((i) => i.done).length;
  return (
    <div className="bg-white rounded-2xl border border-[#ECECEC] shadow-sm p-6">
      <div className="flex items-center justify-between mb-1">
        <h3 className="text-sm font-black text-[#111827]">Go-Live Checklist</h3>
        <button onClick={() => refresh()} className="p-2 rounded-lg hover:bg-gray-100 text-gray-400" aria-label="Refresh"><RefreshCw size={14} /></button>
      </div>
      <p className="text-[11px] font-bold text-gray-400 mb-5">
        {data ? `${doneCount} of ${required.length} launch items done — checked live from your settings.` : 'Checking your live settings…'}
      </p>
      {err && <p className="text-xs font-bold text-red-500 mb-3">{err}</p>}
      <div className="divide-y divide-[#F3F4F6]">
        {data?.items.map((i) => (
          <div key={i.key} className="py-3.5 flex items-start gap-3">
            <span className="mt-0.5 shrink-0">
              {i.manual ? <Info size={18} className="text-blue-500" /> : i.done ? <CheckCircle2 size={18} className="text-green-600" /> : <XCircle size={18} className={i.optional ? 'text-gray-300' : 'text-red-500'} />}
            </span>
            <div className="flex-1 min-w-0">
              <p className="text-sm font-black text-[#111827]">{i.title}{i.optional && <span className="ml-2 text-[9px] font-black uppercase bg-gray-100 text-gray-500 px-2 py-0.5 rounded-full">Optional</span>}{i.manual && <span className="ml-2 text-[9px] font-black uppercase bg-blue-50 text-blue-600 px-2 py-0.5 rounded-full">Outside admin</span>}</p>
              <p className={`text-[11px] font-bold mt-0.5 ${i.done ? 'text-green-700' : 'text-gray-500'}`}>{i.detail}</p>
              {!i.done && HOW[i.key] && <p className="text-[11px] font-bold text-gray-400 mt-1">How: {HOW[i.key]}</p>}
            </div>
            {i.fix && !i.done && (
              <button onClick={() => onGo(i.fix!)} className="shrink-0 flex items-center gap-1 px-3 py-1.5 rounded-lg bg-[#FFF3ED] text-[#FF6B2C] text-xs font-black hover:bg-[#FF6B2C] hover:text-white">
                Fix <ArrowRight size={12} />
              </button>
            )}
          </div>
        ))}
      </div>
      {data?.server && (
        <p className="mt-4 pt-4 border-t border-[#F3F4F6] text-[11px] font-bold text-gray-400">
          Server: Node {data.server.node} · up {data.server.uptime_h} h · memory {data.server.memory_free_mb}/{data.server.memory_total_mb} MB free
          {data.server.disk ? ` · disk ${data.server.disk.free_gb}/${data.server.disk.total_gb} GB free` : ''}
        </p>
      )}
    </div>
  );
};

export default GoLiveChecklist;
