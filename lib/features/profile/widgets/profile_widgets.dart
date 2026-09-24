import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/address/saved_addresses_screen.dart';
import 'package:chillfi/features/auth/login_screen.dart';
import 'package:chillfi/features/orders/my_orders_screen.dart';
import 'package:chillfi/features/payment/payment_method_screen.dart';
import 'package:chillfi/features/profile/about_us_screen.dart';
import 'package:chillfi/features/profile/edit_profile_screen.dart';
import 'package:chillfi/features/profile/help_support_screen.dart';
import 'package:chillfi/features/profile/my_reviews_screen.dart';
import 'package:chillfi/features/profile/notification_settings_screen.dart';
import 'package:chillfi/features/profile/privacy_policy_screen.dart';
import 'package:chillfi/features/recently_viewed/recently_viewed_screen.dart';
import 'package:chillfi/features/wishlist/wishlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "My Profile",
                  style: GoogleFonts.poppins(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  "Manage your account and preferences",
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.greyText,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Row(
            children: [
              Stack(
                children: [
                  _buildIconButton(
                    context,
                    Icons.notifications_none_rounded,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationSettingsScreen())),
                  ),
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: Container(
                      padding: EdgeInsets.all(4.r),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        "3",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(BuildContext context, IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.5)),
        ),
        child: Icon(icon, color: AppColors.darkText, size: 22.sp),
      ),
    );
  }
}

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen())),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 80.r,
                      height: 80.r,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryPurple.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        image: const DecorationImage(
                          image: NetworkImage("https://ui-avatars.com/api/?name=Rahul+Sharma&background=7B2CFF&color=fff"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: const BoxDecoration(
                          color: AppColors.secondaryPurple,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14.sp),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Rahul Sharma",
                            style: GoogleFonts.poppins(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkText,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Icon(Icons.verified_rounded, color: Colors.blue, size: 16.sp),
                        ],
                      ),
                      Text(
                        "+91 98765 43210",
                        style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.greyText),
                      ),
                      Text(
                        "rahul.sharma@example.com",
                        style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.greyText),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: AppColors.lightGrey, size: 24.sp),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MyOrdersProfileCard extends StatelessWidget {
  const MyOrdersProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.shopping_bag_outlined, color: AppColors.secondaryPurple, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    "My Orders",
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyOrdersScreen())),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    Text(
                      "View All Orders",
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryPurple,
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: AppColors.secondaryPurple, size: 18.sp),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(context, "24", "All Orders", Icons.inventory_2_outlined, Colors.purple),
                _buildStatDivider(),
                _buildStatItem(context, "3", "Processing", Icons.local_shipping_outlined, Colors.orange),
                _buildStatDivider(),
                _buildStatItem(context, "2", "Shipped", Icons.local_shipping_outlined, Colors.blue),
                _buildStatDivider(),
                _buildStatItem(context, "18", "Delivered", Icons.check_circle_outline_rounded, Colors.green),
                _buildStatDivider(),
                _buildStatItem(context, "1", "Cancelled", Icons.cancel_outlined, Colors.red),
                _buildStatDivider(),
                _buildStatItem(context, "0", "Returned", Icons.history_rounded, Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String count, String label, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyOrdersScreen())),
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Icon(icon, color: color, size: 18.sp),
          SizedBox(height: 6.h),
          Text(
            count,
            style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w800, color: AppColors.darkText),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 9.sp, color: AppColors.greyText),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 30.h,
      margin: EdgeInsets.symmetric(horizontal: 15.w),
      color: AppColors.lightGrey.withValues(alpha: 0.3),
    );
  }
}

class AccountOptionsList extends StatelessWidget {
  const AccountOptionsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          _buildOptionRow(
            context,
            Icons.location_on_outlined,
            "My Addresses",
            "Manage your saved addresses",
            Colors.purple,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SavedAddressesScreen())),
          ),
          _divider(),
          _buildOptionRow(
            context,
            Icons.credit_card_rounded,
            "Payment Methods",
            "Manage cards and UPI payments",
            Colors.blue,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentMethodScreen())),
          ),
          _divider(),
          _buildOptionRow(
            context,
            Icons.favorite_outline_rounded,
            "My Wishlist",
            "View and manage your wishlist",
            Colors.red,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const WishlistScreen())),
          ),
          _divider(),
          _buildOptionRow(
            context,
            Icons.visibility_outlined,
            "Recently Viewed",
            "Products you have recently viewed",
            Colors.orange,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RecentlyViewedScreen())),
          ),
          _divider(),
          _buildOptionRow(
            context,
            Icons.star_outline_rounded,
            "My Reviews",
            "Reviews you have written",
            Colors.amber,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyReviewsScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionRow(BuildContext context, IconData icon, String title, String subtitle, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: color, size: 22.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.greyText),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.lightGrey, size: 24.sp),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(height: 1, color: AppColors.lightGrey.withValues(alpha: 0.3), indent: 60.w);
  }
}

class SettingsSectionCard extends StatelessWidget {
  const SettingsSectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          _buildSettingsRow(
            context,
            Icons.notifications_none_rounded,
            "Notifications",
            "Manage your notification preferences",
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationSettingsScreen())),
          ),
          _divider(),
          _buildSettingsRow(
            context,
            Icons.security_rounded,
            "Privacy & Security",
            "Manage your privacy and security",
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen())),
          ),
          _divider(),
          _buildSettingsRow(
            context,
            Icons.headset_mic_outlined,
            "Help & Support",
            "Get help and support",
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpSupportScreen())),
          ),
          _divider(),
          _buildSettingsRow(
            context,
            Icons.info_outline_rounded,
            "About CHILLFI",
            "Know more about us",
            trailing: "Version 2.5.0",
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutUsScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsRow(BuildContext context, IconData icon, String title, String subtitle, {String? trailing, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
        child: Row(
          children: [
            Icon(icon, color: AppColors.secondaryPurple, size: 22.sp),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.greyText),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              Text(
                trailing,
                style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.greyText, fontWeight: FontWeight.w600),
              ),
            Icon(Icons.chevron_right_rounded, color: AppColors.lightGrey, size: 24.sp),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(height: 1, color: AppColors.lightGrey.withValues(alpha: 0.3), indent: 40.w);
  }
}

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: GestureDetector(
        onTap: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          height: 56.h,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: Colors.red, size: 20.sp),
              SizedBox(width: 10.w),
              Text(
                "Logout",
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
