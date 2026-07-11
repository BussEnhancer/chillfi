import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/services/api_service.dart';
import 'package:chillfi/features/brands/widgets/brand_banner.dart';
import 'package:chillfi/features/brands/widgets/brand_card.dart';
import 'package:chillfi/features/brands/widgets/brand_chip.dart';
import 'package:chillfi/features/brands/widgets/brand_header.dart';
import 'package:chillfi/features/brands/widgets/bottom_offer_widget.dart';
import 'package:chillfi/features/home/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class BrandListingScreen extends StatefulWidget {
  const BrandListingScreen({super.key});

  @override
  State<BrandListingScreen> createState() => _BrandListingScreenState();
}

class _Brand {
  final String id;
  final String name;
  final String? logoUrl;
  final int productCount;
  _Brand({required this.id, required this.name, this.logoUrl, required this.productCount});
  factory _Brand.fromJson(Map<String, dynamic> j) => _Brand(
        id: j['id'] ?? '',
        name: j['name'] ?? '',
        logoUrl: j['logo_url'],
        productCount: int.tryParse(j['product_count'].toString()) ?? 0,
      );
}

class _BrandListingScreenState extends State<BrandListingScreen> {
  int _selectedChipIndex = 0;
  List<_Brand> _brands = [];
  bool _loading = true;
  String? _error;
  String _search = '';

  final List<Map<String, dynamic>> _filterChips = [
    {'label': 'All Brands', 'icon': Icons.grid_view_rounded},
    {'label': 'Popular', 'icon': Icons.star_rounded},
    {'label': 'Electronics', 'icon': Icons.smartphone_rounded},
    {'label': 'Fashion', 'icon': Icons.checkroom_rounded},
    {'label': 'Home', 'icon': Icons.home_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiService().get('/brands');
      final list = (res.data['data']['brands'] as List?) ?? [];
      setState(() {
        _brands = list.map((b) => _Brand.fromJson(b)).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = 'Failed to load brands'; _loading = false; });
    }
  }

  List<_Brand> get _filtered {
    if (_search.isEmpty) return _brands;
    return _brands.where((b) => b.name.toLowerCase().contains(_search.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const BrandHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    SizedBox(height: 10.h),
                    _buildSearchBar(),
                    SizedBox(height: 20.h),
                    _buildFilterChips(),
                    SizedBox(height: 20.h),
                    const BrandBanner(),
                    SizedBox(height: 24.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.poppins(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkText,
                            ),
                            children: [
                              const TextSpan(text: "All Brands "),
                              TextSpan(
                                text: "(${_filtered.length})",
                                style: TextStyle(
                                  color: AppColors.greyText,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _buildBrandsGrid(),
                    SizedBox(height: 24.h),
                    const BottomOfferWidget(),
                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 1),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 50.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.r),
        border: Border.all(color: AppColors.fieldBorder.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: AppColors.greyText, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: "Search brands...",
                hintStyle: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.greyText.withOpacity(0.6)),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(
          _filterChips.length,
          (index) => Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: BrandChip(
              label: _filterChips[index]['label'],
              icon: _filterChips[index]['icon'],
              isSelected: _selectedChipIndex == index,
              onTap: () => setState(() => _selectedChipIndex = index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandsGrid() {
    if (_loading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: const Center(child: CircularProgressIndicator(color: AppColors.secondaryPurple)),
      );
    }
    if (_error != null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Column(
          children: [
            Icon(Icons.error_outline_rounded, size: 36.sp, color: AppColors.greyText),
            SizedBox(height: 8.h),
            Text(_error!, style: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.greyText)),
            SizedBox(height: 12.h),
            TextButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_filtered.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Text('No brands found', style: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.greyText)),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 15.h,
      ),
      itemCount: _filtered.length,
      itemBuilder: (context, index) {
        final b = _filtered[index];
        return BrandCard(
          name: b.name,
          logoUrl: b.logoUrl,
          productCount: '${b.productCount} Products',
        );
      },
    );
  }
}
