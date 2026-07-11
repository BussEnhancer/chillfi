import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class OtpInputField extends StatefulWidget {
  final int length;
  final Function(String) onCompleted;

  const OtpInputField({
    super.key,
    this.length = 6,
    required this.onCompleted,
  });

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;
  late List<String> _otpValues;

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(widget.length, (index) => FocusNode());
    _controllers = List.generate(widget.length, (index) => TextEditingController());
    _otpValues = List.generate(widget.length, (index) => '');
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      _otpValues[index] = value.characters.last;
      _controllers[index].text = _otpValues[index];
      
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        widget.onCompleted(_otpValues.join());
      }
    } else {
      _otpValues[index] = '';
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (index) {
        return Container(
          width: 48.w,
          height: 56.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: _focusNodes[index].hasFocus 
                  ? AppColors.secondaryPurple 
                  : AppColors.fieldBorder,
              width: _focusNodes[index].hasFocus ? 2 : 1,
            ),
            boxShadow: _focusNodes[index].hasFocus 
              ? [BoxShadow(color: AppColors.secondaryPurple.withOpacity(0.1), blurRadius: 8, spreadRadius: 1)]
              : [],
          ),
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (value) => _onChanged(value, index),
          ),
        );
      }),
    );
  }
}

class SecurityInfoCard extends StatelessWidget {
  const SecurityInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EFFF), // Light purple background
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondaryPurple.withOpacity(0.1),
                  blurRadius: 10,
                )
              ],
            ),
            child: Icon(Icons.verified_user_outlined, color: AppColors.secondaryPurple, size: 24.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your security is our priority',
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  'We never share your information with anyone.',
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: AppColors.greyText,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SecurityShieldIllustration(),
        ],
      ),
    );
  }
}

class SecurityShieldIllustration extends StatelessWidget {
  const SecurityShieldIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70.w,
      height: 70.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Glow
          Container(
            width: 50.r,
            height: 50.r,
            decoration: BoxDecoration(
              color: AppColors.secondaryPurple.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
          ),
          // Main Shield
          Icon(Icons.shield, size: 55.sp, color: AppColors.secondaryPurple),
          // Lock Icon inside
          Positioned(
            top: 22.h,
            child: Icon(Icons.lock_rounded, size: 20.sp, color: Colors.white),
          ),
          // Small Orange Check
          Positioned(
            bottom: 5.h,
            right: 5.w,
            child: Container(
              padding: EdgeInsets.all(4.r),
              decoration: const BoxDecoration(
                color: AppColors.primaryOrange,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, color: Colors.white, size: 12.sp),
            ),
          ),
        ],
      ),
    );
  }
}

class SecondaryOutlinedButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const SecondaryOutlinedButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        height: 56.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.secondaryPurple.withOpacity(0.5), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.secondaryPurple, size: 18.sp),
            SizedBox(width: 8.w),
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Purple Layer
    Paint purplePaint = Paint()..color = AppColors.secondaryPurple;
    Path purplePath = Path();
    purplePath.moveTo(0, size.height);
    purplePath.lineTo(0, size.height * 0.4);
    purplePath.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.2,
      size.width * 0.5,
      size.height * 0.5,
    );
    purplePath.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.8,
      size.width,
      size.height * 0.4,
    );
    purplePath.lineTo(size.width, size.height);
    purplePath.close();
    canvas.drawPath(purplePath, purplePaint);

    // Orange Layer
    Paint orangePaint = Paint()..color = AppColors.primaryOrange;
    Path orangePath = Path();
    orangePath.moveTo(0, size.height);
    orangePath.lineTo(0, size.height * 0.6);
    orangePath.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.4,
      size.width * 0.6,
      size.height * 0.7,
    );
    orangePath.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.9,
      size.width,
      size.height * 0.6,
    );
    orangePath.lineTo(size.width, size.height);
    orangePath.close();
    canvas.drawPath(orangePath, orangePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FloatingSphere extends StatefulWidget {
  const FloatingSphere({super.key});

  @override
  State<FloatingSphere> createState() => _FloatingSphereState();
}

class _FloatingSphereState extends State<FloatingSphere> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 0.2),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: Container(
        width: 24.r,
        height: 24.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              const Color(0xFFA166FF),
              AppColors.secondaryPurple.withOpacity(0.8),
              AppColors.secondaryPurple,
            ],
            stops: const [0.2, 0.7, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondaryPurple.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      ),
    );
  }
}
