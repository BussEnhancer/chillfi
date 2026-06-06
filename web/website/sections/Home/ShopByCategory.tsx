import React from 'react';
import Container from '../../components/common/Container';

const categories = [
  { name: 'Fashion', icon: '👕', color: '#E3F2FD' },
  { name: 'Electronics', icon: '🎧', color: '#F3E5F5' },
  { name: 'Home & Living', icon: '🛋️', color: '#E8F5E9' },
  { name: 'Beauty', icon: '💄', color: '#FCE4EC' },
  { name: 'Men', icon: '🧔', color: '#EFEBE9' },
  { name: 'Women', icon: '👗', color: '#FFF3E0' },
  { name: 'Sports', icon: '⚽', color: '#F1F8E9' },
  { name: 'Toys', icon: '🧸', color: '#E0F2F1' },
  { name: 'Grocery', icon: '🍎', color: '#FFFDE7' },
];

const ShopByCategory: React.FC = () => {
  return (
    <section className="py-16">
      <Container>
        <div className="flex items-center justify-between mb-10">
          <h2 className="text-2xl font-bold text-gray-900">Shop by Categories</h2>
          <button className="text-[#6C2BFF] font-bold text-sm hover:underline">View All Categories ›</button>
        </div>

        <div className="flex justify-between items-center overflow-x-auto pb-4 gap-6 scrollbar-hide">
          {categories.map((cat, i) => (
            <div key={i} className="flex flex-col items-center gap-4 min-w-[100px] cursor-pointer group">
              <div
                className="w-20 h-20 rounded-full flex items-center justify-center text-3xl transition-all duration-300 group-hover:scale-110 group-hover:shadow-lg border-2 border-transparent group-hover:border-[#6C2BFF]"
                style={{ backgroundColor: cat.color }}
              >
                {cat.icon}
              </div>
              <span className="text-sm font-bold text-gray-700 group-hover:text-[#6C2BFF] transition-colors">{cat.name}</span>
            </div>
          ))}
        </div>
      </Container>
    </section>
  );
};

export default ShopByCategory;
