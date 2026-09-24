import React from 'react';
import SupportTopicCard from '../../components/support/SupportTopicCard';
import {
  Truck, RotateCcw, CreditCard, Ship, User,
  Package, Tag, ShieldQuestion
} from 'lucide-react';

const topics = [
  { icon: <Truck size={28} />, title: 'Track Your Order', to: '/account/orders', desc: 'Real-time updates on your order status' },
  { icon: <RotateCcw size={28} />, title: 'Returns & Refunds', to: '/return-policy', desc: 'Easy returns and quick refunds', color: '#FF6B2C' },
  { icon: <CreditCard size={28} />, title: 'Orders & Payments', to: '/refund-policy', desc: 'Payment methods, failed payments and more', color: '#16A34A' },
  { icon: <Ship size={28} />, title: 'Shipping & Delivery', to: '/shipping-policy', desc: 'Delivery timelines, charges and locations', color: '#3B82F6' },
  { icon: <User size={28} />, title: 'Account & Profile', to: '/account/settings', desc: 'Manage your account, addresses and profile' },
  { icon: <Package size={28} />, title: 'Products & Services', to: '/products', desc: 'Product info, availability and warranties', color: '#F59E0B' },
  { icon: <Tag size={28} />, title: 'Offers & Promotions', to: '/offers', desc: 'How to use coupons, deals and offers', color: '#EC4899' },
  { icon: <ShieldQuestion size={28} />, title: 'Policies & Help', to: '/terms', desc: 'Terms, privacy and other important policies' },
];

const SupportTopicsGrid: React.FC = () => {
  return (
    <section className="py-12">
      <div className="flex items-center justify-between mb-8">
        <h2 className="text-2xl font-black text-[#111827]">Popular Topics</h2>
      </div>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
        {topics.map((topic, i) => (
          <SupportTopicCard key={i} {...topic} />
        ))}
      </div>
    </section>
  );
};

export default SupportTopicsGrid;
