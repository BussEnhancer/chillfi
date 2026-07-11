import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/models/product_model.dart';
import 'package:chillfi/core/services/product_service.dart';
import 'package:chillfi/features/product_details/product_details_screen.dart';
import 'package:chillfi/features/product_details/widgets/similar_product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class SimilarProductsSection extends StatefulWidget {
  final String title;
  final String subtitle;
  final String? categoryId;
  final String? excludeProductId;

  const SimilarProductsSection({
    super.key,
    this.title = "Similar Products",
    this.subtitle = "You may also like these products",
    this.categoryId,
    this.excludeProductId,
  });

  @override
  State<SimilarProductsSection> createState() => _SimilarProductsSectionState();
}

class _SimilarProductsSectionState extends State<SimilarProductsSection> {
  final _service = ProductService();
  List<ProductModel> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(SimilarProductsSection old) {
    super.didUpdateWidget(old);
    if (old.categoryId != widget.categoryId) _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    List<ProductModel> result = [];
    if (widget.categoryId != null) {
      result = await _service.getCategoryProducts(widget.categoryId!);
    } else {
      result = await _service.getRecommended();
    }
    result = result.where((p) => p.id != widget.excludeProductId).take(8).toList();
    if (!mounted) return;
    setState(() { _products = result; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loading && _products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  Text(
                    widget.subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: AppColors.greyText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: 16.h),

        SizedBox(
          height: 310.h,
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(left: 20.w),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final p = _products[index];
                    return SimilarProductCard(
                      productId: p.id,
                      title: p.name,
                      variant: p.brandName ?? p.categoryName ?? '',
                      price: p.price.toStringAsFixed(0),
                      oldPrice: (p.oldPrice ?? p.price).toStringAsFixed(0),
                      discount: '${p.discountPct}%',
                      savings: ((p.oldPrice ?? p.price) - p.price).toStringAsFixed(0),
                      rating: p.rating,
                      reviews: p.reviewCount > 999 ? '${(p.reviewCount / 1000).toStringAsFixed(1)}k' : '${p.reviewCount}',
                      imageUrl: p.primaryImage,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ProductDetailsScreen(productId: p.id)),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
