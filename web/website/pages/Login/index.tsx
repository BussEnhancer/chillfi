import React from 'react';
import Header from '../../components/navigation/Header';
import TopBar from '../../components/navigation/TopBar';
import Footer from '../../components/navigation/Footer';
import Container from '../../components/common/Container';
import AuthHeroSection from '../../components/auth/AuthHeroSection';
import AuthTabs from '../../components/auth/AuthTabs';
import AuthMethodTabs from '../../components/auth/AuthMethodTabs';
import SocialLoginButtons from '../../components/auth/SocialLoginButtons';
import CheckoutTrustStrip from '../../sections/Checkout/CheckoutTrustStrip';
import { ChevronRight, ChevronDown } from 'lucide-react';

const LoginPage: React.FC = () => {
  return (
    <div className="min-h-screen bg-white font-['Poppins']">
      <TopBar />
      <Header />

      <Container className="py-12 md:py-20">
        <div className="flex flex-col lg:flex-row gap-12 items-stretch">
          {/* Left: Hero Section */}
          <AuthHeroSection />

          {/* Right: Auth Card */}
          <div className="flex-1 max-w-[550px] mx-auto w-full">
            <div className="bg-white rounded-[32px] border border-[#ECECEC] p-8 md:p-12 shadow-sm h-full">
              <AuthTabs />

              <AuthMethodTabs />

              <div className="mb-8">
                <h3 className="text-sm font-black text-[#111827] mb-6 uppercase tracking-wider">Login with Mobile Number</h3>
                <div className="flex gap-4">
                  <div className="w-24 bg-gray-50 border border-[#ECECEC] rounded-xl px-4 py-3.5 flex items-center justify-between cursor-pointer group focus-within:border-[#6C2BFF] transition-all">
                    <span className="text-sm font-black">+91</span>
                    <ChevronDown size={14} className="text-gray-400 group-hover:text-[#6C2BFF]" />
                  </div>
                  <div className="flex-1 bg-white border border-[#ECECEC] rounded-xl px-5 py-3.5 focus-within:border-[#6C2BFF] transition-all flex items-center shadow-sm">
                    <input
                      type="tel"
                      placeholder="Enter your mobile number"
                      className="w-full bg-transparent outline-none text-sm font-bold"
                    />
                  </div>
                </div>
              </div>

              <button className="w-full bg-gradient-to-r from-[#6C2BFF] to-[#5A24D6] text-white py-4 rounded-xl font-black flex items-center justify-center gap-3 shadow-xl shadow-[#6C2BFF]/20 hover:scale-[1.02] active:scale-[0.98] transition-all mb-8">
                Continue
                <ChevronRight size={18} />
              </button>

              {/* OR Divider */}
              <div className="relative flex items-center justify-center mb-8">
                <div className="absolute inset-0 flex items-center">
                  <div className="w-full border-t border-[#ECECEC]"></div>
                </div>
                <span className="relative bg-white px-4 text-[10px] font-black text-gray-400 uppercase tracking-widest">OR</span>
              </div>

              <div className="text-center mb-6">
                <span className="text-[11px] font-bold text-gray-400 uppercase tracking-widest">Continue with</span>
              </div>

              <SocialLoginButtons />

              <p className="text-[11px] font-bold text-gray-400 text-center leading-relaxed">
                By continuing, you agree to our <br />
                <a href="#" className="text-[#6C2BFF] hover:underline font-black uppercase">Terms & Conditions</a> and <a href="#" className="text-[#6C2BFF] hover:underline font-black uppercase">Privacy Policy</a>
              </p>
            </div>
          </div>
        </div>

        {/* Bottom Trust Strip */}
        <CheckoutTrustStrip />
      </Container>

      <Footer />
    </div>
  );
};

export default LoginPage;
