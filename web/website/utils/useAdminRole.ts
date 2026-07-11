import { useEffect, useState } from 'react';
import { apiGet } from './api';

interface AdminProfile {
  id: string;
  name: string;
  role: string;
}

let cached: AdminProfile | null = null;
let inflight: Promise<AdminProfile | null> | null = null;

const fetchAdminProfile = (): Promise<AdminProfile | null> => {
  if (cached) return Promise.resolve(cached);
  if (inflight) return inflight;
  inflight = apiGet<{ success: boolean; data: AdminProfile }>('/profile')
    .then(res => { cached = res.data; return cached; })
    .catch(() => null)
    .finally(() => { inflight = null; });
  return inflight;
};

export const useAdminRole = () => {
  const [profile, setProfile] = useState<AdminProfile | null>(cached);
  const [loading, setLoading] = useState(!cached);

  useEffect(() => {
    if (cached) return;
    fetchAdminProfile().then(p => { setProfile(p); setLoading(false); });
  }, []);

  return {
    role: profile?.role || 'admin',
    name: profile?.name || 'Admin',
    loading,
    isSupportStaff: profile?.role === 'support_staff',
  };
};
