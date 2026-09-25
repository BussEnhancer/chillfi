import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/providers/wishlist_provider.dart';
import 'package:chillfi/core/widgets/app_error_dialog.dart';
import 'package:chillfi/core/widgets/app_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameC;
  late TextEditingController _emailC;
  bool _saving = false;
  bool _uploadingAvatar = false;

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 800);
    if (picked == null || !mounted) return;

    setState(() => _uploadingAvatar = true);
    final ok = await context.read<WishlistProvider>().uploadAvatar(picked.path);
    setState(() => _uploadingAvatar = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'Profile photo updated!' : 'Failed to upload photo'),
      backgroundColor: ok ? Colors.green : Colors.red,
    ));
  }

  @override
  void initState() {
    super.initState();
    final profile = context.read<WishlistProvider>().profile;
    _nameC = TextEditingController(text: profile?.name ?? '');
    _emailC = TextEditingController(text: profile?.email ?? '');
  }

  @override
  void dispose() {
    _nameC.dispose();
    _emailC.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameC.text.trim();
    final email = _emailC.text.trim();
    String? invalid;
    if (name.length < 2) invalid = 'Please enter your full name (at least 2 characters).';
    if (email.isNotEmpty && !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$').hasMatch(email)) invalid = 'Please enter a valid email address.';
    if (invalid != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(invalid), backgroundColor: Colors.red));
      return;
    }
    setState(() => _saving = true);
    final wp = context.read<WishlistProvider>();
    final ok = await wp.updateProfile(
      name: _nameC.text.trim().isNotEmpty ? _nameC.text.trim() : null,
      email: _emailC.text.trim().isNotEmpty ? _emailC.text.trim() : null,
    );
    setState(() => _saving = false);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated!'), backgroundColor: Colors.green));
      Navigator.pop(context);
    } else {
      AppErrorDialog.show(context, message: "We couldn't save your profile. Please try again.", title: "Couldn't save changes");
    }
  }

  Widget _field(TextEditingController c, String label, IconData icon, {TextInputType? keyboardType, bool readOnly = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: TextField(
        controller: c,
        readOnly: readOnly,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(fontSize: 14.sp, color: AppColors.darkText),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.greyText),
          prefixIcon: Icon(icon, color: AppColors.secondaryPurple, size: 20.sp),
          filled: true,
          fillColor: readOnly ? const Color(0xFFF0F0F0) : const Color(0xFFF5F5F5),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide.none),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<WishlistProvider>().profile;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 60.w,
        leading: Padding(padding: EdgeInsets.only(left: 16.w), child: const AppBackButton()),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit Profile', style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
            Text('Update your personal information', style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.greyText)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text('Save', style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppColors.secondaryPurple)),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 52.r,
                    backgroundColor: AppColors.secondaryPurple.withValues(alpha: 0.1),
                    child: profile?.avatarUrl != null
                        ? ClipOval(child: Image.network(profile!.avatarUrl!, width: 104.w, height: 104.h, fit: BoxFit.cover))
                        : Icon(Icons.person_rounded, size: 56.sp, color: AppColors.secondaryPurple),
                  ),
                  Positioned(
                    right: 0, bottom: 0,
                    child: GestureDetector(
                      onTap: _uploadingAvatar ? null : _pickAndUploadAvatar,
                      child: Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(color: AppColors.secondaryPurple, shape: BoxShape.circle),
                        child: _uploadingAvatar
                            ? SizedBox(width: 16.sp, height: 16.sp, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16.sp),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 28.h),

            Text('Personal Information', style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.greyText, letterSpacing: 0.5)),
            SizedBox(height: 12.h),

            _field(_nameC, 'Full Name', Icons.person_outline_rounded),
            _field(TextEditingController(text: profile?.phone ?? ''), 'Phone Number', Icons.phone_outlined, readOnly: true),
            _field(_emailC, 'Email Address', Icons.mail_outline_rounded, keyboardType: TextInputType.emailAddress),
            SizedBox(height: 24.h),

            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                ),
                icon: _saving
                    ? SizedBox(width: 18.w, height: 18.h, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Icon(Icons.save_rounded, size: 20.sp),
                label: Text('Save Changes', style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
