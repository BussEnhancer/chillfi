import 'dart:async';
import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/models/product_model.dart';
import 'package:chillfi/core/providers/product_provider.dart';
import 'package:chillfi/features/product_details/product_details_screen.dart';
import 'package:chillfi/features/search/voice_search_screen.dart';
import 'package:chillfi/features/search/widgets/help_banner_widget.dart';
import 'package:chillfi/features/search/widgets/trending_chip_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  bool _showResults = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadTrendingSearches();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.trim().isEmpty) return;
    setState(() => _showResults = true);
    context.read<ProductProvider>().searchProducts(query.trim());
  }

  void _onChanged(String query) {
    if (query.isEmpty) {
      _debounce?.cancel();
      setState(() => _showResults = false);
      context.read<ProductProvider>().clearSearch();
      return;
    }
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) context.read<ProductProvider>().loadSuggestions(query);
    });
  }

  Future<void> _openVoiceSearch() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const VoiceSearchScreen()),
    );
    if (result != null && result.isNotEmpty && mounted) {
      _ctrl.text = result;
      _onSearch(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Search bar header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back_rounded, size: 22.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      autofocus: true,
                      onChanged: _onChanged,
                      onSubmitted: _onSearch,
                      decoration: InputDecoration(
                        hintText: 'Search products, brands...',
                        hintStyle: GoogleFonts.poppins(fontSize: 14.sp, color: AppColors.greyText),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_ctrl.text.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _ctrl.clear();
                                  _onChanged('');
                                },
                                child: Icon(Icons.close_rounded, size: 18.sp, color: AppColors.greyText),
                              ),
                            GestureDetector(
                              onTap: _openVoiceSearch,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.w),
                                child: Icon(Icons.mic_rounded, size: 20.sp, color: AppColors.secondaryPurple),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  GestureDetector(
                    onTap: () => _onSearch(_ctrl.text),
                    child: Text('Search',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryOrange,
                        )),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            Expanded(
              child: _showResults ? _buildResults(provider) : _buildDiscovery(provider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(ProductProvider provider) {
    if (provider.searchState == LoadState.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 60.sp, color: Colors.grey.shade300),
            SizedBox(height: 12.h),
            Text('No results found', style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.grey)),
            SizedBox(height: 6.h),
            Text('Try different keywords', style: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.greyText)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: provider.searchResults.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final p = provider.searchResults[i];
        return _ProductSearchTile(product: p);
      },
    );
  }

  Widget _buildDiscovery(ProductProvider provider) {
    final trending = provider.trendingSearches;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.h),

          // Suggestions while typing
          if (provider.suggestions.isNotEmpty) ...[
            _buildSectionHeader('Suggestions'),
            SizedBox(height: 8.h),
            ...provider.suggestions.map((s) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.search_rounded, color: AppColors.greyText, size: 18.sp),
                  title: Text(s, style: GoogleFonts.poppins(fontSize: 14.sp)),
                  onTap: () {
                    _ctrl.text = s;
                    _onSearch(s);
                  },
                )),
            SizedBox(height: 20.h),
          ],

          // Trending Searches
          if (trending.isNotEmpty) ...[
            _buildSectionHeader('Trending Searches'),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 10.h,
              children: trending.map((t) => GestureDetector(
                onTap: () { _ctrl.text = t; _onSearch(t); },
                child: TrendingChipWidget(label: t),
              )).toList(),
            ),
            SizedBox(height: 30.h),
          ],

          const HelpBannerWidget(),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {String? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
        if (trailing != null)
          Text(trailing, style: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.primaryOrange, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _ProductSearchTile extends StatelessWidget {
  final ProductModel product;
  const _ProductSearchTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 6.h),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: product.primaryImage != null
            ? Image.network(product.primaryImage!, width: 50.w, height: 50.w, fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _placeholder())
            : _placeholder(),
      ),
      title: Text(product.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600)),
      subtitle: Text('₹${product.price.toStringAsFixed(0)}',
          style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.primaryOrange)),
      trailing: product.hasDiscount
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(6.r)),
              child: Text('${product.discountPct}% OFF',
                  style: GoogleFonts.poppins(fontSize: 10.sp, fontWeight: FontWeight.w700, color: Colors.green)),
            )
          : null,
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => ProductDetailsScreen(productId: product.id))),
    );
  }

  Widget _placeholder() => Container(
      width: 50, height: 50, color: Colors.grey.shade100,
      child: Icon(Icons.image_outlined, color: Colors.grey.shade400));
}
