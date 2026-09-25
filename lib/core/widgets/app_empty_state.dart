import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// The one empty-state layout (cart, wishlist, orders, reviews, addresses, notifications, search, lists).
/// Tinted icon circle → title → optional message → optional action. Same look as [GuestPrompt].
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Smaller variant for empty sections inside a scrolling page (no vertical centring).
  final bool compact;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final circle = compact ? 56.r : 72.r;
    final content = Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: compact ? 24.h : 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: circle,
            height: circle,
            decoration: const BoxDecoration(color: Color(0xFFF1EBFF), shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.secondaryPurple, size: (compact ? 26 : 34).sp),
          ),
          SizedBox(height: 16.h),
          Text(title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: (compact ? 15 : 17).sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
          if (message != null) ...[
            SizedBox(height: 6.h),
            Text(message!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.greyText, height: 1.4)),
          ],
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryPurple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 36.w, vertical: 13.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              child: Text(actionLabel!, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            ),
          ],
        ],
      ),
    );
    return compact ? content : Center(child: SingleChildScrollView(child: content));
  }
}
