import 'package:chillfi/core/widgets/app_error_dialog.dart';
import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/services/api_service.dart';
import 'package:chillfi/features/orders/widgets/tracking_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class _TrackingScan {
  final String location;
  final String instructions;
  final String status;
  final DateTime? time;

  _TrackingScan({
    required this.location,
    required this.instructions,
    required this.status,
    required this.time,
  });

  factory _TrackingScan.fromJson(Map<String, dynamic> j) => _TrackingScan(
        location: j['location']?.toString() ?? '',
        instructions: j['instructions']?.toString() ?? '',
        status: j['status']?.toString() ?? '',
        time: j['time'] != null ? DateTime.tryParse(j['time'].toString())?.toLocal() : null,
      );
}

class _TrackingData {
  final String waybill;
  final String status;
  final String? expectedDelivery;
  final DateTime? lastUpdate;
  final List<_TrackingScan> scans;

  _TrackingData({
    required this.waybill,
    required this.status,
    this.expectedDelivery,
    this.lastUpdate,
    required this.scans,
  });

  factory _TrackingData.fromJson(Map<String, dynamic> j) {
    final rawScans = j['scans'];
    final scans = (rawScans is List)
        ? rawScans.map((s) => _TrackingScan.fromJson(s as Map<String, dynamic>)).toList()
        : <_TrackingScan>[];
    return _TrackingData(
      waybill: j['waybill']?.toString() ?? '',
      // Prefer ChillFi's normalized stage label; fall back to the raw courier status
      status: (j['shipping_status_label'] ?? j['status'])?.toString() ?? 'Unknown',
      expectedDelivery: j['expected_delivery'] != null
          ? (DateTime.tryParse(j['expected_delivery'].toString()) != null
              ? DateFormat('d MMM yyyy').format(DateTime.parse(j['expected_delivery'].toString()).toLocal())
              : j['expected_delivery'].toString())
          : null,
      lastUpdate: j['last_update'] != null ? DateTime.tryParse(j['last_update'].toString())?.toLocal() : null,
      scans: scans,
    );
  }
}

class DelhiveryTrackingTimelineScreen extends StatefulWidget {
  final String? orderId;
  final String? trackingId;
  final String? orderNumber;
  final String? orderStatus;
  final DateTime? createdAt;
  /// 'shiprocket' | 'delhivery' — determines branding on the tracking screen
  final String shipmentProvider;

  const DelhiveryTrackingTimelineScreen({
    super.key,
    this.orderId,
    this.trackingId,
    this.orderNumber,
    this.orderStatus,
    this.createdAt,
    this.shipmentProvider = 'delhivery',
  });

  @override
  State<DelhiveryTrackingTimelineScreen> createState() => _DelhiveryTrackingTimelineScreenState();
}

