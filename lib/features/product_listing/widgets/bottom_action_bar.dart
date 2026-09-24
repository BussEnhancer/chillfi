import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomActionBar extends StatelessWidget {
  final VoidCallback onSort;
  final VoidCallback onFilter;
  final VoidCallback onGrid;
  final int activeFilterCount;
  final bool isGridView;

  const BottomActionBar({
    super.key,
    required this.onSort,
    required this.onFilter,
    required this.onGrid,
    this.activeFilterCount = 0,
    this.isGridView = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.8.sw,
      height: 54.h,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildItem(Icons.swap_vert_rounded, "Sort", onSort),
          Container(height: 24.h, width: 1, color: AppColors.lightGrey),
          _buildFilterItem("Filter", activeFilterCount, onFilter),
          Container(height: 24.h, width: 1, color: AppColors.lightGrey),
          _buildItem(
            isGridView ? Icons.grid_view_rounded : Icons.view_list_rounded,
            isGridView ? "Grid" : "List",
            onGrid,
          ),
        ],
      ),
    );
  }

  Widget _buildItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            Icon(icon, size: 20.sp, color: AppColors.darkText),
            SizedBox(width: 8.w),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterItem(String label, int badgeCount, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            Icon(Icons.tune_rounded, size: 20.sp, color: AppColors.darkText),
            SizedBox(width: 8.w),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
            if (badgeCount > 0) ...[
              SizedBox(width: 6.w),
              Container(
                padding: EdgeInsets.all(4.r),
                decoration: const BoxDecoration(
                  color: AppColors.secondaryPurple,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badgeCount.toString(),
                  style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
