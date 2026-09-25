import 'package:chillfi/core/widgets/cart_feedback.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/models/wishlist_model.dart';
import 'package:chillfi/core/providers/auth_provider.dart';
import 'package:chillfi/core/providers/wishlist_provider.dart';
import 'package:chillfi/core/widgets/guest_prompt.dart';
import 'package:chillfi/features/home/widgets/bottom_nav.dart';
import 'package:chillfi/features/product_details/product_details_screen.dart';
import 'package:chillfi/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WishlistProvider>().loadWishlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: context.watch<AuthProvider>().user == null
          ? const SafeArea(
              child: GuestPrompt(
                icon: Icons.favorite_border_rounded,
                title: 'Sign in to see your wishlist',
                message: 'Save products you love and find them on any device.',
              ),
            )
          : Consumer<WishlistProvider>(builder: (context, wishlist, _) {
        final isLoading = wishlist.wishlistState == WishlistState.loading && wishlist.items.isEmpty;

        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Wishlist', style: AppText.pageTitle()),
                        Text('${wishlist.items.length} saved item${wishlist.items.length == 1 ? '' : 's'}', style: AppText.pageSubtitle()),
                      ],
                    ),
                    if (wishlist.items.isNotEmpty)
                      TextButton(
                        onPressed: () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (dctx) => AlertDialog(
                              title: const Text('Clear wishlist?'),
                              content: Text('Remove all ${wishlist.items.length} saved items?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(dctx, false), child: const Text('Cancel')),
                                TextButton(onPressed: () => Navigator.pop(dctx, true), child: const Text('Clear All', style: TextStyle(color: Colors.red))),
                              ],
                            ),
                          );
                          if (ok != true) return;
                          for (final item in List.of(wishlist.items)) {
                            await wishlist.removeItem(item.id);
                          }
                        },
                        child: Text('Clear All', style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.red.shade400, fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              isLoading
                  ? const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.secondaryPurple)))
                  : wishlist.items.isEmpty
                      ? Expanded(child: _buildEmpty())
                      : Expanded(
                          child: RefreshIndicator(
                            onRefresh: () => wishlist.loadWishlist(),
                            color: AppColors.secondaryPurple,
                            child: ListView.separated(
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                              itemCount: wishlist.items.length,
                              separatorBuilder: (_, _) => SizedBox(height: 10.h),
                              itemBuilder: (_, i) => _WishlistCard(item: wishlist.items[i]),
                            ),
                          ),
                        ),
            ],
          ),
        );
      }),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 3),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border_rounded, size: 80.sp, color: AppColors.greyText),
          SizedBox(height: 16.h),
          Text('Your wishlist is empty', style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w600, color: AppColors.darkText)),
          SizedBox(height: 8.h),
          Text('Save items you love here', style: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.greyText)),
        ],
      ),
    );
  }
}

class _WishlistCard extends StatelessWidget {
  final WishlistItemModel item;
  const _WishlistCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsScreen(productId: item.productId))),
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: item.image != null
                  ? CachedNetworkImage(
                      imageUrl: item.image!,
                      width: 85.w, height: 85.h, fit: BoxFit.cover,
                      placeholder: (_, _) => Container(color: const Color(0xFFEEEEEE)),
                      errorWidget: (_, _, _) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            SizedBox(width: 12.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name & remove
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(item.name, style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.darkText), maxLines: 2, overflow: TextOverflow.ellipsis),
                      ),
                      GestureDetector(
                        onTap: () => context.read<WishlistProvider>().removeItem(item.id),
                        child: Padding(
                          padding: EdgeInsets.only(left: 8.w),
                          child: Icon(Icons.close_rounded, color: AppColors.greyText, size: 18.sp),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),

                  // Price row
                  Row(
                    children: [
                      Text('₹${item.price.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
                      if (item.oldPrice != null) ...[
                        SizedBox(width: 6.w),
                        Text('₹${item.oldPrice!.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.greyText, decoration: TextDecoration.lineThrough)),
                        SizedBox(width: 6.w),
                        Text('${item.discountPct}% off', style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.green, fontWeight: FontWeight.w600)),
                      ],
                    ],
                  ),
                  SizedBox(height: 4.h),

                  // Stock status
                  Text(
                    item.unavailable ? 'No longer available' : item.inStock ? 'In Stock' : 'Out of Stock',
                    style: GoogleFonts.poppins(fontSize: 11.sp, color: item.inStock ? Colors.green : Colors.red, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 10.h),

                  // Add to cart button
                  if (item.inStock)
                    SizedBox(
                      width: double.infinity,
                      height: 36.h,
                      child: ElevatedButton.icon(
                        onPressed: () => addToCartWithFeedback(context, item.productId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondaryPurple,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                        ),
                        icon: Icon(Icons.shopping_cart_outlined, size: 15.sp),
                        label: Text('Add to Cart', style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600)),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(width: 85.w, height: 85.h, color: const Color(0xFFEEEEEE), child: Icon(Icons.image_outlined, size: 30.sp, color: AppColors.greyText));
}
