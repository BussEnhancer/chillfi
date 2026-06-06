import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class NoInternetIllustration extends StatelessWidget {
  const NoInternetIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background soft circle
          Container(
            width: 180.r,
            height: 180.r,
            decoration: const BoxDecoration(
              color: Color(0xFFF7F2FF),
              shape: BoxShape.circle,
            ),
          ),
          
          // Floating decorations
          Positioned(top: 20.h, left: 10.w, child: _cloud()),
          Positioned(top: 40.h, right: 0, child: _star(8.r)),
          Positioned(bottom: 30.h, left: 20.w, child: _star(6.r)),
          
          // Main WiFi Icon
          Stack(
            children: [
              Icon(
                Icons.wifi_off_rounded,
                color: const Color(0xFF6C2BFF),
                size: 90.sp,
              ),
              Positioned(
                bottom: 5.h,
                right: 5.w,
                child: Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: const BoxDecoration(
                    color: Color(0xFF6C2BFF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close_rounded, color: Colors.white, size: 16.sp),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cloud() {
    return Icon(Icons.cloud_queue_rounded, color: const Color(0xFFE5E7EB), size: 32.sp);
  }

  Widget _star(double size) {
    return Icon(Icons.auto_awesome_rounded, color: const Color(0xFF8B5CFF).withOpacity(0.3), size: size);
  }
}

class InternetHelpCard extends StatelessWidget {
  const InternetHelpCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What you can do?",
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
            ),
          ),
          SizedBox(height: 20.h),
          _buildStep(Icons.wifi_rounded, "Check your Wi-Fi or mobile data connection."),
          _divider(),
          _buildStep(Icons.airplanemode_active_rounded, "Make sure airplane mode is turned off."),
          _divider(),
          _buildStep(Icons.signal_cellular_alt_rounded, "Move to an area with a stronger connection."),
        ],
      ),
    );
  }

  Widget _buildStep(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.r),
          decoration: const BoxDecoration(
            color: Color(0xFFF7F2FF),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF6C2BFF), size: 20.sp),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 15.sp,
              color: const Color(0xFF111827),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Divider(height: 1, color: const Color(0xFFE5E7EB).withOpacity(0.5), indent: 50.w),
    );
  }
}
