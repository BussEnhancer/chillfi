import React, { useEffect, useRef, useState } from 'react';
import { ERR_OFFLINE, friendlyError } from '../../utils/api';

type DialogRequest = { title?: string; message?: string; error?: unknown; fallback?: string; onRetry?: () => void };
type Listener = (r: DialogRequest) => void;
let listener: Listener | null = null;

/**
 * Shows the single, universal error dialog. Pass either a friendly `message` or the raw `error`
 * (it is converted with friendlyError, so technical text never reaches the customer).
 */
export const showErrorDialog = (r: DialogRequest) => {
  if (listener) listener(r);
  else window.alert(r.message || friendlyError(r.error, r.fallback)); // dialog host not mounted yet
};

export const ErrorDialogHost: React.FC = () => {
  const [req, setReq] = useState<DialogRequest | null>(null);
  const okRef = useRef<HTMLButtonElement>(null);

  useEffect(() => {
    listener = (r) => setReq(r);
    return () => { listener = null; };
  }, []);

  useEffect(() => {
    if (!req) return;
    okRef.current?.focus();
    const onKey = (e: KeyboardEvent) => { if (e.key === 'Escape') setReq(null); };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [req]);

  if (!req) return null;
  const text = req.message && !req.error ? friendlyError(req.message, req.fallback) : friendlyError(req.error ?? req.message, req.fallback);
  const offline = text === ERR_OFFLINE;
  const title = offline ? 'No internet connection' : req.title || 'Something went wrong';
  const close = () => setReq(null);

  return (
    <div className="fixed inset-0 z-[1000] flex items-center justify-center bg-black/40 px-5" onClick={close}>
      <div
        role="alertdialog"
        aria-modal="true"
        aria-labelledby="cf-err-title"
        aria-describedby="cf-err-msg"
        className="w-full max-w-sm rounded-2xl bg-white p-6 text-center shadow-2xl"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="mx-auto mb-4 flex h-14 w-14 items-center justify-center rounded-full bg-[#FFEEE6]">
          {offline ? (
            <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#FF6B2C" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true"><path d="M1 1l22 22M16.72 11.06A10.94 10.94 0 0 1 19 12.55M5 12.55a10.94 10.94 0 0 1 5.17-2.39M10.71 5.05A16 16 0 0 1 22.58 9M1.42 9a15.91 15.91 0 0 1 4.7-2.88M8.53 16.11a6 6 0 0 1 6.95 0M12 20h.01" /></svg>
          ) : (
            <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#FF6B2C" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="10" /><path d="M12 8v4M12 16h.01" /></svg>
          )}
        </div>
        <h2 id="cf-err-title" className="text-lg font-bold text-gray-900">{title}</h2>
        <p id="cf-err-msg" className="mt-2 text-sm leading-relaxed text-gray-600">{text}</p>
        <div className="mt-6 flex gap-3">
          {req.onRetry && (
            <button type="button" onClick={close} className="flex-1 rounded-xl border border-gray-300 py-3 text-sm font-semibold text-gray-800 hover:bg-gray-50">
              Close
            </button>
          )}
          <button
            ref={okRef}
            type="button"
            onClick={() => { const retry = req.onRetry; close(); retry?.(); }}
            className="flex-1 rounded-xl bg-[#FF6B2C] py-3 text-sm font-semibold text-white hover:bg-[#E05520]"
          >
            {req.onRetry ? 'Try again' : 'OK'}
          </button>
        </div>
      </div>
    </div>
  );
};
