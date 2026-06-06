import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class HeroBrandSection extends StatelessWidget {
  const HeroBrandSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F0FF),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    gradient: AppColors.purpleGradient,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 36.sp),
                ),
                SizedBox(width: 12.w),
                Text(
                  "chillfi",
                  style: GoogleFonts.poppins(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.secondaryPurple,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 80.h, color: AppColors.lightGrey.withValues(alpha: 0.5)),
          SizedBox(width: 16.w),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Smart Shopping.\nDelivered to You.",
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "CHILLFI is your one-stop destination for quality products at the best prices.",
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: AppColors.greyText,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AboutMissionCard extends StatelessWidget {
  const AboutMissionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: AppColors.secondaryPurple.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.track_changes_rounded, color: AppColors.secondaryPurple, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Our Mission",
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "To make online shopping simple, affordable and reliable for everyone. We strive to offer a seamless experience with trusted products.",
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    color: AppColors.greyText,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AboutFeaturesGrid extends StatelessWidget {
  const AboutFeaturesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 12.h,
      crossAxisSpacing: 12.w,
      childAspectRatio: 0.7,
      children: [
        _buildFeatureItem(Icons.verified_user_outlined, "Trusted Products", "100% genuine quality"),
        _buildFeatureItem(Icons.local_shipping_outlined, "Fast Delivery", "Quick and reliable"),
        _buildFeatureItem(Icons.local_offer_outlined, "Best Prices", "Competitive and exciting"),
        _buildFeatureItem(Icons.headset_mic_outlined, "24/7 Support", "Here to help, always"),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F0FF),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, color: AppColors.secondaryPurple, size: 20.sp),
        ),
        SizedBox(height: 10.h),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 10.sp, fontWeight: FontWeight.w700, color: AppColors.darkText),
        ),
        SizedBox(height: 4.h),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 8.sp, color: AppColors.greyText, height: 1.2),
        ),
      ],
    );
  }
}

class JourneySection extends StatelessWidget {
  const JourneySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.flag_rounded, color: AppColors.secondaryPurple, size: 24.sp),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Our Journey",
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "CHILLFI was founded with a vision to redefine online shopping. From a small idea to a growing community, we continue to innovate for you.",
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    color: AppColors.greyText,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StatisticsMetricRow extends StatelessWidget {
  const StatisticsMetricRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStat(Icons.people_outline_rounded, "5M+", "Happy Customers"),
        _buildStat(Icons.inventory_2_outlined, "10M+", "Orders Delivered"),
        _buildStat(Icons.sentiment_very_satisfied_rounded, "4.8★", "Average Rating"),
        _buildStat(Icons.location_on_outlined, "500+", "Cities Served"),
      ],
    );
  }

  Widget _buildStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.secondaryPurple.withValues(alpha: 0.6), size: 20.sp),
        SizedBox(height: 6.h),
        Text(
          value,
          style: GoogleFonts.poppins(fontSize: 22.sp, fontWeight: FontWeight.w800, color: AppColors.darkText),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 8.sp, color: AppColors.greyText, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class CompanyLinksCard extends StatelessWidget {
  const CompanyLinksCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          _buildLinkRow(Icons.business_outlined, "Company Information"),
          _divider(),
          _buildLinkRow(Icons.verified_user_outlined, "Policies & Terms"),
          _divider(),
          _buildLinkRow(Icons.description_outlined, "Terms & Conditions"),
          _divider(),
          _buildLinkRow(Icons.lock_outline_rounded, "Privacy Policy"),
        ],
      ),
    );
  }

  Widget _buildLinkRow(IconData icon, String title) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondaryPurple, size: 20.sp),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.darkText),
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.lightGrey, size: 22.sp),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(height: 1, color: AppColors.lightGrey.withValues(alpha: 0.3), indent: 50.w);
  }
}

class ThankYouBanner extends StatelessWidget {
  const ThankYouBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F0FF),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.favorite_rounded, color: Colors.pink, size: 20),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Thank you for being a part of CHILLFI!",
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  "Your trust motivates us to do better every day.",
                  style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.greyText),
                ),
              ],
            ),
          ),
          Icon(Icons.shopping_bag_outlined, color: AppColors.secondaryPurple.withValues(alpha: 0.3), size: 40.sp),
        ],
      ),
    );
  }
}
