import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/profile/privacy_policy_screen.dart';
import 'package:chillfi/features/profile/widgets/about_us_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 70.w,
        leading: Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.5)),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: AppColors.darkText, size: 20.sp),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "About Us",
              style: GoogleFonts.poppins(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
            Text(
              "Know more about CHILLFI",
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            const HeroBrandSection(),
            SizedBox(height: 24.h),
            const AboutMissionCard(),
            SizedBox(height: 32.h),
            Text(
              "Why Shop with CHILLFI?",
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
            SizedBox(height: 16.h),
            const AboutFeaturesGrid(),
            SizedBox(height: 24.h),
            const JourneySection(),
            SizedBox(height: 32.h),
            const StatisticsMetricRow(),
            SizedBox(height: 32.h),
            CompanyLinksCard(
              onCompanyInfo: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Company information page is coming soon.')),
              ),
              onPolicies: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Policies & Terms page is coming soon.')),
              ),
              onTerms: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Terms & Conditions page is coming soon.')),
              ),
              onPrivacy: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
            ),
            SizedBox(height: 24.h),
            const ThankYouBanner(),
            SizedBox(height: 32.h),
            Center(
              child: Text(
                "Version 2.5.0",
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.greyText,
                ),
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}
