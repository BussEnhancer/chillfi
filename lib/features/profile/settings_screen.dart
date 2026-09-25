import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/profile/edit_profile_screen.dart';
import 'package:chillfi/features/profile/notification_settings_screen.dart';
import 'package:chillfi/features/profile/privacy_policy_screen.dart';
import 'package:chillfi/features/profile/help_support_screen.dart';
import 'package:chillfi/features/profile/about_us_screen.dart';
import 'package:chillfi/core/widgets/app_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 60.w,
        leading: Padding(padding: EdgeInsets.only(left: 16.w), child: const AppBackButton()),
        title: Text(
          "Settings",
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.darkText,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            _buildSettingsItem(
              context,
              Icons.person_outline_rounded,
              "Account Settings",
              "Edit your profile information",
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen())),
            ),
            _buildSettingsItem(
              context,
              Icons.notifications_none_rounded,
              "Notifications",
              "Manage your alert preferences",
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationSettingsScreen())),
            ),
            _buildSettingsItem(
              context,
              Icons.security_rounded,
              "Privacy & Security",
              "Privacy policy and security settings",
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen())),
            ),
            _buildSettingsItem(
              context,
              Icons.help_outline_rounded,
              "Help & Support",
              "Get assistance and support",
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpSupportScreen())),
            ),
            _buildSettingsItem(
              context,
              Icons.info_outline_rounded,
              "About CHILLFI",
              "Information about our company",
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutUsScreen())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context, IconData icon, String title, String subtitle, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: AppColors.secondaryPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: AppColors.secondaryPurple, size: 22.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: AppColors.greyText,
                    ),
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
}
