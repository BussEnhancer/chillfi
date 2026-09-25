import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/providers/wishlist_provider.dart';
import 'package:chillfi/features/orders/order_details_screen.dart';
import 'package:chillfi/features/profile/notification_settings_screen.dart';
import 'package:chillfi/core/widgets/app_back_button.dart';
import 'package:chillfi/core/widgets/app_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// In-app notification inbox (order confirmations, shipment updates, promos).
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await context.read<WishlistProvider>().loadNotifications();
    if (mounted) setState(() => _loading = false);
  }

  IconData _icon(String? shippingStatus, String? type) {
    switch (shippingStatus) {
      case 'delivered':
        return Icons.check_circle_rounded;
      case 'out_for_delivery':
        return Icons.delivery_dining_rounded;
      case 'in_transit':
      case 'manifested':
        return Icons.local_shipping_rounded;
      case 'delivery_attempt_failed':
      case 'rto_in_transit':
      case 'rto_delivered':
      case 'cancelled':
        return Icons.error_outline_rounded;
    }
    return type == 'order' ? Icons.receipt_long_rounded : Icons.notifications_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 60.w,
        leading: Padding(padding: EdgeInsets.only(left: 16.w), child: const AppBackButton()),
        title: Text('Notifications',
            style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
        actions: [
          IconButton(
            tooltip: 'Notification settings',
            icon: Icon(Icons.tune_rounded, size: 20.sp, color: AppColors.darkText),
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const NotificationSettingsScreen())),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<WishlistProvider>(builder: (context, p, _) {
              final items = p.notifications;
              return RefreshIndicator(
                onRefresh: () => p.loadNotifications(),
                child: items.isEmpty
                    ? ListView(children: [
                        SizedBox(height: 140.h),
                        const AppEmptyState(
                          compact: true,
                          icon: Icons.notifications_none_rounded,
                          title: 'No notifications yet',
                          message: 'Order and delivery updates will show up here',
                        ),
                      ])
                    : ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => SizedBox(height: 10.h),
                        itemBuilder: (context, i) {
                          final n = items[i];
                          return InkWell(
                            borderRadius: BorderRadius.circular(14.r),
                            onTap: n.orderId == null
                                ? null
                                : () => Navigator.push(context,
                                    MaterialPageRoute(builder: (_) => OrderDetailsScreen(orderId: n.orderId!))),
                            child: Container(
                              padding: EdgeInsets.all(14.w),
                              decoration: BoxDecoration(
                                color: n.isRead ? Colors.white : AppColors.secondaryPurple.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(_icon(n.shippingStatus, n.type), color: AppColors.secondaryPurple, size: 22.sp),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(n.title,
                                            style: GoogleFonts.poppins(
                                                fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
                                        SizedBox(height: 2.h),
                                        Text(n.body,
                                            style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.greyText)),
                                        SizedBox(height: 6.h),
                                        Text(DateFormat('d MMM, hh:mm a').format(n.createdAt.toLocal()),
                                            style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.greyText)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              );
            }),
    );
  }
}
