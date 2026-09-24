import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductListingSearch extends StatefulWidget {
  final String? initialText;
  final ValueChanged<String>? onSubmitted;
  const ProductListingSearch({super.key, this.initialText, this.onSubmitted});

  @override
  State<ProductListingSearch> createState() => _ProductListingSearchState();
}

class _ProductListingSearchState extends State<ProductListingSearch> {
  late final TextEditingController _ctrl = TextEditingController(text: widget.initialText);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.fieldBorder.withValues(alpha: 0.8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(width: 16.w),
            Icon(Icons.search_rounded, color: AppColors.greyText, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: TextField(
                controller: _ctrl,
                textInputAction: TextInputAction.search,
                onSubmitted: widget.onSubmitted,
                decoration: InputDecoration(
                  hintText: 'Search in this list...',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    color: AppColors.greyText.withValues(alpha: 0.6),
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(width: 16.w),
          ],
        ),
      ),
    );
  }
}
