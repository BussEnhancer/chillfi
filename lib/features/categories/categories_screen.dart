import 'package:chillfi/core/widgets/app_error_dialog.dart';
import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/models/product_model.dart';
import 'package:chillfi/core/providers/product_provider.dart';
import 'package:chillfi/features/categories/widgets/category_banner_widget.dart';
import 'package:chillfi/features/categories/widgets/category_grid_card.dart';
import 'package:chillfi/features/categories/widgets/category_sidebar_item.dart';
import 'package:chillfi/features/home/widgets/bottom_nav.dart';
import 'package:chillfi/features/home/widgets/home_header.dart';
import 'package:chillfi/features/home/widgets/home_search_bar.dart';
import 'package:chillfi/features/product_listing/product_listing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  int _selectedCategoryIndex = 0;

  static IconData _iconForCategory(String name) {
    final n = name.toLowerCase();
    if (n.contains('smartphone') || n.contains('mobile') || n.contains('phone')) return Icons.smartphone_rounded;
    if (n.contains('laptop') || n.contains('computer')) return Icons.laptop_rounded;
    if (n.contains('audio') || n.contains('headphone') || n.contains('earphone')) return Icons.headphones_rounded;
    if (n.contains('wearable') || n.contains('watch')) return Icons.watch_rounded;
    if (n.contains('camera')) return Icons.camera_alt_rounded;
    if (n.contains('tv') || n.contains('television') || n.contains('entertainment')) return Icons.tv_rounded;
    if (n.contains('gaming') || n.contains('game')) return Icons.sports_esports_rounded;
    if (n.contains('appliance') || n.contains('kitchen')) return Icons.kitchen_rounded;
    if (n.contains('accessory') || n.contains('accessories')) return Icons.cable_rounded;
    if (n.contains('beauty') || n.contains('personal')) return Icons.face_rounded;
    if (n.contains('fashion') || n.contains('clothing')) return Icons.checkroom_rounded;
    if (n.contains('book') || n.contains('stationery')) return Icons.menu_book_rounded;
    if (n.contains('sport') || n.contains('outdoor')) return Icons.sports_soccer_rounded;
    if (n.contains('health') || n.contains('nutrition')) return Icons.health_and_safety_rounded;
    if (n.contains('toy') || n.contains('baby')) return Icons.child_care_rounded;
    if (n.contains('auto') || n.contains('car')) return Icons.directions_car_rounded;
    return Icons.category_rounded;
  }

  void _openCategory(BuildContext context, CategoryModel cat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductListingScreen(
          categoryId: cat.id,
          categoryName: cat.name,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<ProductProvider>();
      if (p.categories.isEmpty) p.loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const HomeHeader(),
            const HomeSearchBar(),
            Expanded(
              child: Consumer<ProductProvider>(
                builder: (context, pp, _) {
                  final cats = pp.categories.where((c) => c.isActive).toList();
                  if (cats.isEmpty) {
                    if (pp.categoriesState == LoadState.error) {
                      return Center(child: AppErrorState(onRetry: pp.loadCategories));
                    }
                    return const Center(child: CircularProgressIndicator());
                  }
                  return Row(
                    children: [
                      _buildSidebar(cats),
                      _buildMainContent(context, cats),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 1),
    );
  }

  Widget _buildSidebar(List<CategoryModel> cats) {
    return Container(
      width: 90.w,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        border: Border(right: BorderSide(color: AppColors.lightGrey.withValues(alpha: 0.5))),
      ),
      child: ListView.builder(
        itemCount: cats.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return CategorySidebarItem(
              title: 'All',
              icon: Icons.grid_view_rounded,
              isSelected: _selectedCategoryIndex == 0,
              onTap: () => setState(() => _selectedCategoryIndex = 0),
            );
          }
          final cat = cats[index - 1];
          return CategorySidebarItem(
            title: cat.name,
            icon: _iconForCategory(cat.name),
            isSelected: _selectedCategoryIndex == index,
            onTap: () {
              setState(() => _selectedCategoryIndex = index);
              _openCategory(context, cat);
            },
          );
        },
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, List<CategoryModel> cats) {
    return Expanded(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CategoryBannerWidget(),
            SizedBox(height: 24.h),
            Text(
              'Shop by Category',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
            SizedBox(height: 16.h),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.75,
                crossAxisSpacing: 10.w,
                mainAxisSpacing: 15.h,
              ),
              itemCount: cats.length,
              itemBuilder: (context, index) {
                final cat = cats[index];
                final count = cat.productCount > 0 ? '${cat.productCount} items' : 'Browse';
                return GestureDetector(
                  onTap: () => _openCategory(context, cat),
                  child: CategoryGridCard(
                    title: cat.name,
                    itemCount: count,
                    icon: _iconForCategory(cat.name),
                  ),
                );
              },
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