class _DelhiveryTrackingTimelineScreenState extends State<DelhiveryTrackingTimelineScreen> {
  final _api = ApiService();
  _TrackingData? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.orderId == null) {
      setState(() { _loading = false; _error = 'Order ID not provided'; });
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final res = await _api.get('/orders/${widget.orderId}/tracking');
      final body = res.data as Map<String, dynamic>;
      if (body['success'] == true && body['data'] != null) {
        setState(() { _data = _TrackingData.fromJson(body['data'] as Map<String, dynamic>); });
      } else {
        setState(() { _error = AppError.message(body['message']?.toString(), fallback: "We couldn't load tracking right now. Please try again."); });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = AppError.message(e, fallback: "We couldn't load tracking right now. Please try again."); });
    } finally {
      setState(() { _loading = false; });
    }
  }

  String _fmt(DateTime dt) => DateFormat('d MMM yyyy, hh:mm a').format(dt.toLocal());

  @override
  Widget build(BuildContext context) {
    final waybill = _data?.waybill ?? widget.trackingId ?? '';
    final status = _data?.status ?? widget.orderStatus ?? 'Processing';
    final expectedDelivery = _data?.expectedDelivery;
    final scans = _data?.scans ?? [];
    final lastUpdated = _data?.lastUpdate != null
        ? _fmt(_data!.lastUpdate!)
        : scans.isNotEmpty && scans.first.time != null
            ? _fmt(scans.first.time!)
            : null;
    final isShiprocket = widget.shipmentProvider == 'shiprocket';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 70.w,
        leading: Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.5)),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: AppColors.darkText, size: 20.sp),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Track Order",
              style: GoogleFonts.poppins(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
            Text(
              isShiprocket ? "Shiprocket live updates" : "Delhivery live updates",
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.greyText,
              ),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: _load,
            child: Row(
              children: [
                Icon(Icons.refresh_rounded, color: AppColors.secondaryPurple, size: 18.sp),
                SizedBox(width: 6.w),
                Text(
                  "Refresh",
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryPurple,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 20.w),
        ],
      ),
      body: _loading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.secondaryPurple, strokeWidth: 2),
                  SizedBox(height: 16.h),
                  Text(
                    isShiprocket ? "Fetching from Shiprocket..." : "Fetching from Delhivery...",
                    style: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.greyText),
                  ),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_off_rounded, size: 48.sp, color: AppColors.greyText),
                        SizedBox(height: 16.h),
                        Text(
                          _error!, // ignore: unnecessary_null_check_on_nullable_value
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: AppColors.greyText,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24.h),
                        TextButton.icon(
                          onPressed: _load,
                          icon: Icon(Icons.refresh_rounded, color: AppColors.secondaryPurple),
                          label: Text(
                            "Try Again",
                            style: GoogleFonts.poppins(
                              color: AppColors.secondaryPurple,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    children: [
                      SizedBox(height: 20.h),
                      // Header card with real data
                      _LiveHeaderCard(
                        waybill: waybill,
                        status: status,
                        expectedDelivery: expectedDelivery,
                        isShiprocket: isShiprocket,
                      ),
                      SizedBox(height: 16.h),
                      // Order info card
                      _OrderInfoCard(orderNumber: widget.orderNumber),
                      SizedBox(height: 24.h),
                      // Real courier scans; before the first scan show only facts we know (no invented dates)
                      _LiveScanTimeline(
                        scans: scans.isNotEmpty
                            ? scans
                            : [
                                _TrackingScan(
                                  location: '',
                                  instructions: 'Tracking updates will appear once the courier scans your package',
                                  status: 'Order placed',
                                  time: widget.createdAt,
                                ),
                              ],
                      ),
                      SizedBox(height: 24.h),
                      // Last-updated info
                      _LastUpdatedCard(lastUpdated: lastUpdated),
                      SizedBox(height: 16.h),
                      const TrustFooter(),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
    );
  }
}

class _LiveHeaderCard extends StatelessWidget {
  final String waybill;
  final String status;
  final String? expectedDelivery;
  final bool isShiprocket;

  const _LiveHeaderCard({
    required this.waybill,
    required this.status,
    this.expectedDelivery,
    this.isShiprocket = true,
  });

  Color get _statusColor {
    switch (status.toLowerCase()) {
      case 'delivered': return Colors.green;
      case 'transit': case 'in transit': case 'shipped': return Colors.blue;
      case 'out for delivery': return Colors.orange;
      default: return AppColors.secondaryPurple;
    }
  }

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Provider logo circle
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: isShiprocket ? const Color(0xFF002B5C) : Colors.black,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                isShiprocket ? "S" : "D",
                style: GoogleFonts.poppins(
                  color: isShiprocket ? const Color(0xFF00C2FF) : Colors.red,
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
                  isShiprocket ? "SHIPROCKET" : "DELHIVERY",
                  style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w800, color: AppColors.darkText, letterSpacing: 1),
                ),
                if (waybill.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: waybill));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(isShiprocket ? "AWB copied" : "Waybill copied"), duration: const Duration(seconds: 1)),
                      );
                    },
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            "${isShiprocket ? 'AWB' : 'Waybill'}: $waybill",
                            style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.greyText),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(Icons.copy_rounded, size: 12.sp, color: AppColors.greyText),
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
                  color: _statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(status, style: GoogleFonts.poppins(fontSize: 10.sp, fontWeight: FontWeight.w700, color: _statusColor)),
              ),
              if (expectedDelivery != null && expectedDelivery!.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Text("Expected Delivery", style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.greyText)),
                Text(expectedDelivery!, style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w700, color: AppColors.secondaryPurple)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderInfoCard extends StatelessWidget {
  final String? orderNumber;
  const _OrderInfoCard({this.orderNumber});

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
            child: Icon(Icons.inventory_2_rounded, size: 28.sp, color: Colors.grey[300]),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Your Order", style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
                if (orderNumber != null)
                  Text("Order #$orderNumber", style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w600, color: AppColors.darkText)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveScanTimeline extends StatelessWidget {
  final List<_TrackingScan> scans;
  const _LiveScanTimeline({required this.scans});

  String _fmt(DateTime dt) => DateFormat('d MMM yyyy, hh:mm a').format(dt.toLocal());

  @override
  Widget build(BuildContext context) {
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
          Text("Live Scan Events", style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w600, color: AppColors.darkText)),
          SizedBox(height: 24.h),
          ...List.generate(scans.length, (i) {
            final scan = scans[i];
            final isFirst = i == 0;
            final isLast = i == scans.length - 1;
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
                          color: isFirst ? AppColors.secondaryPurple : Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            isFirst ? Icons.local_shipping_rounded : Icons.check_rounded,
                            color: Colors.white,
                            size: 14.sp,
                          ),
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: SizedBox(
                            width: 2,
                            child: CustomPaint(painter: LinePainter(color: Colors.green, isDashed: isFirst)),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 24.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(scan.status, style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
                          if (scan.instructions.isNotEmpty)
                            Text(scan.instructions, style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.greyText)),
                          if (scan.location.isNotEmpty)
                            Text(scan.location, style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.greyText)),
                          if (scan.time != null) ...[
                            SizedBox(height: 4.h),
                            Text(_fmt(scan.time!), style: GoogleFonts.poppins(fontSize: 10.sp, fontWeight: FontWeight.w600, color: Colors.green)),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _LastUpdatedCard extends StatelessWidget {
  final String? lastUpdated;
  const _LastUpdatedCard({this.lastUpdated});

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
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
            child: Icon(Icons.location_searching_rounded, color: AppColors.secondaryPurple, size: 22.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Real-time Tracking", style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
                Text("Tracking details are updated in real-time.", style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.greyText)),
                if (lastUpdated != null)
                  Text("Last updated: $lastUpdated", style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.greyText)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
