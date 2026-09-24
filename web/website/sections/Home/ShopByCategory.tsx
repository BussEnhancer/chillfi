import React from 'react';
import { Link } from 'react-router-dom';
import Container from '../../components/common/Container';
import { useStore } from '../../context/StoreContext';

const categoryColors: Record<string, string> = {
  Smartphones: '#E3F2FD', Laptops: '#F3E5F5', Audio: '#E8F5E9',
  'Smart TVs': '#FCE4EC', Tablets: '#EFEBE9', Cameras: '#FFF3E0',
  Gaming: '#F1F8E9', Wearables: '#E0F2F1', Accessories: '#FFFDE7',
  'Computer Accessories': '#EDE7F6',
};

const ShopByCategory: React.FC = () => {
  const { categories } = useStore();
  const active = categories.filter(c => c.status);

  return (
    <section className="py-16">
      <Container>
        <div className="flex items-center justify-between mb-10">
          <h2 className="text-2xl font-bold text-gray-900">Shop by Categories</h2>
          <Link to="/categories" className="text-[#FF6B2C] font-bold text-sm hover:underline">View All Categories ›</Link>
        </div>

        <div className="flex justify-between items-center overflow-x-auto pb-4 gap-6 scrollbar-hide">
          {active.map((cat, i) => (
            <Link key={cat.id} to={`/products?category=${cat.id}`} className="flex flex-col items-center gap-4 min-w-[100px] cursor-pointer group">
              <div
                className="w-20 h-20 rounded-full flex items-center justify-center text-3xl transition-all duration-300 group-hover:scale-110 group-hover:shadow-lg border-2 border-transparent group-hover:border-[#FF6B2C]"
                style={{ backgroundColor: categoryColors[cat.name] || '#F3F4F6' }}
              >
                {cat.icon}
              </div>
              <span className="text-sm font-bold text-gray-700 group-hover:text-[#FF6B2C] transition-colors">{cat.name}</span>
            </Link>
          ))}
        </div>
      </Container>
    </section>
  );
};

export default ShopByCategory;
