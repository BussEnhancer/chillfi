import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/categories/sub_categories_screen.dart';
import 'package:chillfi/features/categories/widgets/category_banner_widget.dart';
import 'package:chillfi/features/categories/widgets/category_grid_card.dart';
import 'package:chillfi/features/categories/widgets/category_sidebar_item.dart';
import 'package:chillfi/features/home/widgets/bottom_nav.dart';
import 'package:chillfi/features/home/widgets/home_header.dart';
import 'package:chillfi/features/home/widgets/home_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  int _selectedCategoryIndex = 0;

  final List<Map<String, dynamic>> _sidebarCategories = [
    {'title': 'All Categories', 'icon': Icons.grid_view_rounded},
    {'title': 'Mobiles', 'icon': Icons.smartphone_rounded},
    {'title': 'Laptops', 'icon': Icons.laptop_rounded},
    {'title': 'Audio', 'icon': Icons.headphones_rounded},
    {'title': 'Wearables', 'icon': Icons.watch_rounded},
    {'title': 'Cameras', 'icon': Icons.camera_alt_rounded},
    {'title': 'Appliances', 'icon': Icons.kitchen_rounded},
    {'title': 'Gaming', 'icon': Icons.sports_esports_rounded},
    {'title': 'Beauty', 'icon': Icons.face_rounded},
    {'title': 'Fashion', 'icon': Icons.checkroom_rounded},
  ];

  final List<Map<String, dynamic>> _gridCategories = [
    {'title': 'Mobiles & Tablets', 'items': '2,356 items', 'icon': Icons.smartphone_rounded},
    {'title': 'Laptops & Accessories', 'items': '1,245 items', 'icon': Icons.laptop_rounded},
    {'title': 'Audio', 'items': '1,876 items', 'icon': Icons.headphones_rounded},
    {'title': 'Wearables', 'items': '1,234 items', 'icon': Icons.watch_rounded},
    {'title': 'Cameras', 'items': '985 items', 'icon': Icons.camera_alt_rounded},
    {'title': 'Home Appliances', 'items': '1,567 items', 'icon': Icons.kitchen_rounded},
    {'title': 'TV & Entertainment', 'items': '843 items', 'icon': Icons.tv_rounded},
    {'title': 'Gaming', 'items': '1,342 items', 'icon': Icons.sports_esports_rounded},
    {'title': 'Beauty & Personal Care', 'items': '2,134 items', 'icon': Icons.face_rounded},
    {'title': 'Fashion', 'items': '3,245 items', 'icon': Icons.checkroom_rounded},
    {'title': 'Toys & Baby Products', 'items': '1,098 items', 'icon': Icons.child_care_rounded},
    {'title': 'Sports & Outdoors', 'items': '987 items', 'icon': Icons.sports_soccer_rounded},
    {'title': 'Automotive', 'items': '1,234 items', 'icon': Icons.directions_car_rounded},
    {'title': 'Books & Stationery', 'items': '1,543 items', 'icon': Icons.menu_book_rounded},
    {'title': 'Health & Nutrition', 'items': '876 items', 'icon': Icons.health_and_safety_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header (Reusing HomeHeader as it matches the design)
            const HomeHeader(),
            
            // Search Bar (Reusing HomeSearchBar)
            const HomeSearchBar(),

            Expanded(
              child: Row(
                children: [
                  // Left Sidebar
                  _buildSidebar(),

                  // Main Content
                  _buildMainContent(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 1),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 90.w,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        border: Border(right: BorderSide(color: AppColors.lightGrey.withOpacity(0.5))),
      ),
      child: ListView.builder(
        itemCount: _sidebarCategories.length,
        itemBuilder: (context, index) {
          return CategorySidebarItem(
            title: _sidebarCategories[index]['title'],
            icon: _sidebarCategories[index]['icon'],
            isSelected: _selectedCategoryIndex == index,
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildMainContent() {
    return Expanded(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Promo Banner
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
              itemCount: _gridCategories.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    if (_gridCategories[index]['title'] == 'Mobiles & Tablets') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SubCategoriesScreen()),
                      );
                    }
                  },
                  child: CategoryGridCard(
                    title: _gridCategories[index]['title'],
                    itemCount: _gridCategories[index]['items'],
                    icon: _gridCategories[index]['icon'],
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
