import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CancellationOrderCard extends StatelessWidget {
  const CancellationOrderCard({super.key});

  @override
  Widget build(BuildContext context) {
    final order = context.watch<CartProvider>().currentOrder;
    final firstItem = (order?.items.isNotEmpty == true) ? order!.items.first : null;
    final itemLabel = firstItem == null
        ? 'Order'
        : (order!.items.length > 1
            ? '${firstItem.productName} + ${order.items.length - 1} more'
            : firstItem.productName);
    final qtyLabel = firstItem != null ? 'Qty: ${firstItem.quantity}' : '';
    final orderNumber = order?.orderNumber ?? '—';
    final dateLabel = order != null
        ? DateFormat('d MMM yyyy, hh:mm a').format(order.createdAt.toLocal())
        : '—';
    final totalLabel = order != null
        ? '₹${order.total.toStringAsFixed(0)}'
        : '—';
    final statusLabel = order?.status ?? '—';
    final statusColor = statusLabel == 'Processing'
        ? Colors.orange
        : statusLabel == 'Shipped'
            ? Colors.blue
            : statusLabel == 'Delivered'
                ? Colors.green
                : Colors.grey;

    return _buildCard(
      context,
      itemLabel: itemLabel,
      qtyLabel: qtyLabel,
      orderNumber: orderNumber,
      dateLabel: dateLabel,
      totalLabel: totalLabel,
      statusLabel: statusLabel,
      statusColor: statusColor,
      imageUrl: firstItem?.productImage,
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String itemLabel,
    required String qtyLabel,
    required String orderNumber,
    required String dateLabel,
    required String totalLabel,
    required String statusLabel,
    required Color statusColor,
    String? imageUrl,
  }) {
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
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60.r,
            height: 60.r,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.network(imageUrl, fit: BoxFit.cover,
                        errorBuilder: (ctx, err, st) => Icon(Icons.shopping_bag_rounded, size: 35.sp, color: Colors.grey[300])),
                  )
                : Icon(Icons.shopping_bag_rounded, size: 35.sp, color: Colors.grey[300]),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (qtyLabel.isNotEmpty)
                  Text(
                    qtyLabel,
                    style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.greyText),
                  ),
                SizedBox(height: 8.h),
                Text(
                  "Order ID",
                  style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.greyText),
                ),
                Text(
                  "#$orderNumber",
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  "Placed on $dateLabel",
                  style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.greyText),
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
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  statusLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                "Amount",
                style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.greyText),
              ),
              Text(
                totalLabel,
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
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

class CancellationWarningCard extends StatelessWidget {
  const CancellationWarningCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E7),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: const Color(0xFFF59E0B), size: 18.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              "Once cancelled, this order cannot be restored.",
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF92400E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReasonRadioList extends StatefulWidget {
  final ValueChanged<String>? onSelected;
  const ReasonRadioList({super.key, this.onSelected});

  @override
  State<ReasonRadioList> createState() => _ReasonRadioListState();
}

class _ReasonRadioListState extends State<ReasonRadioList> {
  int selectedIndex = 0;

  final List<Map<String, String>> reasons = [
    {
      "title": "I want to change the delivery address",
      "desc": "I entered the wrong or incomplete address"
    },
    {
      "title": "I want to change the order",
      "desc": "I want to add/remove items or change the variant"
    },
    {
      "title": "Found a better price somewhere else",
      "desc": "I found the product for a lower price"
    },
    {
      "title": "Delivery taking too long",
      "desc": "The estimated delivery time is too long"
    },
    {
      "title": "Ordered by mistake",
      "desc": "I placed this order accidentally"
    },
    {
      "title": "Other reason",
      "desc": "Please let us know the reason"
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.onSelected?.call(reasons[selectedIndex]['title']!));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(reasons.length, (index) {
        bool isSelected = selectedIndex == index;
        return GestureDetector(
          onTap: () {
            setState(() => selectedIndex = index);
            widget.onSelected?.call(reasons[index]['title']!);
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isSelected ? AppColors.secondaryPurple : AppColors.lightGrey.withValues(alpha: 0.3),
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
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reasons[index]["title"]!,
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkText,
                        ),
                      ),
                      Text(
                        reasons[index]["desc"]!,
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          color: AppColors.greyText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class AdditionalCommentsBox extends StatelessWidget {
  final TextEditingController? controller;
  const AdditionalCommentsBox({super.key, this.controller});

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
            "Additional Comments (Optional)",
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          Text(
            "Help us improve by sharing more details",
            style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.greyText),
          ),
          SizedBox(height: 16.h),
          Container(
            height: 100.h,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: "Write your comments here...",
                      hintStyle: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.greyText),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    "0/250",
                    style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.greyText),
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

class RefundInfoCard extends StatelessWidget {
  const RefundInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF3FAF5),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.green.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(Icons.currency_exchange_rounded, color: Colors.green, size: 20.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Refund Information",
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.green[800],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.green[700], height: 1.5),
                    children: [
                      const TextSpan(text: "If your order is cancelled now, your refund will be processed to the original payment method within "),
                      TextSpan(
                        text: "3-5 business days.",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                      ),
                    ],
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

class CancellationHelpCard extends StatelessWidget {
  const CancellationHelpCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5FF),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.secondaryPurple.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(Icons.shield_outlined, color: AppColors.secondaryPurple, size: 20.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Not sure about cancelling?",
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                    Text(
                      "You can track your order or contact our support team for more assistance.",
                      style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.greyText, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: _buildHelpBtn(Icons.local_shipping_outlined, "Track Order"),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildHelpBtn(Icons.headset_mic_outlined, "Contact Support"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHelpBtn(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.secondaryPurple, size: 16.sp),
          SizedBox(width: 8.w),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }
}
