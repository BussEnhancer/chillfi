import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/home/widgets/bottom_nav.dart';
import 'package:chillfi/core/widgets/no_internet_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

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
                    SizedBox(height: 60.h),
                    const NoInternetIllustration(),
                    SizedBox(height: 40.h),
                    Text(
                      "No Internet Connection",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 34.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111827),
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      "Looks like you're offline. Please check your internet connection and try again.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        color: const Color(0xFF6B7280),
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 40.h),
                    
                    // Action Buttons
                    Container(
                      width: double.infinity,
                      height: 58.h,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C2BFF), Color(0xFF8B5CFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16.r),
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
                          Icon(Icons.refresh_rounded, color: Colors.white, size: 24.sp),
                          SizedBox(width: 12.w),
                          Text(
                            "Try Again",
                            style: GoogleFonts.poppins(
                              fontSize: 18.sp,
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
                      height: 58.h,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF6C2BFF), width: 1.5),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.wifi_rounded, color: const Color(0xFF6C2BFF), size: 24.sp),
                          SizedBox(width: 12.w),
                          Text(
                            "Check Connection",
                            style: GoogleFonts.poppins(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF6C2BFF),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 32.h),
                    const InternetHelpCard(),
                    SizedBox(height: 32.h),
                    
                    // Bottom Data Message
                    Column(
                      children: [
                        Icon(Icons.favorite_outline_rounded, color: const Color(0xFF6C2BFF), size: 24.sp),
                        SizedBox(height: 8.h),
                        Text(
                          "We'll save your data.",
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        Text(
                          "Your session will resume once you're back online.",
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 4),
    );
  }
}
