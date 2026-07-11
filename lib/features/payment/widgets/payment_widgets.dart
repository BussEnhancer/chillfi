import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentSecurityBanner extends StatelessWidget {
  const PaymentSecurityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.secondaryPurple.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.secondaryPurple.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColors.secondaryPurple.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.shield_rounded, color: AppColors.secondaryPurple, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Safe and Secure Payments",
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  "Your payment information is encrypted and safe with us.",
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    color: AppColors.greyText,
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

class PaymentSectionHeader extends StatelessWidget {
  final String title;
  const PaymentSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 24.h, bottom: 12.h),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.darkText,
        ),
      ),
    );
  }
}

class PaymentRadioButton extends StatelessWidget {
  final bool isSelected;
  const PaymentRadioButton({super.key, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20.r,
      height: 20.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.secondaryPurple : AppColors.lightGrey,
          width: isSelected ? 6.r : 1.5,
        ),
      ),
    );
  }
}

class RecommendedUPICard extends StatelessWidget {
  const RecommendedUPICard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.secondaryPurple.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.secondaryPurple, width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50.r,
                height: 50.r,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.5)),
                ),
                alignment: Alignment.center,
                child: Text("UPI", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.sp)),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "UPI",
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkText,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        _buildBadge("Instant", Colors.green),
                        SizedBox(width: 4.w),
                        _buildBadge("Recommended", AppColors.secondaryPurple),
                      ],
                    ),
                    Text(
                      "Pay directly from your bank account",
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: AppColors.greyText,
                      ),
                    ),
                  ],
                ),
              ),
              const PaymentRadioButton(isSelected: true),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              SizedBox(width: 62.w),
              _buildLogo(Icons.account_balance_wallet_rounded),
              _buildLogo(Icons.payments_rounded),
              _buildLogo(Icons.api_rounded),
              _buildLogo(Icons.change_history_rounded),
              SizedBox(width: 8.w),
              Text(
                "& more",
                style: GoogleFonts.poppins(
                  fontSize: 10.sp,
                  color: AppColors.greyText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 8.sp,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildLogo(IconData icon) {
    return Container(
      margin: EdgeInsets.only(right: 8.w),
      child: Icon(icon, size: 16.sp, color: AppColors.greyText),
    );
  }
}

class PaymentOptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final Widget? leading;
  final Widget? trailing;
  final bool showArrow;

  const PaymentOptionTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.isSelected = false,
    this.leading,
    this.trailing,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            SizedBox(width: 12.w),
          ],
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
          if (trailing != null) ...[
            trailing!,
            SizedBox(width: 12.w),
          ],
          if (showArrow)
            Icon(Icons.chevron_right_rounded, color: AppColors.greyText, size: 20.sp)
          else
            PaymentRadioButton(isSelected: isSelected),
        ],
      ),
    );
  }
}

class TrustIndicatorCard extends StatelessWidget {
  const TrustIndicatorCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        border: Border(top: BorderSide(color: AppColors.lightGrey.withValues(alpha: 0.3))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildItem(Icons.verified_user_outlined, "100% Secure Payments", "Your data is protected"),
          _buildItem(Icons.lock_outline_rounded, "Secure Encryption", "256-bit SSL encryption"),
          _buildItem(Icons.headset_mic_outlined, "24x7 Support", "We're here to help you"),
        ],
      ),
    );
  }

  Widget _buildItem(IconData icon, String title, String subtitle) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.green, size: 20.sp),
          SizedBox(height: 8.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 9.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 8.sp,
              color: AppColors.greyText,
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentBottomBar extends StatelessWidget {
  const PaymentBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
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
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Amount Payable",
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      color: AppColors.greyText,
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Text(
                          "₹1,36,897",
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkText,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          "You will save ₹2,100",
                          style: GoogleFonts.poppins(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: Container(
                height: 56.h,
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
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Continue to Checkout",
                        style: GoogleFonts.poppins(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18.sp),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
