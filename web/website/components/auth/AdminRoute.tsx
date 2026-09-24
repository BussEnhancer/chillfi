import React from 'react';
import { Navigate, useLocation } from 'react-router-dom';
import { useStore } from '../../context/StoreContext';
import { useAdminRole } from '../../utils/useAdminRole';

const STAFF_PATHS = ['/admin/orders', '/admin/reviews', '/admin/messages'];

const AdminRoute: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const { isLoggedIn } = useStore();
  const { role, loading } = useAdminRole();
  const location = useLocation();

  if (!isLoggedIn) {
    return <Navigate to="/login" state={{ from: location.pathname }} replace />;
  }

  if (loading) return null;

  const allowed = role === 'admin' || role === 'support_staff' || role === 'superadmin';
  if (!allowed) {
    return <Navigate to="/" replace />;
  }

  // Support staff may only use the pages their API access covers (same list as the sidebar's staffAllowed).
  if (role === 'support_staff' && !STAFF_PATHS.some(p => location.pathname === p || location.pathname.startsWith(p + '/'))) {
    return <Navigate to="/admin/orders" replace />;
  }

  return <>{children}</>;
};

export default AdminRoute;
