import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/payment/cod_confirmation_screen.dart';
import 'package:chillfi/features/payment/phonepe_payment_screen.dart';
import 'package:chillfi/features/payment/widgets/payment_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentMethodScreen extends StatelessWidget {
  const PaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.all(8.r),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(Icons.arrow_back_rounded, color: AppColors.darkText, size: 22.sp),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Payment Method",
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
            Text(
              "Select a safe payment option",
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                color: AppColors.greyText,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Icon(Icons.verified_user_rounded, color: AppColors.secondaryPurple, size: 16.sp),
              SizedBox(width: 4.w),
              Text(
                "100% Secure",
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryPurple,
                ),
              ),
              SizedBox(width: 16.w),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),
                const PaymentSecurityBanner(),
                
                const PaymentSectionHeader(title: "Recommended"),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PhonePePaymentScreen()),
                    );
                  },
                  child: const RecommendedUPICard(),
                ),

                const PaymentSectionHeader(title: "Cards"),
                PaymentOptionTile(
                  title: "Credit / Debit Card",
                  subtitle: "Visa, Mastercard, Rupay & more",
                  leading: _buildSquareLogo("VISA", const Color(0xFF1A1F71)),
                  trailing: Row(
                    children: [
                      Icon(Icons.credit_card_rounded, size: 16.sp, color: Colors.blue[900]),
                      SizedBox(width: 4.w),
                      Icon(Icons.credit_card_rounded, size: 16.sp, color: Colors.orange),
                    ],
                  ),
                ),
                PaymentOptionTile(
                  title: "Add New Card",
                  subtitle: "Save card securely for faster payments",
                  leading: Icon(Icons.add_card_rounded, color: AppColors.secondaryPurple),
                  showArrow: true,
                ),

                const PaymentSectionHeader(title: "Wallets"),
                PaymentOptionTile(
                  title: "Paytm Wallet",
                  subtitle: "Pay using your Paytm wallet",
                  leading: Icon(Icons.account_balance_wallet_outlined, color: Colors.blue),
                ),
                PaymentOptionTile(
                  title: "PhonePe Wallet",
                  subtitle: "Pay using your PhonePe wallet",
                  leading: Icon(Icons.account_balance_wallet_outlined, color: Colors.purple),
                ),
                PaymentOptionTile(
                  title: "Amazon Pay",
                  subtitle: "Pay using your Amazon Pay balance",
                  leading: Icon(Icons.payment_rounded, color: Colors.orange),
                ),

                PaymentOptionTile(
                  title: "Net Banking",
                  subtitle: "Pay using your preferred bank",
                  leading: Icon(Icons.account_balance_rounded, color: AppColors.secondaryPurple),
                  trailing: Row(
                    children: [
                      Icon(Icons.account_balance_outlined, size: 14.sp, color: Colors.blue),
                      SizedBox(width: 4.w),
                      Icon(Icons.account_balance_outlined, size: 14.sp, color: Colors.red),
                      SizedBox(width: 4.w),
                      Text("& more", style: TextStyle(fontSize: 10.sp, color: AppColors.greyText)),
                    ],
                  ),
                ),

                const PaymentSectionHeader(title: "More Options"),
                PaymentOptionTile(
                  title: "EMI / No Cost EMI",
                  subtitle: "Pay in easy monthly installments",
                  leading: Icon(Icons.percent_rounded, color: AppColors.secondaryPurple),
                  showArrow: true,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CODConfirmationScreen()),
                    );
                  },
                  child: PaymentOptionTile(
                    title: "Cash on Delivery",
                    subtitle: "Pay when you receive the order",
                    leading: Icon(Icons.handshake_outlined, color: AppColors.secondaryPurple),
                    showArrow: true,
                  ),
                ),

                SizedBox(height: 32.h),
                const TrustIndicatorCard(),
                SizedBox(height: 140.h), // Footer space
              ],
            ),
          ),
          
          const Align(
            alignment: Alignment.bottomCenter,
            child: PaymentBottomBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildSquareLogo(String text, Color color) {
    return Container(
      width: 40.r,
      height: 25.r,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.5)),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 8.sp,
          fontWeight: FontWeight.w900,
          color: color,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
