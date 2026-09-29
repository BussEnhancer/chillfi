import React from 'react';
import { Link } from 'react-router-dom';
import Container from '../common/Container';

const Footer: React.FC = () => {
  return (
    <footer className="bg-[#121212] pt-20 pb-10 text-gray-400 font-medium">
      <Container>
        <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-5 gap-12 mb-20">
          {/* Brand Col */}
          <div className="col-span-2 lg:col-span-2 pr-10">
            <Link to="/" className="flex items-center gap-2 mb-6 text-white w-fit">
              <div className="bg-[#FF6B2C] p-2 rounded-xl">
                <img src="/logo-icon-white.png" alt="" className="w-6 h-6" />
              </div>
              <span className="text-2xl font-bold tracking-tight">ChillFi</span>
            </Link>
            <p className="leading-relaxed mb-8">
              Shop smart, Chill more. Discover the best products at the best prices across multiple categories. Your one-stop destination for everything premium.
            </p>
            <div className="flex items-center gap-3">
               {/* Google Play badge - app is live */}
               <a
                 href="https://play.google.com/store/apps/details?id=com.ecom.chillfi"
                 target="_blank"
                 rel="noopener noreferrer"
                 className="flex items-center gap-2 bg-white/5 border border-white/10 rounded-xl px-4 py-2.5 hover:bg-white/10 hover:border-white/20 transition-colors"
               >
                 <svg className="w-5 h-5" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                   <path d="M3.18 1.26C2.77 1.69 2.5 2.37 2.5 3.25v17.5c0 .88.27 1.56.68 1.99l.11.1 9.8-9.8v-.23L3.29 1.15l-.11.11z" fill="#EA4335"/>
                   <path d="M16.34 15.81l-3.25-3.25v-.23l3.26-3.26.07.04 3.86 2.19c1.1.63 1.1 1.65 0 2.28l-3.86 2.2-.08.03z" fill="#FBBC04"/>
                   <path d="M16.42 15.77L13.09 12.44 3.18 22.35c.36.38.96.43 1.63.05l11.61-6.63" fill="#34A853"/>
                   <path d="M16.42 8.22L4.81 1.6C4.14 1.22 3.54 1.27 3.18 1.65l9.91 9.91 3.33-3.34z" fill="#4285F4"/>
                 </svg>
                 <div>
                   <div className="text-[10px] text-white/60 leading-none">GET IT ON</div>
                   <div className="text-xs font-bold text-white leading-tight">Google Play</div>
                 </div>
               </a>
            </div>
          </div>

          {/* Links Col 1 */}
          <div>
            <h4 className="text-white font-bold mb-6 uppercase tracking-widest text-sm">Customer Service</h4>
            <ul className="space-y-4 text-sm">
              <li><Link to="/contact" className="hover:text-white transition-colors">Contact Us</Link></li>
              <li><Link to="/account/orders" className="hover:text-white transition-colors">Track Order</Link></li>
              <li><Link to="/return-policy" className="hover:text-white transition-colors">Return &amp; Refund</Link></li>
              <li><Link to="/shipping-policy" className="hover:text-white transition-colors">Shipping Policy</Link></li>
              <li><Link to="/support" className="hover:text-white transition-colors">FAQs</Link></li>
            </ul>
          </div>

          {/* Links Col 2 */}
          <div>
            <h4 className="text-white font-bold mb-6 uppercase tracking-widest text-sm">Company</h4>
            <ul className="space-y-4 text-sm">
              <li><Link to="/about" className="hover:text-white transition-colors">About Us</Link></li>
            </ul>
          </div>

          {/* Links Col 3 */}
          <div>
            <h4 className="text-white font-bold mb-6 uppercase tracking-widest text-sm">Policies</h4>
            <ul className="space-y-4 text-sm">
              <li><Link to="/privacy-policy" className="hover:text-white transition-colors">Privacy Policy</Link></li>
              <li><Link to="/terms" className="hover:text-white transition-colors">Terms &amp; Conditions</Link></li>
              <li><Link to="/refund-policy" className="hover:text-white transition-colors">Refund Policy</Link></li>
            </ul>
          </div>
        </div>

        <div className="border-t border-white/5 pt-10 flex flex-col md:flex-row items-center justify-between gap-6">
           <p className="text-xs">
              © {new Date().getFullYear()} ChillFi. All rights reserved.
           </p>
           <div className="flex items-center gap-3">
              {/* Visa */}
              <span className="bg-white/5 border border-white/10 px-3 py-1.5 rounded-lg text-[11px] font-black text-white/60 tracking-widest hover:text-white hover:border-white/30 transition-all cursor-pointer italic">VISA</span>
              {/* Mastercard */}
              <span className="bg-white/5 border border-white/10 px-3 py-1.5 rounded-lg flex items-center gap-1 cursor-pointer hover:border-white/30 transition-all group">
                <span className="w-4 h-4 rounded-full bg-red-500/70 group-hover:bg-red-500 -mr-2 transition-all"></span>
                <span className="w-4 h-4 rounded-full bg-yellow-400/70 group-hover:bg-yellow-400 transition-all"></span>
              </span>
              {/* RuPay */}
              <span className="bg-white/5 border border-white/10 px-3 py-1.5 rounded-lg text-[11px] font-black text-white/60 tracking-wider hover:text-white hover:border-white/30 transition-all cursor-pointer">RuPay</span>
              {/* UPI */}
              <span className="bg-white/5 border border-white/10 px-3 py-1.5 rounded-lg text-[11px] font-black tracking-wider cursor-pointer hover:border-white/30 transition-all">
                <span className="text-[#FF6B2C]">U</span><span className="text-white/60 hover:text-white">PI</span>
              </span>
           </div>
        </div>
      </Container>
    </footer>
  );
};

export default Footer;
