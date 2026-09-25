import React from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import Header from '../../components/navigation/Header';
import TopBar from '../../components/navigation/TopBar';
import Footer from '../../components/navigation/Footer';
import Container from '../../components/common/Container';
import { XCircle, RefreshCw, ShoppingBag, Headphones } from 'lucide-react';

const OrderFailedPage: React.FC = () => {
  const location = useLocation();
  const navigate = useNavigate();
  const { reason } = (location.state as { reason?: string }) || {};

  return (
    <div className="min-h-screen bg-white font-['Poppins']">
      <TopBar />
      <Header />

      <Container className="py-20 animate-page-in">
        <div className="max-w-xl mx-auto text-center">
          <div className="w-24 h-24 rounded-full bg-red-50 flex items-center justify-center mx-auto mb-6 border-4 border-red-100">
            <XCircle size={48} className="text-red-500" />
          </div>

          <h1 className="text-3xl font-black text-[#111827] mb-3">Order Failed</h1>
          <p className="text-base font-bold text-gray-400 mb-4">
            We couldn't place your order. Your cart is still saved.
          </p>
          {reason && (
            <div className="bg-red-50 text-red-600 text-sm font-bold px-5 py-3 rounded-xl border border-red-100 mb-8">
              {reason}
            </div>
          )}

          <div className="flex flex-col sm:flex-row gap-4 justify-center mb-10">
            <button
              onClick={() => navigate('/checkout')}
              className="flex items-center justify-center gap-2 bg-[#FF6B2C] text-white px-8 py-4 rounded-xl font-black shadow-xl shadow-[#FF6B2C]/20 hover:bg-[#E05520] transition-all"
            >
              <RefreshCw size={18} />
              Try Again
            </button>
            <Link
              to="/cart"
              className="flex items-center justify-center gap-2 border-2 border-[#ECECEC] text-[#111827] px-8 py-4 rounded-xl font-black hover:border-[#FF6B2C] hover:text-[#FF6B2C] transition-all"
            >
              <ShoppingBag size={18} />
              Back to Cart
            </Link>
          </div>

          <Link to="/support" className="flex items-center justify-center gap-2 text-sm font-black text-gray-400 hover:text-[#FF6B2C] transition-colors mx-auto">
            <Headphones size={16} />
            Need help? Contact support
          </Link>
        </div>
      </Container>

      <Footer />
    </div>
  );
};

export default OrderFailedPage;
