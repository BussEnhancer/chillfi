import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class PremiumAuthField extends StatefulWidget {
  final String label;
  final String hintText;
  final IconData prefixIcon;
  final bool isPassword;
  final bool isOptional;
  final TextEditingController? controller;

  const PremiumAuthField({
    super.key,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    this.isPassword = false,
    this.isOptional = false,
    this.controller,
  });

  @override
  State<PremiumAuthField> createState() => _PremiumAuthFieldState();
}

class _PremiumAuthFieldState extends State<PremiumAuthField> {
  bool _obscureText = true;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: _isFocused ? AppColors.secondaryPurple : AppColors.fieldBorder,
          width: _isFocused ? 1.5 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: _isFocused 
                ? AppColors.secondaryPurple.withOpacity(0.06)
                : Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: AppColors.secondaryPurple.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              widget.prefixIcon,
              color: AppColors.secondaryPurple,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.label,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                    letterSpacing: 0.2,
                  ),
                ),
                Focus(
                  onFocusChange: (hasFocus) => setState(() => _isFocused = hasFocus),
                  child: TextField(
                    controller: widget.controller,
                    obscureText: widget.isPassword ? _obscureText : false,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        color: AppColors.greyText.withOpacity(0.4),
                      ),
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(top: 4.h),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.isPassword)
            GestureDetector(
              onTap: () => setState(() => _obscureText = !_obscureText),
              child: Icon(
                _obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: AppColors.greyText.withOpacity(0.6),
                size: 20.sp,
              ),
            ),
        ],
      ),
    );
  }
}

class SocialLoginButton extends StatelessWidget {
  final Widget icon;
  final String text;
  final VoidCallback onTap;

  const SocialLoginButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.fieldBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              SizedBox(height: 6.h),
              Text(
                text,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.greyText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomCheckbox extends StatefulWidget {
  final Function(bool) onChanged;
  const CustomCheckbox({super.key, required this.onChanged});

  @override
  State<CustomCheckbox> createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isChecked = !_isChecked;
          widget.onChanged(_isChecked);
        });
      },
      child: Container(
        width: 20.r,
        height: 20.r,
        decoration: BoxDecoration(
          color: _isChecked ? AppColors.secondaryPurple : Colors.white,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(
            color: _isChecked ? AppColors.secondaryPurple : AppColors.fieldBorder,
            width: 1.5,
          ),
        ),
        child: _isChecked
            ? Icon(Icons.check, color: Colors.white, size: 14.sp)
            : null,
      ),
    );
  }
}

class GoogleIcon extends StatelessWidget {
  const GoogleIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
      height: 20.h,
      width: 20.w,
      errorBuilder: (context, error, stackTrace) => Icon(Icons.g_mobiledata, color: Colors.red, size: 24.sp),
    );
  }
}

// Since I cannot use network images, I will create a simple colored icon representation for Google/FB/Apple
class BrandLogoIcon extends StatelessWidget {
  final String brand;
  const BrandLogoIcon({super.key, required this.brand});

  @override
  Widget build(BuildContext context) {
    switch (brand.toLowerCase()) {
      case 'google':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _colorBlock(Colors.blue),
            _colorBlock(Colors.red),
            _colorBlock(Colors.yellow),
            _colorBlock(Colors.green),
          ],
        );
      case 'facebook':
        return Container(
          padding: EdgeInsets.all(2.r),
          decoration: const BoxDecoration(color: Color(0xFF1877F2), shape: BoxShape.circle),
          child: Icon(Icons.facebook, color: Colors.white, size: 18.sp),
        );
      case 'apple':
        return Icon(Icons.apple, color: Colors.black, size: 22.sp);
      default:
        return Icon(Icons.help_outline, size: 20.sp);
    }
  }

  Widget _colorBlock(Color color) {
    return Container(
      width: 4.w,
      height: 4.h,
      margin: EdgeInsets.all(0.5.r),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
