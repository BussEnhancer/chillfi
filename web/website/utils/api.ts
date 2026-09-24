const BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:5000/api';

// ── Customer-safe error messages ────────────────────────────────────────────
export const ERR_OFFLINE = "You're offline or our server can't be reached. Please check your connection and try again.";
export const ERR_SERVER = 'Something went wrong on our side. Please try again in a moment.';
export const ERR_GENERIC = 'Something went wrong. Please try again.';
export const ERR_SESSION = 'Your session has expired. Please log in again.';

const TECHNICAL = ['exception', 'error:', 'stack', 'sql', 'syntax', 'unexpected token', 'json', 'failed to fetch', 'networkerror', 'load failed', 'undefined', 'typeerror', '<html', 'econn', 'status code'];
/** True when a message is plain, short and safe to show to a customer. */
export const isUserFacing = (m?: string | null) => {
  const t = (m || '').trim();
  if (!t || t.length > 180) return false;
  const l = t.toLowerCase();
  return !TECHNICAL.some((w) => l.includes(w));
};

export class ApiError extends Error {
  status: number;
  constructor(message: string, status: number) { super(message); this.status = status; this.name = 'ApiError'; }
}

/** Converts any thrown value into a message that is safe to show to customers. */
export const friendlyError = (e: unknown, fallback = ERR_GENERIC): string => {
  if (e instanceof ApiError) return e.message;
  const msg = e instanceof Error ? e.message : typeof e === 'string' ? e : '';
  return isUserFacing(msg) ? msg : fallback;
};

let accessToken: string | null = localStorage.getItem('access_token');
let refreshToken: string | null = localStorage.getItem('refresh_token');

export const saveTokens = (access: string, refresh: string) => {
  accessToken = access;
  refreshToken = refresh;
  localStorage.setItem('access_token', access);
  localStorage.setItem('refresh_token', refresh);
};

export const clearTokens = () => {
  accessToken = null;
  refreshToken = null;
  localStorage.removeItem('access_token');
  localStorage.removeItem('refresh_token');
};

export const getAccessToken = () => accessToken;

const refreshAccessToken = async (): Promise<boolean> => {
  if (!refreshToken) return false;
  try {
    const res = await fetch(`${BASE_URL}/auth/refresh-token`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ refreshToken }),
    });
    if (!res.ok) { clearTokens(); return false; }
    const data = await res.json();
    saveTokens(data.data.accessToken, data.data.refreshToken);
    return true;
  } catch {
    clearTokens();
    return false;
  }
};

type Method = 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH';

export const api = async <T = unknown>(
  path: string,
  method: Method = 'GET',
  body?: unknown,
  retried = false
): Promise<T> => {
  const headers: HeadersInit = { 'Content-Type': 'application/json' };
  if (accessToken) headers['Authorization'] = `Bearer ${accessToken}`;

  let res: Response;
  try {
    res = await fetch(`${BASE_URL}${path}`, {
      method,
      headers,
      body: body !== undefined ? JSON.stringify(body) : undefined,
    });
  } catch {
    throw new ApiError(ERR_OFFLINE, 0);
  }

  if (res.status === 401 && !retried) {
    const ok = await refreshAccessToken();
    if (ok) return api<T>(path, method, body, true);
    clearTokens();
    window.location.href = '/login';
    throw new ApiError(ERR_SESSION, 401);
  }

  let data: any = null;
  try { data = await res.json(); } catch { /* non-JSON body (proxy error page, empty 502, …) */ }
  if (!res.ok || data === null) {
    const status = res.ok ? 502 : res.status;
    const serverMsg = data?.message as string | undefined;
    throw new ApiError(status >= 500 ? ERR_SERVER : isUserFacing(serverMsg) ? serverMsg! : ERR_GENERIC, status);
  }
  return data;
};

export const apiGet = <T = unknown>(path: string) => api<T>(path, 'GET');
export const apiPost = <T = unknown>(path: string, body: unknown) => api<T>(path, 'POST', body);
export const apiPut = <T = unknown>(path: string, body: unknown) => api<T>(path, 'PUT', body);
export const apiDelete = <T = unknown>(path: string) => api<T>(path, 'DELETE');

export const uploadImage = async (file: File, folder = 'chillfi/products'): Promise<string> => {
  const formData = new FormData();
  formData.append('image', file);
  formData.append('folder', folder);

  const headers: HeadersInit = {};
  if (accessToken) headers['Authorization'] = `Bearer ${accessToken}`;

  let res: Response;
  try {
    res = await fetch(`${BASE_URL}/admin/upload`, { method: 'POST', headers, body: formData });
  } catch {
    throw new ApiError(ERR_OFFLINE, 0);
  }
  let data: any = null;
  try { data = await res.json(); } catch { /* non-JSON */ }
  if (!res.ok || !data?.data?.url) {
    const status = res.ok ? 502 : res.status;
    throw new ApiError(status >= 500 ? ERR_SERVER : isUserFacing(data?.message) ? data.message : 'Upload failed. Please try again.', status);
  }
  return data.data.url;
};
