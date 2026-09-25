import 'package:chillfi/core/config.dart';
import 'package:chillfi/features/profile/terms_and_conditions_screen.dart';
import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/profile/privacy_policy_screen.dart';
import 'package:chillfi/features/profile/widgets/about_us_widgets.dart';
import 'package:chillfi/core/widgets/app_back_button.dart';
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
        leadingWidth: 60.w,
        leading: Padding(padding: EdgeInsets.only(left: 16.w), child: const AppBackButton()),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "About Us",
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
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
            CompanyLinksCard(
              onTerms: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsAndConditionsScreen())),
              onPrivacy: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
            ),
            SizedBox(height: 24.h),
            const ThankYouBanner(),
            SizedBox(height: 32.h),
            Center(
              child: FutureBuilder<String>(
                future: AppConfig.installedVersion(),
                builder: (context, snap) => Text(
                snap.hasData ? "Version ${snap.data}" : "",
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.greyText,
                ),
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
