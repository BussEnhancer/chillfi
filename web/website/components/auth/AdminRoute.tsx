import React from 'react';
import { Navigate, useLocation } from 'react-router-dom';
import { useStore } from '../../context/StoreContext';
import { useAdminRole } from '../../utils/useAdminRole';

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

  return <>{children}</>;
};

export default AdminRoute;
