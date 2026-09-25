import { useEffect, useState } from 'react';
import { apiGet } from './api';

// Store-wide values edited in Admin → Settings (served by /app-config), cached for the session.
export interface AppConfig {
  free_shipping_enabled: boolean; free_shipping_threshold: number; standard_shipping_fee: number;
  max_delivery_days: number | null;
  seo?: { title: string | null; description: string | null; keywords: string | null; og_image: string | null };
}
let cached: AppConfig | null = null;
let inFlight: Promise<AppConfig | null> | null = null;
const load = () => {
  if (cached) return Promise.resolve(cached);
  if (!inFlight) inFlight = apiGet<{ data: AppConfig }>('/app-config').then((r) => (cached = r.data)).catch(() => null).finally(() => { inFlight = null; });
  return inFlight;
};

export const useAppConfig = (): AppConfig | null => {
  const [c, setC] = useState<AppConfig | null>(cached);
  useEffect(() => { let alive = true; load().then((v) => { if (alive && v) setC(v); }); return () => { alive = false; }; }, []);
  return c;
};

/** "On orders above ₹499" / "Flat ₹49 delivery" — always matches the admin's shipping settings. */
export const freeDeliveryText = (c: AppConfig | null, prefix = 'On orders above') => {
  if (!c) return `${prefix} ₹499`;
  return c.free_shipping_enabled ? `${prefix} ₹${Number(c.free_shipping_threshold).toLocaleString('en-IN')}` : `Flat ₹${c.standard_shipping_fee} delivery`;
};
