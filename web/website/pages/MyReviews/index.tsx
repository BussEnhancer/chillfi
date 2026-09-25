import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import Header from '../../components/navigation/Header';
import TopBar from '../../components/navigation/TopBar';
import CategoryNav from '../../components/navigation/CategoryNav';
import Footer from '../../components/navigation/Footer';
import Container from '../../components/common/Container';
import Breadcrumb from '../../components/common/Breadcrumb';
import AccountSidebar from '../../components/profile/AccountSidebar';
import { Loader2, Star } from 'lucide-react';
import { apiGet } from '../../utils/api';

interface ApiReview {
  id: string;
  rating: number;
  title?: string;
  body: string;
  created_at: string;
  product_id: string;
  product_name: string;
  product_image?: string;
}

const MyReviewsPage: React.FC = () => {
  const breadcrumbItems = [{ label: 'My Account', href: '/account' }, { label: 'Reviews & Ratings' }];

  const [reviews, setReviews] = useState<ApiReview[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    apiGet<{ success: boolean; data: ApiReview[] }>('/profile/reviews')
      .then(res => setReviews(res.data || []))
      .catch(() => {})
      .finally(() => setLoading(false));
  }, []);

  return (
    <div className="min-h-screen bg-white font-['Poppins']">
      <TopBar />
      <Header />
      <CategoryNav />
      <Breadcrumb items={breadcrumbItems} />

      <Container className="py-10 animate-page-in">
        <div className="flex flex-col lg:flex-row gap-10">
          <AccountSidebar activeId="reviews" />

          <div className="flex-1">
            <h1 className="text-3xl font-black text-[#111827] mb-8">Reviews & Ratings</h1>

            {loading ? (
              <div className="flex items-center gap-3 text-gray-400">
                <Loader2 size={20} className="animate-spin text-[#FF6B2C]" />
                <span className="text-sm font-bold">Loading reviews...</span>
              </div>
            ) : reviews.length === 0 ? (
              <div className="py-16 text-center text-gray-400">
                <Star size={40} className="mx-auto mb-4 text-gray-200" />
                <p className="text-sm font-bold">You haven't reviewed any products yet.</p>
              </div>
            ) : (
              <div className="space-y-4">
                {reviews.map(r => (
                  <div key={r.id} className="p-5 rounded-2xl border border-[#ECECEC] flex items-start gap-4">
                    <Link to={`/product/${r.product_id}`} className="shrink-0">
                      <img
                        src={r.product_image || 'https://via.placeholder.com/64'}
                        alt={r.product_name}
                        className="w-16 h-16 rounded-xl object-cover bg-gray-50"
                      />
                    </Link>
                    <div className="flex-1">
                      <Link to={`/product/${r.product_id}`} className="text-sm font-black text-[#111827] hover:text-[#FF6B2C]">
                        {r.product_name}
                      </Link>
                      <div className="flex items-center gap-1 my-1">
                        {Array.from({ length: 5 }).map((_, i) => (
                          <Star key={i} size={14} className={i < r.rating ? 'text-orange-400 fill-orange-400' : 'text-gray-200'} />
                        ))}
                      </div>
                      {r.title && <p className="text-sm font-black text-[#111827]">{r.title}</p>}
                      <p className="text-sm font-bold text-gray-500">{r.body}</p>
                      <p className="text-xs font-bold text-gray-400 mt-2">{new Date(r.created_at).toLocaleDateString()}</p>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </Container>

      <Footer />
    </div>
  );
};

export default MyReviewsPage;
