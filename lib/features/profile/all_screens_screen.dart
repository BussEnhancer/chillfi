import 'package:chillfi/features/address/delivery_address_screen.dart';
import 'package:chillfi/features/auth/forgot_password_screen.dart';
import 'package:chillfi/features/auth/login_screen.dart';
import 'package:chillfi/features/auth/reset_password_screen.dart';
import 'package:chillfi/features/auth/signup_screen.dart';
import 'package:chillfi/features/auth/welcome_screen.dart';
import 'package:chillfi/features/brands/brand_listing_screen.dart';
import 'package:chillfi/features/cart/apply_coupon_screen.dart';
import 'package:chillfi/features/cart/cart_screen.dart';
import 'package:chillfi/features/categories/categories_screen.dart';
import 'package:chillfi/features/checkout/checkout_screen.dart';
import 'package:chillfi/features/deals/flash_deals_screen.dart';
import 'package:chillfi/features/home/home_dashboard_screen.dart';
import 'package:chillfi/features/intro/splash_screen.dart';
import 'package:chillfi/features/offers/offers_products_screen.dart';
import 'package:chillfi/features/onboarding/onboarding_screen_one.dart';
import 'package:chillfi/features/onboarding/onboarding_screen_three.dart';
import 'package:chillfi/features/onboarding/onboarding_screen_two.dart';
import 'package:chillfi/features/orders/delhivery_tracking_screen.dart';
import 'package:chillfi/features/orders/my_orders_screen.dart';
import 'package:chillfi/features/product_details/product_details_screen.dart';
import 'package:chillfi/features/product_listing/product_listing_screen.dart';
import 'package:chillfi/features/profile/about_us_screen.dart';
import 'package:chillfi/features/profile/edit_profile_screen.dart';
import 'package:chillfi/features/profile/help_support_screen.dart';
import 'package:chillfi/features/profile/my_profile_screen.dart';
import 'package:chillfi/features/profile/privacy_policy_screen.dart';
import 'package:chillfi/features/profile/settings_screen.dart';
import 'package:chillfi/features/profile/terms_and_conditions_screen.dart';
import 'package:chillfi/features/recently_viewed/recently_viewed_screen.dart';
import 'package:chillfi/features/recommended/recommended_products_screen.dart';
import 'package:chillfi/features/search/search_screen.dart';
import 'package:chillfi/features/trending/trending_products_screen.dart';
import 'package:chillfi/features/wishlist/wishlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AllScreensScreen extends StatelessWidget {
  const AllScreensScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ALL SCREENS'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            _buildScreenButton(context, 'Splash Screen', const SplashScreen()),
            _buildSectionTitle('Onboarding'),
            _buildScreenButton(context, 'Onboarding 1', const OnboardingScreenOne()),
            _buildScreenButton(context, 'Onboarding 2', const OnboardingScreenTwo()),
            _buildScreenButton(context, 'Onboarding 3', const OnboardingScreenThree()),
            _buildSectionTitle('Authentication'),
            _buildScreenButton(context, 'Welcome Screen', const WelcomeScreen()),
            _buildScreenButton(context, 'Login Screen', const LoginScreen()),
            _buildScreenButton(context, 'Sign Up Screen', const SignupScreen()),
            _buildScreenButton(context, 'Forgot Password', const ForgotPasswordScreen()),
            _buildScreenButton(context, 'Reset Password', ResetPasswordScreen(phone: '9999999999', otp: '000000')),
            _buildSectionTitle('Main Features'),
            _buildScreenButton(context, 'Home Dashboard', const HomeDashboardScreen()),
            _buildScreenButton(context, 'Categories', const CategoriesScreen()),
            _buildScreenButton(context, 'Cart', const CartScreen()),
            _buildScreenButton(context, 'Wishlist', const WishlistScreen()),
            _buildScreenButton(context, 'Search', const SearchScreen()),
            _buildSectionTitle('Product Listing'),
            _buildScreenButton(context, 'All Products', const ProductListingScreen()),
            _buildScreenButton(context, 'Flash Deals', const FlashDealsScreen()),
            _buildScreenButton(context, 'Brand Listing', const BrandListingScreen()),
            _buildScreenButton(context, 'Offers', const OffersProductsScreen()),
            _buildScreenButton(context, 'Recommended', const RecommendedProductsScreen()),
            _buildScreenButton(context, 'Trending', const TrendingProductsScreen()),
            _buildScreenButton(context, 'Recently Viewed', const RecentlyViewedScreen()),
            _buildSectionTitle('Product Details'),
            _buildScreenButton(context, 'Product Details', const ProductDetailsScreen()),
            _buildSectionTitle('Checkout & Orders'),
            _buildScreenButton(context, 'Checkout', const CheckoutScreen()),
            _buildScreenButton(context, 'Apply Coupon', const ApplyCouponScreen()),
            // OrderSuccessScreen requires an OrderModel — accessible from real order flow
            _buildScreenButton(context, 'My Orders', const MyOrdersScreen()),
            _buildScreenButton(context, 'Delivery Tracking', const DelhiveryTrackingTimelineScreen()),
            _buildSectionTitle('Profile & Address'),
            _buildScreenButton(context, 'My Profile', const MyProfileScreen()),
            _buildScreenButton(context, 'Edit Profile', const EditProfileScreen()),
            _buildScreenButton(context, 'Delivery Address', const DeliveryAddressScreen()),
            _buildSectionTitle('Settings & Info'),
            _buildScreenButton(context, 'Settings', const SettingsScreen()),
            _buildScreenButton(context, 'About Us', const AboutUsScreen()),
            _buildScreenButton(context, 'Help & Support', const HelpSupportScreen()),
            _buildScreenButton(context, 'Privacy Policy', const PrivacyPolicyScreen()),
            _buildScreenButton(context, 'Terms & Conditions', const TermsAndConditionsScreen()),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              title,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }

  Widget _buildScreenButton(BuildContext context, String title, Widget screen) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 8.h),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
        child: Text(title),
      ),
    );
  }
}
