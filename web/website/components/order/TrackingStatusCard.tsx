import React from 'react';
import { Link } from 'react-router-dom';
import { CheckCircle2, Truck, Clock, XCircle, Star } from 'lucide-react';

interface TrackingStatusCardProps {
  status: string;
  updatedAt: string;
  detail?: string | null; // courier-level stage, e.g. "Out for delivery"
  reviewProductId?: string | null; // when set, "Rate & Review" opens that product page
}

const STATUS_CONFIG: Record<string, { icon: React.ReactNode; bg: string; iconBg: string; title: string; message: string }> = {
  Delivered: { icon: <CheckCircle2 size={32} />, bg: 'bg-green-50 border-green-100', iconBg: 'bg-green-500 shadow-green-200', title: 'Delivered', message: 'Your order has been delivered on' },
  Shipped: { icon: <Truck size={32} />, bg: 'bg-blue-50 border-blue-100', iconBg: 'bg-blue-500 shadow-blue-200', title: 'Shipped', message: 'Your order is on its way, last updated' },
  Processing: { icon: <Clock size={32} />, bg: 'bg-amber-50 border-amber-100', iconBg: 'bg-amber-500 shadow-amber-200', title: 'Processing', message: 'Your order is being prepared, last updated' },
  Cancelled: { icon: <XCircle size={32} />, bg: 'bg-red-50 border-red-100', iconBg: 'bg-red-500 shadow-red-200', title: 'Cancelled', message: 'Your order was cancelled on' },
};

const TrackingStatusCard: React.FC<TrackingStatusCardProps> = ({ status, updatedAt, detail, reviewProductId }) => {
  const cfg = STATUS_CONFIG[status] || STATUS_CONFIG.Processing;
  const d = new Date(updatedAt);
  const dateStr = `${d.toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' })} at ${d.toLocaleTimeString('en-IN', { hour: '2-digit', minute: '2-digit', hour12: true })}`;

  return (
    <div className={`${cfg.bg} rounded-[24px] border p-6 flex flex-col md:flex-row items-center justify-between gap-6 mb-8`}>
      <div className="flex items-center gap-6">
        <div className={`w-14 h-14 ${cfg.iconBg} rounded-2xl flex items-center justify-center text-white shadow-lg`}>
          {cfg.icon}
        </div>
        <div>
          <h3 className="text-xl font-black text-[#111827] mb-1">{cfg.title}{detail && detail !== cfg.title && <span className="text-sm font-bold text-gray-500"> · {detail}</span>}</h3>
          <p className="text-sm font-bold text-gray-500 leading-tight">
            {cfg.message} <br />
            <span className="text-[#111827]">{dateStr}</span>
          </p>
        </div>
      </div>

      {status === 'Delivered' && (
        <Link
          to={reviewProductId ? `/product/${reviewProductId}` : '/account/reviews'}
          className="bg-white border-2 border-[#FF6B2C] text-[#FF6B2C] px-8 py-3 rounded-xl font-black text-sm flex items-center gap-2 hover:bg-[#FF6B2C] hover:text-white transition-all shadow-sm active:scale-[0.98]"
        >
          <Star size={18} />
          Rate & Review
        </Link>
      )}
    </div>
  );
};

export default TrackingStatusCard;
