import React, { useEffect, useState } from 'react';
import { Truck, RefreshCw, Loader2, CheckCircle2, AlertTriangle, Copy, PlugZap } from 'lucide-react';
import { apiGet, apiPost } from '../../utils/api';

interface DelhiveryStatus {
  provider: string;
  environment: 'staging' | 'production';
  configured: boolean;
  missing: string[];
  pickup_location: string | null;
  auto_ship: boolean;
  webhook: { url: string; secret_set: boolean; last_received: string | null };
  pickup?: { last: { date?: string; time?: string; pickup_id?: number; existing?: boolean; ok?: boolean; count?: number; at?: string } | null; awaiting_pickup: number };
  last_event: { source: string; created_at: string } | null;
  last_scheduled_sync: { at: string | null; result: unknown };
  shipping_status_counts: Record<string, number>;
  failed_shipments: { id: string; order_number: string; shipment_error: string; shipment_attempts: number }[];
}

const fmt = (d?: string | null) => (d ? new Date(d).toLocaleString('en-IN') : '—');

// Integration health for Delhivery: environment, config completeness, webhook, sync, failures.
const DelhiveryStatusPanel: React.FC<{ refreshKey?: number }> = ({ refreshKey }) => {
  const [status, setStatus] = useState<DelhiveryStatus | null>(null);
  const [loading, setLoading] = useState(true);
  const [busy, setBusy] = useState<'' | 'test' | 'sync' | 'pickup'>('');
  const [message, setMessage] = useState<{ ok: boolean; text: string } | null>(null);

  const load = async () => {
    setLoading(true);
    try {
      const res = await apiGet<{ data: DelhiveryStatus }>('/admin/shipping/delhivery/status');
      setStatus(res.data);
    } catch (e: any) { setMessage({ ok: false, text: e.message }); } finally { setLoading(false); }
  };
  useEffect(() => { load(); }, [refreshKey]);

  const test = async () => {
    setBusy('test'); setMessage(null);
    try {
      const res = await apiPost<{ message: string }>('/admin/shipping/delhivery/test', {});
      setMessage({ ok: true, text: res.message });
    } catch (e: any) { setMessage({ ok: false, text: e.message }); } finally { setBusy(''); }
  };
  const sync = async () => {
    setBusy('sync'); setMessage(null);
    try {
      await apiPost('/admin/shipping/delhivery/sync', {});
      setMessage({ ok: true, text: 'Sync complete — active shipments refreshed and failed shipments retried.' });
      load();
    } catch (e: any) { setMessage({ ok: false, text: e.message }); } finally { setBusy(''); }
  };

  const pickup = async () => {
    setBusy('pickup'); setMessage(null);
    try {
      const res = await apiPost<{ message: string }>('/admin/shipping/delhivery/pickup', {});
      setMessage({ ok: true, text: res.message });
      load();
    } catch (e: any) { setMessage({ ok: false, text: e.message }); } finally { setBusy(''); }
  };

  if (loading && !status) {
    return <div className="flex items-center gap-2 text-gray-400 py-4"><Loader2 size={16} className="animate-spin" /><span className="text-sm font-bold">Loading Delhivery status...</span></div>;
  }
  if (!status) return null;
  const isProd = status.environment === 'production';
  const counts = status.shipping_status_counts;

  return (
    <div className="bg-white rounded-2xl border border-[#ECECEC] shadow-sm p-6 space-y-4">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2">
          <Truck size={16} className="text-[#FF6B2C]" />
          <h3 className="text-sm font-black text-[#111827]">Delhivery Integration</h3>
          <span className={`text-[10px] font-black px-2 py-0.5 rounded-full uppercase ${isProd ? 'bg-green-50 text-green-600' : 'bg-amber-50 text-amber-600'}`}>
            {isProd ? 'Production (LIVE)' : 'Staging (TEST)'}
          </span>
          <span className={`text-[10px] font-black px-2 py-0.5 rounded-full ${status.configured ? 'bg-green-50 text-green-600' : 'bg-red-50 text-red-500'}`}>
            {status.configured ? 'CONFIGURED' : 'INCOMPLETE'}
          </span>
        </div>
        <div className="flex gap-2">
          <button onClick={test} disabled={!!busy} className="flex items-center gap-1.5 px-3 py-2 rounded-xl bg-[#F8F7FC] text-xs font-black text-gray-600 hover:bg-[#FFF3ED] hover:text-[#FF6B2C] disabled:opacity-50">
            {busy === 'test' ? <Loader2 size={12} className="animate-spin" /> : <PlugZap size={12} />} Test connection
          </button>
          <button onClick={sync} disabled={!!busy || !status.configured} className="flex items-center gap-1.5 px-3 py-2 rounded-xl bg-[#F8F7FC] text-xs font-black text-gray-600 hover:bg-[#FFF3ED] hover:text-[#FF6B2C] disabled:opacity-50">
            <RefreshCw size={12} className={busy === 'sync' ? 'animate-spin' : ''} /> Sync now
          </button>
          <button onClick={pickup} disabled={!!busy || !status.configured} title="Ask Delhivery to collect parcels waiting at the pickup location"
            className="flex items-center gap-1.5 px-3 py-2 rounded-xl bg-[#F8F7FC] text-xs font-black text-gray-600 hover:bg-[#FFF3ED] hover:text-[#FF6B2C] disabled:opacity-50">
            {busy === 'pickup' ? <Loader2 size={12} className="animate-spin" /> : <Truck size={12} />} Request pickup
          </button>
        </div>
      </div>

      {message && (
        <p className={`text-xs font-bold rounded-xl px-3 py-2 flex gap-1.5 ${message.ok ? 'bg-green-50 text-green-700' : 'bg-red-50 text-red-600'}`}>
          {message.ok ? <CheckCircle2 size={14} /> : <AlertTriangle size={14} />}{message.text}
        </p>
      )}
      {!!status.missing.length && (
        <p className="text-xs font-bold bg-red-50 text-red-600 rounded-xl px-3 py-2">Missing for {status.environment}: {status.missing.join(', ')}</p>
      )}

      <div className="grid grid-cols-2 md:grid-cols-4 gap-3 text-xs">
        <div className="bg-[#F8F7FC] rounded-xl p-3"><p className="text-[10px] font-black text-gray-400 uppercase">Pickup location</p><p className="font-black text-[#111827] mt-0.5">{status.pickup_location || '—'}</p></div>
        <div className="bg-[#F8F7FC] rounded-xl p-3"><p className="text-[10px] font-black text-gray-400 uppercase">Auto-ship</p><p className="font-black text-[#111827] mt-0.5">{status.auto_ship ? 'On' : 'Off'}</p></div>
        <div className="bg-[#F8F7FC] rounded-xl p-3"><p className="text-[10px] font-black text-gray-400 uppercase">Last webhook</p><p className="font-black text-[#111827] mt-0.5">{fmt(status.webhook.last_received)}</p></div>
        <div className="bg-[#F8F7FC] rounded-xl p-3"><p className="text-[10px] font-black text-gray-400 uppercase">Last sync</p><p className="font-black text-[#111827] mt-0.5">{fmt(status.last_scheduled_sync?.at)}</p></div>
      </div>

      {status.pickup && (
        <p className="text-[11px] font-bold text-gray-500 bg-[#F8F7FC] rounded-xl px-3 py-2">
          Parcels awaiting pickup: <b className="text-[#111827]">{status.pickup.awaiting_pickup}</b>
          {status.pickup.last?.date
            ? <> · Last pickup booked for <b className="text-[#111827]">{status.pickup.last.date} {status.pickup.last.time?.slice(0, 5)}</b>{status.pickup.last.pickup_id ? ` (ID ${status.pickup.last.pickup_id})` : ''}{status.pickup.last.existing ? ' — already open' : ''}</>
            : ' · No pickup booked yet'}
        </p>
      )}

      <div className="bg-[#F8F7FC] rounded-xl p-3 text-xs">
        <p className="text-[10px] font-black text-gray-400 uppercase mb-1">Webhook URL to register with Delhivery (header: Authorization: Bearer &lt;Webhook Secret&gt;)</p>
        <div className="flex items-center gap-2">
          <code className="font-mono font-bold text-[#111827] break-all">{status.webhook.url}</code>
          <button onClick={() => navigator.clipboard?.writeText(status.webhook.url)} className="text-gray-400 hover:text-[#FF6B2C]" title="Copy"><Copy size={12} /></button>
          {!status.webhook.secret_set && <span className="text-[10px] font-black text-red-500">secret not set</span>}
        </div>
      </div>

      <div className="flex flex-wrap gap-2 text-[11px] font-bold">
        {Object.entries(counts).map(([k, n]) => (
          <span key={k} className={`px-2 py-1 rounded-lg ${k === 'failed' ? 'bg-red-50 text-red-500' : 'bg-[#F8F7FC] text-gray-500'}`}>{k}: {n}</span>
        ))}
      </div>

      {!!status.failed_shipments.length && (
        <div className="border border-red-100 rounded-xl p-3">
          <p className="text-[10px] font-black text-red-500 uppercase mb-2">Failed shipment creations (retried automatically, or use Orders → Retry)</p>
          {status.failed_shipments.map((f) => (
            <p key={f.id} className="text-[11px] font-bold text-gray-600"><span className="text-[#FF6B2C]">{f.order_number}</span> · {f.shipment_attempts} attempt(s) · {f.shipment_error}</p>
          ))}
        </div>
      )}
      {isProd || (
        <p className="text-[11px] font-bold text-gray-400">To go live: set the PRODUCTION token + pickup location below, register the webhook in Delhivery, then switch Delhivery Environment to <b>production</b>. No code change needed.</p>
      )}
    </div>
  );
};

export default DelhiveryStatusPanel;
