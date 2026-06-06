import React from 'react';
import Container from '../../components/common/Container';
import { Star, ChevronLeft, ChevronRight, Quote } from 'lucide-react';

const reviews = [
  {
    name: 'Rohit Sharma',
    image: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=200',
    rating: 5,
    text: 'Amazing experience! The product quality is excellent and delivery was super fast. Highly recommended for everyone looking for premium products.',
    tag: 'Verified Buyer',
  },
  {
    name: 'Priya Patel',
    image: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=200',
    rating: 5,
    text: 'Loved the packaging and the product! Definitely coming back for more. The customer service was very helpful with my queries.',
    tag: 'Verified Buyer',
  },
  {
    name: 'Amit Verma',
    image: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=200',
    rating: 4,
    text: 'Best prices, good quality and great customer support. The app is also very easy to use and provides real-time tracking.',
    tag: 'Verified Buyer',
  },
];

const Testimonials: React.FC = () => {
  return (
    <section className="py-20 bg-gray-50/50 relative overflow-hidden">
      {/* Decorative quotes */}
      <Quote size={200} className="absolute -top-10 -left-10 text-gray-200/50 -rotate-12" />
      <Quote size={200} className="absolute -bottom-10 -right-10 text-gray-200/50 rotate-180" />

      <Container className="relative z-10">
        <div className="flex items-center justify-between mb-12">
          <h2 className="text-3xl font-black text-gray-900">What Our Customers Say</h2>
          <div className="flex gap-4">
             <button className="w-10 h-10 rounded-full border border-gray-200 flex items-center justify-center hover:bg-[#6C2BFF] hover:text-white transition-all">
                <ChevronLeft size={20} />
             </button>
             <button className="w-10 h-10 rounded-full border border-gray-200 flex items-center justify-center hover:bg-[#6C2BFF] hover:text-white transition-all">
                <ChevronRight size={20} />
             </button>
          </div>
        </div>

        <div className="grid md:grid-cols-3 gap-8">
          {reviews.map((r, i) => (
            <div key={i} className="bg-white p-8 rounded-3xl shadow-sm border border-gray-100 hover:shadow-xl transition-all group">
              <div className="flex items-center gap-4 mb-6">
                 <img src={r.image} alt={r.name} className="w-14 h-14 rounded-full object-cover ring-2 ring-gray-50 group-hover:ring-[#6C2BFF]/30 transition-all" />
                 <div>
                    <h4 className="font-bold text-gray-900">{r.name}</h4>
                    <span className="text-[10px] text-green-500 font-bold uppercase tracking-widest">{r.tag}</span>
                 </div>
              </div>
              <div className="flex gap-1 mb-4 text-yellow-400">
                 {[...Array(5)].map((_, i) => (
                   <Star key={i} size={14} fill={i < r.rating ? "currentColor" : "none"} />
                 ))}
              </div>
              <p className="text-gray-600 font-medium leading-relaxed italic">
                 "{r.text}"
              </p>
            </div>
          ))}
        </div>
      </Container>
    </section>
  );
};

export default Testimonials;
