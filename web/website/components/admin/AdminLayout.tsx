import React from 'react';
import { useLocation } from 'react-router-dom';
import { ShieldAlert } from 'lucide-react';
import AdminSidebar from './AdminSidebar';
import AdminHeader from './AdminHeader';
import { useAdminRole } from '../../utils/useAdminRole';
import { useAdminIdleTimeout } from '../../utils/useAdminIdleTimeout';

interface AdminLayoutProps {
  children: React.ReactNode;
  title: string;
  subtitle?: string;
}

const STAFF_ALLOWED_PREFIXES = ['/admin/orders', '/admin/reviews', '/admin/messages'];

const AdminLayout: React.FC<AdminLayoutProps> = ({ children, title, subtitle }) => {
  const { pathname } = useLocation();
  const { isSupportStaff, loading } = useAdminRole();
  useAdminIdleTimeout();
  const isRestricted = !loading && isSupportStaff && !STAFF_ALLOWED_PREFIXES.some(p => pathname.startsWith(p));

  return (
    <div className="flex min-h-screen bg-[#F4F2FA] font-['Poppins']">
      <AdminSidebar />
      <div className="flex-1 flex flex-col min-w-0">
        <AdminHeader title={title} subtitle={subtitle} />
        <main className="flex-1 p-6 overflow-auto">
          {isRestricted ? (
            <div className="flex flex-col items-center justify-center py-32 bg-white rounded-2xl border border-[#ECECEC]">
              <ShieldAlert size={48} className="text-gray-300 mb-4" />
              <h3 className="text-xl font-black text-[#111827] mb-2">Access Restricted</h3>
              <p className="text-sm font-bold text-gray-400">Your support staff account doesn't have access to this section.</p>
            </div>
          ) : (
            children
          )}
        </main>
      </div>
    </div>
  );
};

export default AdminLayout;
