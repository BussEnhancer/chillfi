import 'dart:io';
import 'package:chillfi/core/widgets/app_error_dialog.dart';
import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ForceUpdateScreen extends StatelessWidget {
  final String message;

  const ForceUpdateScreen({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 28.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.system_update_rounded, size: 80.sp, color: AppColors.secondaryPurple),
                SizedBox(height: 32.h),
                Text(
                  "Update Required",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 26.sp, fontWeight: FontWeight.w800, color: const Color(0xFF111827)),
                ),
                SizedBox(height: 16.h),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 14.sp, color: const Color(0xFF6B7280), height: 1.5),
                ),
                SizedBox(height: 36.h),
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (Platform.isIOS) {
                        // No App Store id is configured in the project yet — guide the user instead of a dead link.
                        AppErrorDialog.show(context, title: 'Update ChillFi', message: 'Please open the App Store and update ChillFi to continue.');
                        return;
                      }
                      final uri = Uri.parse('https://play.google.com/store/apps/details?id=com.ecom.chillfi');
                      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication).catchError((_) => false);
                      if (!ok && context.mounted) {
                        AppErrorDialog.show(context, title: "Couldn't open the store", message: 'Please update ChillFi from the Google Play Store / App Store.');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                    ),
                    child: Text("Update Now", style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
