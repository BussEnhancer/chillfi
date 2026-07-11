import React from 'react';
import { Link, useNavigate } from 'react-router-dom';
import Header from '../../components/navigation/Header';
import TopBar from '../../components/navigation/TopBar';
import Footer from '../../components/navigation/Footer';
import Container from '../../components/common/Container';
import { Home, ShoppingBag, ArrowLeft } from 'lucide-react';

const NotFoundPage: React.FC = () => {
  const navigate = useNavigate();

  return (
    <div className="min-h-screen bg-white font-['Poppins']">
      <TopBar />
      <Header />

      <Container className="py-20">
        <div className="max-w-xl mx-auto text-center">
          <div className="relative mb-8">
            <p className="text-[120px] font-black text-[#F8F7FC] leading-none select-none">404</p>
            <p className="absolute inset-0 flex items-center justify-center text-5xl font-black text-[#FF6B2C]">404</p>
          </div>

          <h1 className="text-2xl font-black text-[#111827] mb-3">Page Not Found</h1>
          <p className="text-base font-bold text-gray-400 mb-10">
            Looks like this page wandered off. Let's get you back to something good.
          </p>

          <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
            <button
              onClick={() => navigate(-1)}
              className="flex items-center gap-2 px-6 py-3 border-2 border-[#ECECEC] text-gray-600 rounded-xl font-black text-sm hover:border-[#FF6B2C] hover:text-[#FF6B2C] transition-colors"
            >
              <ArrowLeft size={16} /> Go Back
            </button>
            <Link
              to="/"
              className="flex items-center gap-2 px-6 py-3 bg-[#FF6B2C] text-white rounded-xl font-black text-sm shadow-lg shadow-[#FF6B2C]/20 hover:bg-[#E05520] transition-colors"
            >
              <Home size={16} /> Back to Home
            </Link>
            <Link
              to="/products"
              className="flex items-center gap-2 px-6 py-3 bg-[#F8F7FC] text-[#111827] rounded-xl font-black text-sm hover:bg-[#ECECEC] transition-colors"
            >
              <ShoppingBag size={16} /> Shop Products
            </Link>
          </div>
        </div>
      </Container>

      <Footer />
    </div>
  );
};

export default NotFoundPage;
