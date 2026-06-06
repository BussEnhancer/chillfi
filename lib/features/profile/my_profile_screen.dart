import 'package:chillfi/features/home/widgets/bottom_nav.dart';
import 'package:chillfi/features/profile/widgets/profile_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: 10.h),
              const ProfileHeader(),
              SizedBox(height: 20.h),
              const ProfileHeaderCard(),
              SizedBox(height: 16.h),
              const PremiumMembershipCard(),
              SizedBox(height: 24.h),
              const MyOrdersProfileCard(),
              SizedBox(height: 24.h),
              const AccountOptionsList(),
              SizedBox(height: 16.h),
              const SettingsSectionCard(),
              SizedBox(height: 32.h),
              const LogoutButton(),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 4),
    );
  }
}
