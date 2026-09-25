import { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { apiGet } from './api';
import { useStore } from '../context/StoreContext';

// Admin → Settings → Security → Session Timeout: sign out of the admin panel after N minutes without
// activity. Activity is shared across tabs via localStorage, so an active tab keeps the others alive.
const KEY = 'admin_last_active';
let timeoutMin: number | null | undefined;

export const useAdminIdleTimeout = () => {
  const navigate = useNavigate();
  const { logoutUser } = useStore();
  useEffect(() => {
    let alive = true; let timer: ReturnType<typeof setInterval> | undefined; let lastWrite = 0;
    const touch = () => { const now = Date.now(); if (now - lastWrite > 15000) { lastWrite = now; localStorage.setItem(KEY, String(now)); } };
    const events = ['mousemove', 'keydown', 'click', 'scroll', 'touchstart'] as const;
    const start = (min: number) => {
      localStorage.setItem(KEY, String(Date.now()));
      events.forEach((e) => window.addEventListener(e, touch, { passive: true }));
      timer = setInterval(() => {
        const last = Number(localStorage.getItem(KEY) || Date.now());
        if (Date.now() - last > min * 60000) {
          clearInterval(timer);
          sessionStorage.setItem('signed_out_reason', `You were signed out after ${min} minutes without activity. Please sign in again.`);
          logoutUser();
          navigate('/login', { replace: true });
        }
      }, 30000);
    };
    const run = (min: number | null) => { if (alive && min) start(min); };
    if (timeoutMin !== undefined) run(timeoutMin);
    else apiGet<{ data: { admin_session_timeout_min?: number | null } }>('/app-config')
      .then((r) => { timeoutMin = r.data.admin_session_timeout_min ?? null; run(timeoutMin); })
      .catch(() => {});
    return () => { alive = false; if (timer) clearInterval(timer); events.forEach((e) => window.removeEventListener(e, touch)); };
  }, [navigate, logoutUser]);
};
