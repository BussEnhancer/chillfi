import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckoutProgressStepper extends StatelessWidget {
  final int currentStep;
  const CheckoutProgressStepper({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStep(1, "Address", true),
          _buildDivider(),
          _buildStep(2, "Delivery", false),
          _buildDivider(),
          _buildStep(3, "Payment", false),
          _buildDivider(),
          _buildStep(4, "Review", false),
        ],
      ),
    );
  }

  Widget _buildStep(int step, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 28.r,
          height: 28.r,
          decoration: BoxDecoration(
            color: isActive ? AppColors.secondaryPurple : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? AppColors.secondaryPurple : AppColors.lightGrey,
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            step.toString(),
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: isActive ? Colors.white : AppColors.greyText,
            ),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10.sp,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? AppColors.secondaryPurple : AppColors.greyText,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 40.w,
      height: 1,
      margin: EdgeInsets.only(bottom: 18.h, left: 4.w, right: 4.w),
      child: Row(
        children: List.generate(
          5,
          (index) => Expanded(
            child: Container(
              height: 1,
              color: index % 2 == 0 ? AppColors.lightGrey : Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }
}

class CheckoutAddressCard extends StatelessWidget {
  const CheckoutAddressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: AppColors.secondaryPurple.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.location_on_rounded, color: AppColors.secondaryPurple, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "John Sharma",
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    _buildSmallBadge("Home", AppColors.secondaryPurple),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  "226010, 14/285, Vivek Khand, Gomti Nagar, Lucknow, Uttar Pradesh, India",
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: AppColors.greyText,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "+91 98765 43210",
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    _buildTag(Icons.verified_rounded, "Default Address"),
                    SizedBox(width: 8.w),
                    _buildTag(Icons.bolt_rounded, "Fast Delivery"),
                  ],
                ),
              ],
            ),
          ),
          Text(
            "Change >",
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryPurple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallBadge(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 8.sp,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  Widget _buildTag(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12.sp, color: Colors.green),
          SizedBox(width: 4.w),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 9.sp,
              fontWeight: FontWeight.w700,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}

class CheckoutOrderItemCard extends StatelessWidget {
  const CheckoutOrderItemCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          _buildItem("Apple iPhone 15 (128GB)", "Pink  •  128GB", "1", "69,999"),
          Divider(height: 24.h, color: AppColors.lightGrey.withValues(alpha: 0.3)),
          _buildItem("Samsung Galaxy S23 (256GB)", "Phantom Black  •  256GB", "1", "49,999"),
          Divider(height: 24.h, color: AppColors.lightGrey.withValues(alpha: 0.3)),
          _buildItem("Apple AirPods Pro (2nd Gen)", "White", "1", "18,999"),
        ],
      ),
    );
  }

  Widget _buildItem(String name, String variant, String qty, String price) {
    return Row(
      children: [
        Container(
          width: 50.r,
          height: 50.r,
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8F8),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(Icons.smartphone_rounded, size: 30.sp, color: Colors.grey[300]),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                variant,
                style: GoogleFonts.poppins(
                  fontSize: 10.sp,
                  color: AppColors.greyText,
                ),
              ),
              Text(
                "Qty: $qty",
                style: GoogleFonts.poppins(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
        ),
        Text(
          "₹$price",
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.darkText,
          ),
        ),
      ],
    );
  }
}

class DeliveryOptionCard extends StatelessWidget {
  final String title;
  final String date;
  final String price;
  final bool isSelected;
  final bool isFree;

  const DeliveryOptionCard({
    super.key,
    required this.title,
    required this.date,
    required this.price,
    required this.isSelected,
    this.isFree = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isSelected ? AppColors.secondaryPurple : AppColors.lightGrey.withValues(alpha: 0.5),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 20.r,
            height: 20.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.secondaryPurple : AppColors.lightGrey,
                width: isSelected ? 6.r : 1.5,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                    if (isFree) ...[
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          "FREE",
                          style: GoogleFonts.poppins(
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  "Delivery by $date",
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: AppColors.greyText,
                  ),
                ),
              ],
            ),
          ),
          Text(
            isFree ? "₹0" : "₹$price",
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: isFree ? Colors.green : AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentMethodCard extends StatelessWidget {
  const PaymentMethodCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  "VISA",
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1A1F71),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Visa **** **** **** 4242",
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                    Text(
                      "Expires 04/28",
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: AppColors.greyText,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(Icons.verified_user_outlined, color: Colors.green, size: 14.sp),
                  SizedBox(width: 4.w),
                  Text(
                    "Secure Payment",
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      color: AppColors.greyText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AppliedOfferCard extends StatelessWidget {
  const AppliedOfferCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, color: Colors.green, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "FLAT15 Applied",
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.green[800],
                  ),
                ),
                Text(
                  "You saved ₹2,100",
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              "-₹2,100",
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: Colors.green,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Icon(Icons.close_rounded, color: AppColors.greyText, size: 20.sp),
        ],
      ),
    );
  }
}

class PriceDetailsCard extends StatelessWidget {
  const PriceDetailsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          _buildRow("Price (3 Items)", "₹1,38,997"),
          SizedBox(height: 12.h),
          _buildRow("Discount (FLAT15)", "-₹2,100", isDiscount: true),
          SizedBox(height: 12.h),
          _buildRow("Delivery Charges", "FREE", isFree: true),
          Divider(height: 30.h, color: AppColors.lightGrey.withValues(alpha: 0.3)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Amount",
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
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
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              "You will save ₹2,100 on this order",
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: Colors.green[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isDiscount = false, bool isFree = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            color: AppColors.greyText,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: isDiscount || isFree ? Colors.green : AppColors.darkText,
          ),
        ),
      ],
    );
  }
}

class CheckoutBottomBar extends StatelessWidget {
  const CheckoutBottomBar({super.key});

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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Total Amount",
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: AppColors.greyText,
                  ),
                ),
                Row(
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
                      "Saved ₹2,100",
                      style: GoogleFonts.poppins(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_rounded, color: Colors.white, size: 18.sp),
                    SizedBox(width: 8.w),
                    Text(
                      "Place Order",
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
          ],
        ),
      ),
    );
  }
}
