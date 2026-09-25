import { useEffect } from 'react';
import { useAppConfig } from './useAppConfig';

// Admin → Settings → SEO: default <title>, meta description / keywords and social-share (Open Graph) tags.
const setMeta = (attr: 'name' | 'property', key: string, content: string | null | undefined) => {
  if (!content) return;
  let el = document.head.querySelector<HTMLMetaElement>(`meta[${attr}="${key}"]`);
  if (!el) { el = document.createElement('meta'); el.setAttribute(attr, key); document.head.appendChild(el); }
  el.setAttribute('content', content);
};

export const useSeoDefaults = () => {
  const cfg = useAppConfig();
  useEffect(() => {
    const seo = cfg?.seo;
    if (!seo) return;
    if (seo.title) document.title = seo.title;
    setMeta('name', 'description', seo.description);
    setMeta('name', 'keywords', seo.keywords);
    setMeta('property', 'og:title', seo.title);
    setMeta('property', 'og:description', seo.description);
    setMeta('property', 'og:image', seo.og_image);
  }, [cfg]);
};
