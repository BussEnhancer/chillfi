import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class LogoutIllustration extends StatelessWidget {
  const LogoutIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: 140.r,
            height: 140.r,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F2FF),
              shape: BoxShape.circle,
            ),
          ),
          // Main Icon
          Container(
            width: 100.r,
            height: 100.r,
            decoration: BoxDecoration(
              gradient: AppColors.purpleGradient,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 50.sp),
          ),
          // Exit Arrow Overlay
          Positioned(
            bottom: 5.h,
            right: 5.w,
            child: Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondaryPurple.withOpacity(0.2),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(Icons.arrow_forward_rounded, color: AppColors.secondaryPurple, size: 24.sp),
            ),
          ),
          // Floating Sparkles
          ..._buildSparkles(),
        ],
      ),
    );
  }

  List<Widget> _buildSparkles() {
    return [
      Positioned(top: 10.h, left: 20.w, child: _sparkle(4.r)),
      Positioned(top: 30.h, right: 10.w, child: _sparkle(6.r)),
      Positioned(bottom: 40.h, left: 0, child: _sparkle(5.r)),
    ];
  }

  Widget _sparkle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.secondaryPurple,
        shape: BoxShape.circle,
      ),
    );
  }
}

class LogoutInformationCard extends StatelessWidget {
  const LogoutInformationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2FF),
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Column(
        children: [
          _buildInfoItem(
            Icons.person_outline_rounded,
            "Your account will be signed out",
            "You'll need to login again to access your account and personalized features.",
          ),
          _divider(),
          _buildInfoItem(
            Icons.favorite_outline_rounded,
            "Your data is safe",
            "Your orders, wishlist and account information will be saved securely.",
          ),
          _divider(),
          _buildInfoItem(
            Icons.notifications_none_rounded,
            "You may miss out!",
            "You won't receive order updates, offers and important notifications.",
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Icon(icon, color: AppColors.secondaryPurple, size: 18.sp),
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
                  color: const Color(0xFF111827),
                ),
              ),
              Text(
                desc,
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: const Color(0xFF6B7280),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Divider(height: 1, color: AppColors.secondaryPurple.withOpacity(0.1)),
    );
  }
}

class PrimaryLogoutButton extends StatelessWidget {
  const PrimaryLogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60.h,
      decoration: BoxDecoration(
        gradient: AppColors.purpleGradient,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryPurple.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.logout_rounded, color: Colors.white, size: 22.sp),
          SizedBox(width: 12.w),
          Text(
            "Yes, Logout",
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class SecondaryCancelButton extends StatelessWidget {
  const SecondaryCancelButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.secondaryPurple, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        "Cancel",
        style: GoogleFonts.poppins(
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.secondaryPurple,
        ),
      ),
    );
  }
}

class LogoutPrivacyFooter extends StatelessWidget {
  const LogoutPrivacyFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.shield_outlined, color: AppColors.secondaryPurple, size: 16.sp),
        SizedBox(width: 8.w),
        Text(
          "We respect your privacy and keep your information secure.",
          style: GoogleFonts.poppins(
            fontSize: 11.sp,
            color: const Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
