import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/providers/cart_provider.dart';
import 'package:chillfi/core/providers/product_provider.dart';
import 'package:chillfi/core/providers/wishlist_provider.dart';
import 'package:chillfi/features/cart/cart_screen.dart';
import 'package:chillfi/features/categories/widgets/feature_highlights.dart';
import 'package:chillfi/features/product_details/product_reviews_screen.dart';
import 'package:chillfi/features/product_details/widgets/product_gallery.dart';
import 'package:chillfi/features/product_details/widgets/product_highlight_item.dart';
import 'package:chillfi/features/product_details/widgets/product_offer_card.dart';
import 'package:chillfi/features/product_details/widgets/similar_products_section.dart';
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
  int _selectedColorIndex = 0;
  int _selectedStorageIndex = 0;

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
      body: Consumer<ProductProvider>(
        builder: (context, pp, _) {
          if (pp.detailState == LoadState.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          final product = pp.selectedProduct;
          if (product == null) {
            return const Center(child: Text('Product not found'));
          }
          final savings = product.oldPrice != null ? (product.oldPrice! - product.price) : 0.0;
          return Stack(
        children: [
          SingleChildScrollView(
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
                          if (product.isFeatured) _buildBadge("Best Seller", Colors.orange),
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
                          Container(
                            padding: EdgeInsets.all(10.r),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF8F8F8),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.share_outlined, size: 20.sp, color: AppColors.darkText),
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
                              const Spacer(),
                              Icon(Icons.chevron_right_rounded, color: Colors.green[800], size: 20.sp),
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
                              icon: Icons.credit_card_rounded,
                              title: "No Cost EMI",
                              subtitle: "Available on orders above ₹3,000",
                            ),
                            ProductOfferCard(
                              icon: Icons.account_balance_rounded,
                              title: "Bank Offers",
                              subtitle: "Check eligible banks at checkout",
                            ),
                            ProductOfferCard(
                              icon: Icons.swap_horizontal_circle_rounded,
                              title: "Exchange Offer",
                              subtitle: "Get extra value on exchange",
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
          ),

          // Sticky Bottom Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomActionBar(),
          ),
        ],
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

  Widget _buildColorCard(int index) {
    bool isSelected = _selectedColorIndex == index;
    List<String> labels = ["Pink", "Blue", "Black", "Green", "Yellow"];
    return GestureDetector(
      onTap: () => setState(() => _selectedColorIndex = index),
      child: Container(
        width: 70.w,
        margin: EdgeInsets.only(right: 12.w),
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.secondaryPurple : AppColors.lightGrey.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.smartphone_rounded, color: Colors.grey[300], size: 40.sp),
            SizedBox(height: 4.h),
            Text(
              labels[index],
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.darkText : AppColors.greyText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageChip(String label, int index) {
    bool isSelected = _selectedStorageIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedStorageIndex = index),
      child: Container(
        margin: EdgeInsets.only(right: 12.w),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondaryPurple : Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected ? AppColors.secondaryPurple : AppColors.lightGrey.withOpacity(0.5),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.darkText,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionBar() {
    final productId = widget.productId;
    final cart = context.read<CartProvider>();
    final cartCount = context.watch<CartProvider>().cartCount;
    return Container(
      padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 15.h, bottom: 25.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
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
          // Add to Cart
          Expanded(
            child: GestureDetector(
              onTap: productId == null ? null : () async {
                final err = await cart.addToCart(productId);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(err ?? 'Added to cart!'),
                  backgroundColor: err == null ? Colors.green : Colors.red,
                  duration: const Duration(seconds: 2),
                ));
              },
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
                final err = await cart.addToCart(productId);
                if (!context.mounted) return;
                if (err == null) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err), backgroundColor: Colors.red));
                }
              },
              child: Container(
                height: 54.h,
                decoration: BoxDecoration(
                  gradient: AppColors.purpleGradient,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [BoxShadow(color: AppColors.secondaryPurple.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
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
      ),
    );
  }
}
