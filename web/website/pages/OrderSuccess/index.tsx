import React from 'react';
import { Link, useLocation, useSearchParams } from 'react-router-dom';
import Header from '../../components/navigation/Header';
import TopBar from '../../components/navigation/TopBar';
import Footer from '../../components/navigation/Footer';
import Container from '../../components/common/Container';
import { CheckCircle2, ShoppingBag, Truck, ChevronRight } from 'lucide-react';

const OrderSuccessPage: React.FC = () => {
  const location = useLocation();
  const [searchParams] = useSearchParams();
  const stateData = (location.state as { orderNumber?: string; total?: number; cod?: boolean }) || {};
  const orderNumber = stateData.orderNumber || searchParams.get('order_number') || undefined;
  const total = stateData.total ?? (searchParams.get('total') ? Number(searchParams.get('total')) : undefined);

  return (
    <div className="min-h-screen bg-white font-['Poppins']">
      <TopBar />
      <Header />

      <Container className="py-20">
        <div className="max-w-xl mx-auto text-center">
          <div className="w-24 h-24 rounded-full bg-green-50 flex items-center justify-center mx-auto mb-6 border-4 border-green-100">
            <CheckCircle2 size={48} className="text-green-500" />
          </div>

          <h1 className="text-3xl font-black text-[#111827] mb-3">Order Placed Successfully!</h1>
          <p className="text-base font-bold text-gray-400 mb-8">
            Thank you for shopping with ChillFi. Your order has been confirmed and will be processed shortly.
          </p>

          {orderNumber && (
            <div className="bg-[#F8F7FC] rounded-2xl p-6 border border-[#ECECEC] mb-8 text-left">
              <div className="flex items-center justify-between mb-4">
                <span className="text-[11px] font-black text-gray-400 uppercase tracking-wider">Order ID</span>
                <span className="text-sm font-black text-[#111827]">{orderNumber}</span>
              </div>
              {total !== undefined && (
                <div className="flex items-center justify-between">
                  <span className="text-[11px] font-black text-gray-400 uppercase tracking-wider">{stateData.cod ? 'Pay on Delivery' : 'Total Paid'}</span>
                  <span className="text-lg font-black text-[#FF6B2C]">₹{Number(total).toLocaleString()}</span>
                </div>
              )}
            </div>
          )}

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-10">
            <div className="bg-[#FFF8F5] rounded-2xl p-5 border border-[#FF6B2C]/10 text-left">
              <div className="flex items-center gap-3 mb-2">
                <div className="w-8 h-8 rounded-lg bg-[#FF6B2C]/10 flex items-center justify-center text-[#FF6B2C]">
                  <Truck size={16} />
                </div>
                <span className="text-[11px] font-black text-[#111827] uppercase tracking-wider">Estimated Delivery</span>
              </div>
              <p className="text-sm font-black text-[#111827]">3–5 Business Days</p>
              <p className="text-xs font-bold text-gray-400">You'll receive a tracking link via SMS</p>
            </div>
            <div className="bg-green-50 rounded-2xl p-5 border border-green-100 text-left">
              <div className="flex items-center gap-3 mb-2">
                <div className="w-8 h-8 rounded-lg bg-green-100 flex items-center justify-center text-green-600">
                  <ShoppingBag size={16} />
                </div>
                <span className="text-[11px] font-black text-[#111827] uppercase tracking-wider">Payment</span>
              </div>
              <p className="text-sm font-black text-[#111827]">Confirmed</p>
              <p className="text-xs font-bold text-gray-400">Order confirmation sent to your phone</p>
            </div>
          </div>

          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link
              to="/account/orders"
              className="flex items-center justify-center gap-2 bg-[#FF6B2C] text-white px-8 py-4 rounded-xl font-black shadow-xl shadow-[#FF6B2C]/20 hover:bg-[#E05520] transition-all"
            >
              Track My Order <ChevronRight size={18} />
            </Link>
            <Link
              to="/products"
              className="flex items-center justify-center gap-2 border-2 border-[#ECECEC] text-[#111827] px-8 py-4 rounded-xl font-black hover:border-[#FF6B2C] hover:text-[#FF6B2C] transition-all"
            >
              Continue Shopping
            </Link>
          </div>
        </div>
      </Container>

      <Footer />
    </div>
  );
};

export default OrderSuccessPage;
