import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/widgets/maintenance_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    SizedBox(height: 40.h),
                    
                    // Brand Section
                    Column(
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          height: 40.h,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Shop Smart.",
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              "Chill More.",
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF6C2BFF),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 60.h),
                    const MaintenanceIllustration(),
                    SizedBox(height: 60.h),

                    Text(
                      "We’re Under Maintenance",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 34.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111827),
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      "We’re making some improvements to serve you better. We’ll be back soon! 💜",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        color: const Color(0xFF6B7280),
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: 40.h),
                    const DowntimeInfoCard(),
                    
                    SizedBox(height: 40.h),
                    
                    // Thank You Section
                    Column(
                      children: [
                        Icon(Icons.favorite_outline_rounded, color: const Color(0xFF6C2BFF), size: 28.sp),
                        SizedBox(height: 12.h),
                        Text(
                          "Thank you for your patience.\nWe appreciate your support!",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6B7280),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 40.h),

                    // Action Buttons
                    Container(
                      width: double.infinity,
                      height: 62.h,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C2BFF), Color(0xFF8B5CFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18.r),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6C2BFF).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_active_outlined, color: Colors.white, size: 22.sp),
                          SizedBox(width: 12.w),
                          Text(
                            "Notify Me When It’s Back",
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      width: double.infinity,
                      height: 62.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(color: const Color(0xFF6C2BFF), width: 1.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.home_outlined, color: const Color(0xFF6C2BFF), size: 22.sp),
                          SizedBox(width: 12.w),
                          Text(
                            "Go to Home",
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF6C2BFF),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 60.h),
                  ],
                ),
              ),
            ),
            const SkylineFooterDecoration(),
          ],
        ),
      ),
    );
  }
}
