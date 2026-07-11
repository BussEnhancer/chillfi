import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/services/wishlist_service.dart';
import 'package:chillfi/features/profile/widgets/offer_notification_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class OfferNotificationsScreen extends StatefulWidget {
  const OfferNotificationsScreen({super.key});

  @override
  State<OfferNotificationsScreen> createState() => _OfferNotificationsScreenState();
}

class _OfferNotificationsScreenState extends State<OfferNotificationsScreen> {
  final _profileService = ProfileService();

  bool masterToggle = true;
  bool exclusiveOffers = true;
  bool discountsDeals = true;
  bool seasonalSales = true;
  bool flashSales = true;
  bool festiveOffers = true;
  bool bankPartnerOffers = true;
  TimeOfDay quietStart = const TimeOfDay(hour: 23, minute: 0);
  TimeOfDay quietEnd = const TimeOfDay(hour: 7, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await _profileService.getNotificationPreferences();
    if (!mounted) return;
    setState(() {
      masterToggle = prefs['offerMaster'] as bool? ?? true;
      exclusiveOffers = prefs['exclusiveOffers'] as bool? ?? true;
      discountsDeals = prefs['discountsDeals'] as bool? ?? true;
      seasonalSales = prefs['seasonalSales'] as bool? ?? true;
      flashSales = prefs['flashSales'] as bool? ?? true;
      festiveOffers = prefs['festiveOffers'] as bool? ?? true;
      bankPartnerOffers = prefs['bankPartnerOffers'] as bool? ?? true;
      quietStart = _parseTime(prefs['offerQuietStart'] as String?) ?? quietStart;
      quietEnd = _parseTime(prefs['offerQuietEnd'] as String?) ?? quietEnd;
    });
  }

  TimeOfDay? _parseTime(String? value) {
    if (value == null) return null;
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTime(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  void _savePrefs() {
    _profileService.updateNotificationPreferences({
      'offerMaster': masterToggle,
      'exclusiveOffers': exclusiveOffers,
      'discountsDeals': discountsDeals,
      'seasonalSales': seasonalSales,
      'flashSales': flashSales,
      'festiveOffers': festiveOffers,
      'bankPartnerOffers': bankPartnerOffers,
      'offerQuietStart': _formatTime(quietStart),
      'offerQuietEnd': _formatTime(quietEnd),
    });
  }

  String get _quietHoursLabel => '${quietStart.format(context)} – ${quietEnd.format(context)}';

  Future<void> _pickQuietHours() async {
    final start = await showTimePicker(context: context, initialTime: quietStart, helpText: 'Quiet hours start');
    if (start == null || !mounted) return;
    final end = await showTimePicker(context: context, initialTime: quietEnd, helpText: 'Quiet hours end');
    if (end == null || !mounted) return;
    setState(() { quietStart = start; quietEnd = end; });
    _savePrefs();
  }

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
              "Offer Notifications",
              style: GoogleFonts.poppins(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
            ),
            Text(
              "Get notified about exciting offers & deals",
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
            const OfferHeroBanner(),
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
                              "Allow Offer Notifications",
                              style: GoogleFonts.poppins(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF111827),
                              ),
                            ),
                            Text(
                              "Receive notifications for offers and promotions",
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
                        onChanged: (val) { setState(() => masterToggle = val); _savePrefs(); },
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  _buildPrivacyBox(),
                ],
              ),
            ),

            SizedBox(height: 32.h),
            Text(
              "Notification Types",
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
            ),
            SizedBox(height: 16.h),

            // Notification Types Card
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
                  OfferTypeTile(
                    icon: Icons.local_offer_outlined,
                    title: "Exclusive Offers",
                    description: "Get notified about exclusive offers just for you.",
                    value: exclusiveOffers,
                    onChanged: (val) { setState(() => exclusiveOffers = val); _savePrefs(); },
                  ),
                  _divider(),
                  OfferTypeTile(
                    icon: Icons.label_important_outline_rounded,
                    title: "Discounts & Deals",
                    description: "Receive alerts for discounts and limited-time deals.",
                    value: discountsDeals,
                    onChanged: (val) { setState(() => discountsDeals = val); _savePrefs(); },
                  ),
                  _divider(),
                  OfferTypeTile(
                    icon: Icons.shopping_cart_outlined,
                    title: "Seasonal Sales",
                    description: "Stay updated about seasonal sales and special events.",
                    value: seasonalSales,
                    onChanged: (val) { setState(() => seasonalSales = val); _savePrefs(); },
                  ),
                  _divider(),
                  OfferTypeTile(
                    icon: Icons.flash_on_rounded,
                    title: "Flash Sales",
                    description: "Be the first to know about flash sales and surprise offers.",
                    value: flashSales,
                    onChanged: (val) { setState(() => flashSales = val); _savePrefs(); },
                  ),
                  _divider(),
                  OfferTypeTile(
                    icon: Icons.card_giftcard_rounded,
                    title: "Festive Offers",
                    description: "Get notified about offers during festivals and celebrations.",
                    value: festiveOffers,
                    onChanged: (val) { setState(() => festiveOffers = val); _savePrefs(); },
                  ),
                  _divider(),
                  OfferTypeTile(
                    icon: Icons.star_outline_rounded,
                    title: "Bank & Partner Offers",
                    description: "Receive notifications for bank offers and partner promotions.",
                    value: bankPartnerOffers,
                    onChanged: (val) { setState(() => bankPartnerOffers = val); _savePrefs(); },
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),
            Text(
              "Offer Preferences",
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
            ),
            SizedBox(height: 16.h),

            // Preferences Card
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
                  const OfferPreferenceRow(
                    icon: Icons.filter_alt_outlined,
                    title: "Choose Offer Categories",
                    subtitle: "Select the categories you're interested in",
                  ),
                  _divider(),
                  OfferPreferenceRow(
                    icon: Icons.notifications_off_outlined,
                    title: "Quiet Hours",
                    subtitle: "Choose time when you don't want to receive offer notifications",
                    trailingText: _quietHoursLabel,
                    onTap: _pickQuietHours,
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),
            _buildDeviceAlertCard(),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyBox() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2FF),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(Icons.verified_user_rounded, color: AppColors.secondaryPurple, size: 20.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "We respect your preferences",
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                Text(
                  "You'll only receive relevant offers. You can update your preferences anytime.",
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: const Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceAlertCard() {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2FF),
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(Icons.notifications_none_rounded, color: AppColors.secondaryPurple, size: 22.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Not receiving offer notifications?",
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                Text(
                  "Make sure notifications are enabled for ChillFI in your device settings.",
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: const Color(0xFF6B7280), size: 24.sp),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(height: 1, color: const Color(0xFFE8E8EE));
  }
}
