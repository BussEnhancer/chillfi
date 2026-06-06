import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/profile/widgets/push_notification_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class PushNotificationsScreen extends StatefulWidget {
  const PushNotificationsScreen({super.key});

  @override
  State<PushNotificationsScreen> createState() => _PushNotificationsScreenState();
}

class _PushNotificationsScreenState extends State<PushNotificationsScreen> {
  bool masterToggle = true;
  bool orderUpdates = true;
  bool offersDeals = true;
  bool newArrivals = true;
  bool priceAlerts = true;
  bool recommendations = true;
  bool wishlistAlerts = true;
  bool chillfiUpdates = true;

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
              border: Border.all(color: AppColors.lightGrey.withOpacity(0.5)),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: const Color(0xFF111827), size: 20.sp),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Push Notifications",
              style: GoogleFonts.poppins(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
            ),
            Text(
              "Stay updated with important alerts",
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            const PushHeroBanner(),
            SizedBox(height: 24.h),
            
            // Master Toggle Card
            Container(
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(color: const Color(0xFFE8E8EE)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Allow Push Notifications",
                              style: GoogleFonts.poppins(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF111827),
                              ),
                            ),
                            Text(
                              "Receive notifications on this device",
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      CupertinoSwitch(
                        value: masterToggle,
                        activeTrackColor: AppColors.secondaryPurple,
                        onChanged: (val) => setState(() => masterToggle = val),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  const PushPrivacyCard(),
                ],
              ),
            ),

            SizedBox(height: 32.h),
            Text(
              "Notification Categories",
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
            ),
            SizedBox(height: 16.h),

            // Categories Card
            Container(
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(color: const Color(0xFFE8E8EE)),
              ),
              child: Column(
                children: [
                  PushCategoryTile(
                    icon: Icons.inventory_2_outlined,
                    title: "Order Updates",
                    description: "Get notified about order confirmations, shipping updates and delivery status.",
                    value: orderUpdates,
                    onChanged: (val) => setState(() => orderUpdates = val),
                  ),
                  _divider(),
                  PushCategoryTile(
                    icon: Icons.local_offer_outlined,
                    title: "Offers & Deals",
                    description: "Stay updated with exclusive offers, discounts and promotions.",
                    value: offersDeals,
                    onChanged: (val) => setState(() => offersDeals = val),
                  ),
                  _divider(),
                  PushCategoryTile(
                    icon: Icons.shopping_bag_outlined,
                    title: "New Arrivals",
                    description: "Be the first to know about new products and collections.",
                    value: newArrivals,
                    onChanged: (val) => setState(() => newArrivals = val),
                  ),
                  _divider(),
                  PushCategoryTile(
                    icon: Icons.notifications_active_outlined,
                    title: "Price Alerts",
                    description: "Receive alerts when your favorite products drop in price.",
                    value: priceAlerts,
                    onChanged: (val) => setState(() => priceAlerts = val),
                  ),
                  _divider(),
                  PushCategoryTile(
                    icon: Icons.star_outline_rounded,
                    title: "Recommendations",
                    description: "Get personalized product and category recommendations.",
                    value: recommendations,
                    onChanged: (val) => setState(() => recommendations = val),
                  ),
                  _divider(),
                  PushCategoryTile(
                    icon: Icons.favorite_outline_rounded,
                    title: "Wishlist Alerts",
                    description: "Get notified about price drops and availability of wishlist items.",
                    value: wishlistAlerts,
                    onChanged: (val) => setState(() => wishlistAlerts = val),
                  ),
                  _divider(),
                  PushCategoryTile(
                    icon: Icons.campaign_outlined,
                    title: "ChillFI Updates",
                    description: "Important announcements, feature updates and service alerts.",
                    value: chillfiUpdates,
                    onChanged: (val) => setState(() => chillfiUpdates = val),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),
            const PushInfoRowCard(
              icon: Icons.nights_stay_outlined,
              title: "Quiet Hours",
              subtitle: "Choose time when you don't want to receive notifications",
              trailingText: "11:00 PM – 7:00 AM",
            ),
            SizedBox(height: 16.h),
            const PushInfoRowCard(
              icon: Icons.notifications_none_rounded,
              title: "Not receiving notifications?",
              subtitle: "Make sure notifications are enabled for ChillFI in your device settings.",
              backgroundColor: Color(0xFFF7F2FF),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(height: 1, color: const Color(0xFFE8E8EE));
  }
}
