import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TrackingHeaderCard extends StatelessWidget {
  const TrackingHeaderCard({super.key});

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 40.r,
                      height: 40.r,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          "D",
                          style: GoogleFonts.poppins(
                            color: Colors.red,
                            fontWeight: FontWeight.w900,
                            fontSize: 20.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "DELHIVERY",
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkText,
                              letterSpacing: 1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  "Tracking ID: 14928736123456",
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.sp,
                                    color: AppColors.greyText,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Icon(Icons.copy_rounded, size: 12.sp, color: AppColors.greyText),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
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
                      "On the Way",
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Expected Delivery",
                    style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.greyText),
                  ),
                  Text(
                    "24 May 2026 by 8:00 PM",
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondaryPurple,
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

class TrackingProductCard extends StatelessWidget {
  const TrackingProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.3)),
      ),
      child: Row(
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
                  "Apple iPhone 15 (128GB)",
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "Pink • 128GB  |  Qty: 1",
                  style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.greyText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "Order ID: #CHILLFI125678",
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                Text(
                  "View",
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: AppColors.greyText, size: 14.sp),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VerticalTrackingTimeline extends StatelessWidget {
  final String orderStatus;
  final DateTime createdAt;

  const VerticalTrackingTimeline({
    super.key,
    required this.orderStatus,
    required this.createdAt,
  });

  static const _statusOrder = ['Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled'];

  int get _statusIndex {
    final idx = _statusOrder.indexOf(orderStatus);
    return idx < 0 ? 1 : idx;
  }

  String _fmt(DateTime dt) => DateFormat('d MMM yyyy, hh:mm a').format(dt);

  @override
  Widget build(BuildContext context) {
    final idx = _statusIndex;
    final isCancelled = orderStatus == 'Cancelled';
    final placed = createdAt;
    final confirmed = placed.add(const Duration(minutes: 15));
    final shipped = placed.add(const Duration(days: 1));
    final outForDelivery = placed.add(const Duration(days: 4));
    final delivered = placed.add(const Duration(days: 5));

    TimelineStatus st(int stepIdx) {
      if (isCancelled) return stepIdx == 0 ? TimelineStatus.completed : TimelineStatus.pending;
      if (idx > stepIdx) return TimelineStatus.completed;
      if (idx == stepIdx) return TimelineStatus.current;
      return TimelineStatus.pending;
    }

    return Container(
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
            "Tracking Timeline",
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          if (isCancelled) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.cancel_rounded, color: Colors.red, size: 16.sp),
                  SizedBox(width: 8.w),
                  Text(
                    "This order was cancelled",
                    style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.red, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 24.h),
          _buildTimelineStep(
            title: "Order Placed",
            description: "Your order was placed successfully",
            date: _fmt(placed),
            isFirst: true,
            status: st(0),
          ),
          _buildTimelineStep(
            title: "Order Confirmed",
            description: "Seller confirmed your order",
            date: st(1) == TimelineStatus.pending ? null : _fmt(confirmed),
            status: st(1),
          ),
          _buildTimelineStep(
            title: "Shipped",
            description: "Package picked up by courier",
            date: st(2) == TimelineStatus.pending ? null : _fmt(shipped),
            status: st(2),
          ),
          _buildTimelineStep(
            title: "Out for Delivery",
            description: "Package is on its way to you",
            date: st(3) == TimelineStatus.pending ? null : _fmt(outForDelivery),
            status: st(3),
          ),
          _buildTimelineStep(
            title: "Delivered",
            description: idx >= 3
                ? "Package delivered successfully"
                : "Expected by ${DateFormat('d MMM yyyy').format(delivered)}",
            date: idx >= 4 ? _fmt(delivered) : null,
            isLast: true,
            status: st(4),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String description,
    String? date,
    bool isFirst = false,
    bool isLast = false,
    bool isNextPurple = false,
    required TimelineStatus status,
  }) {
    Color circleColor;
    Widget? icon;
    Color lineColor;
    bool isDashed = false;

    switch (status) {
      case TimelineStatus.completed:
        circleColor = Colors.green;
        icon = Icon(Icons.check_rounded, color: Colors.white, size: 14.sp);
        lineColor = Colors.green;
        break;
      case TimelineStatus.current:
        circleColor = AppColors.secondaryPurple;
        icon = Icon(Icons.local_shipping_rounded, color: Colors.white, size: 14.sp);
        lineColor = AppColors.secondaryPurple;
        isDashed = true;
        break;
      case TimelineStatus.pending:
        circleColor = Colors.white;
        lineColor = AppColors.lightGrey;
        isDashed = true;
        break;
    }

    if (isNextPurple) {
      lineColor = AppColors.secondaryPurple;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24.r,
                height: 24.r,
                decoration: BoxDecoration(
                  color: circleColor,
                  shape: BoxShape.circle,
                  border: status == TimelineStatus.pending
                      ? Border.all(color: AppColors.lightGrey, width: 1.5)
                      : null,
                ),
                child: Center(child: icon),
              ),
              if (!isLast)
                Expanded(
                  child: SizedBox(
                    width: 2,
                    child: CustomPaint(
                      painter: LinePainter(
                        color: lineColor,
                        isDashed: isDashed,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: 30.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: status == TimelineStatus.pending
                                ? AppColors.greyText
                                : AppColors.darkText,
                          ),
                        ),
                        Text(
                          description,
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            color: AppColors.greyText,
                          ),
                        ),
                        if (date != null) ...[
                          SizedBox(height: 4.h),
                          Text(
                            date,
                            style: GoogleFonts.poppins(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: status == TimelineStatus.pending
                                  ? AppColors.greyText
                                  : Colors.green,
                            ),
                          ),
                        ],
                      ],
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

enum TimelineStatus { completed, current, pending }

class LinePainter extends CustomPainter {
  final Color color;
  final bool isDashed;

  LinePainter({required this.color, required this.isDashed});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2;

    if (isDashed) {
      double dashHeight = 4, dashSpace = 4, startY = 0;
      while (startY < size.height) {
        canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
        startY += dashHeight + dashSpace;
      }
    } else {
      canvas.drawLine(Offset(0, 0), Offset(0, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class RealTimeTrackingCard extends StatelessWidget {
  const RealTimeTrackingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            ),
            child: Icon(Icons.location_searching_rounded, color: AppColors.secondaryPurple, size: 22.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Real-time Tracking",
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  "Tracking details are updated in real-time.",
                  style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.greyText),
                ),
                Text(
                  "Last updated: 23 May 2026, 10:05 AM",
                  style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.greyText),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Icon(Icons.refresh_rounded, color: AppColors.darkText, size: 14.sp),
                SizedBox(width: 6.w),
                Text(
                  "Refresh",
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
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

class DeliveryPartnerCard extends StatelessWidget {
  const DeliveryPartnerCard({super.key});

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
        children: [
          Container(
            width: 50.r,
            height: 50.r,
            decoration: BoxDecoration(
              color: const Color(0xFFF3EFFF),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.person_rounded, color: AppColors.secondaryPurple, size: 30.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Your delivery partner",
                  style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.greyText),
                ),
                Text(
                  "Rahul Kumar",
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, color: Colors.green, size: 10.sp),
                      SizedBox(width: 4.w),
                      Text(
                        "4.8",
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: AppColors.secondaryPurple.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.call_rounded, color: AppColors.secondaryPurple, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: AppColors.secondaryPurple.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.chat_bubble_rounded, color: AppColors.secondaryPurple, size: 18.sp),
          ),
        ],
      ),
    );
  }
}

class TrustFooter extends StatelessWidget {
  const TrustFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified_user_rounded, color: AppColors.greyText, size: 14.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              "Tracking information is 100% secure and reliable",
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                color: AppColors.greyText,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
