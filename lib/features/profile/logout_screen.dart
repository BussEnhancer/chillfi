import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/home/widgets/bottom_nav.dart';
import 'package:chillfi/features/profile/widgets/logout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class LogoutScreen extends StatelessWidget {
  const LogoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.h),
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 48.r,
                        height: 48.r,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(Icons.arrow_back_rounded, color: const Color(0xFF111827), size: 22.sp),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Logout",
                            style: GoogleFonts.poppins(
                              fontSize: 26.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          Text(
                            "We'll miss you!",
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 30.h),

                  // Main Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                      border: Border.all(color: const Color(0xFFE5E7EB).withOpacity(0.5)),
                    ),
                    child: Column(
                      children: [
                        const LogoutIllustration(),
                        SizedBox(height: 30.h),
                        Text(
                          "Are you sure you want to logout?",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF111827),
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          "You will be signed out of your account and need to login again to access your account.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: const Color(0xFF6B7280),
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 30.h),
                        const LogoutInformationCard(),
                        SizedBox(height: 30.h),
                        const PrimaryLogoutButton(),
                        SizedBox(height: 16.h),
                        const SecondaryCancelButton(),
                        SizedBox(height: 24.h),
                        const LogoutPrivacyFooter(),
                      ],
                    ),
                  ),
                  SizedBox(height: 120.h), // Space for bottom nav
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 4),
    );
  }
}
