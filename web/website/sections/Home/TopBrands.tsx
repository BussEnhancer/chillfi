import React from 'react';
import Container from '../../components/common/Container';

const brands = [
  { name: 'Puma', logo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/88/Puma_logo.svg/2560px-Puma_logo.svg.png' },
  { name: 'boAt', logo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Boat_Logo.svg/1200px-Boat_Logo.svg.png' },
  { name: 'Fastrack', logo: 'https://upload.wikimedia.org/wikipedia/en/thumb/5/52/Fastrack_Logo.svg/1200px-Fastrack_Logo.svg.png' },
  { name: 'Realme', logo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/13/Realme-logo.svg/2560px-Realme-logo.svg.png' },
  { name: 'Samsung', logo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/Samsung_Logo.svg/2560px-Samsung_Logo.svg.png' },
  { name: 'Nike', logo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a6/Logo_NIKE.svg/1200px-Logo_NIKE.svg.png' },
  { name: 'Adidas', logo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/20/Adidas_Logo.svg/2560px-Adidas_Logo.svg.png' },
  { name: 'Mivi', logo: 'https://m.media-amazon.com/images/S/abs-image-upload-na/3/AmazonStores/A21TJ7DG9HDCZ8/b86d9a98701918341646279148560383.w2560.h631._CR0%2C0%2C2560%2C631_SX500_SY123_.png' },
];

const TopBrands: React.FC = () => {
  return (
    <section className="py-16">
      <Container>
        <div className="flex items-center justify-between mb-10">
          <h2 className="text-2xl font-bold text-gray-900">Top Brands</h2>
          <button className="text-[#6C2BFF] font-bold text-sm hover:underline">View All Brands ›</button>
        </div>

        <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-8 gap-8 items-center">
          {brands.map((brand, i) => (
            <div key={i} className="h-16 flex items-center justify-center p-4 bg-gray-50 rounded-xl hover:bg-white hover:shadow-xl hover:-translate-y-1 transition-all grayscale hover:grayscale-0 border border-transparent hover:border-gray-100 cursor-pointer">
              <img src={brand.logo} alt={brand.name} className="max-h-full max-w-full object-contain" />
            </div>
          ))}
        </div>
      </Container>
    </section>
  );
};

export default TopBrands;
