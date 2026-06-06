import React from 'react';
import Container from '../common/Container';
import { ShoppingCart, Smartphone, PlaySquare, Apple } from 'lucide-react';

const Footer: React.FC = () => {
  return (
    <footer className="bg-[#121212] pt-20 pb-10 text-gray-400 font-medium">
      <Container>
        <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-5 gap-12 mb-20">
          {/* Brand Col */}
          <div className="col-span-2 lg:col-span-2 pr-10">
            <div className="flex items-center gap-2 mb-6 text-white">
              <div className="bg-[#6C2BFF] p-2 rounded-xl">
                <ShoppingCart className="text-white" size={24} />
              </div>
              <span className="text-2xl font-bold tracking-tight">chillFi</span>
            </div>
            <p className="leading-relaxed mb-8">
              Shop smart, Chill more. Discover the best products at the best prices across multiple categories. Your one-stop destination for everything premium.
            </p>
            <div className="flex items-center gap-4">
               <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/7/78/Google_Play_Store_badge_EN.svg/1024px-Google_Play_Store_badge_EN.svg.png" alt="Play Store" className="h-10 cursor-pointer" />
               <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/3/3c/Download_on_the_App_Store_Badge_US-UK_RGB_blk_092917.svg/1024px-Download_on_the_App_Store_Badge_US-UK_RGB_blk_092917.svg.png" alt="App Store" className="h-10 cursor-pointer" />
            </div>
          </div>

          {/* Links Col 1 */}
          <div>
            <h4 className="text-white font-bold mb-6 uppercase tracking-widest text-sm">Customer Service</h4>
            <ul className="space-y-4 text-sm">
               {['Contact Us', 'Track Order', 'Return & Refund', 'Shipping Policy', 'FAQs'].map((item) => (
                 <li key={item}><a href="#" className="hover:text-white transition-colors">{item}</a></li>
               ))}
            </ul>
          </div>

          {/* Links Col 2 */}
          <div>
            <h4 className="text-white font-bold mb-6 uppercase tracking-widest text-sm">Company</h4>
            <ul className="space-y-4 text-sm">
               {['About Us', 'Careers', 'Blog', 'Affiliate Program', 'Sitemap'].map((item) => (
                 <li key={item}><a href="#" className="hover:text-white transition-colors">{item}</a></li>
               ))}
            </ul>
          </div>

          {/* Links Col 3 */}
          <div>
            <h4 className="text-white font-bold mb-6 uppercase tracking-widest text-sm">Policies</h4>
            <ul className="space-y-4 text-sm">
               {['Privacy Policy', 'Terms & Conditions', 'Refund Policy', 'Cancellation Policy', 'Disclaimer'].map((item) => (
                 <li key={item}><a href="#" className="hover:text-white transition-colors">{item}</a></li>
               ))}
            </ul>
          </div>
        </div>

        <div className="border-t border-white/5 pt-10 flex flex-col md:flex-row items-center justify-between gap-6">
           <p className="text-xs">
              © 2024 ChillFi. All rights reserved.
           </p>
           <div className="flex items-center gap-6">
              <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Visa_Inc._logo.svg/2560px-Visa_Inc._logo.svg.png" alt="Visa" className="h-4 opacity-50 grayscale hover:grayscale-0 transition-all cursor-pointer" />
              <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Mastercard-logo.svg/1280px-Mastercard-logo.svg.png" alt="Mastercard" className="h-6 opacity-50 grayscale hover:grayscale-0 transition-all cursor-pointer" />
              <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/PayPal.svg/1200px-PayPal.svg.png" alt="PayPal" className="h-4 opacity-50 grayscale hover:grayscale-0 transition-all cursor-pointer" />
              <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/e/e1/UPI-Logo-vector.svg/1200px-UPI-Logo-vector.svg.png" alt="UPI" className="h-4 opacity-50 grayscale hover:grayscale-0 transition-all cursor-pointer" />
           </div>
        </div>
      </Container>
    </footer>
  );
};

export default Footer;
