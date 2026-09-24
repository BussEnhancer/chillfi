import React from 'react';
import Container from '../../components/common/Container';
import { Star, Quote, User } from 'lucide-react';

export interface ApiTestimonial {
  id: string;
  customer_name: string;
  avatar_url?: string;
  rating: number;
  quote: string;
}

interface TestimonialsProps {
  testimonials?: ApiTestimonial[];
}

const Testimonials: React.FC<TestimonialsProps> = ({ testimonials }) => {
  if (!testimonials || testimonials.length === 0) return null;

  return (
    <section className="py-20 bg-gray-50/50 relative overflow-hidden">
      {/* Decorative quotes */}
      <Quote size={200} className="absolute -top-10 -left-10 text-gray-200/50 -rotate-12" />
      <Quote size={200} className="absolute -bottom-10 -right-10 text-gray-200/50 rotate-180" />

      <Container className="relative z-10">
        <div className="flex items-center justify-between mb-12">
          <h2 className="text-3xl font-black text-gray-900">What Our Customers Say</h2>
        </div>

        <div className="grid md:grid-cols-3 gap-8">
          {testimonials.map(t => (
            <div key={t.id} className="bg-white p-8 rounded-3xl shadow-sm border border-gray-100 hover:shadow-xl transition-all group">
              <div className="flex items-center gap-4 mb-6">
                 {t.avatar_url ? (
                   <img src={t.avatar_url} alt={t.customer_name} className="w-14 h-14 rounded-full object-cover ring-2 ring-gray-50 group-hover:ring-[#FF6B2C]/30 transition-all" />
                 ) : (
                   <div className="w-14 h-14 rounded-full bg-gray-100 flex items-center justify-center ring-2 ring-gray-50">
                     <User size={22} className="text-gray-300" />
                   </div>
                 )}
                 <div>
                    <h4 className="font-bold text-gray-900">{t.customer_name}</h4>
                    
                 </div>
              </div>
              <div className="flex gap-1 mb-4 text-yellow-400">
                 {[...Array(5)].map((_, i) => (
                   <Star key={i} size={14} fill={i < t.rating ? "currentColor" : "none"} />
                 ))}
              </div>
              <p className="text-gray-600 font-medium leading-relaxed italic">
                 "{t.quote}"
              </p>
            </div>
          ))}
        </div>
      </Container>
    </section>
  );
};

export default Testimonials;
