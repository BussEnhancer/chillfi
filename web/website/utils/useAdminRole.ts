import { useEffect, useState } from 'react';
import { apiGet, getAccessToken } from './api';

interface AdminProfile {
  id: string;
  name: string;
  role: string;
}

// Cache is tied to the access token so a logout/login in the same tab never reuses another user's role.
let cached: AdminProfile | null = null;
let cachedFor: string | null = null;
let inflight: Promise<AdminProfile | null> | null = null;

const currentCache = () => (cachedFor && cachedFor === getAccessToken() ? cached : null);

const fetchAdminProfile = (): Promise<AdminProfile | null> => {
  if (currentCache()) return Promise.resolve(cached);
  const token = getAccessToken();
  if (inflight) return inflight;
  inflight = apiGet<{ success: boolean; data: AdminProfile }>('/profile')
    .then(res => { cached = res.data; cachedFor = token; return cached; })
    .catch(() => null)
    .finally(() => { inflight = null; });
  return inflight;
};

export const useAdminRole = () => {
  const [profile, setProfile] = useState<AdminProfile | null>(currentCache());
  const [loading, setLoading] = useState(!currentCache());

  useEffect(() => {
    if (currentCache()) return;
    fetchAdminProfile().then(p => { setProfile(p); setLoading(false); });
  }, []);

  return {
    // No default role: if the profile can't be loaded, the user is NOT treated as an admin.
    role: profile?.role || '',
    name: profile?.name || 'Admin',
    loading,
    isSupportStaff: profile?.role === 'support_staff',
  };
};
