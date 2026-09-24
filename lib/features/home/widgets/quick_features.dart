import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/brands/brand_listing_screen.dart';
import 'package:chillfi/features/categories/categories_screen.dart';
import 'package:chillfi/features/offers/offers_products_screen.dart';
import 'package:chillfi/features/profile/help_support_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class QuickFeatureSection extends StatelessWidget {
  const QuickFeatureSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> features = [
      {
        'icon': Icons.delivery_dining_rounded,
        'label': 'Fast\nDelivery',
        'color': AppColors.secondaryPurple,
        'onTap': () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Free delivery on orders above ₹499!'),
            duration: Duration(seconds: 2),
          ),
        ),
      },
      {
        'icon': Icons.percent_rounded,
        'label': 'Best\nDeals',
        'color': AppColors.primaryOrange,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OffersProductsScreen())),
      },
      {
        'icon': Icons.verified_user_rounded,
        'label': '100%\nOriginal',
        'color': AppColors.secondaryPurple,
        'onTap': () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All products are 100% authentic & brand verified!'),
            duration: Duration(seconds: 2),
          ),
        ),
      },
      {
        'icon': Icons.workspace_premium_rounded,
        'label': 'Top\nBrands',
        'color': AppColors.primaryOrange,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BrandListingScreen())),
      },
      {
        'icon': Icons.headset_mic_rounded,
        'label': '24x7\nSupport',
        'color': AppColors.secondaryPurple,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen())),
      },
      {
        'icon': Icons.grid_view_rounded,
        'label': 'Categories',
        'color': AppColors.primaryOrange,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesScreen())),
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: features
            .map(
              (f) => GestureDetector(
                onTap: f['onTap'] as VoidCallback,
                child: Column(
                  children: [
                    Container(
                      width: 54.r,
                      height: 54.r,
                      decoration: BoxDecoration(
                        color: (f['color'] as Color).withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(f['icon'] as IconData, color: f['color'] as Color, size: 24.sp),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      f['label'] as String,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
