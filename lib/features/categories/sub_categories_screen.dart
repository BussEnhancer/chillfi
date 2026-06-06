import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/brands/brand_listing_screen.dart';
import 'package:chillfi/features/categories/widgets/best_selling_product.dart';
import 'package:chillfi/features/categories/widgets/brand_item.dart';
import 'package:chillfi/features/categories/widgets/category_grid_card.dart';
import 'package:chillfi/features/categories/widgets/category_sidebar_item.dart';
import 'package:chillfi/features/categories/widgets/feature_highlights.dart';
import 'package:chillfi/features/categories/widgets/sub_categories_header.dart';
import 'package:chillfi/features/categories/widgets/sub_category_banner.dart';
import 'package:chillfi/features/home/widgets/bottom_nav.dart';
import 'package:chillfi/features/product_listing/product_listing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class SubCategoriesScreen extends StatefulWidget {
  const SubCategoriesScreen({super.key});

  @override
  State<SubCategoriesScreen> createState() => _SubCategoriesScreenState();
}

class _SubCategoriesScreenState extends State<SubCategoriesScreen> {
  int _selectedSidebarIndex = 0;

  final List<Map<String, dynamic>> _sidebarItems = [
    {'title': 'All Mobiles', 'icon': Icons.grid_view_rounded},
    {'title': 'Smartphones', 'icon': Icons.smartphone_rounded},
    {'title': 'Feature Phones', 'icon': Icons.phone_android_rounded},
    {'title': 'Tablets', 'icon': Icons.tablet_rounded},
    {'title': 'Phablets', 'icon': Icons.stay_current_portrait_rounded},
    {'title': 'Refurbished', 'icon': Icons.restart_alt_rounded, 'isNew': true},
    {'title': 'Accessories', 'icon': Icons.headset_rounded, 'hasArrow': true},
  ];

  final List<Map<String, dynamic>> _subCategories = [
    {'title': 'All Smartphones', 'items': '1,234 items', 'icon': Icons.smartphone_rounded},
    {'title': 'Android Phones', 'items': '843 items', 'icon': Icons.android_rounded},
    {'title': 'iOS iPhone', 'items': '124 items', 'icon': Icons.apple_rounded},
    {'title': '5G Smartphones', 'items': '567 items', 'icon': Icons.five_g_rounded},
    {'title': '4G Smartphones', 'items': '654 items', 'icon': Icons.four_g_plus_mobiledata_rounded},
    {'title': 'Gaming Phones', 'items': '234 items', 'icon': Icons.sports_esports_rounded},
    {'title': 'Budget Phones', 'items': 'Under ₹15k', 'icon': Icons.payments_rounded},
    {'title': 'Mid Range', 'items': '₹15k - ₹30k', 'icon': Icons.account_balance_wallet_rounded},
    {'title': 'Premium', 'items': 'Above ₹30k', 'icon': Icons.diamond_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SubCategoriesHeader(
              title: 'Mobiles & Tablets',
              subtitle: '2,356 Products',
            ),
            Expanded(
              child: Row(
                children: [
                  // Sidebar
                  _buildSidebar(),
                  
                  // Main Content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SubCategoryBanner(),
                          SizedBox(height: 24.h),
                          
                          _buildSectionTitle('Sub Categories'),
                          SizedBox(height: 16.h),
                          _buildSubCategoryGrid(),
                          
                          SizedBox(height: 30.h),
                          _buildSectionTitle(
                            'Popular Brands',
                            showViewAll: true,
                            onViewAll: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const BrandListingScreen()),
                              );
                            },
                          ),
                          SizedBox(height: 16.h),
                          _buildBrandsList(),
                          
                          SizedBox(height: 30.h),
                          _buildSectionTitle('Best Selling Phones', showViewAll: true),
                          SizedBox(height: 16.h),
                          _buildBestSellingList(),
                          
                          SizedBox(height: 30.h),
                          const FeatureHighlightsRow(),
                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ),
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
        itemCount: _sidebarItems.length,
        itemBuilder: (context, index) {
          final item = _sidebarItems[index];
          return CategorySidebarItem(
            title: item['title'],
            icon: item['icon'],
            isSelected: _selectedSidebarIndex == index,
            onTap: () => setState(() => _selectedSidebarIndex = index),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool showViewAll = false, VoidCallback? onViewAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.darkText,
          ),
        ),
        if (showViewAll)
          GestureDetector(
            onTap: onViewAll,
            child: Text(
              'View All >',
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryPurple,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSubCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.8,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 12.h,
      ),
      itemCount: _subCategories.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProductListingScreen()),
            );
          },
          child: CategoryGridCard(
            title: _subCategories[index]['title'],
            itemCount: _subCategories[index]['items'],
            icon: _subCategories[index]['icon'],
          ),
        );
      },
    );
  }

  Widget _buildBrandsList() {
    final brands = [
      {'name': 'Apple', 'icon': Icons.apple_rounded},
      {'name': 'Samsung', 'icon': Icons.smartphone_rounded},
      {'name': 'OnePlus', 'icon': Icons.phone_android_rounded},
      {'name': 'Xiaomi', 'icon': Icons.phone_iphone_rounded},
      {'name': 'Realme', 'icon': Icons.mobile_friendly_rounded},
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: brands.map((b) => BrandCircleItem(name: b['name'] as String, icon: b['icon'] as IconData)).toList(),
      ),
    );
  }

  Widget _buildBestSellingList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: const [
          BestSellingProductCard(
            title: 'iPhone 15',
            variant: 'Pink | 128GB',
            price: '69,999',
            oldPrice: '79,900',
            discount: '12%',
            rating: 4.8,
          ),
          BestSellingProductCard(
            title: 'Galaxy S24',
            variant: 'Black | 256GB',
            price: '74,999',
            oldPrice: '87,900',
            discount: '15%',
            rating: 4.7,
          ),
          BestSellingProductCard(
            title: 'OnePlus 12R',
            variant: 'Blue | 128GB',
            price: '39,999',
            oldPrice: '45,900',
            discount: '13%',
            rating: 4.6,
          ),
        ],
      ),
    );
  }
}
