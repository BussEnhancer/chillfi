import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The one back button used by every in-app header (AppBar leading or custom header row):
/// 40px white circle, hairline border, 20px rounded arrow; 44px touch target.
class AppBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  const AppBackButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Back',
      child: SizedBox(
        width: 44.r,
        height: 44.r,
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap ?? () => Navigator.maybePop(context),
            customBorder: const CircleBorder(),
            child: Center(
              child: Container(
                width: AppSize.backButton.r,
                height: AppSize.backButton.r,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.fieldBorder),
                ),
                child: Icon(Icons.arrow_back_rounded, color: AppColors.darkText, size: AppSize.iconBack.sp),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
