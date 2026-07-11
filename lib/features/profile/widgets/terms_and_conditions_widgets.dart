import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsHeroBanner extends StatelessWidget {
  const TermsHeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2FF),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.description_rounded, color: AppColors.secondaryPurple.withValues(alpha: 0.1), size: 80.sp),
                Icon(Icons.verified_user_rounded, color: AppColors.secondaryPurple, size: 40.sp),
              ],
            ),
          ),
          Container(width: 1, height: 80.h, color: AppColors.lightGrey.withValues(alpha: 0.5)),
          SizedBox(width: 20.w),
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Agreement to our terms",
                  style: GoogleFonts.poppins(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "By accessing or using CHILLFI, you agree to be bound by these Terms & Conditions. Please read them carefully.",
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

class DocumentIndexCard extends StatelessWidget {
  const DocumentIndexCard({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> items = [
      'Acceptance of Terms',
      'Eligibility',
      'Account Registration',
      'Use of the App',
      'Orders and Payments',
      'Shipping and Delivery',
      'Returns and Refunds',
      'Intellectual Property',
      'Limitation of Liability',
      'Termination',
      'Governing Law',
      'Changes to Terms',
      'Contact Us',
    ];

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: const Color(0xFFE8E8EE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "In this document",
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          SizedBox(height: 16.h),
          ...List.generate(items.length, (index) {
            return _buildIndexItem(index + 1, items[index], index == items.length - 1);
          }),
        ],
      ),
    );
  }

  Widget _buildIndexItem(int number, String title, bool isLast) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Row(
            children: [
              Container(
                width: 24.r,
                height: 24.r,
                decoration: BoxDecoration(
                  color: AppColors.secondaryPurple.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  number.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondaryPurple,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkText,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.lightGrey, size: 20.sp),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, color: AppColors.lightGrey.withValues(alpha: 0.2), indent: 40.w),
      ],
    );
  }
}

class ExpandableTermsCard extends StatefulWidget {
  const ExpandableTermsCard({super.key});

  @override
  State<ExpandableTermsCard> createState() => _ExpandableTermsCardState();
}

class _ExpandableTermsCardState extends State<ExpandableTermsCard> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: const Color(0xFFE8E8EE)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Row(
              children: [
                Icon(Icons.verified_user_rounded, color: AppColors.secondaryPurple, size: 20.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    "1. Acceptance of Terms",
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.greyText,
                ),
              ],
            ),
          ),
          if (_isExpanded) ...[
            SizedBox(height: 16.h),
            Text(
              "By downloading, accessing or using the CHILLFI app (\"App\"), website or any of our services, you agree to be bound by these Terms & Conditions and our Privacy Policy.",
              style: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.greyText, height: 1.5),
            ),
            SizedBox(height: 12.h),
            Text(
              "If you do not agree to these terms, please do not use our App or services.",
              style: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.greyText, height: 1.5),
            ),
          ],
        ],
      ),
    );
  }
}

class TermsInfoBanner extends StatelessWidget {
  const TermsInfoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2FF),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(Icons.info_outline_rounded, color: AppColors.secondaryPurple, size: 20.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "These terms apply to all users",
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  "Including browsers, vendors, customers, merchants and contributors.",
                  style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.greyText),
                ),
              ],
            ),
          ),
          Icon(Icons.people_alt_rounded, color: AppColors.secondaryPurple.withValues(alpha: 0.3), size: 40.sp),
        ],
      ),
    );
  }
}

class AgreementCheckbox extends StatefulWidget {
  const AgreementCheckbox({super.key});

  @override
  State<AgreementCheckbox> createState() => _AgreementCheckboxState();
}

class _AgreementCheckboxState extends State<AgreementCheckbox> {
  bool _isChecked = true;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => setState(() => _isChecked = !_isChecked),
          child: Container(
            width: 20.r,
            height: 20.r,
            decoration: BoxDecoration(
              color: _isChecked ? AppColors.secondaryPurple : Colors.white,
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(
                color: _isChecked ? AppColors.secondaryPurple : AppColors.lightGrey,
                width: 1.5,
              ),
            ),
            child: _isChecked ? Icon(Icons.check, color: Colors.white, size: 14.sp) : null,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            "I have read, understood and agree to the Terms & Conditions",
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.darkText,
            ),
          ),
        ),
      ],
    );
  }
}
