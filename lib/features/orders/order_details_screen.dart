import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/models/cart_model.dart';
import 'package:chillfi/core/providers/cart_provider.dart';
import 'package:chillfi/core/services/api_service.dart';
import 'package:chillfi/core/widgets/app_error_dialog.dart';
import 'package:chillfi/features/orders/cancel_order_screen.dart';
import 'package:chillfi/features/orders/delhivery_tracking_screen.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().loadOrder(widget.orderId);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Shipment status changes server-side (Delhivery webhooks); refresh when the user comes back.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<CartProvider>().loadOrder(widget.orderId);
    }
  }

  bool _downloadingInvoice = false;

  /// Fetches the GST invoice PDF and opens the system share/save sheet.
  Future<void> _downloadInvoice(OrderModel order) async {
    if (_downloadingInvoice) return;
    setState(() => _downloadingInvoice = true);
    try {
      final bytes = await ApiService().getBytes('/orders/${order.id}/invoice');
      // A real, properly named file so "Save to Drive / Files" keeps the invoice name.
      final f = File('${Directory.systemTemp.path}/Invoice-${order.orderNumber}.pdf');
      await f.writeAsBytes(bytes, flush: true);
      await Share.shareXFiles([XFile(f.path, mimeType: 'application/pdf')], subject: 'ChillFi invoice ${order.orderNumber}');
    } catch (e) {
      if (mounted) AppErrorDialog.show(context, error: e, title: "Couldn't download the invoice");
    } finally {
      if (mounted) setState(() => _downloadingInvoice = false);
    }
  }

  Future<void> _cancelOrder(OrderModel order) async {
    final cancelled = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => CancelOrderScreen(orderId: widget.orderId, isPaid: order.paymentStatus == 'Paid' && order.paymentMethod != 'COD')),
    );
    if (cancelled == true && mounted) {
      context.read<CartProvider>().loadOrder(widget.orderId);
    }
  }

  Future<void> _requestRefund(OrderModel order) async {
    String type = 'Refund';
    final reasonController = TextEditingController();
    String? error;
    bool submitting = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h + MediaQuery.of(sheetContext).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(order.status == 'Cancelled' ? 'Request Refund' : 'Request Refund / Return', style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
              SizedBox(height: 16.h),
              Row(
                children: (order.status == 'Cancelled' ? ['Refund'] : ['Refund', 'Return', 'Exchange']).map((t) {
                  final selected = type == t;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: t != 'Exchange' ? 8.w : 0),
                      child: GestureDetector(
                        onTap: () => setSheetState(() => type = t),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: selected ? AppColors.secondaryPurple : Colors.grey.shade300, width: 1.5),
                            color: selected ? AppColors.secondaryPurple.withValues(alpha: 0.08) : null,
                          ),
                          child: Text(t, style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w700, color: selected ? AppColors.secondaryPurple : AppColors.greyText)),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: reasonController,
                maxLines: 4,
                onChanged: (_) => setSheetState(() {}),
                decoration: InputDecoration(
                  hintText: "Tell us why you'd like a ${type.toLowerCase()}...",
                  hintStyle: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.greyText),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide.none),
                ),
              ),
              if (error != null) Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Text(error!, style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.red)),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: submitting || reasonController.text.trim().isEmpty ? null : () async {
                    setSheetState(() => submitting = true);
                    final err = await context.read<CartProvider>().requestRefund(order.id, type, reasonController.text.trim());
                    if (err != null) {
                      setSheetState(() { submitting = false; error = err; });
                    } else if (sheetContext.mounted) {
                      Navigator.pop(sheetContext);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  ),
                  child: submitting
                      ? SizedBox(width: 20.w, height: 20.h, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Submit Request', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Mirrors backend utils/shipmentStatus.js labels
  String? _shippingLabel(String? s) => const {
        'manifested': 'Shipment created',
        'pickup_pending': 'Awaiting pickup',
        'in_transit': 'In transit',
        'at_destination_hub': 'Reached delivery hub',
        'out_for_delivery': 'Out for delivery',
        'delivered': 'Delivered',
        'rto_in_transit': 'Returning to seller',
        'rto_delivered': 'Returned to seller',
        'cancelled': 'Shipment cancelled',
      }[s];

  Color _statusColor(String status) {
    switch (status) {
      case 'Processing': return Colors.blue;
      case 'Shipped': return Colors.orange;
      case 'Delivered': return Colors.green;
      case 'Cancelled': return Colors.red;
      default: return AppColors.greyText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(builder: (context, cart, _) {
      final order = cart.currentOrder;

      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_rounded, color: AppColors.darkText, size: 22.sp),
          ),
          title: Text('Order Details', style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
        ),
        body: order == null
            ? const Center(child: CircularProgressIndicator(color: AppColors.secondaryPurple))
            : SingleChildScrollView(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  children: [
                    // Status card
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(order.orderNumber, style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                                decoration: BoxDecoration(color: _statusColor(order.status).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8.r)),
                                child: Text(order.status, style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: _statusColor(order.status))),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          _infoRow('Payment', order.paymentMethod),
                          _infoRow('Payment Status', order.paymentStatus),
                          _infoRow('Date', '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}'),
                          if (order.trackingId != null) _infoRow('Tracking ID (AWB)', order.trackingId!),
                          if (_shippingLabel(order.shippingStatus) != null) _infoRow('Shipment', _shippingLabel(order.shippingStatus)!),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Items
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Items (${order.items.length})', style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
                          SizedBox(height: 12.h),
                          ...order.items.map((item) => Padding(
                                padding: EdgeInsets.symmetric(vertical: 6.h),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text('${item.productName} × ${item.quantity}',
                                          style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.darkText)),
                                    ),
                                    Text('₹${(item.price * item.quantity).toStringAsFixed(0)}',
                                        style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.darkText)),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Price summary
                    _Card(
                      child: Column(
                        children: [
                          _infoRow('Subtotal', '₹${order.subtotal.toStringAsFixed(0)}'),
                          if (order.discount > 0) _infoRow('Discount', '-₹${order.discount.toStringAsFixed(0)}', valueColor: Colors.green),
                          _infoRow('Delivery', order.deliveryFee == 0 ? 'FREE' : '₹${order.deliveryFee.toStringAsFixed(0)}', valueColor: order.deliveryFee == 0 ? Colors.green : null),
                          // Orders before 25 Sep 2026 added GST on top; newer orders include it in the price.
                          if (order.taxAmount > 0) _infoRow(
                              (order.total - (order.subtotal + order.deliveryFee - order.discount)).abs() < 0.01 ? 'Includes GST' : 'GST',
                              '₹${order.taxAmount.toStringAsFixed(0)}'),
                          Divider(height: 20.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
                              Text('₹${order.total.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w800, color: AppColors.darkText)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Track button — available as soon as Delhivery assigns an AWB
                    if (order.trackingId != null || order.status == 'Shipped' || order.status == 'Delivered') ...[
                      SizedBox(height: 20.h),
                      SizedBox(
                        width: double.infinity,
                        height: 52.h,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(
                            builder: (_) => DelhiveryTrackingTimelineScreen(
                              orderId: order.id,
                              trackingId: order.trackingId,
                              orderNumber: order.orderNumber,
                              orderStatus: order.status,
                              createdAt: order.createdAt,
                              shipmentProvider: order.shipmentProvider,
                            ),
                          )),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondaryPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                          ),
                          icon: Icon(Icons.local_shipping_outlined, size: 20.sp),
                          label: Text('Track Order', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                      ),
                    ],

                    // GST tax invoice (shipped/delivered orders, when the store has invoicing on)
                    if (order.invoiceAvailable) ...[
                      SizedBox(height: 12.h),
                      SizedBox(
                        width: double.infinity,
                        height: 52.h,
                        child: OutlinedButton.icon(
                          onPressed: () => _downloadInvoice(order),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.secondaryPurple,
                            side: BorderSide(color: AppColors.secondaryPurple.withValues(alpha: 0.4)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                          ),
                          icon: Icon(Icons.receipt_long_outlined, size: 20.sp),
                          label: Text('Download Invoice', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],

                    // Cancel button
                    if (order.status == 'Processing') ...[
                      SizedBox(height: 20.h),
                      SizedBox(
                        width: double.infinity,
                        height: 52.h,
                        child: OutlinedButton(
                          onPressed: () => _cancelOrder(order),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: BorderSide(color: Colors.red.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                          ),
                          child: Text('Cancel Order', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.red.shade400)),
                        ),
                      ),
                    ],

                    // Refund / Return request
                    // Cancelled orders only need a refund when money was actually taken online.
                    if (order.status == 'Delivered' ||
                        (order.status == 'Cancelled' && (order.paymentStatus == 'Paid' || order.refundRequest != null))) ...[
                      SizedBox(height: 20.h),
                      if (order.refundRequest != null && order.refundRequest!.status != 'Rejected')
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
                          decoration: BoxDecoration(
                            color: (order.refundRequest!.status == 'Refunded' ? Colors.green : Colors.amber).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: Text(
                            '${order.refundRequest!.type} ${order.refundRequest!.status}',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp, fontWeight: FontWeight.w700,
                              color: order.refundRequest!.status == 'Refunded' ? Colors.green.shade700 : Colors.amber.shade800,
                            ),
                          ),
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          height: 52.h,
                          child: OutlinedButton(
                            onPressed: () => _requestRefund(order),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.secondaryPurple,
                              side: BorderSide(color: AppColors.secondaryPurple.withValues(alpha: 0.4)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                            ),
                            child: Text(order.status == 'Cancelled' ? 'Request Refund' : 'Request Refund / Return', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.secondaryPurple)),
                          ),
                        ),
                    ],
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
      );
    });
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.greyText)),
          Text(value, style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: valueColor ?? AppColors.darkText)),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
      child: child,
    );
  }
}
