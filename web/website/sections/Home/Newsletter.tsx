import React from 'react';
import Container from '../../components/common/Container';
import { Send, Facebook, Twitter, Instagram, Youtube } from 'lucide-react';

// No newsletter backend exists yet, so the form is shown disabled rather than faking a subscription.
const Newsletter: React.FC = () => {
  return (
    <section className="bg-[#121212] py-12 border-b border-white/10">
      <Container className="flex flex-col lg:flex-row items-center justify-between gap-10">
        <div className="text-center lg:text-left">
          <h3 className="text-2xl font-black text-white mb-2">Subscribe to Our Newsletter</h3>
          <p className="text-gray-400 font-medium">Newsletter coming soon. Meanwhile, check our Offers page for current deals.</p>
        </div>

        <div className="flex-1 max-w-[500px] w-full">
          <div title="Coming soon" className="flex bg-white/5 p-1.5 rounded-xl border border-white/10 opacity-60 cursor-not-allowed">
            <input
              type="email"
              disabled
              aria-label="Email address (newsletter coming soon)"
              placeholder="Enter your email address"
              className="flex-1 min-w-0 bg-transparent px-6 text-white outline-none placeholder-gray-500 cursor-not-allowed"
            />
            <button
              type="button"
              disabled
              className="bg-[#FF6B2C] text-white px-8 py-3 rounded-lg font-bold flex items-center gap-2 shrink-0 cursor-not-allowed active:scale-[0.98] transition-all"
            >
              Coming Soon
              <Send size={16} />
            </button>
          </div>
        </div>

        <div className="flex items-center gap-6">
          <span className="text-white font-bold text-sm uppercase tracking-widest hidden xl:block">Follow Us</span>
          <div className="flex gap-4">
            {([
              { Icon: Facebook, label: 'Facebook' },
              { Icon: Twitter, label: 'Twitter' },
              { Icon: Instagram, label: 'Instagram' },
              { Icon: Youtube, label: 'YouTube' },
            ] as const).map(({ Icon, label }) => (
              <span
                key={label}
                title={`${label} — Coming soon`}
                aria-label={`${label} (coming soon)`}
                className="w-10 h-10 bg-white/5 rounded-full flex items-center justify-center text-white opacity-60 cursor-not-allowed border border-white/10"
              >
                <Icon size={18} />
              </span>
            ))}
          </div>
        </div>
      </Container>
    </section>
  );
};

export default Newsletter;
