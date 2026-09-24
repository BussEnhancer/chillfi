import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class LocationIllustration extends StatefulWidget {
  const LocationIllustration({super.key});

  @override
  State<LocationIllustration> createState() => _LocationIllustrationState();
}

class _LocationIllustrationState extends State<LocationIllustration> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return SizedBox(
          height: 180.h,
          width: 1.sw,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Skyline Silhouette (Simplified)
              Positioned(
                bottom: 20.h,
                child: Opacity(
                  opacity: 0.1,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(width: 30.w, height: 60.h, color: AppColors.secondaryPurple),
                      SizedBox(width: 4.w),
                      Container(width: 20.w, height: 80.h, color: AppColors.secondaryPurple),
                      SizedBox(width: 4.w),
                      Container(width: 40.w, height: 50.h, color: AppColors.secondaryPurple),
                      SizedBox(width: 4.w),
                      Container(width: 25.w, height: 90.h, color: AppColors.secondaryPurple),
                    ],
                  ),
                ),
              ),

              // Map Design
              Positioned(
                bottom: 10.h,
                child: CustomPaint(
                  size: Size(200.w, 80.h),
                  painter: FoldedMapPainter(),
                ),
              ),

              // Main Pin
              Transform.translate(
                offset: Offset(0, -_floatAnimation.value - 20.h),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 60.r,
                      height: 60.r,
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryOrange.withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(Icons.location_on_rounded, color: Colors.white, size: 35.sp),
                    ),
                    Positioned(
                      bottom: -15.h,
                      child: CustomPaint(
                        size: Size(20.w, 20.h),
                        painter: PinTrianglePainter(),
                      ),
                    ),
                  ],
                ),
              ),

              // Paper Plane
              Positioned(
                top: 20.h,
                right: 60.w,
                child: Transform.rotate(
                  angle: -0.5,
                  child: Icon(Icons.send_rounded, color: AppColors.secondaryPurple, size: 20.sp),
                ),
              ),

              // Decorative Leaves
              Positioned(
                left: 40.w,
                bottom: 40.h,
                child: _buildLeaf(30),
              ),
              Positioned(
                right: 40.w,
                bottom: 30.h,
                child: _buildLeaf(-20),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLeaf(double angle) {
    return Transform.rotate(
      angle: angle * 3.14 / 180,
      child: Container(
        width: 30.w,
        height: 50.h,
        decoration: BoxDecoration(
          color: AppColors.secondaryPurple.withValues(alpha: 0.1),
          borderRadius: BorderRadius.all(Radius.elliptical(30.w, 50.h)),
        ),
      ),
    );
  }
}

class FoldedMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.grey.withValues(alpha: 0.15)..style = PaintingStyle.fill;
    Path path = Path();
    path.moveTo(0, size.height * 0.2);
    path.lineTo(size.width * 0.3, 0);
    path.lineTo(size.width * 0.6, size.height * 0.2);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.8);
    path.lineTo(size.width * 0.6, size.height);
    path.lineTo(size.width * 0.3, size.height * 0.8);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);

    // Grid lines
    Paint linePaint = Paint()..color = Colors.white..strokeWidth = 1;
    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.3, size.height * 0.8), linePaint);
    canvas.drawLine(Offset(size.width * 0.6, size.height * 0.2), Offset(size.width * 0.6, size.height), linePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class PinTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = AppColors.primaryOrange..style = PaintingStyle.fill;
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class BenefitRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const BenefitRow({
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
              color: AppColors.secondaryPurple.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.secondaryPurple, size: 20.sp),
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
        ],
      ),
    );
  }
}
