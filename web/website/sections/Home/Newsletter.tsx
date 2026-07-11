import React from 'react';
import Container from '../../components/common/Container';
import { Send, Facebook, Twitter, Instagram, Youtube } from 'lucide-react';

const Newsletter: React.FC = () => {
  return (
    <section className="bg-[#121212] py-12 border-b border-white/10">
      <Container className="flex flex-col lg:flex-row items-center justify-between gap-10">
        <div className="text-center lg:text-left">
           <h3 className="text-2xl font-black text-white mb-2">Subscribe to Our Newsletter</h3>
           <p className="text-gray-400 font-medium">Get updates on the latest offers and new arrivals.</p>
        </div>

        <div className="flex-1 max-w-[500px] w-full">
           <div className="flex bg-white/5 p-1.5 rounded-xl border border-white/10 focus-within:border-[#FF6B2C] transition-all">
              <input
                type="email"
                placeholder="Enter your email address"
                className="flex-1 bg-transparent px-6 text-white outline-none"
              />
              <button className="bg-[#FF6B2C] text-white px-8 py-3 rounded-lg font-bold hover:bg-[#E05520] transition-all flex items-center gap-2">
                 Subscribe
                 <Send size={16} />
              </button>
           </div>
        </div>

        <div className="flex items-center gap-6">
           <span className="text-white font-bold text-sm uppercase tracking-widest hidden xl:block">Follow Us</span>
           <div className="flex gap-4">
              {[Facebook, Twitter, Instagram, Youtube].map((Icon, i) => (
                <a key={i} href="#" className="w-10 h-10 bg-white/5 rounded-full flex items-center justify-center text-white hover:bg-[#FF6B2C] transition-all border border-white/10">
                   <Icon size={18} />
                </a>
              ))}
           </div>
        </div>
      </Container>
    </section>
  );
};

export default Newsletter;
