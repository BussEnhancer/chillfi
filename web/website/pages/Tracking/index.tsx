import React, { useEffect, useState } from 'react';
import { createPortal } from 'react-dom';
import { useParams, Link } from 'react-router-dom';
import Header from '../../components/navigation/Header';
import TopBar from '../../components/navigation/TopBar';
import CategoryNav from '../../components/navigation/CategoryNav';
import Footer from '../../components/navigation/Footer';
import Container from '../../components/common/Container';
import Breadcrumb from '../../components/common/Breadcrumb';
import AccountSidebar from '../../components/profile/AccountSidebar';
import CheckoutTrustStrip from '../../sections/Checkout/CheckoutTrustStrip';
import TrackingStatusCard from '../../components/order/TrackingStatusCard';
import OrderProgressTracker from '../../components/order/OrderProgressTracker';
import DeliveryInfoSection from '../../sections/Tracking/DeliveryInfoSection';
import DeliveryTimelineSection from '../../sections/Tracking/DeliveryTimelineSection';
import TrackingOrderSummary from '../../sections/Tracking/TrackingOrderSummary';
import { apiGet, apiPost, downloadFile } from '../../utils/api';

import { Headphones, Loader2, X } from 'lucide-react';
import { showErrorDialog } from '../../components/feedback/ErrorDialog';
import { friendlyError } from '../../utils/api';

interface ApiOrderItem {
  product_id?: string | null;
  product_name: string;
  product_image: string;
  quantity: number;
  price: number;
}

interface ApiRefundRequest {
  id: string;
  type: 'Refund' | 'Return' | 'Exchange';
  reason: string;
  status: 'Requested' | 'Approved' | 'Rejected' | 'Refunded';
  refund_amount?: number;
  admin_notes?: string;
  created_at: string;
}

interface ApiOrderDetail {
  id: string;
  order_number: string;
  status: string;
  payment_method: string;
  payment_status: string;
  subtotal: number;
  discount: number;
  delivery_fee: number;
  tax_amount: number;
  invoice_available?: boolean;
  invoice_number?: string | null;
  total: number;
  tracking_id: string | null;
  created_at: string;
  updated_at: string;
  addr_name: string | null;
  addr_phone: string | null;
  line1: string | null;
  line2: string | null;
  city: string | null;
  state: string | null;
  pincode: string | null;
  items: ApiOrderItem[];
  refund_request: ApiRefundRequest | null;
  shipping_status?: string | null;
  shipment_provider?: string | null;
  can_cancel?: boolean;
  cancel_deadline_at?: string | null;
  can_return?: boolean;
  return_deadline_at?: string | null;
}

export interface ApiTracking {
  waybill: string;
  provider: string;
  env?: string | null;
  status: string | null;
  shipping_status?: string | null;
  shipping_status_label?: string | null;
  location?: string | null;
  expected_delivery?: string | null;
  last_update?: string | null;
  stale?: boolean;
  scans: { status: string | null; location: string | null; instructions: string | null; time: string | null }[];
}

