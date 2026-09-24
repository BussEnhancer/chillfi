import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/product_listing/product_listing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class HeroBannerSlider extends StatefulWidget {
  final List<dynamic> banners;

  const HeroBannerSlider({super.key, this.banners = const []});

  @override
  State<HeroBannerSlider> createState() => _HeroBannerSliderState();
}

class _HeroBannerSliderState extends State<HeroBannerSlider> {
  final _controller = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
      child: Column(
        children: [
          SizedBox(
            height: 180.h,
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.banners.length,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemBuilder: (context, index) => _buildBanner(context, widget.banners[index] as Map),
            ),
          ),
          if (widget.banners.length > 1) ...[
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.banners.length, (index) => Container(
                width: index == _currentIndex ? 20.w : 6.w,
                height: 6.h,
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                decoration: BoxDecoration(
                  color: index == _currentIndex ? AppColors.secondaryPurple : AppColors.secondaryPurple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              )),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBanner(BuildContext context, Map banner) {
    final title = banner['title'] as String? ?? '';
    final subtitle = banner['subtitle'] as String?;
    final imageUrl = banner['image_url'] as String?;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProductListingScreen()),
      ),
      child: Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFBF4FF),
            AppColors.secondaryPurple.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.secondaryPurple.withValues(alpha: 0.1)),
      ),
      child: Stack(
        children: [
          Padding(
            // Reserve space for the image positioned on the right (110.w) so the
            // FittedBox below scales text to fit next to it, instead of laying out
            // at the full banner width and then being covered by the image.
            padding: EdgeInsets.only(left: 20.r, top: 20.r, bottom: 20.r, right: 110.w + 20.r),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkText,
                      height: 1.2,
                    ),
                  ),
                  if (subtitle != null && subtitle.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        color: AppColors.greyText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      gradient: AppColors.buttonGradient,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryOrange.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Shop Now',
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14.sp),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (imageUrl != null && imageUrl.isNotEmpty)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 110.w,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(24.r),
                  bottomRight: Radius.circular(24.r),
                ),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            ),
        ],
      ),
      ),
    );
  }
}
