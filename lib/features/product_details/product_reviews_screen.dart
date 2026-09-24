import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/providers/cart_provider.dart';
import 'package:chillfi/core/services/api_service.dart';
import 'package:chillfi/features/cart/cart_screen.dart';
import 'package:chillfi/features/product_details/widgets/review_card.dart';
import 'package:chillfi/features/product_details/widgets/review_filter_chips.dart';
import 'package:chillfi/features/product_details/widgets/review_statistics_card.dart';
import 'package:chillfi/features/product_details/widgets/review_summary_card.dart';
import 'package:chillfi/features/search/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ProductReviewsScreen extends StatefulWidget {
  final String? productId;
  final String? productName;
  const ProductReviewsScreen({super.key, this.productId, this.productName});

  @override
  State<ProductReviewsScreen> createState() => _ProductReviewsScreenState();
}

class _ProductReviewsScreenState extends State<ProductReviewsScreen> {
  List<Map<String, dynamic>> _reviews = [];
  Map<String, dynamic> _stats = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    if (widget.productId == null) {
      setState(() { _loading = false; });
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiService().get('/products/${widget.productId}/reviews', params: {'limit': '50'});
      final reviews = (res.data['data']?['reviews'] as List?) ?? [];
      final stats = (res.data['data']?['stats'] as Map<String, dynamic>?) ?? {};
      setState(() {
        _reviews = reviews.cast<Map<String, dynamic>>();
        _stats = stats;
        _loading = false;
      });
    } catch (_) {
      setState(() { _error = 'Failed to load reviews'; _loading = false; });
    }
  }

  String _timeAgo(String? iso) {
    if (iso == null) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} months ago';
    if (diff.inDays > 0) return '${diff.inDays} days ago';
    if (diff.inHours > 0) return '${diff.inHours} hours ago';
    return 'Just now';
  }

  void _showWriteReviewSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _WriteReviewSheet(
        productId: widget.productId,
        productName: widget.productName,
        onSubmitted: _loadReviews,
      ),
    );
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
        title: Row(
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.smartphone_rounded, color: AppColors.primaryOrange, size: 24.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Product Reviews",
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                  if (widget.productName != null)
                    Text(
                      widget.productName!,
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: AppColors.greyText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
            icon: Icon(Icons.search_rounded, color: AppColors.darkText, size: 24.sp),
          ),
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
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                SizedBox(height: 16.h),
                ReviewSummaryCard(stats: _stats),
                SizedBox(height: 24.h),
                ReviewFilterChips(stats: _stats),
                SizedBox(height: 24.h),

                // Sort and Write Review Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Most Helpful",
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkText,
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_down_rounded, size: 20.sp, color: AppColors.darkText),
                      ],
                    ),
                    GestureDetector(
                      onTap: _showWriteReviewSheet,
                      child: Row(
                        children: [
                          Text(
                            "Write a Review",
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondaryPurple,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(Icons.edit_note_rounded, color: AppColors.secondaryPurple, size: 20.sp),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                // Review List
                if (_loading)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: const CircularProgressIndicator(),
                  )
                else if (_error != null)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.h),
                    child: Column(
                      children: [
                        Text(_error!, style: GoogleFonts.poppins(color: AppColors.greyText)),
                        SizedBox(height: 12.h),
                        TextButton(onPressed: _loadReviews, child: const Text('Retry')),
                      ],
                    ),
                  )
                else if (_reviews.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: Column(
                      children: [
                        Icon(Icons.rate_review_outlined, size: 48.sp, color: AppColors.greyText),
                        SizedBox(height: 12.h),
                        Text("No reviews yet", style: GoogleFonts.poppins(fontSize: 14.sp, color: AppColors.greyText)),
                        SizedBox(height: 6.h),
                        Text("Be the first to review!", style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.greyText)),
                      ],
                    ),
                  )
                else
                  ..._reviews.map((r) {
                    final name = (r['user_name'] as String?) ?? 'Anonymous';
                    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
                    return ReviewCard(
                      userName: name,
                      userInitial: initial,
                      date: _timeAgo(r['created_at'] as String?),
                      title: (r['title'] as String?) ?? '',
                      description: (r['body'] as String?) ?? '',
                      rating: (r['rating'] as num?)?.toInt() ?? 0,
                      helpfulCount: 0,
                    );
                  }),

                SizedBox(height: 24.h),
                ReviewStatisticsCard(stats: _stats),
                SizedBox(height: 120.h),
              ],
            ),
          ),

          // Sticky Bottom Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomPurchaseBar(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPurchaseBar(BuildContext context) {
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
          // Cart with badge
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Consumer<CartProvider>(builder: (context, cart, _) {
                  return Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Icon(Icons.shopping_cart_outlined, color: AppColors.darkText, size: 24.sp),
                      if (cart.cartCount > 0)
                        Positioned(
                          right: -2,
                          top: -2,
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
                Text(
                  "Cart",
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 20.w),
          // Add to Cart
          Expanded(
            child: Container(
              height: 54.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.secondaryPurple, width: 2),
              ),
              alignment: Alignment.center,
              child: Text(
                "Add to Cart",
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondaryPurple,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // Buy Now
          Expanded(
            child: Container(
              height: 54.h,
              decoration: BoxDecoration(
                gradient: AppColors.purpleGradient,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondaryPurple.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bolt_rounded, color: Colors.white, size: 18.sp),
                  SizedBox(width: 4.w),
                  Text(
                    "Buy Now",
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WriteReviewSheet extends StatefulWidget {
  final String? productId;
  final String? productName;
  final VoidCallback? onSubmitted;
  const _WriteReviewSheet({this.productId, this.productName, this.onSubmitted});

  @override
  State<_WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends State<_WriteReviewSheet> {
  int _rating = 0;
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) { setState(() => _error = 'Please select a star rating'); return; }
    if (_bodyCtrl.text.trim().isEmpty) { setState(() => _error = 'Please write your review'); return; }
    if (widget.productId == null) { setState(() => _error = 'Product not found'); return; }
    setState(() { _submitting = true; _error = null; });
    try {
      await ApiService().post(
        '/products/${widget.productId}/reviews',
        data: {
          'rating': _rating,
          'title': _titleCtrl.text.trim(),
          'body': _bodyCtrl.text.trim(),
        },
      );
      if (mounted) {
        Navigator.pop(context);
        widget.onSubmitted?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Review submitted successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      setState(() { _error = 'Failed to submit review. Please try again.'; _submitting = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w, height: 4.h,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2.r)),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Write a Review',
              style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppColors.darkText),
            ),
            if (widget.productName != null) ...[
              SizedBox(height: 4.h),
              Text(widget.productName!, style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.greyText), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
            SizedBox(height: 20.h),
            Text('Your Rating', style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.darkText)),
            SizedBox(height: 8.h),
            Row(
              children: List.generate(5, (i) => GestureDetector(
                onTap: () => setState(() => _rating = i + 1),
                child: Icon(
                  i < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: Colors.orange,
                  size: 36.sp,
                ),
              )),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                labelText: 'Review Title (optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: _bodyCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Your Review',
                hintText: 'Share your experience with this product...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              ),
            ),
            if (_error != null) ...[
              SizedBox(height: 8.h),
              Text(_error!, style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.red)),
            ],
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                ),
                child: _submitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('Submit Review', style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w700)),
              ),
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }
}
