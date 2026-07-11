import React from 'react';
import { Link } from 'react-router-dom';
import Container from '../../components/common/Container';
import { Gift } from 'lucide-react';

export interface ApiPromoBanner {
  id: string;
  title: string;
  subtitle?: string;
  image_url?: string;
  link?: string;
  background_color?: string;
}

interface PromoBannersProps {
  promos?: ApiPromoBanner[];
}

const PromoBanners: React.FC<PromoBannersProps> = ({ promos }) => {
  if (!promos || promos.length === 0) return null;

  return (
    <section className="py-16 bg-gray-50/30">
      <Container className={`grid gap-8 ${promos.length > 1 ? 'md:grid-cols-2' : ''}`}>
        {promos.map(p => (
          <div
            key={p.id}
            className="rounded-[32px] p-10 flex items-center justify-between text-white overflow-hidden relative group"
            style={{ background: p.background_color || '#FF6B2C' }}
          >
            <div className="relative z-10 max-w-[65%]">
              <h3 className="text-3xl font-black mb-4">{p.title}</h3>
              {p.subtitle && <p className="text-sm font-bold opacity-80 mb-8">{p.subtitle}</p>}
              {p.link && (
                <Link to={p.link} className="inline-block bg-white px-8 py-3 rounded-xl font-bold hover:scale-105 transition-all" style={{ color: p.background_color || '#FF6B2C' }}>
                  Shop Now
                </Link>
              )}
            </div>
            <div className="relative z-10 w-[150px] h-[150px] flex items-center justify-center shrink-0">
              {p.image_url ? (
                <img src={p.image_url} alt={p.title} className="w-full h-full object-contain" />
              ) : (
                <div className="w-full h-full bg-white/10 rounded-full flex items-center justify-center">
                  <Gift size={80} className="text-white" />
                </div>
              )}
            </div>
            <div className="absolute -bottom-10 -right-10 w-40 h-40 bg-white/5 rounded-full blur-2xl group-hover:scale-150 transition-transform duration-1000"></div>
          </div>
        ))}
      </Container>
    </section>
  );
};

export default PromoBanners;
