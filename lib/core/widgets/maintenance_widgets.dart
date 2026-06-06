import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class MaintenanceIllustration extends StatelessWidget {
  const MaintenanceIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background soft elements
          Positioned(top: 20.h, left: 0, child: _cloud(40.sp)),
          Positioned(top: 10.h, right: 20.w, child: _cloud(30.sp)),
          
          // Main Illustration Box
          Container(
            width: 220.r,
            height: 180.r,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Browser Top Bar
                Container(
                  height: 25.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F2FF),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 10.w),
                      _dot(Colors.red),
                      _dot(Colors.amber),
                      _dot(Colors.green),
                    ],
                  ),
                ),
                // Center Gear
                Center(
                  child: Icon(Icons.settings_rounded, color: const Color(0xFF6C2BFF).withOpacity(0.15), size: 100.sp),
                ),
              ],
            ),
          ),

          // Foreground Interactive Elements
          Positioned(
            bottom: 20.h,
            right: 0,
            child: _warningSign(),
          ),
          Positioned(
            bottom: 0,
            left: 20.w,
            child: _trafficCone(),
          ),
          Positioned(
            top: 60.h,
            right: 40.w,
            child: _barrier(),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      width: 6.r,
      height: 6.r,
      decoration: BoxDecoration(color: color.withOpacity(0.5), shape: BoxShape.circle),
    );
  }

  Widget _cloud(double size) {
    return Icon(Icons.cloud_queue_rounded, color: const Color(0xFFE5E7EB), size: size);
  }

  Widget _warningSign() {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.amber[100],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(Icons.build_rounded, color: Colors.amber[800], size: 30.sp),
    );
  }

  Widget _trafficCone() {
    return Column(
      children: [
        Container(
          width: 20.w,
          height: 40.h,
          decoration: const BoxDecoration(
            color: Color(0xFF6C2BFF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
          ),
        ),
        Container(width: 40.w, height: 4.h, decoration: const BoxDecoration(color: Color(0xFF6C2BFF))),
      ],
    );
  }

  Widget _barrier() {
    return Container(
      width: 60.w,
      height: 30.h,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: const Color(0xFF6C2BFF), width: 2),
      ),
      child: Center(
        child: Container(
          width: 40.w,
          height: 10.h,
          color: const Color(0xFF6C2BFF).withOpacity(0.2),
        ),
      ),
    );
  }
}

class DowntimeInfoCard extends StatelessWidget {
  const DowntimeInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2FF),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildInfoSection(
              icon: Icons.access_time_rounded,
              title: "Estimated Downtime",
              value: "30 – 60 Minutes",
            ),
          ),
          Container(width: 1, height: 60.h, color: const Color(0xFFE5E7EB)),
          Expanded(
            child: _buildInfoSection(
              icon: Icons.calendar_today_rounded,
              title: "May 18, 2025",
              value: "10:00 AM – 11:00 AM",
              isRight: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String value,
    bool isRight = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(left: isRight ? 20.w : 0, right: isRight ? 0 : 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(icon, color: const Color(0xFF6C2BFF), size: 16.sp),
              ),
              SizedBox(width: 8.w),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6C2BFF),
            ),
          ),
        ],
      ),
    );
  }
}

class SkylineFooterDecoration extends StatelessWidget {
  const SkylineFooterDecoration({super.key});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.05,
      child: Container(
        height: 100.h,
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(10, (index) => _building(index)),
        ),
      ),
    );
  }

  Widget _building(int index) {
    double height = (index % 3 == 0) ? 60.h : (index % 2 == 0 ? 40.h : 80.h);
    return Container(
      width: 30.w,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF6C2BFF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)),
      ),
    );
  }
}
