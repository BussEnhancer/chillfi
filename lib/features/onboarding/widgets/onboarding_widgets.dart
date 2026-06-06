import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class FeatureBadge extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;

  const FeatureBadge({
    super.key,
    required this.icon,
    required this.title,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 26.sp),
          SizedBox(height: 6.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class PremiumGradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;

  const PremiumGradientText({
    super.key,
    required this.text,
    required this.style,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style),
    );
  }
}

class OnboardingCTA extends StatelessWidget {
  final VoidCallback onTap;
  final String text;

  const OnboardingCTA({
    super.key,
    required this.onTap,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 1.sw,
        height: 64.h,
        decoration: BoxDecoration(
          gradient: AppColors.buttonGradient,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryOrange.withValues(alpha: 0.35),
              blurRadius: 25,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              text,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            Positioned(
              right: 24.w,
              child: Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 22.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DottedPattern extends StatelessWidget {
  final int rows;
  final int cols;
  final Color color;

  const DottedPattern({
    super.key,
    required this.rows,
    required this.cols,
    this.color = Colors.black12,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        rows,
        (i) => Padding(
          padding: EdgeInsets.only(bottom: 6.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              cols,
              (j) => Container(
                margin: EdgeInsets.only(right: 6.w),
                width: 4.r,
                height: 4.r,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BottomWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = AppColors.bottomWaveGradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      )
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.6);
    
    var firstControlPoint = Offset(size.width * 0.2, size.height * 0.3);
    var firstEndPoint = Offset(size.width * 0.5, size.height * 0.6);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(size.width * 0.8, size.height * 0.9);
    var secondEndPoint = Offset(size.width, size.height * 0.5);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class PhoneMockupWithUI extends StatelessWidget {
  const PhoneMockupWithUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190.w,
      height: 380.h,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: const Color(0xFF2C2C2C), width: 8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(15, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22.r),
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              // Mock Status Bar Area (Dynamic Island style)
              Container(
                height: 25.h,
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 45.w,
                      height: 14.h,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Mock App Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/logo.png', 
                      height: 16.h, 
                      errorBuilder: (_,__,___) => Row(
                        children: [
                          Icon(Icons.shopping_bag, size: 14.h, color: AppColors.primaryOrange),
                          SizedBox(width: 4.w),
                          Text('CHILLFI', style: GoogleFonts.poppins(fontSize: 10.sp, fontWeight: FontWeight.bold, color: AppColors.primaryOrange)),
                        ],
                      )
                    ),
                    const Spacer(),
                    Icon(Icons.search, size: 16.sp, color: Colors.grey[600]),
                    SizedBox(width: 8.w),
                    Stack(
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 16.sp, color: Colors.grey[600]),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 6.r,
                            height: 6.r,
                            decoration: const BoxDecoration(color: AppColors.primaryOrange, shape: BoxShape.circle),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),

              // Mock Search Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Container(
                  height: 30.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 8.w),
                      Icon(Icons.search, size: 12.sp, color: Colors.grey[400]),
                      SizedBox(width: 5.w),
                      Text('Search products...', style: TextStyle(fontSize: 9.sp, color: Colors.grey[400])),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 10.h),

              // Mock Promo Banner
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Container(
                  height: 100.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF121212),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 12.w,
                        top: 15.h,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryPurple,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text('New Launch', style: TextStyle(color: Colors.white, fontSize: 6.sp, fontWeight: FontWeight.w600)),
                            ),
                            SizedBox(height: 5.h),
                            Text('Big Sound,\nBigger Savings.', style: GoogleFonts.poppins(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold, height: 1.2)),
                            SizedBox(height: 4.h),
                            Text('Up to 40% off on\npremium headphones', style: TextStyle(color: Colors.white70, fontSize: 6.sp)),
                            SizedBox(height: 8.h),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text('Shop Now >', style: TextStyle(color: Colors.black, fontSize: 6.sp, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: -5.w,
                        bottom: 0,
                        child: Icon(Icons.headset, size: 85.sp, color: Colors.white.withValues(alpha: 0.15)),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              // Mock Categories
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Shop by Category', style: GoogleFonts.poppins(fontSize: 9.sp, fontWeight: FontWeight.w700)),
                    Text('View All', style: GoogleFonts.poppins(fontSize: 7.sp, color: AppColors.secondaryPurple, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              
              SizedBox(height: 8.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(4, (index) => Column(
                    children: [
                      Container(
                        width: 32.w,
                        height: 32.w,
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Icon(
                          [Icons.smartphone, Icons.laptop, Icons.headset, Icons.grid_view_rounded][index],
                          size: 16.sp,
                          color: AppColors.primaryOrange,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(['Mobiles', 'Laptops', 'Audio', 'More'][index], style: TextStyle(fontSize: 6.sp, fontWeight: FontWeight.w500)),
                    ],
                  )),
                ),
              ),

              const Spacer(),
              
              // Mock Flash Deals
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Flash Deals', style: GoogleFonts.poppins(fontSize: 9.sp, fontWeight: FontWeight.w700)),
                    Row(
                      children: [
                        _buildTimerUnit('02'),
                        _buildTimerDivider(),
                        _buildTimerUnit('48'),
                        _buildTimerDivider(),
                        _buildTimerUnit('30'),
                      ],
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 8.h),
              
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(3, (index) => Container(
                    width: 50.w,
                    height: 55.w,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          [Icons.earbuds, Icons.watch_rounded, Icons.power][index],
                          size: 24.sp,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  )),
                ),
              ),
              SizedBox(height: 15.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerUnit(String val) {
    return Container(
      padding: EdgeInsets.all(2.r),
      decoration: BoxDecoration(color: AppColors.primaryOrange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(2)),
      child: Text(val, style: TextStyle(fontSize: 6.sp, color: AppColors.primaryOrange, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTimerDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 1.w),
      child: Text(':', style: TextStyle(fontSize: 6.sp, color: AppColors.primaryOrange, fontWeight: FontWeight.bold)),
    );
  }
}

class OrderTrackingMockUI extends StatelessWidget {
  const OrderTrackingMockUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190.w,
      height: 380.h,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: const Color(0xFF2C2C2C), width: 8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(15, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22.r),
        child: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mock Status Bar
              Container(
                height: 20.h,
                alignment: Alignment.center,
                child: Container(
                  width: 45.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Tracking Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                child: Row(
                  children: [
                    Icon(Icons.chevron_left, size: 16.sp),
                    const Spacer(),
                    Text('Order Tracking', style: GoogleFonts.poppins(fontSize: 9.sp, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Icon(Icons.headset_mic_outlined, size: 12.sp),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order #EH123456789', style: TextStyle(fontSize: 8.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 1.h),
                    Text('Out for Delivery', style: TextStyle(fontSize: 7.sp, color: Colors.green, fontWeight: FontWeight.w600)),
                    Text('Arriving today by 08:00 PM', style: TextStyle(fontSize: 6.sp, color: Colors.grey)),
                  ],
                ),
              ),

              SizedBox(height: 8.h),

              // Timeline
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        _buildTimelineStep('Order Confirmed', '20 May, 10:30 AM', true, true),
                        _buildTimelineStep('Packed', '21 May, 12:00 PM', true, true),
                        _buildTimelineStep('Shipped', '22 May, 08:15 AM', true, true),
                        _buildTimelineStep('Out for Delivery', '22 May, 11:30 AM', false, true, isActive: true),
                        _buildTimelineStep('Delivered', 'Yet to be delivered', false, false, isLast: true),
                      ],
                    ),
                  ),
                ),
              ),

              // Delivery Partner Card
              Container(
                margin: EdgeInsets.symmetric(horizontal: 8.r, vertical: 4.r),
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 8.r,
                      backgroundColor: Colors.grey[300],
                      child: Icon(Icons.person, size: 10.sp, color: Colors.white),
                    ),
                    SizedBox(width: 5.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Delivery Partner', style: TextStyle(fontSize: 4.sp, color: Colors.grey)),
                        Text('DeLiverY', style: TextStyle(fontSize: 6.sp, fontWeight: FontWeight.bold)),
                        Text('Tracking ID: 123456789012', style: TextStyle(fontSize: 4.sp, color: Colors.grey)),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.call, size: 6.sp, color: AppColors.secondaryPurple),
                          SizedBox(width: 2.w),
                          Text('Call', style: TextStyle(fontSize: 5.sp, fontWeight: FontWeight.bold, color: AppColors.secondaryPurple)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineStep(String title, String time, bool isCompleted, bool hasLine, {bool isActive = false, bool isLast = false}) {
    return SizedBox(
      height: 32.h,
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 10.r,
                height: 10.r,
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green : (isActive ? AppColors.secondaryPurple : Colors.grey[200]),
                  shape: BoxShape.circle,
                ),
                child: isCompleted ? Icon(Icons.check, size: 6.sp, color: Colors.white) : (isActive ? Icon(Icons.local_shipping, size: 5.sp, color: Colors.white) : null),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5.w,
                    color: isCompleted ? Colors.green : Colors.grey[200],
                  ),
                ),
            ],
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: TextStyle(fontSize: 6.sp, fontWeight: FontWeight.bold, color: isActive ? AppColors.secondaryPurple : Colors.black)),
              Text(time, style: TextStyle(fontSize: 5.sp, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}

class DeliveryBoxWidget extends StatelessWidget {
  const DeliveryBoxWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110.w,
      height: 140.h,
      child: Stack(
        children: [
          // The Box
          Positioned(
            bottom: 0,
            child: Container(
              width: 90.w,
              height: 90.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(5, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Box Tape
                  Container(
                    width: 15.w,
                    height: 90.h,
                    color: AppColors.primaryOrange.withValues(alpha: 0.8),
                  ),
                ],
              ),
            ),
          ),
          
          // CHILLFI Logo on Box
          Positioned(
            bottom: 20.h,
            left: 20.w,
            child: Column(
              children: [
                Icon(Icons.shopping_bag, size: 24.sp, color: AppColors.primaryOrange),
                Text('CHILLFI', style: GoogleFonts.poppins(fontSize: 10.sp, fontWeight: FontWeight.bold, color: AppColors.primaryOrange)),
              ],
            ),
          ),

          // Map Pin
          Positioned(
            top: 10.h,
            left: 45.w,
            child: Container(
              width: 35.r,
              height: 45.h,
              decoration: const BoxDecoration(
                color: AppColors.secondaryPurple,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(2),
                ),
              ),
              transform: Matrix4.rotationZ(0.78), // 45 degrees
              child: Center(
                child: Transform.rotate(
                  angle: -0.78,
                  child: Container(
                    width: 12.r,
                    height: 12.r,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
