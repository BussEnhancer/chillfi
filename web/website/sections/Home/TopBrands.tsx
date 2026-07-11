import React from 'react';
import { Link } from 'react-router-dom';
import Container from '../../components/common/Container';

export interface ApiBrand {
  id: string;
  name: string;
  logo_url?: string;
}

interface TopBrandsProps {
  brands?: ApiBrand[];
}

const STATIC_BRANDS = ['Samsung', 'Apple', 'OnePlus', 'Sony', 'boAt', 'Realme', 'Mi', 'Dell'];

const TopBrands: React.FC<TopBrandsProps> = ({ brands }) => {
  return (
    <section className="py-16">
      <Container>
        <div className="flex items-center justify-between mb-10">
          <h2 className="text-2xl font-bold text-gray-900">Top Brands</h2>
          <Link to="/products" className="text-[#FF6B2C] font-bold text-sm hover:underline">View All Brands ›</Link>
        </div>

        <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-8 gap-8 items-center">
          {brands && brands.length > 0
            ? brands.map(brand => (
                <Link
                  key={brand.id}
                  to={`/products?brand=${encodeURIComponent(brand.name)}`}
                  className="h-16 flex items-center justify-center p-4 bg-gray-50 rounded-xl hover:bg-white hover:shadow-xl hover:-translate-y-1 transition-all border border-transparent hover:border-[#FF6B2C]/20 cursor-pointer group"
                >
                  {brand.logo_url ? (
                    <img src={brand.logo_url} alt={brand.name} className="max-h-8 object-contain filter grayscale group-hover:grayscale-0 transition-all" />
                  ) : (
                    <span className="text-sm font-black text-gray-400 group-hover:text-[#FF6B2C] tracking-tight text-center transition-colors">{brand.name}</span>
                  )}
                </Link>
              ))
            : STATIC_BRANDS.map((name, i) => (
                <div key={i} className="h-16 flex items-center justify-center p-4 bg-gray-50 rounded-xl hover:bg-white hover:shadow-xl hover:-translate-y-1 transition-all border border-transparent hover:border-[#FF6B2C]/20 cursor-pointer group">
                  <span className="text-sm font-black text-gray-400 group-hover:text-[#FF6B2C] tracking-tight text-center transition-colors">{name}</span>
                </div>
              ))
          }
        </div>
      </Container>
    </section>
  );
};

export default TopBrands;
