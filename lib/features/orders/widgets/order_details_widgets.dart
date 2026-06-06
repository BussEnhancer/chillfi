import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: AppColors.secondaryPurple.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.description_outlined, color: AppColors.secondaryPurple, size: 24.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order ID",
                      style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.greyText),
                    ),
                    Text(
                      "#CHILLFI125678",
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkText,
                      ),
                    ),
                    Text(
                      "May 21, 2026  •  09:41 AM",
                      style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.greyText),
                    ),
                    Text(
                      "Placed from CHILLFI App",
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp, 
                        color: AppColors.secondaryPurple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      "Delivered",
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    "Total Amount",
                    style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.greyText),
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
                      Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.greyText, size: 20.sp),
                    ],
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

class OrderStatusTimeline extends StatelessWidget {
  const OrderStatusTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Order Status",
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStep("Confirmed", "21 May 2026", "09:41 AM", true, false),
              _buildLine(true),
              _buildStep("Packed", "22 May 2026", "11:20 AM", true, false),
              _buildLine(true),
              _buildStep("Shipped", "23 May 2026", "08:15 AM", true, false),
              _buildLine(true),
              _buildStep("Delivered", "24 May 2026", "02:30 PM", false, true),
            ],
          ),
          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.green, size: 18.sp),
                SizedBox(width: 8.w),
                Text(
                  "Your order has been delivered successfully.",
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String label, String date, String time, bool isCompleted, bool isDelivered) {
    return Column(
      children: [
        Container(
          width: 32.r,
          height: 32.r,
          decoration: BoxDecoration(
            color: isCompleted ? Colors.green : (isDelivered ? AppColors.secondaryPurple : Colors.white),
            shape: BoxShape.circle,
            border: Border.all(
              color: isCompleted ? Colors.green : (isDelivered ? AppColors.secondaryPurple : AppColors.lightGrey),
              width: 1.5,
            ),
          ),
          child: Icon(
            isDelivered ? Icons.inventory_2_rounded : Icons.check_rounded,
            color: (isCompleted || isDelivered) ? Colors.white : AppColors.lightGrey,
            size: 16.sp,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 9.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.darkText,
          ),
        ),
        Text(
          date,
          style: GoogleFonts.poppins(fontSize: 8.sp, color: AppColors.greyText),
        ),
        Text(
          time,
          style: GoogleFonts.poppins(fontSize: 8.sp, color: AppColors.greyText),
        ),
      ],
    );
  }

  Widget _buildLine(bool isCompleted) {
    return Expanded(
      child: Container(
        height: 2,
        margin: EdgeInsets.only(bottom: 50.h),
        color: isCompleted ? Colors.green : AppColors.lightGrey.withValues(alpha: 0.5),
      ),
    );
  }
}

class OrderAddressCard extends StatelessWidget {
  const OrderAddressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: AppColors.secondaryPurple.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.location_on_outlined, color: AppColors.secondaryPurple, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Delivery Address",
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Text(
                      "John Sharma",
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryPurple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        "Home",
                        style: GoogleFonts.poppins(
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.secondaryPurple,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  "226010, 14/285, Vivek Khand, Gomti Nagar,\nLucknow, Uttar Pradesh, India",
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: AppColors.greyText,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "+91 98765 43210",
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
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
}

class OrderItemsCard extends StatelessWidget {
  const OrderItemsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.shopping_bag_outlined, color: AppColors.secondaryPurple, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    "Order Items (3)",
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    "View Invoice",
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondaryPurple,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(Icons.file_download_outlined, color: AppColors.secondaryPurple, size: 16.sp),
                ],
              ),
            ],
          ),
          SizedBox(height: 20.h),
          _buildItem("Apple iPhone 15 (128GB)", "Pink • 128GB", "1", "69,999"),
          Divider(height: 32.h, color: AppColors.lightGrey.withValues(alpha: 0.3)),
          _buildItem("Samsung Galaxy S23 (256GB)", "Phantom Black • 256GB", "1", "49,999"),
          Divider(height: 32.h, color: AppColors.lightGrey.withValues(alpha: 0.3)),
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
            borderRadius: BorderRadius.circular(10.r),
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
                style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.greyText),
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
            fontWeight: FontWeight.w800,
            color: AppColors.darkText,
          ),
        ),
      ],
    );
  }
}

class OrderPriceDetailsCard extends StatelessWidget {
  const OrderPriceDetailsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.description_outlined, color: AppColors.secondaryPurple, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                "Price Details",
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          _buildPriceRow("Price (3 Items)", "₹1,38,997"),
          SizedBox(height: 12.h),
          _buildPriceRow("Discount (FLAT15)", "-₹2,100", isDiscount: true),
          SizedBox(height: 12.h),
          _buildPriceRow("Delivery Charges", "FREE", isFree: true),
          Divider(height: 32.h, color: AppColors.lightGrey.withValues(alpha: 0.3), thickness: 1),
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
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "You will save ",
                  style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.green[700]),
                ),
                Text(
                  "₹2,100 ",
                  style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w700, color: Colors.green[700]),
                ),
                Text(
                  "on this order",
                  style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.green[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isDiscount = false, bool isFree = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.greyText),
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

class OrderPaymentMethodCard extends StatelessWidget {
  const OrderPaymentMethodCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.credit_card_rounded, color: AppColors.secondaryPurple, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    "Payment Method",
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    "View Payment Details",
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondaryPurple,
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: AppColors.secondaryPurple, size: 18.sp),
                ],
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Container(
                width: 45.r,
                height: 45.r,
                decoration: BoxDecoration(
                  color: const Color(0xFF5F259F).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.account_balance_wallet_rounded, color: const Color(0xFF5F259F), size: 24.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "PhonePe UPI",
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                    Text(
                      "rahul.sharma@ibl",
                      style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.greyText),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Paid",
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    "₹1,36,897",
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkText,
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

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildAction(Icons.local_shipping_outlined, "Track Order"),
        _buildAction(Icons.refresh_rounded, "Buy Again"),
        _buildAction(Icons.file_download_outlined, "Download Invoice"),
        _buildAction(Icons.headset_mic_outlined, "Need Help?"),
      ],
    );
  }

  Widget _buildAction(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 75.w,
          height: 75.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, color: AppColors.secondaryPurple, size: 26.sp),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          width: 75.w,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
        ),
      ],
    );
  }
}

class OrderBottomActions extends StatelessWidget {
  const OrderBottomActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 56.h,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.secondaryPurple, width: 1.5),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2_outlined, color: AppColors.secondaryPurple, size: 18.sp),
                    SizedBox(width: 8.w),
                    Text(
                      "Return / Replace",
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondaryPurple,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 16.w),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.share_outlined, color: Colors.white, size: 18.sp),
                    SizedBox(width: 8.w),
                    Text(
                      "Share Order",
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
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
      ),
    );
  }
}
