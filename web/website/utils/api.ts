const BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:5000/api';

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

  const res = await fetch(`${BASE_URL}${path}`, {
    method,
    headers,
    body: body !== undefined ? JSON.stringify(body) : undefined,
  });

  if (res.status === 401 && !retried) {
    const ok = await refreshAccessToken();
    if (ok) return api<T>(path, method, body, true);
    clearTokens();
    window.location.href = '/login';
    throw new Error('Session expired');
  }

  const data = await res.json();
  if (!res.ok) throw new Error(data.message || 'Request failed');
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

  const res = await fetch(`${BASE_URL}/admin/upload`, {
    method: 'POST',
    headers,
    body: formData,
  });
  const data = await res.json();
  if (!res.ok) throw new Error(data.message || 'Upload failed');
  return data.data.url;
};
