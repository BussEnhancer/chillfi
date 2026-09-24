import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/models/product_model.dart';
import 'package:chillfi/core/providers/product_provider.dart';
import 'package:chillfi/features/categories/categories_screen.dart';
import 'package:chillfi/features/product_listing/product_listing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  static IconData _iconFor(String name) {
    final n = name.toLowerCase();
    if (n.contains('mobile') || n.contains('phone') || n.contains('smartphone')) return Icons.smartphone_rounded;
    if (n.contains('laptop') || n.contains('computer')) return Icons.laptop_mac_rounded;
    if (n.contains('audio') || n.contains('headphone') || n.contains('earphone') || n.contains('earbuds')) return Icons.headphones_rounded;
    if (n.contains('wear') || n.contains('watch')) return Icons.watch_rounded;
    if (n.contains('camera')) return Icons.camera_alt_rounded;
    if (n.contains('tv') || n.contains('television')) return Icons.tv_rounded;
    if (n.contains('appliance') || n.contains('kitchen')) return Icons.kitchen_rounded;
    if (n.contains('gaming') || n.contains('game')) return Icons.sports_esports_rounded;
    if (n.contains('tablet')) return Icons.tablet_rounded;
    return Icons.devices_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<ProductProvider>().home.categories;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shop by Category',
                style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.darkText),
              ),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesScreen())),
                child: Text(
                  'View All >',
                  style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.secondaryPurple),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 15.h),
        SizedBox(
          height: 100.h,
          child: categories.isEmpty
              ? _buildSkeleton()
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  physics: const BouncingScrollPhysics(),
                  itemCount: categories.length,
                  itemBuilder: (context, index) => _buildItem(context, categories[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildItem(BuildContext context, CategoryModel cat) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductListingScreen(categoryId: cat.id, categoryName: cat.name),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: Column(
          children: [
            Container(
              width: 70.w,
              height: 70.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.fieldBorder.withValues(alpha: 0.5)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Center(child: Icon(_iconFor(cat.name), color: AppColors.darkText.withValues(alpha: 0.8), size: 30.sp)),
            ),
            SizedBox(height: 8.h),
            Text(
              cat.name.length > 10 ? '${cat.name.substring(0, 9)}…' : cat.name,
              style: GoogleFonts.poppins(fontSize: 10.sp, fontWeight: FontWeight.w500, color: AppColors.greyText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      itemCount: 6,
      itemBuilder: (_, _) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: Column(
          children: [
            Container(
              width: 70.w,
              height: 70.h,
              decoration: BoxDecoration(
                color: AppColors.lightBackground,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            SizedBox(height: 8.h),
            Container(width: 50.w, height: 10.h, decoration: BoxDecoration(color: AppColors.lightBackground, borderRadius: BorderRadius.circular(4.r))),
          ],
        ),
      ),
    );
  }
}
