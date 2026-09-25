import React, { useEffect, useState } from 'react';
import Header from '../../components/navigation/Header';
import TopBar from '../../components/navigation/TopBar';
import CategoryNav from '../../components/navigation/CategoryNav';
import Footer from '../../components/navigation/Footer';
import Container from '../../components/common/Container';
import Breadcrumb from '../../components/common/Breadcrumb';
import AccountSidebar from '../../components/profile/AccountSidebar';
import { Loader2, Bell } from 'lucide-react';
import { apiGet } from '../../utils/api';

interface ApiNotification {
  id: string;
  title: string;
  body: string;
  type: string;
  is_read: boolean;
  created_at: string;
}

const NotificationsPage: React.FC = () => {
  const breadcrumbItems = [{ label: 'My Account', href: '/account' }, { label: 'Notifications' }];

  const [notifications, setNotifications] = useState<ApiNotification[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    apiGet<{ success: boolean; data: ApiNotification[] }>('/profile/notifications')
      .then(res => setNotifications(res.data || []))
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
          <AccountSidebar activeId="notifications" />

          <div className="flex-1">
            <h1 className="text-3xl font-black text-[#111827] mb-8">Notifications</h1>

            {loading ? (
              <div className="flex items-center gap-3 text-gray-400">
                <Loader2 size={20} className="animate-spin text-[#FF6B2C]" />
                <span className="text-sm font-bold">Loading notifications...</span>
              </div>
            ) : notifications.length === 0 ? (
              <div className="py-16 text-center text-gray-400">
                <Bell size={40} className="mx-auto mb-4 text-gray-200" />
                <p className="text-sm font-bold">No notifications yet.</p>
              </div>
            ) : (
              <div className="space-y-3">
                {notifications.map(n => (
                  <div
                    key={n.id}
                    className={`p-5 rounded-2xl border flex items-start gap-4 ${n.is_read ? 'border-[#ECECEC] bg-white' : 'border-[#FF6B2C]/30 bg-[#FFF8F5]'}`}
                  >
                    <div className="w-10 h-10 rounded-full bg-[#FF6B2C]/10 text-[#FF6B2C] flex items-center justify-center shrink-0">
                      <Bell size={18} />
                    </div>
                    <div className="flex-1">
                      <p className="text-sm font-black text-[#111827]">{n.title}</p>
                      <p className="text-sm font-bold text-gray-500 mt-0.5">{n.body}</p>
                      <p className="text-xs font-bold text-gray-400 mt-2">{new Date(n.created_at).toLocaleString()}</p>
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

export default NotificationsPage;
