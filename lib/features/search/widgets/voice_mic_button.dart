import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VoiceMicButton extends StatefulWidget {
  const VoiceMicButton({super.key});

  @override
  State<VoiceMicButton> createState() => _VoiceMicButtonState();
}

class _VoiceMicButtonState extends State<VoiceMicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Ripple 1
            _buildRipple(1.0 + (_controller.value * 0.5), 0.2 - (_controller.value * 0.2)),
            // Ripple 2
            _buildRipple(1.3 + (_controller.value * 0.6), 0.1 - (_controller.value * 0.1)),
            
            // Main Mic Button
            Container(
              width: 80.r,
              height: 80.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.secondaryPurple,
                    Color(0xFFA166FF),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondaryPurple.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.mic_rounded,
                color: Colors.white,
                size: 36.sp,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRipple(double scale, double opacity) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 80.r,
        height: 80.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.secondaryPurple.withOpacity(opacity > 0 ? opacity : 0),
        ),
      ),
    );
  }
}
