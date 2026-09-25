import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shown on account-only screens (orders, wishlist) when nobody is signed in.
class GuestPrompt extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  const GuestPrompt({super.key, required this.icon, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.r,
              height: 72.r,
              decoration: const BoxDecoration(color: Color(0xFFF1EBFF), shape: BoxShape.circle),
              child: Icon(icon, color: AppColors.secondaryPurple, size: 34.sp),
            ),
            SizedBox(height: 16.h),
            Text(title, textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 17.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
            SizedBox(height: 6.h),
            Text(message, textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.greyText, height: 1.4)),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryPurple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 36.w, vertical: 13.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              child: Text('Login / Sign up', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
