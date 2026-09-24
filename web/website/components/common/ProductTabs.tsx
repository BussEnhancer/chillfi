import React, { useState, useEffect } from 'react';
import { Star, ThumbsUp, User, ChevronDown, ChevronUp, Loader2, Send } from 'lucide-react';
import { apiGet, apiPost, getAccessToken } from '../../utils/api';
import { friendlyError } from '../../utils/api';

interface Review {
  id: string;
  rating: number;
  title?: string;
  body?: string;
  user_name: string;
  avatar_url?: string;
  created_at: string;
  is_verified?: boolean;
}

interface ReviewStats {
  total: string;
  avg_rating: string;
  five_star: string;
  four_star: string;
  three_star: string;
  two_star: string;
  one_star: string;
}

interface Spec {
  label: string;
  value: string;
}

interface ProductTabsProps {
  reviewCount?: number;
  productId?: string;
  description?: string;
  specs?: Spec[];
  isLoggedIn?: boolean;
}

const StarRating: React.FC<{ value: number; onChange?: (v: number) => void; size?: number }> = ({ value, onChange, size = 20 }) => (
  <div className="flex gap-1">
    {[1, 2, 3, 4, 5].map(n => (
      <button
        key={n}
        type="button"
        onClick={() => onChange?.(n)}
        className={onChange ? 'cursor-pointer' : 'cursor-default'}
      >
        <Star
          size={size}
          className={n <= value ? 'fill-amber-400 text-amber-400' : 'text-gray-200'}
        />
      </button>
    ))}
  </div>
);

const RatingBar: React.FC<{ label: string; count: number; total: number }> = ({ label, count, total }) => {
  const pct = total > 0 ? Math.round((count / total) * 100) : 0;
  return (
    <div className="flex items-center gap-3 text-sm">
      <span className="w-8 text-right font-bold text-gray-500">{label}★</span>
      <div className="flex-1 h-2 bg-gray-100 rounded-full overflow-hidden">
        <div className="h-full bg-amber-400 rounded-full transition-all" style={{ width: `${pct}%` }} />
      </div>
      <span className="w-8 text-gray-400 font-bold">{count}</span>
    </div>
  );
};

const TABS = ['Description', 'Specifications', 'Reviews', 'FAQs', 'Delivery & Returns'];

