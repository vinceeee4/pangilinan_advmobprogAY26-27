import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';

// ENHANCEMENT 3: Profile screen.
// Loads the saved user from SharedPreferences through
// UserService.getUser() (returns the User model) and renders it.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  late final Future<User> _userFuture = _userService.getUser();

  Future<void> _logout() async {
    await _userService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/signin', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: CustomText(text: 'Could not load profile', fontSize: 14.sp),
          );
        }
        final user = snapshot.data!;

        return ListView(
          padding: EdgeInsets.all(16.r),
          children: [
            // Header card: avatar + name + @username
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 46.r,
                      backgroundColor: kAccent.withValues(alpha: 0.2),
                      foregroundImage: user.image.isNotEmpty
                          ? NetworkImage(user.image)
                          : null,
                      child: CustomText(
                        text: user.fullName.isNotEmpty
                            ? user.fullName[0].toUpperCase()
                            : '?',
                        fontSize: 30.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    CustomText(
                      text: user.fullName,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    CustomText(
                      text: '@${user.username}',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: kAccent,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.h),
            // Details card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Column(
                children: [
                  _InfoTile(
                    icon: Icons.mail_outline,
                    label: 'Email',
                    value: user.email,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _InfoTile(
                    icon: Icons.wc,
                    label: 'Gender',
                    value: user.gender,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _InfoTile(
                    icon: Icons.badge_outlined,
                    label: 'User ID',
                    value: '#${user.id}',
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              height: 52.h,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6150),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: CustomText(
                  text: 'Log Out',
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: kAccent),
      title: CustomText(
        text: label,
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
      ),
      trailing: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 200.w),
        child: CustomText(
          text: value.isEmpty ? '-' : value,
          fontSize: 13.sp,
          color: Colors.grey,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.right,
        ),
      ),
    );
  }
}
