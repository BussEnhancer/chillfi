import React from 'react'
import { Routes, Route } from 'react-router-dom'

import ProtectedRoute from '../components/auth/ProtectedRoute'
import AdminRoute from '../components/auth/AdminRoute'

import AdminDashboard from '../pages/Admin/Dashboard/index'
import AdminProducts from '../pages/Admin/Products/index'
import AdminOrders from '../pages/Admin/Orders/index'
import AdminUsers from '../pages/Admin/Users/index'
import AdminCategories from '../pages/Admin/Categories/index'
import AdminAnalytics from '../pages/Admin/Analytics/index'
import AdminCoupons from '../pages/Admin/Coupons/index'
import AdminSettings from '../pages/Admin/Settings/index'
import AdminBannersPage from '../pages/Admin/Banners/index'
import AdminReviews from '../pages/Admin/Reviews/index'
import AdminMessages from '../pages/Admin/Messages/index'
import AdminTestimonials from '../pages/Admin/Testimonials/index'
import AdminPromoBanners from '../pages/Admin/PromoBanners/index'
import AdminNotifications from '../pages/Admin/Notifications/index'
import AdminRefunds from '../pages/Admin/Refunds/index'
import AdminShippingRules from '../pages/Admin/ShippingRules/index'

import HomePage from '../pages/Home/index'
import SearchPage from '../pages/Search/index'
import LoginPage from '../pages/Login/index'
import ProductListingPage from '../pages/ProductListing/index'
import ProductDetailsPage from '../pages/ProductDetails/index'
import CartPage from '../pages/Cart/index'
import CheckoutPage from '../pages/Checkout/index'
import MyAccountPage from '../pages/MyAccount/index'
import OrdersPage from '../pages/Orders/index'
import TrackingPage from '../pages/Tracking/index'
import WishlistPage from '../pages/Wishlist/index'
import OrderSuccessPage from '../pages/OrderSuccess/index'
import OrderFailedPage from '../pages/OrderFailed/index'
import SavedAddressesPage from '../pages/SavedAddresses/index'
import EditProfilePage from '../pages/EditProfile/index'
import NotificationsPage from '../pages/Notifications/index'
import MyReviewsPage from '../pages/MyReviews/index'
import CategoriesPage from '../pages/Categories/index'
import OffersPage from '../pages/Offers/index'
import SupportPage from '../pages/Support/index'
import AboutUsPage from '../pages/AboutUs/index'
import ContactUsPage from '../pages/ContactUs/index'
import PrivacyPolicyPage from '../pages/PrivacyPolicy/index'
import TermsConditionsPage from '../pages/TermsConditions/index'
import NotFoundPage from '../pages/NotFound/index'

function App() {
  return (
    <Routes>
      <Route path="/" element={<HomePage />} />
      <Route path="/login" element={<LoginPage />} />
      <Route path="/products" element={<ProductListingPage />} />
      <Route path="/search" element={<SearchPage />} />
      <Route path="/product/:id" element={<ProductDetailsPage />} />

      <Route path="/cart" element={<ProtectedRoute><CartPage /></ProtectedRoute>} />
      <Route path="/checkout" element={<ProtectedRoute><CheckoutPage /></ProtectedRoute>} />
      <Route path="/order-success" element={<ProtectedRoute><OrderSuccessPage /></ProtectedRoute>} />
      <Route path="/order-failed" element={<ProtectedRoute><OrderFailedPage /></ProtectedRoute>} />
      <Route path="/account" element={<ProtectedRoute><MyAccountPage /></ProtectedRoute>} />
      <Route path="/account/orders" element={<ProtectedRoute><OrdersPage /></ProtectedRoute>} />
      <Route path="/account/orders/:id/track" element={<ProtectedRoute><TrackingPage /></ProtectedRoute>} />
      <Route path="/account/wishlist" element={<ProtectedRoute><WishlistPage /></ProtectedRoute>} />
      <Route path="/account/addresses" element={<ProtectedRoute><SavedAddressesPage /></ProtectedRoute>} />
      <Route path="/account/settings" element={<ProtectedRoute><EditProfilePage /></ProtectedRoute>} />
      <Route path="/account/notifications" element={<ProtectedRoute><NotificationsPage /></ProtectedRoute>} />
      <Route path="/account/reviews" element={<ProtectedRoute><MyReviewsPage /></ProtectedRoute>} />

      <Route path="/categories" element={<CategoriesPage />} />
      <Route path="/offers" element={<OffersPage />} />
      <Route path="/support" element={<SupportPage />} />
      <Route path="/about" element={<AboutUsPage />} />
      <Route path="/contact" element={<ContactUsPage />} />
      <Route path="/privacy-policy" element={<PrivacyPolicyPage />} />
      <Route path="/terms" element={<TermsConditionsPage />} />

      <Route path="/admin" element={<AdminRoute><AdminDashboard /></AdminRoute>} />
      <Route path="/admin/products" element={<AdminRoute><AdminProducts /></AdminRoute>} />
      <Route path="/admin/orders" element={<AdminRoute><AdminOrders /></AdminRoute>} />
      <Route path="/admin/users" element={<AdminRoute><AdminUsers /></AdminRoute>} />
      <Route path="/admin/categories" element={<AdminRoute><AdminCategories /></AdminRoute>} />
      <Route path="/admin/analytics" element={<AdminRoute><AdminAnalytics /></AdminRoute>} />
      <Route path="/admin/coupons" element={<AdminRoute><AdminCoupons /></AdminRoute>} />
      <Route path="/admin/reviews" element={<AdminRoute><AdminReviews /></AdminRoute>} />
      <Route path="/admin/messages" element={<AdminRoute><AdminMessages /></AdminRoute>} />
      <Route path="/admin/testimonials" element={<AdminRoute><AdminTestimonials /></AdminRoute>} />
      <Route path="/admin/promo-banners" element={<AdminRoute><AdminPromoBanners /></AdminRoute>} />
      <Route path="/admin/notifications" element={<AdminRoute><AdminNotifications /></AdminRoute>} />
      <Route path="/admin/refunds" element={<AdminRoute><AdminRefunds /></AdminRoute>} />
      <Route path="/admin/shipping-rules" element={<AdminRoute><AdminShippingRules /></AdminRoute>} />
      <Route path="/admin/settings" element={<AdminRoute><AdminSettings /></AdminRoute>} />
      <Route path="/admin/banners" element={<AdminRoute><AdminBannersPage /></AdminRoute>} />

      <Route path="*" element={<NotFoundPage />} />
    </Routes>
  )
}

export default App
