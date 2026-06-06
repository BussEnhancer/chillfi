import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/product_details/product_image_gallery_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductGallery extends StatefulWidget {
  const ProductGallery({super.key});

  @override
  State<ProductGallery> createState() => _ProductGalleryState();
}

class _ProductGalleryState extends State<ProductGallery> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProductImageGalleryScreen()),
            );
          },
          child: SizedBox(
            height: 380.h,
            child: Stack(
              children: [
                // Background Glow
                Center(
                  child: Container(
                    width: 280.r,
                    height: 280.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.secondaryPurple.withOpacity(0.08),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Thumbnail Selector (Left)
                Positioned(
                  left: 20.w,
                  top: 20.h,
                  bottom: 20.h,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) => _buildThumbnail(index)),
                  ),
                ),
                
                // Main Image
                Center(
                  child: Hero(
                    tag: 'product_image',
                    child: Icon(
                      Icons.smartphone_rounded,
                      size: 280.sp,
                      color: AppColors.primaryOrange.withOpacity(0.9),
                    ),
                  ),
                ),
                
                // 3D View Button
                Positioned(
                  bottom: 20.h,
                  right: 20.w,
                  child: Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(Icons.view_in_ar_rounded, color: AppColors.secondaryPurple, size: 24.sp),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Carousel Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            5,
            (index) => Container(
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              width: _selectedIndex == index ? 20.w : 6.w,
              height: 6.h,
              decoration: BoxDecoration(
                color: _selectedIndex == index ? AppColors.secondaryPurple : AppColors.lightGrey,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnail(int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.h),
        width: 50.r,
        height: 50.r,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected ? AppColors.secondaryPurple : AppColors.lightGrey.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 5,
            ),
          ],
        ),
        child: Icon(Icons.smartphone_rounded, size: 30.sp, color: Colors.grey[300]),
      ),
    );
  }
}
