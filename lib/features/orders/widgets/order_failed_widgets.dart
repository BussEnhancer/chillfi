import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderFailedHeader extends StatelessWidget {
  const OrderFailedHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 40.h, bottom: 20.h),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer soft glow
            Container(
              width: 120.r,
              height: 120.r,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
            // Middle ring
            Container(
              width: 100.r,
              height: 100.r,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
            // Inner Red Circle
            Container(
              width: 75.r,
              height: 75.r,
              decoration: BoxDecoration(
                color: const Color(0xFFFF4B4B),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF4B4B).withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(Icons.close_rounded, color: Colors.white, size: 45.sp),
            ),
            // Floating Confetti Particles
            ..._buildConfetti(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildConfetti() {
    return [
      Positioned(
        top: 15.h,
        left: 20.w,
        child: _confettiBit(Colors.purple, 0.5),
      ),
      Positioned(
        top: 25.h,
        right: 25.w,
        child: _confettiBit(Colors.orange, 1.2),
      ),
      Positioned(
        bottom: 30.h,
        left: 15.w,
        child: _confettiBit(Colors.yellow, 0.8),
      ),
      Positioned(
        bottom: 20.h,
        right: 20.w,
        child: _confettiBit(Colors.blue, 2.1),
      ),
      Positioned(
        top: 50.h,
        left: 5.w,
        child: _confettiBit(Colors.pink, 0.3),
      ),
      Positioned(
        bottom: 50.h,
        right: 5.w,
        child: _confettiBit(Colors.green, 1.5),
      ),
    ];
  }

  Widget _confettiBit(Color color, double rotate) {
    return Transform.rotate(
      angle: rotate,
      child: Container(
        width: 6.r,
        height: 6.r,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(1.5.r),
        ),
      ),
    );
  }
}

class FailureMessageSection extends StatelessWidget {
  const FailureMessageSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Order Failed!",
          style: GoogleFonts.poppins(
            fontSize: 24.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.darkText,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 8.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.w),
          child: Text(
            "We couldn't process your order.\nPlease try again or choose another payment method.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              color: AppColors.greyText,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class OrderInfoCard extends StatelessWidget {
  const OrderInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.description_outlined, color: Colors.red[300], size: 28.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Order ID",
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: AppColors.greyText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "#CHILLFI125678",
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "May 21, 2025  •  09:41 AM",
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: AppColors.greyText,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5.r,
                      height: 5.r,
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      "Payment Failed",
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "Amount",
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  color: AppColors.greyText,
                ),
              ),
              Text(
                "₹1,36,897",
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FailureReasonCard extends StatelessWidget {
  const FailureReasonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      "What went wrong?",
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  "Your payment could not be processed. This could be due to insufficient balance, network issue, or bank decline.",
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: AppColors.greyText,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 70.w,
                height: 50.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB2B2).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.account_balance_wallet_outlined, color: Colors.red[200], size: 30.sp),
              ),
              Container(
                padding: EdgeInsets.all(4.r),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: Icon(Icons.close_rounded, color: Colors.white, size: 12.sp),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ActionOptionsCard extends StatelessWidget {
  const ActionOptionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What can you do?",
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          SizedBox(height: 20.h),
          _buildActionTile(
            icon: Icons.refresh_rounded,
            title: "Try Again",
            subtitle: "Retry with the same payment method",
            iconColor: Colors.purple,
          ),
          _divider(),
          _buildActionTile(
            icon: Icons.credit_card_rounded,
            title: "Choose Another Payment Method",
            subtitle: "Select a different payment option",
            iconColor: Colors.blue,
          ),
          _divider(),
          _buildActionTile(
            icon: Icons.shopping_cart_outlined,
            title: "Return to Cart",
            subtitle: "Review your items and try again later",
            iconColor: Colors.pink,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: iconColor, size: 22.sp),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  color: AppColors.greyText,
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.chevron_right_rounded, color: AppColors.lightGrey, size: 24.sp),
      ],
    );
  }

  Widget _divider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Divider(height: 1, color: AppColors.lightGrey.withValues(alpha: 0.3)),
    );
  }
}

class SupportCard extends StatelessWidget {
  const SupportCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5FF),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.secondaryPurple.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondaryPurple.withValues(alpha: 0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Icon(Icons.headset_mic_outlined, color: AppColors.secondaryPurple, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Need Help?",
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  "Our support team is here to help you.",
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: AppColors.greyText,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: AppColors.secondaryPurple.withValues(alpha: 0.3)),
            ),
            child: Text(
              "Contact Support",
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.secondaryPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RetryButton extends StatelessWidget {
  const RetryButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60.h,
      decoration: BoxDecoration(
        gradient: AppColors.purpleGradient,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryPurple.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.refresh_rounded, color: Colors.white, size: 22.sp),
          SizedBox(width: 12.w),
          Text(
            "Try Again",
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class BackToShoppingButton extends StatelessWidget {
  const BackToShoppingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.secondaryPurple, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, color: AppColors.secondaryPurple, size: 20.sp),
          SizedBox(width: 10.w),
          Text(
            "Back to Shopping",
            style: GoogleFonts.poppins(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.secondaryPurple,
            ),
          ),
        ],
      ),
    );
  }
}

class SecurityFooter extends StatelessWidget {
  const SecurityFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_outline_rounded, color: AppColors.greyText, size: 14.sp),
        SizedBox(width: 6.w),
        Text(
          "Your data is safe and secure",
          style: GoogleFonts.poppins(
            fontSize: 11.sp,
            color: AppColors.greyText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
