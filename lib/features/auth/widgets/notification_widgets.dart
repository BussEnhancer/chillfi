import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationIllustration extends StatefulWidget {
  const NotificationIllustration({super.key});

  @override
  State<NotificationIllustration> createState() => _NotificationIllustrationState();
}

class _NotificationIllustrationState extends State<NotificationIllustration> with TickerProviderStateMixin {
  late AnimationController _bellController;
  late AnimationController _badgeController;
  late Animation<double> _bellRotation;
  late Animation<double> _badgeScale;

  @override
  void initState() {
    super.initState();
    _bellController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _bellRotation = Tween<double>(begin: -0.1, end: 0.1).animate(
      CurvedAnimation(parent: _bellController, curve: Curves.easeInOut),
    );

    _badgeScale = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _badgeController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bellController.dispose();
    _badgeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220.h,
      width: 1.sw,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Glow
          Container(
            width: 150.r,
            height: 150.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primaryOrange.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // 3D Bell Illustration
          RotationTransition(
            turns: _bellRotation,
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Icon(
                  Icons.notifications_active_rounded,
                  size: 100.sp,
                  color: AppColors.primaryOrange,
                ),
                // Badge
                ScaleTransition(
                  scale: _badgeScale,
                  child: Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '1',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Floating Cards
          Positioned(
            left: 50.w,
            top: 40.h,
            child: _buildNotificationBubble(Icons.notifications_none_rounded, AppColors.secondaryPurple),
          ),
          Positioned(
            right: 50.w,
            bottom: 40.h,
            child: _buildNotificationBubble(Icons.favorite_rounded, Colors.redAccent),
          ),

          // Sound Waves
          Positioned(
            left: 80.w,
            top: 60.h,
            child: _buildSoundWave(true),
          ),
          Positioned(
            right: 80.w,
            top: 100.h,
            child: _buildSoundWave(false),
          ),

          // Paper Plane
          Positioned(
            top: 20.h,
            right: 40.w,
            child: Icon(Icons.send_rounded, color: AppColors.secondaryPurple, size: 24.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationBubble(IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 20.sp),
    );
  }

  Widget _buildSoundWave(bool isLeft) {
    return Transform.rotate(
      angle: isLeft ? -0.5 : 0.5,
      child: Icon(
        Icons.graphic_eq_rounded,
        color: AppColors.primaryOrange.withValues(alpha: 0.3),
        size: 30.sp,
      ),
    );
  }
}

class NotificationBenefitRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const NotificationBenefitRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: AppColors.secondaryPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: AppColors.secondaryPurple, size: 22.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: AppColors.greyText,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle_rounded,
            color: const Color(0xFF32C759),
            size: 20.sp,
          ),
        ],
      ),
    );
  }
}
