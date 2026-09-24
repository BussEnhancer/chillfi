import 'package:chillfi/core/widgets/cart_feedback.dart';
import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/models/product_model.dart';
import 'package:chillfi/core/providers/product_provider.dart';
import 'package:chillfi/features/deals/flash_deals_screen.dart';
import 'package:chillfi/features/product_details/product_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DealOfTheDaySection extends StatelessWidget {
  const DealOfTheDaySection({super.key});

  @override
  Widget build(BuildContext context) {
    final flashSale = context.watch<ProductProvider>().home.flashSale;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Row(
            children: [
              Text('Deal of the Day', style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FlashDealsScreen())),
                child: Text('View All >', style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.secondaryPurple)),
              ),
            ],
          ),
        ),
        if (flashSale.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: Container(
              height: 120.h,
              decoration: BoxDecoration(
                color: AppColors.lightBackground,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Center(child: Text('No flash deals today', style: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.greyText))),
            ),
          )
        else
          ...flashSale.take(3).map((p) => _DealCard(product: p)),
      ],
    );
  }
}

class _DealCard extends StatelessWidget {
  final ProductModel product;
  const _DealCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final discountPct = product.oldPrice != null && product.oldPrice! > 0
        ? ((1 - product.price / product.oldPrice!) * 100).round()
        : 0;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsScreen(productId: product.id))),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
        child: Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.fieldBorder.withValues(alpha: 0.5)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 100.w,
                    height: 100.h,
                    decoration: BoxDecoration(color: AppColors.lightBackground, borderRadius: BorderRadius.circular(16.r)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: product.primaryImage != null && product.primaryImage!.isNotEmpty
                          ? Image.network(
                              product.primaryImage!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Center(child: Icon(Icons.devices_rounded, size: 46.sp, color: AppColors.darkText.withValues(alpha: 0.2))),
                            )
                          : Center(child: Icon(Icons.devices_rounded, size: 46.sp, color: AppColors.darkText.withValues(alpha: 0.2))),
                    ),
                  ),
                  if (discountPct > 0)
                    Positioned(
                      top: 8.h,
                      left: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(color: AppColors.secondaryPurple, borderRadius: BorderRadius.circular(4.r)),
                        child: Text('-$discountPct%', style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
                    if (product.description != null && product.description!.isNotEmpty)
                      Text(product.description!, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.greyText)),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        ...List.generate(product.rating.floor(), (_) => Icon(Icons.star_rounded, color: Colors.amber, size: 14.sp)),
                        if (product.rating % 1 >= 0.5) Icon(Icons.star_half_rounded, color: Colors.amber, size: 14.sp),
                        SizedBox(width: 4.w),
                        Text('(${product.rating})', style: TextStyle(fontSize: 10.sp, color: AppColors.greyText)),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Text('₹${product.price.toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w800, color: AppColors.darkText)),
                        if (product.oldPrice != null) ...[
                          SizedBox(width: 8.w),
                          Text('₹${product.oldPrice!.toStringAsFixed(0)}',
                              style: TextStyle(fontSize: 11.sp, color: AppColors.greyText, decoration: TextDecoration.lineThrough)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => addToCartWithFeedback(context, product.id, productName: product.name),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(color: AppColors.secondaryPurple.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12.r)),
                      child: Icon(Icons.add_shopping_cart_rounded, color: AppColors.secondaryPurple, size: 20.sp),
                    ),
                    SizedBox(height: 4.h),
                    Text('Add', style: GoogleFonts.poppins(fontSize: 9.sp, fontWeight: FontWeight.w600, color: AppColors.secondaryPurple)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
