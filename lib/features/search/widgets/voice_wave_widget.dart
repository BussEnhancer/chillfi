import 'dart:math';
import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VoiceWaveWidget extends StatefulWidget {
  const VoiceWaveWidget({super.key});

  @override
  State<VoiceWaveWidget> createState() => _VoiceWaveWidgetState();
}

class _VoiceWaveWidgetState extends State<VoiceWaveWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
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
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(15, (index) {
            // Create a symmetrical wave effect
            double value = sin((_controller.value * 2 * pi) + (index * 0.5));
            double height = 15.h + (value.abs() * 25.h);
            
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              width: 3.w,
              height: height,
              decoration: BoxDecoration(
                color: AppColors.secondaryPurple.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(2.r),
              ),
            );
          }),
        );
      },
    );
  }
}
