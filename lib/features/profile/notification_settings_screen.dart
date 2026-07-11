import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/profile/widgets/notification_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  // Order Updates Toggles
  bool orderConfirmation = true;
  bool orderProcessing = true;
  bool shippingUpdates = true;
  bool outForDelivery = true;
  bool delivered = true;

  // Promotions Toggles
  bool exclusiveOffers = true;
  bool saleAlerts = true;
  bool priceDrop = false;

  // Account Toggles
  bool accountUpdates = true;
  bool reviewsRatings = false;
  bool wishlistReminders = false;

  @override
  Widget build(BuildContext context) {
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
              color: Colors.white,
              border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.5)),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
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
              "Notification Settings",
              style: GoogleFonts.poppins(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
            Text(
              "Manage how you stay updated with CHILLFI",
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.greyText,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            SizedBox(height: 20.h),
            const NotificationWelcomeBanner(),
            
            SizedBox(height: 32.h),
            const NotificationSectionHeader(
              icon: Icons.local_shipping_outlined,
              title: "Order & Delivery Updates",
              subtitle: "Updates about your orders and deliveries",
            ),
            SizedBox(height: 16.h),
            _buildSettingsCard([
              NotificationToggleItem(
                icon: Icons.assignment_turned_in_outlined,
                title: "Order Confirmations",
                description: "Get notified when your order is confirmed",
                value: orderConfirmation,
                onChanged: (val) => setState(() => orderConfirmation = val),
              ),
              NotificationToggleItem(
                icon: Icons.inventory_2_outlined,
                title: "Order Processing",
                description: "Updates when your order is being processed",
                value: orderProcessing,
                onChanged: (val) => setState(() => orderProcessing = val),
              ),
              NotificationToggleItem(
                icon: Icons.local_shipping_outlined,
                title: "Shipping Updates",
                description: "Notifications when your order is shipped",
                value: shippingUpdates,
                onChanged: (val) => setState(() => shippingUpdates = val),
              ),
              NotificationToggleItem(
                icon: Icons.location_on_outlined,
                title: "Out for Delivery",
                description: "Get notified when your order is out for delivery",
                value: outForDelivery,
                onChanged: (val) => setState(() => outForDelivery = val),
              ),
              NotificationToggleItem(
                icon: Icons.check_circle_outline_rounded,
                title: "Delivered",
                description: "Get notified when your order is delivered",
                value: delivered,
                onChanged: (val) => setState(() => delivered = val),
              ),
            ]),

            SizedBox(height: 32.h),
            const NotificationSectionHeader(
              icon: Icons.campaign_outlined,
              title: "Promotions & Offers",
              subtitle: "Deals, offers and exciting updates for you",
            ),
            SizedBox(height: 16.h),
            _buildSettingsCard([
              NotificationToggleItem(
                icon: Icons.local_offer_outlined,
                title: "Exclusive Offers",
                description: "Receive exclusive offers and discounts",
                value: exclusiveOffers,
                onChanged: (val) => setState(() => exclusiveOffers = val),
              ),
              NotificationToggleItem(
                icon: Icons.redeem_rounded,
                title: "Sale Alerts",
                description: "Get notified about big sales and events",
                value: saleAlerts,
                onChanged: (val) => setState(() => saleAlerts = val),
              ),
              NotificationToggleItem(
                icon: Icons.notifications_active_outlined,
                title: "Price Drop Alerts",
                description: "Get notified when items in wishlist drop price",
                value: priceDrop,
                onChanged: (val) => setState(() => priceDrop = val),
              ),
            ]),

            SizedBox(height: 32.h),
            const NotificationSectionHeader(
              icon: Icons.notifications_none_rounded,
              title: "Account & Other Updates",
              subtitle: "Important updates about your account",
            ),
            SizedBox(height: 16.h),
            _buildSettingsCard([
              NotificationToggleItem(
                icon: Icons.person_outline_rounded,
                title: "Account Updates",
                description: "Important updates about your account",
                value: accountUpdates,
                onChanged: (val) => setState(() => accountUpdates = val),
              ),
              NotificationToggleItem(
                icon: Icons.chat_bubble_outline_rounded,
                title: "Reviews & Ratings",
                description: "Get reminders for reviews and ratings",
                value: reviewsRatings,
                onChanged: (val) => setState(() => reviewsRatings = val),
              ),
              NotificationToggleItem(
                icon: Icons.favorite_border_rounded,
                title: "Wishlist Reminders",
                description: "Get reminders for items in your wishlist",
                value: wishlistReminders,
                onChanged: (val) => setState(() => wishlistReminders = val),
              ),
            ]),

            SizedBox(height: 24.h),
            const NotificationChannelsCard(),
            SizedBox(height: 16.h),
            const DNDCard(),
            SizedBox(height: 32.h),
            const NotificationPrivacyFooter(),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}
