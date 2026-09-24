import 'package:share_plus/share_plus.dart';
import 'package:chillfi/core/widgets/cart_feedback.dart';
import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/providers/cart_provider.dart';
import 'package:chillfi/core/providers/product_provider.dart';
import 'package:chillfi/core/providers/wishlist_provider.dart';
import 'package:chillfi/core/services/api_service.dart';
import 'package:chillfi/features/cart/cart_screen.dart';
import 'package:chillfi/features/categories/widgets/feature_highlights.dart';
import 'package:chillfi/features/product_details/product_reviews_screen.dart';
import 'package:chillfi/features/product_details/widgets/product_gallery.dart';
import 'package:chillfi/features/product_details/widgets/product_highlight_item.dart';
import 'package:chillfi/features/product_details/widgets/product_offer_card.dart';
import 'package:chillfi/features/product_details/widgets/similar_products_section.dart';
import 'package:chillfi/core/widgets/app_error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String? productId;
  const ProductDetailsScreen({super.key, this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ProductProvider>().loadProduct(widget.productId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.darkText, size: 24.sp),
        ),
        actions: [
          Consumer<WishlistProvider>(builder: (context, wp, _) {
            final productId = widget.productId;
            final wishlisted = productId != null && wp.isWishlisted(productId);
            return IconButton(
              onPressed: productId == null ? null : () => wp.toggleWishlist(productId),
              icon: Icon(wishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: wishlisted ? Colors.red : AppColors.darkText, size: 24.sp),
            );
          }),
          Consumer<CartProvider>(builder: (context, cart, _) {
            return Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
                  icon: Icon(Icons.shopping_cart_outlined, color: AppColors.darkText, size: 24.sp),
                ),
                if (cart.cartCount > 0)
                  Positioned(
                    right: 8.w,
                    top: 8.h,
                    child: Container(
                      padding: EdgeInsets.all(4.r),
                      decoration: const BoxDecoration(
                        color: AppColors.secondaryPurple,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${cart.cartCount}',
                        style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            );
          }),
          SizedBox(width: 8.w),
        ],
      ),
      // Placed via the Scaffold's own bottom slot (not stacked on top of the body) so
      // ScaffoldMessenger's SnackBars are correctly inset above it instead of being
      // rendered underneath it, invisible to the user.
      bottomNavigationBar: Consumer<ProductProvider>(
        builder: (context, pp, _) {
          if (pp.detailState == LoadState.loading || pp.selectedProduct == null) {
            return const SizedBox.shrink();
          }
          return _buildBottomActionBar(inStock: pp.selectedProduct!.inStock);
        },
      ),
      body: Consumer<ProductProvider>(
        builder: (context, pp, _) {
          if (pp.detailState == LoadState.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          final product = pp.selectedProduct;
          if (product == null) {
            return Center(
              child: pp.detailGone
                  ? AppErrorState(
                      offline: false,
                      title: 'Product unavailable',
                      message: 'This product is no longer available. It may have been discontinued.',
                    )
                  : AppErrorState(
                      offline: pp.detailError == AppError.noInternet,
                      message: pp.detailError ?? "This product couldn't be loaded. Please try again.",
                      onRetry: widget.productId == null ? null : () => pp.loadProduct(widget.productId!),
                    ),
            );
          }
          final savings = product.oldPrice != null ? (product.oldPrice! - product.price) : 0.0;
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ProductGallery(),

                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badges
                      Row(
                        children: [
                          if (product.hasDiscount) _buildBadge("-${product.discountPct}% OFF", AppColors.secondaryPurple),
                          if (product.hasDiscount) SizedBox(width: 8.w),
                          if (product.isFeatured) _buildBadge("Featured", Colors.orange),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // Title & Share
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: GoogleFonts.poppins(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkText,
                              ),
                            ),
                          ),
                          Semantics(
                            button: true,
                            label: 'Share product',
                            child: GestureDetector(
                              onTap: () => Share.share('Check out ${product.name} on ChillFi: https://chillfi.in/product/${product.id}'),
                              child: Container(
                                padding: EdgeInsets.all(10.r),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF8F8F8),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.share_outlined, size: 20.sp, color: AppColors.darkText),
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (product.brandName != null)
                        Text(
                          product.brandName!,
                          style: GoogleFonts.poppins(fontSize: 14.sp, color: AppColors.greyText),
                        ),
                      SizedBox(height: 8.h),

                      // Ratings
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ProductReviewsScreen(productId: product.id, productName: product.name)),
                          );
                        },
                        child: Row(
                          children: [
                            Icon(Icons.star_rounded, color: Colors.orange, size: 18.sp),
                            SizedBox(width: 4.w),
                            Text(
                              "${product.rating.toStringAsFixed(1)} (${product.reviewCount} reviews)",
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkText,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              product.inStock ? "In Stock (${product.stock})" : "Out of Stock",
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                color: product.inStock ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // Pricing
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "₹${product.price.toStringAsFixed(0)}",
                            style: GoogleFonts.poppins(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkText,
                            ),
                          ),
                          if (product.oldPrice != null) ...[
                            SizedBox(width: 12.w),
                            Text(
                              "₹${product.oldPrice!.toStringAsFixed(0)}",
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                color: AppColors.greyText,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              "${product.discountPct}% OFF",
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 12.h),

                      // Savings Banner
                      if (savings > 0)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.verified_rounded, color: Colors.green, size: 20.sp),
                              SizedBox(width: 8.w),
                              Text(
                                "You Save ₹${savings.toStringAsFixed(0)} on this product",
                                style: GoogleFonts.poppins(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green[800],
                                ),
                              ),
                            ],
                          ),
                        ),

                      SizedBox(height: 30.h),

                      // Offer Sections
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: const [
                            ProductOfferCard(
                              icon: Icons.lock_rounded,
                              title: "Secure Payment",
                              subtitle: "UPI, cards & netbanking via PhonePe",
                            ),
                            ProductOfferCard(
                              icon: Icons.payments_rounded,
                              title: "Pay on Delivery",
                              subtitle: "On eligible pincodes at checkout",
                            ),
                            ProductOfferCard(
                              icon: Icons.assignment_return_rounded,
                              title: "Easy Returns",
                              subtitle: "As per our return policy",
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 30.h),

                      // Description
                      if (product.description != null && product.description!.isNotEmpty) ...[
                        _buildSectionHeader("Product Description"),
                        SizedBox(height: 8.h),
                        Text(
                          product.description!,
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            color: AppColors.greyText,
                            height: 1.6,
                          ),
                        ),
                        SizedBox(height: 30.h),
                      ],

                      // Product Highlights (category + brand info)
                      _buildSectionHeader("Product Highlights"),
                      SizedBox(height: 16.h),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            if (product.categoryName != null)
                              ProductHighlightItem(
                                icon: Icons.category_rounded,
                                title: product.categoryName!,
                                subtitle: "Category",
                              ),
                            if (product.brandName != null)
                              ProductHighlightItem(
                                icon: Icons.business_rounded,
                                title: product.brandName!,
                                subtitle: "Brand",
                              ),
                            ProductHighlightItem(
                              icon: Icons.star_rounded,
                              title: product.rating.toStringAsFixed(1),
                              subtitle: "${product.reviewCount} Reviews",
                            ),
                            ProductHighlightItem(
                              icon: Icons.inventory_2_rounded,
                              title: "${product.stock}",
                              subtitle: "Units Available",
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 30.h),

                      // Inline Reviews Preview
                      _InlineReviewsPreview(
                        productId: widget.productId,
                        productName: product.name,
                        reviewCount: product.reviewCount,
                      ),

                      SizedBox(height: 30.h),

                      // Similar Products
                      SimilarProductsSection(
                        categoryId: product.categoryId,
                        excludeProductId: widget.productId,
                      ),

                      SizedBox(height: 30.h),

                      // Trust Bar (Reused)
                      const FeatureHighlightsRow(),

                      SizedBox(height: 120.h),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool showViewAll = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.darkText,
          ),
        ),
        if (showViewAll)
          Text(
            "View All >",
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryPurple,
            ),
          ),
      ],
    );
  }

  Widget _buildBottomActionBar({bool inStock = true}) {
    final productId = widget.productId;
    final cart = context.read<CartProvider>();
    final cartCount = context.watch<CartProvider>().cartCount;
    return Container(
      padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 15.h, bottom: 25.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.r),
          topRight: Radius.circular(30.r),
        ),
      ),
      child: Row(
        children: [
          // Cart icon with live badge
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: const BoxDecoration(color: Color(0xFFF8F8F8), shape: BoxShape.circle),
                  child: Icon(Icons.shopping_cart_outlined, color: AppColors.darkText, size: 24.sp),
                ),
                if (cartCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(4.r),
                      decoration: const BoxDecoration(color: AppColors.secondaryPurple, shape: BoxShape.circle),
                      child: Text('$cartCount', style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          if (!inStock)
            Expanded(
              child: Container(
                height: 54.h,
                decoration: BoxDecoration(color: const Color(0xFFF1F1F4), borderRadius: BorderRadius.circular(16.r)),
                alignment: Alignment.center,
                child: Text('Currently Out of Stock',
                    style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppColors.greyText)),
              ),
            ),
          if (inStock) ...[
          // Add to Cart
          Expanded(
            child: GestureDetector(
              onTap: productId == null ? null : () => addToCartWithFeedback(context, productId),
              child: Container(
                height: 54.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.secondaryPurple, width: 2),
                ),
                alignment: Alignment.center,
                child: Text('Add to Cart', style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppColors.secondaryPurple)),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // Buy Now
          Expanded(
            child: GestureDetector(
              onTap: productId == null ? null : () async {
                final navigator = Navigator.of(context);
                final err = await cart.addToCart(productId);
                if (!mounted) return;
                if (err == null) {
                  navigator.push(MaterialPageRoute(builder: (_) => const CartScreen()));
                } else {
                  if (mounted) AppErrorDialog.show(context, message: err, title: "Couldn't add to cart");
                }
              },
              child: Container(
                height: 54.h,
                decoration: BoxDecoration(
                  gradient: AppColors.purpleGradient,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [BoxShadow(color: AppColors.secondaryPurple.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bolt_rounded, color: Colors.white, size: 18.sp),
                    SizedBox(width: 4.w),
                    Text('Buy Now', style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
          ],
        ],
      ),
    );
  }
}

class _InlineReviewsPreview extends StatefulWidget {
  final String? productId;
  final String? productName;
  final int reviewCount;
  const _InlineReviewsPreview({this.productId, this.productName, required this.reviewCount});

  @override
  State<_InlineReviewsPreview> createState() => _InlineReviewsPreviewState();
}

class _InlineReviewsPreviewState extends State<_InlineReviewsPreview> {
  List<Map<String, dynamic>> _reviews = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.productId == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final res = await ApiService().get('/products/${widget.productId}/reviews', params: {'limit': '3'});
      final reviews = (res.data['data']?['reviews'] as List?) ?? [];
      if (mounted) setState(() { _reviews = reviews.cast<Map<String, dynamic>>(); _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _timeAgo(String? iso) {
    if (iso == null) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    if (!_loading && _reviews.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Customer Reviews',
              style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.darkText),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProductReviewsScreen(productId: widget.productId, productName: widget.productName)),
              ),
              child: Text(
                'See all ${widget.reviewCount}',
                style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.secondaryPurple),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),

        if (_loading)
          Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 20.h), child: const CircularProgressIndicator()))
        else
          ..._reviews.map((r) {
            final name = (r['user_name'] as String?) ?? 'Anonymous';
            final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
            final rating = (r['rating'] as num?)?.toInt() ?? 0;
            final title = (r['title'] as String?) ?? '';
            final body = (r['body'] as String?) ?? '';
            final date = _timeAgo(r['created_at'] as String?);

            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16.r,
                        backgroundColor: AppColors.secondaryPurple.withValues(alpha: 0.15),
                        child: Text(initial, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppColors.secondaryPurple)),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.darkText)),
                            if (date.isNotEmpty)
                              Text(date, style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.greyText)),
                          ],
                        ),
                      ),
                      Row(
                        children: List.generate(5, (i) => Icon(
                          i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: Colors.orange,
                          size: 14.sp,
                        )),
                      ),
                    ],
                  ),
                  if (title.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Text(title, style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.darkText)),
                  ],
                  if (body.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      body,
                      style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.greyText),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            );
          }),

        if (!_loading && widget.reviewCount > 3)
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProductReviewsScreen(productId: widget.productId, productName: widget.productName)),
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.secondaryPurple.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(12.r),
              ),
              alignment: Alignment.center,
              child: Text(
                'See all ${widget.reviewCount} reviews',
                style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.secondaryPurple),
              ),
            ),
          ),
      ],
    );
  }
}
