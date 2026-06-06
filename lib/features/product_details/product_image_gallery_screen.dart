import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/product_details/widgets/gallery_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductImageGalleryScreen extends StatefulWidget {
  const ProductImageGalleryScreen({super.key});

  @override
  State<ProductImageGalleryScreen> createState() => _ProductImageGalleryScreenState();
}

class _ProductImageGalleryScreenState extends State<ProductImageGalleryScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  final int _totalImages = 6;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            GalleryHeader(currentIndex: _currentIndex, totalImages: _totalImages),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Main Image View
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) => setState(() => _currentIndex = index),
                    itemCount: _totalImages,
                    itemBuilder: (context, index) {
                      return Center(
                        child: Container(
                          width: 0.9.sw,
                          height: 0.5.sh,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9F5FF).withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(24.r),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondaryPurple.withOpacity(0.05),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.smartphone_rounded,
                            size: 300.sp,
                            color: AppColors.primaryOrange.withOpacity(0.8),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // Left Arrow
                  if (_currentIndex > 0)
                    Positioned(
                      left: 16.w,
                      child: _buildNavButton(Icons.chevron_left_rounded, () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }),
                    ),
                  
                  // Right Arrow
                  if (_currentIndex < _totalImages - 1)
                    Positioned(
                      right: 16.w,
                      child: _buildNavButton(Icons.chevron_right_rounded, () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }),
                    ),
                    
                  // Zoom Button
                  Positioned(
                    bottom: 20.h,
                    right: 30.w,
                    child: Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Icon(Icons.zoom_in_rounded, color: AppColors.secondaryPurple, size: 24.sp),
                    ),
                  ),
                ],
              ),
            ),
            
            // Thumbnail Strip
            _buildThumbnailStrip(),
            
            SizedBox(height: 24.h),
            
            // Feature Highlights
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: const GalleryFeatureStrip(),
            ),
            
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.secondaryPurple, size: 28.sp),
      ),
    );
  }

  Widget _buildThumbnailStrip() {
    return SizedBox(
      height: 70.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: _totalImages,
        itemBuilder: (context, index) {
          bool isSelected = _currentIndex == index;
          return GestureDetector(
            onTap: () {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: 12.w),
              width: 65.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isSelected ? AppColors.secondaryPurple : AppColors.lightGrey.withOpacity(0.5),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.secondaryPurple.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
              child: Icon(Icons.smartphone_rounded, size: 40.sp, color: Colors.grey[200]),
            ),
          );
        },
      ),
    );
  }
}
