import React, { useState } from 'react';
import Container from '../../components/common/Container';
import { Send, Facebook, Twitter, Instagram, Youtube, CheckCircle } from 'lucide-react';

const Newsletter: React.FC = () => {
  const [email, setEmail] = useState('');
  const [submitted, setSubmitted] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      setError('Please enter a valid email address.');
      return;
    }
    setError('');
    setSubmitted(true);
    setEmail('');
    setTimeout(() => setSubmitted(false), 4000);
  };

  return (
    <section className="bg-[#121212] py-12 border-b border-white/10">
      <Container className="flex flex-col lg:flex-row items-center justify-between gap-10">
        <div className="text-center lg:text-left">
          <h3 className="text-2xl font-black text-white mb-2">Subscribe to Our Newsletter</h3>
          <p className="text-gray-400 font-medium">Get updates on the latest offers and new arrivals.</p>
        </div>

        <div className="flex-1 max-w-[500px] w-full">
          <form onSubmit={handleSubmit}>
            <div className="flex bg-white/5 p-1.5 rounded-xl border border-white/10 focus-within:border-[#FF6B2C] transition-all">
              <input
                type="email"
                value={email}
                onChange={e => setEmail(e.target.value)}
                placeholder="Enter your email address"
                className="flex-1 bg-transparent px-6 text-white outline-none placeholder-gray-500"
              />
              <button
                type="submit"
                className="bg-[#FF6B2C] text-white px-8 py-3 rounded-lg font-bold hover:bg-[#E05520] transition-all flex items-center gap-2 shrink-0"
              >
                Subscribe
                <Send size={16} />
              </button>
            </div>
            {error && <p className="text-red-400 text-xs font-bold mt-2 pl-2">{error}</p>}
          </form>
          {submitted && (
            <div className="flex items-center gap-2 mt-3 text-green-400 text-sm font-bold pl-2">
              <CheckCircle size={16} />
              Thanks! You're subscribed. We'll keep you posted.
            </div>
          )}
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
              <button
                key={label}
                title={`${label} — Coming soon`}
                aria-label={label}
                onClick={e => e.preventDefault()}
                className="w-10 h-10 bg-white/5 rounded-full flex items-center justify-center text-white opacity-60 cursor-not-allowed border border-white/10"
              >
                <Icon size={18} />
              </button>
            ))}
          </div>
        </div>
      </Container>
    </section>
  );
};

export default Newsletter;