const ProductTabs: React.FC<ProductTabsProps> = ({
  reviewCount = 0, productId, description, specs, isLoggedIn,
}) => {
  const [active, setActive] = useState(0);
  const [reviews, setReviews] = useState<Review[]>([]);
  const [stats, setStats] = useState<ReviewStats | null>(null);
  const [loadingReviews, setLoadingReviews] = useState(false);
  const [reviewsLoaded, setReviewsLoaded] = useState(false);

  // Write-review form
  const [myRating, setMyRating] = useState(0);
  const [myTitle, setMyTitle] = useState('');
  const [myBody, setMyBody] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [submitMsg, setSubmitMsg] = useState('');
  const [submitErr, setSubmitErr] = useState('');
  const [showForm, setShowForm] = useState(false);

  useEffect(() => {
    if (active !== 2 || !productId || reviewsLoaded) return;
    setLoadingReviews(true);
    apiGet<{ success: boolean; data: { reviews: Review[]; stats: ReviewStats } }>(`/products/${productId}/reviews`)
      .then(res => { setReviews(res.data.reviews); setStats(res.data.stats); })
      .catch(() => {})
      .finally(() => { setLoadingReviews(false); setReviewsLoaded(true); });
  }, [active, productId, reviewsLoaded]);

  const handleSubmitReview = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!myRating || !productId) return;
    setSubmitting(true); setSubmitErr(''); setSubmitMsg('');
    try {
      await apiPost(`/products/${productId}/reviews`, { rating: myRating, title: myTitle, body: myBody });
      setSubmitMsg('Review submitted! Thank you.');
      setMyRating(0); setMyTitle(''); setMyBody('');
      setShowForm(false);
      setReviewsLoaded(false); // force reload
    } catch (err: unknown) {
      setSubmitErr(friendlyError(err, 'Failed to submit your review. Please try again.'));
    } finally {
      setSubmitting(false);
    }
  };

  const total = Number(stats?.total || 0);

  return (
    <div>
      {/* Tab bar */}
      <div className="border-b border-[#ECECEC] mb-8">
        <ul className="flex flex-wrap gap-0">
          {TABS.map((tab, i) => (
            <li key={i}>
              <button
                onClick={() => setActive(i)}
                className={`relative px-5 py-4 text-sm font-bold transition-colors hover:text-[#FF6B2C] ${
                  active === i ? 'text-[#FF6B2C]' : 'text-gray-500'
                }`}
              >
                {tab === 'Reviews' ? `Reviews (${Number(reviewCount).toLocaleString()})` : tab}
                {active === i && (
                  <div className="absolute bottom-0 left-0 right-0 h-0.5 bg-[#FF6B2C]" />
                )}
              </button>
            </li>
          ))}
        </ul>
      </div>

      {/* Tab content */}
      <div className="mt-2">
        {/* Description */}
        {active === 0 && (
          <div className="text-gray-600 leading-relaxed font-medium space-y-4">
            {description
              ? <p>{description}</p>
              : <p className="text-gray-400">No description available.</p>}
          </div>
        )}

        {/* Specifications */}
        {active === 1 && (
          <div className="overflow-x-auto">
            {specs && specs.length > 0 ? (
              <table className="w-full text-sm">
                <tbody>
                  {specs.map((s, i) => (
                    <tr key={i} className={i % 2 === 0 ? 'bg-gray-50' : 'bg-white'}>
                      <td className="px-4 py-3 font-black text-gray-500 w-40">{s.label}</td>
                      <td className="px-4 py-3 font-bold text-[#111827]">{s.value}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            ) : (
              <p className="text-gray-400 font-bold">Specifications not available for this product.</p>
            )}
          </div>
        )}

        {/* Reviews */}
        {active === 2 && (
          <div className="space-y-8">
            {/* Stats row */}
            {stats && total > 0 && (
              <div className="flex flex-col md:flex-row gap-8 p-6 bg-[#F8F7FC] rounded-2xl">
                <div className="flex flex-col items-center justify-center min-w-[120px]">
                  <span className="text-5xl font-black text-[#111827]">{Number(stats.avg_rating).toFixed(1)}</span>
                  <StarRating value={Math.round(Number(stats.avg_rating))} size={16} />
                  <span className="text-xs font-bold text-gray-400 mt-1">{total} ratings</span>
                </div>
                <div className="flex-1 space-y-2">
                  <RatingBar label="5" count={Number(stats.five_star)} total={total} />
                  <RatingBar label="4" count={Number(stats.four_star)} total={total} />
                  <RatingBar label="3" count={Number(stats.three_star)} total={total} />
                  <RatingBar label="2" count={Number(stats.two_star)} total={total} />
                  <RatingBar label="1" count={Number(stats.one_star)} total={total} />
                </div>
              </div>
            )}

            {/* Write a review */}
            {isLoggedIn && productId && (
              <div className="border border-[#ECECEC] rounded-2xl overflow-hidden">
                <button
                  onClick={() => setShowForm(f => !f)}
                  className="w-full flex items-center justify-between px-5 py-4 font-black text-[#111827] hover:bg-gray-50 transition-colors"
                >
                  <span className="flex items-center gap-2"><Star size={16} className="text-amber-400 fill-amber-400" /> Write a Review</span>
                  {showForm ? <ChevronUp size={18} /> : <ChevronDown size={18} />}
                </button>
                {showForm && (
                  <form onSubmit={handleSubmitReview} className="px-5 pb-5 space-y-4 border-t border-[#ECECEC]">
                    <div className="pt-4">
                      <p className="text-xs font-black text-gray-500 uppercase tracking-wider mb-2">Your Rating *</p>
                      <StarRating value={myRating} onChange={setMyRating} size={28} />
                    </div>
                    <div>
                      <input
                        value={myTitle}
                        onChange={e => setMyTitle(e.target.value)}
                        placeholder="Review headline (optional)"
                        className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold text-[#111827] outline-none focus:border-[#FF6B2C]"
                      />
                    </div>
                    <div>
                      <textarea
                        value={myBody}
                        onChange={e => setMyBody(e.target.value)}
                        placeholder="Share your experience with this product..."
                        rows={3}
                        className="w-full border border-[#ECECEC] rounded-xl px-4 py-2.5 text-sm font-bold text-[#111827] outline-none focus:border-[#FF6B2C] resize-none"
                      />
                    </div>
                    {submitErr && <p className="text-red-500 text-sm font-bold">{submitErr}</p>}
                    {submitMsg && <p className="text-green-600 text-sm font-bold">{submitMsg}</p>}
                    <button
                      type="submit"
                      disabled={!myRating || submitting}
                      className="flex items-center gap-2 bg-[#FF6B2C] text-white px-6 py-2.5 rounded-xl font-black text-sm disabled:opacity-40 hover:bg-[#E05520] transition-colors"
                    >
                      {submitting ? <Loader2 size={16} className="animate-spin" /> : <Send size={16} />}
                      {submitting ? 'Submitting...' : 'Submit Review'}
                    </button>
                  </form>
                )}
              </div>
            )}

            {/* Review list */}
            {loadingReviews ? (
              <div className="flex items-center gap-3 py-8 justify-center">
                <Loader2 size={24} className="animate-spin text-[#FF6B2C]" />
                <span className="font-bold text-gray-400">Loading reviews...</span>
              </div>
            ) : reviews.length === 0 ? (
              <div className="text-center py-12">
                <ThumbsUp size={40} className="mx-auto text-gray-200 mb-3" />
                <p className="font-black text-gray-400">No reviews yet. Be the first to review!</p>
              </div>
            ) : (
              <div className="space-y-5">
                {reviews.map(r => (
                  <div key={r.id} className="p-5 border border-[#ECECEC] rounded-2xl">
                    <div className="flex items-start gap-3">
                      <div className="w-9 h-9 rounded-full bg-[#FF6B2C]/10 flex items-center justify-center shrink-0">
                        {r.avatar_url
                          ? <img src={r.avatar_url} alt="" className="w-9 h-9 rounded-full object-cover" />
                          : <User size={18} className="text-[#FF6B2C]" />}
                      </div>
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-2 flex-wrap mb-1">
                          <span className="font-black text-[#111827] text-sm">{r.user_name}</span>
                          {r.is_verified && (
                            <span className="text-[10px] font-black text-green-600 bg-green-50 px-2 py-0.5 rounded-full">VERIFIED</span>
                          )}
                          <span className="text-xs text-gray-400 font-bold ml-auto">
                            {new Date(r.created_at).toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' })}
                          </span>
                        </div>
                        <StarRating value={r.rating} size={14} />
                        {r.title && <p className="font-black text-[#111827] text-sm mt-2">{r.title}</p>}
                        {r.body && <p className="text-sm font-medium text-gray-500 mt-1">{r.body}</p>}
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        )}

        {/* FAQs */}
        {active === 3 && (
          <div className="space-y-4">
            {[
              { q: 'Is this product covered under warranty?', a: 'Yes, all products sold on ChillFi come with the manufacturer\'s standard warranty. Warranty details vary by product and brand.' },
              { q: 'How long does delivery take?', a: 'Standard delivery takes 3–7 business days. Express delivery (where available) arrives within 1–2 business days.' },
              { q: 'Can I return this product?', a: 'Yes, ChillFi offers a 7-day easy return policy. The product must be unused, in original packaging with all accessories.' },
              { q: 'Is the product genuine?', a: '100% genuine products are sold on ChillFi. We source directly from brands and authorized distributors.' },
            ].map((faq, i) => (
              <details key={i} className="border border-[#ECECEC] rounded-2xl group">
                <summary className="px-5 py-4 font-black text-[#111827] text-sm cursor-pointer list-none flex justify-between items-center hover:bg-gray-50 rounded-2xl">
                  {faq.q}
                  <ChevronDown size={16} className="text-gray-400 group-open:rotate-180 transition-transform" />
                </summary>
                <p className="px-5 pb-4 text-sm font-medium text-gray-500 leading-relaxed">{faq.a}</p>
              </details>
            ))}
          </div>
        )}

        {/* Delivery & Returns */}
        {active === 4 && (
          <div className="space-y-4 text-sm font-medium text-gray-600 leading-relaxed">
            <div className="p-5 bg-green-50 rounded-2xl border border-green-100">
              <p className="font-black text-green-700 mb-1">Free Delivery</p>
              <p>Free standard delivery on orders above ₹499. Delivery typically takes 3–7 business days across India.</p>
            </div>
            <div className="p-5 bg-blue-50 rounded-2xl border border-blue-100">
              <p className="font-black text-blue-700 mb-1">7-Day Easy Returns</p>
              <p>Not satisfied? Return within 7 days of delivery for a full refund. Product must be unused, in original packaging with all accessories and tags.</p>
            </div>
            <div className="p-5 bg-orange-50 rounded-2xl border border-orange-100">
              <p className="font-black text-[#FF6B2C] mb-1">Refund Timeline</p>
              <p>Refunds are processed within 5–7 business days after the returned product is received and verified at our warehouse.</p>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default ProductTabs;
