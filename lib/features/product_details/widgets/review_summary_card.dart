import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ReviewSummaryCard extends StatelessWidget {
  final Map<String, dynamic>? stats;
  const ReviewSummaryCard({super.key, this.stats});

  @override
  Widget build(BuildContext context) {
    final total = int.tryParse(stats?['total']?.toString() ?? '0') ?? 0;
    final avgRaw = stats?['avg_rating'];
    final avg = avgRaw == null ? 0.0 : (double.tryParse(avgRaw.toString()) ?? 0.0);
    final five = int.tryParse(stats?['five_star']?.toString() ?? '0') ?? 0;
    final four = int.tryParse(stats?['four_star']?.toString() ?? '0') ?? 0;
    final three = int.tryParse(stats?['three_star']?.toString() ?? '0') ?? 0;
    final two = int.tryParse(stats?['two_star']?.toString() ?? '0') ?? 0;
    final one = int.tryParse(stats?['one_star']?.toString() ?? '0') ?? 0;
    final verified = int.tryParse(stats?['verified']?.toString() ?? '0') ?? 0;

    double pct(int count) => total > 0 ? count / total : 0.0;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left Section: Average Rating
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  avg.toStringAsFixed(1),
                  style: GoogleFonts.poppins(
                    fontSize: 48.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkText,
                  ),
                ),
                Row(
                  children: List.generate(
                    5,
                    (index) {
                      if (index < avg.floor()) return Icon(Icons.star_rounded, color: Colors.orange, size: 20.sp);
                      if (index < avg && avg % 1 >= 0.5) return Icon(Icons.star_half_rounded, color: Colors.orange, size: 20.sp);
                      return Icon(Icons.star_outline_rounded, color: Colors.orange, size: 20.sp);
                    },
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '$total ${total == 1 ? 'review' : 'reviews'}',
                  style: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.greyText),
                ),
                if (verified > 0) ...[
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_rounded, color: Colors.green, size: 14.sp),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          "$verified verified purchase${verified == 1 ? '' : 's'}",
                          maxLines: 2,
                          style: GoogleFonts.poppins(fontSize: 10.sp, fontWeight: FontWeight.w700, color: Colors.green[700]),
                        ),
                      ),
                    ],
                  ),
                ),
                ],
              ],
            ),
          ),

          Container(height: 100.h, width: 1, color: AppColors.lightGrey.withValues(alpha: 0.5), margin: EdgeInsets.symmetric(horizontal: 20.w)),

          // Right Section: Rating Breakdown
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildRatingRow("5", pct(five), five.toString()),
                _buildRatingRow("4", pct(four), four.toString()),
                _buildRatingRow("3", pct(three), three.toString()),
                _buildRatingRow("2", pct(two), two.toString()),
                _buildRatingRow("1", pct(one), one.toString()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingRow(String label, double progress, String count) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w600, color: AppColors.darkText)),
          SizedBox(width: 4.w),
          Icon(Icons.star_rounded, color: AppColors.greyText, size: 10.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.lightGrey.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                minHeight: 6.h,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Text(count, style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.greyText)),
        ],
      ),
    );
  }
}
