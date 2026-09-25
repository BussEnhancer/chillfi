import { useEffect, useState } from 'react';
import { apiGet } from './api';

// Customer-support contact, edited in Admin → Settings → Store Info (served by /app-config).
export interface StoreContact { phone: string | null; phoneHref: string | null; whatsappHref: string | null; email: string | null }

const EMPTY: StoreContact = { phone: null, phoneHref: null, whatsappHref: null, email: null };
let cached: StoreContact | null = null;
let inFlight: Promise<StoreContact> | null = null;

const load = (): Promise<StoreContact> => {
  if (cached) return Promise.resolve(cached);
  if (!inFlight) {
    inFlight = apiGet<{ data: { contact?: { phone: string | null; phone_href: string | null; whatsapp_href: string | null; email: string | null } } }>('/app-config')
      .then((r) => {
        const c = r.data.contact;
        cached = c ? { phone: c.phone, phoneHref: c.phone_href, whatsappHref: c.whatsapp_href, email: c.email } : EMPTY;
        return cached;
      })
      .catch(() => EMPTY)
      .finally(() => { inFlight = null; });
  }
  return inFlight;
};

export const useStoreContact = (): StoreContact => {
  const [c, setC] = useState<StoreContact>(cached || EMPTY);
  useEffect(() => { let alive = true; load().then((v) => { if (alive) setC(v); }); return () => { alive = false; }; }, []);
  return c;
};
