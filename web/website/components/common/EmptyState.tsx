import React from 'react';
import type { LucideIcon } from 'lucide-react';

interface EmptyStateProps {
  icon: LucideIcon;
  title: React.ReactNode;
  message?: React.ReactNode;
  /** Optional call to action (a Link or button). */
  children?: React.ReactNode;
  className?: string;
}

/** The one empty-state layout for customer pages (cart, orders, wishlist, search, listings, account lists). */
const EmptyState: React.FC<EmptyStateProps> = ({ icon: Icon, title, message, children, className = 'py-20' }) => (
  <div className={`text-center ${className}`}>
    <div className="w-16 h-16 rounded-full bg-[#FFF8F5] flex items-center justify-center mx-auto mb-4">
      <Icon size={28} className="text-[#FF6B2C]" />
    </div>
    <h3 className="text-xl font-black text-[#111827] mb-2">{title}</h3>
    {message && <p className="text-sm font-bold text-gray-400">{message}</p>}
    {children && <div className="mt-6">{children}</div>}
  </div>
);

export default EmptyState;
