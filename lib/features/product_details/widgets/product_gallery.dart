import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/providers/product_provider.dart';
import 'package:chillfi/features/product_details/product_image_gallery_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ProductGallery extends StatefulWidget {
  const ProductGallery({super.key});

  @override
  State<ProductGallery> createState() => _ProductGalleryState();
}

class _ProductGalleryState extends State<ProductGallery> {
  int _selectedIndex = 0;
  final Set<int> _failedImages = {};

  void _onImageError(int index) {
    // Auto-advance to next non-failed image when the current one 404s
    if (!_failedImages.contains(index)) {
      setState(() {
        _failedImages.add(index);
        // Find next working image
        final allImages = context.read<ProductProvider>().selectedProduct?.images ?? [];
        for (int i = 0; i < allImages.length; i++) {
          if (!_failedImages.contains(i)) {
            _selectedIndex = i;
            break;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = context.watch<ProductProvider>().selectedProduct;
    final images = product?.images ?? [];
    final primaryImage = product?.primaryImage;

    // Build full image list: images from array, or fall back to primaryImage
    final List<String> allImages = images.isNotEmpty
        ? images
        : (primaryImage != null ? [primaryImage] : []);

    final currentImage = allImages.isNotEmpty
        ? allImages[_selectedIndex.clamp(0, allImages.length - 1)]
        : null;

    final thumbnailCount = allImages.length.clamp(1, 4);

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
                          AppColors.secondaryPurple.withValues(alpha: 0.08),
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
                    children: List.generate(
                      thumbnailCount,
                      (index) => _buildThumbnail(index, allImages),
                    ),
                  ),
                ),

                // Main Image
                Center(
                  child: Hero(
                    tag: 'product_image',
                    child: currentImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16.r),
                            child: Image.network(
                              currentImage,
                              width: 260.w,
                              height: 260.h,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) {
                                WidgetsBinding.instance.addPostFrameCallback(
                                  (_) => _onImageError(_selectedIndex.clamp(0, allImages.length - 1)),
                                );
                                return Icon(
                                  Icons.image_not_supported_rounded,
                                  size: 120.sp,
                                  color: AppColors.primaryOrange.withValues(alpha: 0.4),
                                );
                              },
                            ),
                          )
                        : Icon(
                            Icons.smartphone_rounded,
                            size: 280.sp,
                            color: AppColors.primaryOrange.withValues(alpha: 0.9),
                          ),
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
            thumbnailCount,
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

  Widget _buildThumbnail(int index, List<String> images) {
    final bool isSelected = _selectedIndex == index;
    final String? url = index < images.length ? images[index] : null;

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
            color: isSelected ? AppColors.secondaryPurple : AppColors.lightGrey.withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 5),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9.r),
          child: url != null
              ? Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Icon(Icons.image_not_supported_rounded, size: 24.sp, color: Colors.grey[300]),
                )
              : Icon(Icons.smartphone_rounded, size: 30.sp, color: Colors.grey[300]),
        ),
      ),
    );
  }
}
