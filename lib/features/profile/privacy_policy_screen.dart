import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/profile/widgets/privacy_policy_widgets.dart';
import 'package:chillfi/core/widgets/app_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 60.w,
        leading: Padding(padding: EdgeInsets.only(left: 16.w), child: const AppBackButton()),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Privacy Policy",
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
            Text(
              "Your privacy matters to us",
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.greyText,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            SizedBox(height: 20.h),
            const PrivacyHeroBanner(),
            SizedBox(height: 24.h),
            const PolicyIndexCard(),
            SizedBox(height: 24.h),
            const ExpandablePolicyCard(),
            SizedBox(height: 16.h),
            // Account deletion & what is kept (Play / App Store and GST record-keeping)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r), border: Border.all(color: AppColors.fieldBorder)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Deleting your account', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
                  SizedBox(height: 6.h),
                  Text(
                    'Go to Account › Settings › Delete account (or chillfi.in/delete-account). We permanently delete your profile, '
                    'saved addresses, wishlist, reviews, notifications and login sessions. Records of orders you placed (items, amounts, '
                    'invoice and the delivery address on that order) are kept without your name, because Indian GST law requires us '
                    'to keep tax records for six years.',
                    style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.greyText, height: 1.5),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            const PrivacyCommitmentBanner(),
            SizedBox(height: 32.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  Text(
                    "By using CHILLFI, you agree to the terms of this Privacy Policy.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.greyText),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Last updated: 26 September 2026",
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondaryPurple,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}
