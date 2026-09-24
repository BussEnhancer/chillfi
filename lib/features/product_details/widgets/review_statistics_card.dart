import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ReviewStatisticsCard extends StatelessWidget {
  final Map<String, dynamic>? stats;
  const ReviewStatisticsCard({super.key, this.stats});

  @override
  Widget build(BuildContext context) {
    final total = int.tryParse(stats?['total']?.toString() ?? '0') ?? 0;
    final avgRaw = stats?['avg_rating'];
    final avg = avgRaw == null ? 0.0 : (double.tryParse(avgRaw.toString()) ?? 0.0);
    final fiveStar = int.tryParse(stats?['five_star']?.toString() ?? '0') ?? 0;
    final fourStar = int.tryParse(stats?['four_star']?.toString() ?? '0') ?? 0;
    final recommend = total > 0 ? ((fiveStar + fourStar) / total * 100).round() : 0;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.rate_review_rounded, total.toString(), "Total Reviews", Colors.purple),
          _buildStatItem(Icons.star_rounded, avg.toStringAsFixed(1), "Avg Rating", Colors.amber),
          _buildStatItem(Icons.thumb_up_rounded, '$recommend%', "Recommend", Colors.blue),
          _buildStatItem(Icons.grade_rounded, fiveStar.toString(), "5-Star", Colors.green),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24.sp),
        SizedBox(height: 8.h),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.darkText,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 8.sp,
            color: AppColors.greyText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
