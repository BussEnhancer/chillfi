import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import Header from '../../components/navigation/Header';
import TopBar from '../../components/navigation/TopBar';
import CategoryNav from '../../components/navigation/CategoryNav';
import Footer from '../../components/navigation/Footer';
import Container from '../../components/common/Container';
import Breadcrumb from '../../components/common/Breadcrumb';
import AccountSidebar from '../../components/profile/AccountSidebar';
import ProfileOverviewCard from '../../components/profile/ProfileOverviewCard';
import QuickActionCard from '../../components/profile/QuickActionCard';
import RecentOrdersCard from '../../sections/MyAccount/RecentOrdersCard';
import AccountSummaryCard from '../../sections/MyAccount/AccountSummaryCard';
import CheckoutTrustStrip from '../../sections/Checkout/CheckoutTrustStrip';
import { ShoppingBag, Truck, Heart, MapPin, Tag, Headphones } from 'lucide-react';
import { apiGet } from '../../utils/api';
import { useStore } from '../../context/StoreContext';

interface ApiProfile {
  id: string;
  name: string;
  email?: string;
  phone: string;
  avatar_url?: string;
  role: string;
  created_at: string;
}

const MyAccountPage: React.FC = () => {
  const { logoutUser } = useStore();
  const [profile, setProfile] = useState<ApiProfile | null>(null);

  const breadcrumbItems = [{ label: 'My Account' }];

  useEffect(() => {
    apiGet<{ success: boolean; data: ApiProfile }>('/profile')
      .then(res => setProfile(res.data))
      .catch(() => {});
  }, []);

  return (
    <div className="min-h-screen bg-white font-['Poppins']">
      <TopBar />
      <Header />
      <CategoryNav />
      <Breadcrumb items={breadcrumbItems} />

      <Container className="py-10 animate-page-in">
        <div className="flex items-center justify-between mb-8">
          <h1 className="text-3xl font-black text-[#111827]">My Account</h1>
          <button
            onClick={logoutUser}
            className="text-xs font-black text-gray-400 hover:text-red-500 uppercase tracking-widest transition-colors"
          >
            Logout
          </button>
        </div>

        <div className="flex flex-col lg:flex-row gap-10">
          <AccountSidebar />

          <div className="flex-1 min-w-0 space-y-8">
            <ProfileOverviewCard
              name={profile?.name}
              phone={profile?.phone}
              email={profile?.email}
              memberSince={profile?.created_at}
            />

            <div className="grid grid-cols-2 md:grid-cols-3 2xl:grid-cols-6 gap-4 xl:gap-6">
              <Link to="/account/orders">
                <QuickActionCard icon={<ShoppingBag size={24} />} title="My Orders" desc="View all orders" />
              </Link>
              <Link to="/account/orders">
                <QuickActionCard icon={<Truck size={24} />} title="Track Order" desc="Track your orders" />
              </Link>
              <Link to="/account/wishlist">
                <QuickActionCard icon={<Heart size={24} />} title="Wishlist" desc="View saved items" />
              </Link>
              <Link to="/account/addresses">
                <QuickActionCard icon={<MapPin size={24} />} title="Addresses" desc="Manage addresses" />
              </Link>
              <Link to="/offers">
                <QuickActionCard icon={<Tag size={24} />} title="Coupons" desc="View all coupons" />
              </Link>
              <Link to="/support">
                <QuickActionCard icon={<Headphones size={24} />} title="Support" desc="Help & Support" />
              </Link>
            </div>

            <div className="flex flex-col xl:flex-row gap-8">
              <div className="flex-1 min-w-0 space-y-8">
                <RecentOrdersCard />
              </div>
              <div className="xl:w-[350px] space-y-8">
                <AccountSummaryCard />
              </div>
            </div>
          </div>
        </div>

        <CheckoutTrustStrip />
      </Container>

      <Footer />
    </div>
  );
};

export default MyAccountPage;
