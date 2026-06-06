import 'package:chillfi/core/app_colors.dart';
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
          Column(
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
          Row(
            children: [
              _buildIconButton(Icons.settings_outlined),
              SizedBox(width: 12.w),
              Stack(
                children: [
                  _buildIconButton(Icons.notifications_none_rounded),
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

  Widget _buildIconButton(IconData icon) {
    return Container(
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.5)),
      ),
      child: Icon(icon, color: AppColors.darkText, size: 22.sp),
    );
  }
}

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryPurple.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.workspace_premium_rounded, color: AppColors.secondaryPurple, size: 12.sp),
                          SizedBox(width: 4.w),
                          Text(
                            "CHILLFI Member",
                            style: GoogleFonts.poppins(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondaryPurple,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Divider(color: AppColors.lightGrey.withValues(alpha: 0.3)),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Wallet Balance",
                      style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.greyText),
                    ),
                    Row(
                      children: [
                        Text(
                          "₹1,250.00",
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.secondaryPurple,
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: AppColors.greyText, size: 20.sp),
                      ],
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 30.h, color: AppColors.lightGrey.withValues(alpha: 0.3)),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "CHILLFI Coins",
                        style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.greyText),
                      ),
                      Row(
                        children: [
                          Text(
                            "560",
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkText,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(Icons.monetization_on_rounded, color: Colors.amber, size: 16.sp),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PremiumMembershipCard extends StatelessWidget {
  const PremiumMembershipCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: AppColors.purpleGradient,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryPurple.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: const BoxDecoration(
              color: Colors.amber,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.star_rounded, color: Colors.white, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "CHILLFI Premium",
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "You are saving more with Premium",
                  style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.white.withValues(alpha: 0.8)),
                ),
                SizedBox(height: 6.h),
                Text(
                  "• Free delivery  • Exclusive offers  • Early access",
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Text(
              "View Benefits",
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
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
              Row(
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
            ],
          ),
          SizedBox(height: 20.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem("24", "All Orders", Icons.inventory_2_outlined, Colors.purple),
                _buildStatDivider(),
                _buildStatItem("3", "Processing", Icons.local_shipping_outlined, Colors.orange),
                _buildStatDivider(),
                _buildStatItem("2", "Shipped", Icons.local_shipping_outlined, Colors.blue),
                _buildStatDivider(),
                _buildStatItem("18", "Delivered", Icons.check_circle_outline_rounded, Colors.green),
                _buildStatDivider(),
                _buildStatItem("1", "Cancelled", Icons.cancel_outlined, Colors.red),
                _buildStatDivider(),
                _buildStatItem("0", "Returned", Icons.history_rounded, Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label, IconData icon, Color color) {
    return Column(
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
          _buildOptionRow(Icons.location_on_outlined, "My Addresses", "Manage your saved addresses", Colors.purple),
          _divider(),
          _buildOptionRow(Icons.credit_card_rounded, "Payment Methods", "Manage cards, UPI and wallets", Colors.blue),
          _divider(),
          _buildOptionRow(Icons.favorite_outline_rounded, "My Wishlist", "View and manage your wishlist", Colors.red),
          _divider(),
          _buildOptionRow(Icons.visibility_outlined, "Recently Viewed", "Products you have recently viewed", Colors.orange),
          _divider(),
          _buildOptionRow(Icons.star_outline_rounded, "My Reviews", "Reviews you have written", Colors.amber),
          _divider(),
          _buildOptionRow(Icons.confirmation_number_outlined, "My Coupons", "View and manage your coupons", Colors.pink),
        ],
      ),
    );
  }

  Widget _buildOptionRow(IconData icon, String title, String subtitle, Color color) {
    return Padding(
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
          _buildSettingsRow(Icons.settings_outlined, "Account Settings", "Manage your account preferences"),
          _divider(),
          _buildSettingsRow(Icons.notifications_none_rounded, "Notifications", "Manage your notification preferences"),
          _divider(),
          _buildSettingsRow(Icons.security_rounded, "Privacy & Security", "Manage your privacy and security"),
          _divider(),
          _buildSettingsRow(Icons.headset_mic_outlined, "Help & Support", "Get help and support"),
          _divider(),
          _buildSettingsRow(Icons.info_outline_rounded, "About CHILLFI", "Know more about us", trailing: "Version 2.5.0"),
        ],
      ),
    );
  }

  Widget _buildSettingsRow(IconData icon, String title, String subtitle, {String? trailing}) {
    return Padding(
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
    );
  }
}
