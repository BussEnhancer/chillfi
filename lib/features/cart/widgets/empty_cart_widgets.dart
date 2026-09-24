import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class EmptyCartIllustration extends StatelessWidget {
  const EmptyCartIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background soft circle
          Container(
            width: 200.r,
            height: 200.r,
            decoration: const BoxDecoration(
              color: Color(0xFFF7F2FF),
              shape: BoxShape.circle,
            ),
          ),
          
          // Floating decorations
          Positioned(top: 20.h, left: 10.w, child: _cloud()),
          Positioned(top: 40.h, right: 10.w, child: _star(8.r)),
          Positioned(bottom: 30.h, left: 20.w, child: _star(6.r)),
          
          // Paper Plane
          Positioned(
            top: 10.h,
            right: 30.w,
            child: Transform.rotate(
              angle: -0.2,
              child: Icon(Icons.send_rounded, color: const Color(0xFF6C2BFF).withValues(alpha: 0.4), size: 32.sp),
            ),
          ),

          // Main Shopping Cart Icon
          Icon(
            Icons.shopping_cart_outlined,
            color: const Color(0xFF6C2BFF),
            size: 100.sp,
          ),
        ],
      ),
    );
  }

  Widget _cloud() {
    return Icon(Icons.cloud_queue_rounded, color: const Color(0xFFE5E7EB), size: 36.sp);
  }

  Widget _star(double size) {
    return Icon(Icons.auto_awesome_rounded, color: const Color(0xFF8B5CFF).withValues(alpha: 0.3), size: size);
  }
}

class MiniProductCard extends StatelessWidget {
  final String name;
  final String price;
  final String status;
  final Color statusColor;

  const MiniProductCard({
    super.key,
    required this.name,
    required this.price,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150.w,
      margin: EdgeInsets.only(right: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 100.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                ),
                child: Icon(Icons.shopping_bag_outlined, color: Colors.grey[300], size: 40.sp),
              ),
              Positioned(
                top: 8.h,
                right: 8.w,
                child: Icon(Icons.favorite_rounded, color: const Color(0xFF6C2BFF), size: 18.sp),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "₹$price",
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  status,
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SecurityShoppingCard extends StatelessWidget {
  const SecurityShoppingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2FF),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: const BoxDecoration(
              color: Color(0xFF6C2BFF),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.shield_outlined, color: Colors.white, size: 20.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Safe & Secure Shopping",
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                Text(
                  "Your data is protected and your payments are always safe.",
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
