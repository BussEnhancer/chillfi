import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/orders/order_success_screen.dart';
import 'package:chillfi/features/payment/widgets/payment_widgets.dart';
import 'package:chillfi/features/payment/widgets/phonepe_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PhonePePaymentScreen extends StatelessWidget {
  const PhonePePaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PhonePeHeader(),
                  const OrderSummaryCard(),
                  const UpiPaymentCard(),

                  const PaymentSectionHeader(title: "Saved Payment Methods"),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      children: [
                        const SavedPaymentMethodTile(
                          title: "PhonePe UPI",
                          handle: "rahul.sharma@ibl",
                          isPrimary: true,
                          isSelected: true,
                          icon: Icons.account_balance_wallet_rounded,
                        ),
                        const SavedPaymentMethodTile(
                          title: "Paytm UPI",
                          handle: "rahulsharma@paytm",
                          icon: Icons.payments_rounded,
                        ),
                      ],
                    ),
                  ),

                  const PaymentSectionHeader(title: "Other Payment Options"),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      children: [
                        PaymentOptionTile(
                          title: "Debit / Credit Cards",
                          subtitle: "Visa, Mastercard, Rupay & more",
                          leading: Icon(Icons.credit_card_rounded, color: AppColors.secondaryPurple),
                          showArrow: true,
                        ),
                        PaymentOptionTile(
                          title: "Net Banking",
                          subtitle: "Pay using your preferred bank",
                          leading: Icon(Icons.account_balance_rounded, color: AppColors.secondaryPurple),
                          showArrow: true,
                        ),
                        PaymentOptionTile(
                          title: "Wallets",
                          subtitle: "PhonePe Wallet, Paytm, Amazon Pay & more",
                          leading: Icon(Icons.wallet_rounded, color: AppColors.secondaryPurple),
                          showArrow: true,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),
                  const PhonePeTrustIndicators(),
                  SizedBox(height: 140.h), // Footer space
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const OrderSuccessScreen()),
                  (route) => false,
                );
              },
              child: const PhonePeBottomBar(),
            ),
          ),
        ],
      ),
    );
  }
}
