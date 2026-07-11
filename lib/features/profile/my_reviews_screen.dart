import 'package:cached_network_image/cached_network_image.dart';
import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/models/wishlist_model.dart';
import 'package:chillfi/core/providers/wishlist_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({super.key});

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WishlistProvider>().loadMyReviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.darkText, size: 22.sp),
        ),
        title: Text('My Reviews', style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
      ),
      body: Consumer<WishlistProvider>(builder: (context, wp, _) {
        if (wp.myReviews.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star_border_rounded, size: 72.sp, color: AppColors.greyText),
                SizedBox(height: 16.h),
                Text('No reviews yet', style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.darkText)),
                SizedBox(height: 8.h),
                Text('Your product reviews will appear here', style: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.greyText)),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: EdgeInsets.all(16.r),
          itemCount: wp.myReviews.length,
          separatorBuilder: (_, __) => SizedBox(height: 10.h),
          itemBuilder: (_, i) => _ReviewCard(review: wp.myReviews[i]),
        );
      }),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: review.productImage != null
                ? CachedNetworkImage(imageUrl: review.productImage!, width: 60.w, height: 60.h, fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: const Color(0xFFEEEEEE)),
                    errorWidget: (_, __, ___) => _ph())
                : _ph(),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(review.productName, style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.darkText), maxLines: 1, overflow: TextOverflow.ellipsis),
                SizedBox(height: 4.h),
                Row(
                  children: List.generate(5, (i) => Icon(
                    i < review.rating.round() ? Icons.star_rounded : Icons.star_border_rounded,
                    color: Colors.orange, size: 16.sp,
                  )),
                ),
                if (review.comment != null) ...[
                  SizedBox(height: 6.h),
                  Text(review.comment!, style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.greyText), maxLines: 3, overflow: TextOverflow.ellipsis),
                ],
                SizedBox(height: 6.h),
                Text(
                  '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                  style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.greyText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ph() => Container(width: 60.w, height: 60.h, color: const Color(0xFFEEEEEE));
}
