import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationWelcomeBanner extends StatelessWidget {
  const NotificationWelcomeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5FF),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Stack(
              children: [
                Icon(Icons.notifications_active_rounded, color: AppColors.secondaryPurple, size: 30.sp),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 10.r,
                    height: 10.r,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Stay updated, your way",
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  "Choose what notifications you want to receive and how we can reach you.",
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: AppColors.greyText,
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
}

class NotificationSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const NotificationSectionHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: AppColors.secondaryPurple.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.secondaryPurple, size: 18.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  color: AppColors.greyText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class NotificationToggleItem extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? description;
  final bool value;
  final ValueChanged<bool> onChanged;

  const NotificationToggleItem({
    super.key,
    this.icon,
    required this.title,
    this.description,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.secondaryPurple, size: 20.sp),
            SizedBox(width: 16.w),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
                if (description != null)
                  Text(
                    description!,
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      color: AppColors.greyText,
                    ),
                  ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            activeTrackColor: AppColors.secondaryPurple,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class NotificationChannelsCard extends StatefulWidget {
  const NotificationChannelsCard({super.key});

  @override
  State<NotificationChannelsCard> createState() => _NotificationChannelsCardState();
}

class _NotificationChannelsCardState extends State<NotificationChannelsCard> {
  bool _push = true;
  bool _email = true;
  bool _sms = false;
  bool _whatsapp = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _push = prefs.getBool('notif_ch_push') ?? true;
      _email = prefs.getBool('notif_ch_email') ?? true;
      _sms = prefs.getBool('notif_ch_sms') ?? false;
      _whatsapp = prefs.getBool('notif_ch_whatsapp') ?? true;
    });
  }

  Future<void> _toggle(String key, bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, val);
  }

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
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.secondaryPurple.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.mail_outline_rounded, color: AppColors.secondaryPurple, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Notification Channels",
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                    Text(
                      "Choose how you want to receive notifications",
                      style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.greyText),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(child: _buildChannelItem(Icons.phone_android_rounded, "Push", _push,
                  () { setState(() => _push = !_push); _toggle('notif_ch_push', _push); })),
              Expanded(child: _buildChannelItem(Icons.mail_outline_rounded, "Email", _email,
                  () { setState(() => _email = !_email); _toggle('notif_ch_email', _email); })),
              Expanded(child: _buildChannelItem(Icons.chat_bubble_outline_rounded, "SMS", _sms,
                  () { setState(() => _sms = !_sms); _toggle('notif_ch_sms', _sms); })),
              Expanded(child: _buildChannelItem(Icons.chat_bubble_outline_rounded, "WhatsApp", _whatsapp,
                  () { setState(() => _whatsapp = !_whatsapp); _toggle('notif_ch_whatsapp', _whatsapp); })),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChannelItem(IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? AppColors.darkText : AppColors.lightGrey, size: 20.sp),
          SizedBox(height: 4.h),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 9.sp,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.darkText : AppColors.greyText,
            ),
          ),
          SizedBox(height: 4.h),
          Container(
            width: 16.r,
            height: 16.r,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.secondaryPurple : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: isSelected ? AppColors.secondaryPurple : AppColors.lightGrey, width: 1),
            ),
            child: isSelected ? Icon(Icons.check, color: Colors.white, size: 10.sp) : null,
          ),
        ],
        ),
      ),
    );
  }
}

class DNDCard extends StatefulWidget {
  const DNDCard({super.key});

  @override
  State<DNDCard> createState() => _DNDCardState();
}

class _DNDCardState extends State<DNDCard> {
  TimeOfDay _startTime = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 8, minute: 0);
  bool _enabled = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _enabled = prefs.getBool('dnd_enabled') ?? true;
      _startTime = TimeOfDay(
        hour: prefs.getInt('dnd_start_h') ?? 22,
        minute: prefs.getInt('dnd_start_m') ?? 0,
      );
      _endTime = TimeOfDay(
        hour: prefs.getInt('dnd_end_h') ?? 8,
        minute: prefs.getInt('dnd_end_m') ?? 0,
      );
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dnd_enabled', _enabled);
    await prefs.setInt('dnd_start_h', _startTime.hour);
    await prefs.setInt('dnd_start_m', _startTime.minute);
    await prefs.setInt('dnd_end_h', _endTime.hour);
    await prefs.setInt('dnd_end_m', _endTime.minute);
  }

  String _fmt(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  Future<void> _showDNDSheet() async {
    await showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Do Not Disturb", style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
                  CupertinoSwitch(
                    value: _enabled,
                    activeTrackColor: AppColors.secondaryPurple,
                    onChanged: (v) { setState(() => _enabled = v); setSheet(() {}); _save(); },
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Text("Quiet Hours", style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.greyText)),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final picked = await showTimePicker(context: ctx, initialTime: _startTime);
                        if (picked != null) { setState(() => _startTime = picked); setSheet(() {}); _save(); }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F5FF),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppColors.secondaryPurple.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("From", style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.greyText)),
                            Text(_fmt(_startTime), style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Text("to", style: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.greyText)),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final picked = await showTimePicker(context: ctx, initialTime: _endTime);
                        if (picked != null) { setState(() => _endTime = picked); setSheet(() {}); _save(); }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F5FF),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppColors.secondaryPurple.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("To", style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.greyText)),
                            Text(_fmt(_endTime), style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Text("Repeats every day", style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.greyText)),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showDNDSheet,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F5FF),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.secondaryPurple.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(
                _enabled ? Icons.notifications_off_outlined : Icons.notifications_active_outlined,
                color: AppColors.secondaryPurple,
                size: 22.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Do Not Disturb",
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                  Text(
                    "Pause all non-important notifications for a specific time",
                    style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.greyText, height: 1.4),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${_fmt(_startTime)} - ${_fmt(_endTime)}",
                  style: GoogleFonts.poppins(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                    color: _enabled ? AppColors.darkText : AppColors.greyText,
                  ),
                ),
                Text(
                  _enabled ? "Everyday" : "Disabled",
                  style: GoogleFonts.poppins(fontSize: 9.sp, color: AppColors.greyText),
                ),
              ],
            ),
            SizedBox(width: 8.w),
            Icon(Icons.chevron_right_rounded, color: AppColors.lightGrey, size: 24.sp),
          ],
        ),
      ),
    );
  }
}

class NotificationPrivacyFooter extends StatelessWidget {
  const NotificationPrivacyFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_outline_rounded, color: AppColors.greyText, size: 14.sp),
        SizedBox(width: 8.w),
        Text(
          "We respect your privacy and never spam",
          style: GoogleFonts.poppins(
            fontSize: 11.sp,
            color: AppColors.greyText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
