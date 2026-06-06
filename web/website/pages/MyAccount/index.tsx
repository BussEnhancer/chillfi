import React from 'react';
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
import ReferEarnCard from '../../sections/MyAccount/ReferEarnCard';
import PremiumBanner from '../../sections/MyAccount/PremiumBanner';
import CheckoutTrustStrip from '../../sections/Checkout/CheckoutTrustStrip';

import { ShoppingBag, Truck, Heart, MapPin, Tag, Headphones } from 'lucide-react';

const MyAccountPage: React.FC = () => {
  const breadcrumbItems = [
    { label: 'My Account' }
  ];

  return (
    <div className="min-h-screen bg-white font-['Poppins']">
      <TopBar />
      <Header />
      <CategoryNav />
      <Breadcrumb items={breadcrumbItems} />

      <Container className="py-10">
        <h1 className="text-3xl font-black text-[#111827] mb-8">My Account</h1>

        <div className="flex flex-col lg:flex-row gap-10">
          {/* Left: Account Sidebar */}
          <AccountSidebar />

          {/* Right: Dashboard Content */}
          <div className="flex-1 space-y-8">
            {/* Top Section: Profile & Stats */}
            <ProfileOverviewCard />

            {/* Middle Section: Quick Actions */}
            <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-6">
              <QuickActionCard
                icon={<ShoppingBag size={24} />}
                title="My Orders"
                desc="View all orders"
              />
              <QuickActionCard
                icon={<Truck size={24} />}
                title="Track Order"
                desc="Track your orders"
              />
              <QuickActionCard
                icon={<Heart size={24} />}
                title="Wishlist"
                desc="View saved items"
              />
              <QuickActionCard
                icon={<MapPin size={24} />}
                title="Addresses"
                desc="Manage addresses"
              />
              <QuickActionCard
                icon={<Tag size={24} />}
                title="Coupons"
                desc="View all coupons"
              />
              <QuickActionCard
                icon={<Headphones size={24} />}
                title="Support"
                desc="Help & Support"
              />
            </div>

            {/* Bottom Section: Orders, Summary & Marketing */}
            <div className="flex flex-col xl:flex-row gap-8">
              {/* Main Column */}
              <div className="flex-1 space-y-8">
                <RecentOrdersCard />
                <ReferEarnCard />
              </div>

              {/* Sidebar Column */}
              <div className="xl:w-[350px] space-y-8">
                <AccountSummaryCard />
                <PremiumBanner />
              </div>
            </div>

          </div>
        </div>

        {/* Global Trust Strip */}
        <CheckoutTrustStrip />
      </Container>

      <Footer />
    </div>
  );
};

export default MyAccountPage;
