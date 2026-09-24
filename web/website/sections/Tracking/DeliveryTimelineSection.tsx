import React from 'react';

interface Scan { status: string | null; location: string | null; instructions: string | null; time: string | null }

interface DeliveryTimelineSectionProps {
  status: string;
  createdAt: string;
  updatedAt: string;
  scans?: Scan[]; // courier events (newest first) from GET /orders/:id/tracking
}

const fmtFull = (iso: string) => {
  const d = new Date(iso);
  return `${d.toLocaleDateString('en-IN', { day: 'numeric', month: 'short' })}, ${d.toLocaleTimeString('en-IN', { hour: '2-digit', minute: '2-digit', hour12: true })}`;
};

const DeliveryTimelineSection: React.FC<DeliveryTimelineSectionProps> = ({ status, createdAt, updatedAt, scans }) => {
  let events: { status: string; detail?: string; time: string; active: boolean }[];
  if (scans && scans.length) {
    events = scans.map((s, i) => ({
      status: s.status || 'Update',
      detail: [s.instructions && s.instructions !== s.status ? s.instructions : null, s.location].filter(Boolean).join(' · '),
      time: s.time ? fmtFull(s.time) : '',
      active: i === 0,
    }));
    events.push({ status: 'Order Placed', time: fmtFull(createdAt), active: false });
  } else {
    // No courier events yet — show only what we actually know.
    events = [{ status: 'Order Placed', time: fmtFull(createdAt), active: status === 'Processing' }];
    if (status !== 'Processing') events.unshift({ status, time: fmtFull(updatedAt), active: true });
  }

  return (
    <div className="bg-white rounded-[24px] border border-[#ECECEC] p-8 shadow-sm">
      <h3 className="text-sm font-black text-[#111827] uppercase tracking-wider mb-8">Delivery Timeline</h3>

      <div className="relative space-y-8">
        {/* Line */}
        <div className="absolute left-[7px] top-2 bottom-4 w-0.5 bg-green-500"></div>

        {events.map((event, i) => (
          <div key={i} className="relative flex items-start gap-6 pl-8">
            <div className={`absolute left-0 top-1 w-4 h-4 rounded-full border-4 border-white shadow-sm transition-all ${
              event.active ? 'bg-green-500 scale-125' : 'bg-green-500'
            }`}></div>

            <div className="flex-1">
               <h4 className={`text-sm font-black ${event.active ? 'text-green-600' : 'text-[#111827]'}`}>{event.status}</h4>
               {event.detail && <p className="text-xs font-bold text-gray-500 mt-0.5">{event.detail}</p>}
               <p className="text-[10px] font-bold text-gray-400 uppercase tracking-widest mt-0.5">{event.time}</p>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default DeliveryTimelineSection;
