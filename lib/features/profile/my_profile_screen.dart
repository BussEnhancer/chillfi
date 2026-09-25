import 'package:chillfi/features/auth/welcome_screen.dart';
import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/providers/auth_provider.dart';
import 'package:chillfi/core/providers/cart_provider.dart';
import 'package:chillfi/core/providers/wishlist_provider.dart';
import 'package:chillfi/features/auth/login_screen.dart';
import 'package:chillfi/features/home/widgets/bottom_nav.dart';
import 'package:chillfi/features/orders/my_orders_screen.dart';
import 'package:chillfi/features/profile/edit_profile_screen.dart';
import 'package:chillfi/features/profile/my_reviews_screen.dart';
import 'package:chillfi/features/profile/notification_settings_screen.dart';
import 'package:chillfi/features/profile/settings_screen.dart';
import 'package:chillfi/features/profile/help_support_screen.dart';
import 'package:chillfi/features/address/saved_addresses_screen.dart';
import 'package:chillfi/features/recently_viewed/recently_viewed_screen.dart';
import 'package:chillfi/features/wishlist/wishlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WishlistProvider>().loadProfile();
    });
  }

  void _logout() async {
    final navigator = Navigator.of(context);
    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();
    final wishlist = context.read<WishlistProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await auth.logout();
    cart.reset();
    wishlist.reset();
    if (!mounted) return;
    // Welcome at the base, Login on top: Back from Login lands somewhere useful (never a blank screen).
    navigator.pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const WelcomeScreen()), (r) => false);
    navigator.push(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  /// Guests get a sign-in prompt plus the pages that don't need an account (no fake profile / logout).
  Widget _guestView(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(20.r),
          children: [
            SizedBox(height: 30.h),
            Icon(Icons.account_circle_outlined, size: 80.sp, color: AppColors.secondaryPurple),
            SizedBox(height: 12.h),
            Text('Welcome to CHILLFI', textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 20.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
            SizedBox(height: 6.h),
            Text('Log in to see your orders, wishlist, addresses and more.', textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.greyText)),
            SizedBox(height: 24.h),
            SizedBox(
              height: 52.h,
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                ),
                child: Text('Login / Sign Up', style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w700)),
              ),
            ),
            SizedBox(height: 24.h),
            _Section(
              title: 'More',
              tiles: [
                _ProfileTile(icon: Icons.headset_mic_outlined, label: 'Help & Support', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen()))),
                _ProfileTile(icon: Icons.settings_outlined, label: 'Settings', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!context.watch<AuthProvider>().isAuthenticated) return _guestView(context);
    return Consumer<WishlistProvider>(builder: (context, wp, _) {
      final user = wp.profile ?? context.watch<AuthProvider>().user;
      final cartCount = context.watch<CartProvider>().cartCount;

      return Scaffold(
        backgroundColor: AppColors.lightBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Header gradient card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24.r),
                  decoration: BoxDecoration(
                    gradient: AppColors.purpleGradient,
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28.r), bottomRight: Radius.circular(28.r)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('My Profile', style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                          Stack(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyOrdersScreen())),
                                icon: Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 24.sp),
                              ),
                              if (cartCount > 0)
                                Positioned(
                                  right: 6, top: 6,
                                  child: Container(
                                    padding: EdgeInsets.all(3.r),
                                    decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                                    child: Text('$cartCount', style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      CircleAvatar(
                        radius: 42.r,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        child: user?.avatarUrl != null
                            ? ClipOval(child: Image.network(user!.avatarUrl!, width: 84.w, height: 84.h, fit: BoxFit.cover))
                            : Icon(Icons.person_rounded, size: 48.sp, color: Colors.white),
                      ),
                      SizedBox(height: 12.h),
                      Text(user?.name ?? 'ChillFi User', style: GoogleFonts.poppins(fontSize: 20.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                      if (user?.email != null)
                        Text(user!.email!, style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.white70)),
                      Text(user?.phone ?? '', style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.white70)),
                      SizedBox(height: 14.h),
                      OutlinedButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                        ),
                        child: Text('Edit Profile', style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                // Quick stats row
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      _StatCard(
                        label: 'Orders',
                        icon: Icons.receipt_long_rounded,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyOrdersScreen())),
                      ),
                      SizedBox(width: 10.w),
                      _StatCard(
                        label: 'Wishlist',
                        icon: Icons.favorite_rounded,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistScreen())),
                      ),
                      SizedBox(width: 10.w),
                      _StatCard(
                        label: 'Reviews',
                        icon: Icons.star_rounded,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyReviewsScreen())),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                // Account options
                _Section(
                  title: 'Account',
                  tiles: [
                    _ProfileTile(icon: Icons.person_outline_rounded, label: 'Edit Profile', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()))),
                    _ProfileTile(icon: Icons.receipt_long_outlined, label: 'My Orders', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyOrdersScreen()))),
                    _ProfileTile(icon: Icons.favorite_border_rounded, label: 'Wishlist', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistScreen()))),
                    _ProfileTile(icon: Icons.star_border_rounded, label: 'My Reviews', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyReviewsScreen()))),
                    _ProfileTile(icon: Icons.location_on_outlined, label: 'Saved Addresses', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedAddressesScreen()))),
                    _ProfileTile(icon: Icons.history_rounded, label: 'Recently Viewed', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecentlyViewedScreen()))),
                  ],
                ),
                SizedBox(height: 12.h),

                _Section(
                  title: 'Preferences',
                  tiles: [
                    _ProfileTile(icon: Icons.notifications_none_rounded, label: 'Notifications', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()))),
                    _ProfileTile(icon: Icons.settings_outlined, label: 'Settings', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
                    _ProfileTile(icon: Icons.headset_mic_outlined, label: 'Help & Support', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen()))),
                  ],
                ),
                SizedBox(height: 20.h),

                // Logout
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: OutlinedButton.icon(
                      onPressed: _logout,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                      ),
                      icon: Icon(Icons.logout_rounded, color: Colors.red.shade400, size: 20.sp),
                      label: Text('Logout', style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.red.shade400)),
                    ),
                  ),
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 4),
      );
    });
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _StatCard({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14.r)),
          child: Column(
            children: [
              Icon(icon, color: AppColors.secondaryPurple, size: 26.sp),
              SizedBox(height: 6.h),
              Text(label, style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.darkText)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> tiles;
  const _Section({required this.title, required this.tiles});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 8.h, left: 4.w),
            child: Text(title, style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppColors.greyText, letterSpacing: 0.5)),
          ),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
            child: Column(children: tiles),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ProfileTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(color: AppColors.secondaryPurple.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10.r)),
        child: Icon(icon, color: AppColors.secondaryPurple, size: 20.sp),
      ),
      title: Text(label, style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w500, color: AppColors.darkText)),
      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14.sp, color: AppColors.greyText),
      onTap: onTap,
    );
  }
}