const TrackingPage: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const [order, setOrder] = useState<ApiOrderDetail | null>(null);
  const [tracking, setTracking] = useState<ApiTracking | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [showCancelModal, setShowCancelModal] = useState(false);
  const [cancelReason, setCancelReason] = useState('');
  const [cancelling, setCancelling] = useState(false);
  const [cancelError, setCancelError] = useState('');

  const [showRefundModal, setShowRefundModal] = useState(false);
  const [refundType, setRefundType] = useState<'Refund' | 'Return' | 'Exchange'>('Refund');
  const [refundReason, setRefundReason] = useState('');
  const [submittingRefund, setSubmittingRefund] = useState(false);
  const [refundError, setRefundError] = useState('');

  const loadOrder = () => {
    if (!id) return;
    setLoading(true);
    apiGet<{ success: boolean; data: { order: ApiOrderDetail } }>(`/orders/${id}`)
      .then(res => {
        setOrder(res.data.order);
        // Courier timeline (stored Delhivery events, refreshed server-side when stale)
        if (res.data.order.tracking_id) {
          apiGet<{ success: boolean; data: ApiTracking | null }>(`/orders/${id}/tracking`)
            .then(t => setTracking(t.data))
            .catch(() => setTracking(null));
        }
      })
      .catch(e => setError(e.message || 'Failed to load order'))
      .finally(() => setLoading(false));
  };

  useEffect(() => { loadOrder(); }, [id]);

  const handleCancelOrder = async () => {
    if (!id) return;
    setCancelling(true);
    setCancelError('');
    try {
      await apiPost(`/orders/${id}/cancel`, { reason: cancelReason || undefined });
      setShowCancelModal(false);
      setCancelReason('');
      loadOrder();
    } catch (e: any) {
      setCancelError(friendlyError(e, 'Failed to cancel order'));
      showErrorDialog({ title: "Couldn't cancel order", error: e, fallback: 'We couldn\'t cancel your order. Please try again.' });
    } finally {
      setCancelling(false);
    }
  };

  const handleRequestRefund = async () => {
    if (!id || !refundReason.trim()) return;
    setSubmittingRefund(true);
    setRefundError('');
    try {
      await apiPost(`/orders/${id}/refund-request`, { type: refundType, reason: refundReason.trim() });
      setShowRefundModal(false);
      setRefundReason('');
      loadOrder();
    } catch (e: any) {
      setRefundError(friendlyError(e, 'Failed to submit request'));
      showErrorDialog({ title: "Couldn't submit request", error: e, fallback: 'Failed to submit request. Please try again.' });
    } finally {
      setSubmittingRefund(false);
    }
  };

  const breadcrumbItems = [
    { label: 'My Orders', href: '/account/orders' },
    { label: 'Track Order' }
  ];

  const placedAt = order ? new Date(order.created_at) : null;

  return (
    <div className="min-h-screen bg-white font-['Poppins']">
      <TopBar />
      <Header />
      <CategoryNav />
      <Breadcrumb items={breadcrumbItems} />

      <Container className="py-10 animate-page-in">
        {loading ? (
          <div className="flex items-center justify-center py-32">
            <Loader2 size={32} className="animate-spin text-[#FF6B2C]" />
          </div>
        ) : error || !order ? (
          <div className="py-32 text-center">
            <p className="text-red-500 font-bold">{error || 'Order not found'}</p>
          </div>
        ) : (
        <>
        <div className="flex flex-col lg:flex-row items-center justify-between gap-6 mb-10">
          <div>
            <h1 className="text-3xl font-black text-[#111827] mb-1">Track Your Order</h1>
            <p className="text-sm font-bold text-gray-400">Order ID: <span className="text-[#111827]">#{order.order_number}</span> | Placed on {placedAt!.toLocaleDateString('en-IN', { day: 'numeric', month: 'long', year: 'numeric' })} at {placedAt!.toLocaleTimeString('en-IN', { hour: '2-digit', minute: '2-digit', hour12: true })}</p>
          </div>
          <div className="flex flex-wrap items-center gap-3">
            {order.invoice_available && (
              <button
                onClick={() => downloadFile(`/orders/${order.id}/invoice`, `Invoice-${order.order_number}.pdf`)
                  .catch((e) => showErrorDialog({ title: "Couldn't download the invoice", error: e }))}
                className="flex items-center gap-2 border-2 border-[#ECECEC] text-[#111827] px-6 py-2.5 rounded-xl font-black text-sm hover:border-[#FF6B2C] hover:text-[#FF6B2C] transition-all"
              >
                Download Invoice
              </button>
            )}
            {/* Cancellation eligibility (shipment-pickup gate + the store's cancellation window) is decided server-side */}
            {order.can_cancel && (
              <button onClick={() => setShowCancelModal(true)} className="flex items-center gap-2 border-2 border-red-500 text-red-500 px-6 py-2.5 rounded-xl font-black text-sm hover:bg-red-500 hover:text-white transition-all">
                Cancel Order
              </button>
            )}
            {order.refund_request && ['Requested', 'Approved'].includes(order.refund_request.status) ? (
              <span className="flex items-center gap-2 border-2 border-amber-200 bg-amber-50 text-amber-600 px-6 py-2.5 rounded-xl font-black text-sm">
                {order.refund_request.type} {order.refund_request.status}
              </span>
            ) : order.refund_request?.status === 'Refunded' ? (
              <span className="flex items-center gap-2 border-2 border-green-200 bg-green-50 text-green-600 px-6 py-2.5 rounded-xl font-black text-sm">
                Refunded
              </span>
            ) : order.can_return ? (
              <button onClick={() => setShowRefundModal(true)} className="flex items-center gap-2 border-2 border-[#FF6B2C] text-[#FF6B2C] px-6 py-2.5 rounded-xl font-black text-sm hover:bg-[#FF6B2C] hover:text-white transition-all">
                Request Refund / Return
              </button>
            ) : order.status === 'Delivered' && (
              <span className="flex items-center gap-2 border-2 border-[#ECECEC] text-gray-400 px-6 py-2.5 rounded-xl font-black text-sm">
                Return window closed
              </span>
            )}
            <Link to="/support" className="flex items-center gap-2 border-2 border-[#FF6B2C] text-[#FF6B2C] px-6 py-2.5 rounded-xl font-black text-sm hover:bg-[#FF6B2C] hover:text-white transition-all active:scale-[0.98]">
               <Headphones size={18} />
               Contact Support
            </Link>
          </div>
        </div>

        <div className="flex flex-col lg:flex-row gap-10">
          {/* Left: Sidebar */}
          <AccountSidebar activeId="track" />

          {/* Center: Content */}
          <div className="flex-1 min-w-0">
             <TrackingStatusCard status={order.status} updatedAt={tracking?.last_update || order.updated_at} detail={tracking?.shipping_status_label || null}
               reviewProductId={(() => { const ids = Array.from(new Set(order.items.map(i => i.product_id).filter(Boolean))); return ids.length === 1 ? ids[0] : null; })()} />

             <OrderProgressTracker status={order.status} createdAt={order.created_at} updatedAt={order.updated_at} />

             <div className="grid grid-cols-1 xl:grid-cols-2 gap-8 mb-8">
                <DeliveryInfoSection
                  addrName={order.addr_name} addrPhone={order.addr_phone}
                  line1={order.line1} line2={order.line2} city={order.city}
                  state={order.state} pincode={order.pincode} trackingId={order.tracking_id}
                  courier={tracking?.provider || order.shipment_provider || null} env={tracking?.env || null}
                  expectedDelivery={tracking?.expected_delivery || null}
                />
                <DeliveryTimelineSection status={order.status} createdAt={order.created_at} updatedAt={order.updated_at} scans={tracking?.scans} />
             </div>

             {/* Order Items List */}
             <div className="bg-white rounded-[24px] border border-[#ECECEC] p-8 shadow-sm">
                <h3 className="text-sm font-black text-[#111827] uppercase tracking-wider mb-8">Order Items ({order.items.length})</h3>
                <div className="space-y-4">
                  {order.items.map((item, i) => (
                    <div key={i} className="flex items-center gap-6 p-4 rounded-2xl bg-[#FFF8F5] border border-[#FF6B2C]/10">
                       <div className="w-20 h-20 bg-white rounded-xl overflow-hidden border border-[#ECECEC] flex items-center justify-center p-2 shrink-0 shadow-sm">
                          <img src={item.product_image} alt={item.product_name} className="w-full h-full object-contain" />
                       </div>
                       <div className="flex-1 flex flex-col md:flex-row md:items-center justify-between gap-4">
                          <div>
                             <h4 className="text-sm font-black text-[#111827] mb-1">{item.product_name}</h4>
                             <p className="text-[10px] font-bold text-gray-400 uppercase tracking-widest">Qty: {item.quantity}</p>
                          </div>
                          <div className="text-right">
                             <span className="text-lg font-black text-[#111827]">₹{Number(item.price).toLocaleString()}</span>
                          </div>
                       </div>
                    </div>
                  ))}
                </div>
             </div>
          </div>

          {/* Right: Sidebar */}
          <div className="lg:w-[320px] shrink-0">
             <TrackingOrderSummary
               items={order.items} subtotal={Number(order.subtotal)} deliveryFee={Number(order.delivery_fee)}
               discount={Number(order.discount)} taxAmount={Number(order.tax_amount)} total={Number(order.total)}
               addrName={order.addr_name} addrPhone={order.addr_phone}
               line1={order.line1} line2={order.line2} city={order.city} state={order.state} pincode={order.pincode}
             />
          </div>
        </div>

        <CheckoutTrustStrip />

        {showCancelModal && createPortal(
          <div className="fixed inset-0 bg-black/40 backdrop-blur-sm z-50 flex items-center justify-center p-4">
            <div className="bg-white rounded-2xl shadow-2xl w-full max-w-sm p-6">
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-lg font-black text-[#111827]">Cancel Order?</h3>
                <button onClick={() => setShowCancelModal(false)} disabled={cancelling} className="w-8 h-8 rounded-xl bg-[#F8F7FC] flex items-center justify-center hover:bg-red-50 hover:text-red-500 transition-colors"><X size={16} /></button>
              </div>
              <p className="text-sm font-bold text-gray-400 mb-4">Are you sure you want to cancel order #{order.order_number}? This cannot be undone.</p>
              <textarea
                value={cancelReason}
                onChange={e => setCancelReason(e.target.value)}
                placeholder="Reason for cancellation (optional)"
                rows={3}
                className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C] resize-none mb-4"
              />
              {cancelError && <p className="text-xs font-bold text-red-500 mb-4">{cancelError}</p>}
              <div className="flex gap-3">
                <button onClick={() => setShowCancelModal(false)} disabled={cancelling} className="flex-1 border-2 border-[#ECECEC] text-gray-600 py-2.5 rounded-xl font-black text-sm disabled:opacity-50">Keep Order</button>
                <button onClick={handleCancelOrder} disabled={cancelling} className="flex-1 bg-red-500 text-white py-2.5 rounded-xl font-black text-sm hover:bg-red-600 disabled:opacity-60 flex items-center justify-center gap-2">
                  {cancelling ? <><Loader2 size={14} className="animate-spin" />Cancelling...</> : 'Yes, Cancel'}
                </button>
              </div>
            </div>
          </div>,
          document.body
        )}

        {showRefundModal && createPortal(
          <div className="fixed inset-0 bg-black/40 backdrop-blur-sm z-50 flex items-center justify-center p-4">
            <div className="bg-white rounded-2xl shadow-2xl w-full max-w-sm p-6">
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-lg font-black text-[#111827]">Request Refund / Return</h3>
                <button onClick={() => setShowRefundModal(false)} disabled={submittingRefund} className="w-8 h-8 rounded-xl bg-[#F8F7FC] flex items-center justify-center hover:bg-red-50 hover:text-red-500 transition-colors"><X size={16} /></button>
              </div>
              <div className="flex gap-2 mb-4">
                {(['Refund', 'Return', 'Exchange'] as const).map(t => (
                  <button key={t} onClick={() => setRefundType(t)} className={`flex-1 py-2 rounded-xl text-xs font-black border-2 transition-all ${refundType === t ? 'border-[#FF6B2C] bg-[#FFF3ED] text-[#FF6B2C]' : 'border-[#ECECEC] text-gray-500'}`}>
                    {t}
                  </button>
                ))}
              </div>
              <textarea
                value={refundReason}
                onChange={e => setRefundReason(e.target.value)}
                placeholder={`Tell us why you'd like a ${refundType.toLowerCase()} for order #${order.order_number}...`}
                rows={4}
                className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold outline-none focus:border-[#FF6B2C] resize-none mb-4"
              />
              {refundError && <p className="text-xs font-bold text-red-500 mb-4">{refundError}</p>}
              <div className="flex gap-3">
                <button onClick={() => setShowRefundModal(false)} disabled={submittingRefund} className="flex-1 border-2 border-[#ECECEC] text-gray-600 py-2.5 rounded-xl font-black text-sm disabled:opacity-50">Cancel</button>
                <button onClick={handleRequestRefund} disabled={submittingRefund || !refundReason.trim()} className="flex-1 bg-[#FF6B2C] text-white py-2.5 rounded-xl font-black text-sm hover:bg-[#E05520] disabled:opacity-60 flex items-center justify-center gap-2 active:scale-[0.98] transition-all">
                  {submittingRefund ? <><Loader2 size={14} className="animate-spin" />Submitting...</> : 'Submit Request'}
                </button>
              </div>
            </div>
          </div>,
          document.body
        )}
        </>
        )}
      </Container>

      <Footer />
    </div>
  );
};

export default TrackingPage;
