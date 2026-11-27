import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../widgets/custom_text.dart';

// ENHANCEMENT 3: Settings page.
// The dark/light mode switch was moved here from the app bar.
// It reads/updates ThemeProvider, so the whole app re-themes instantly.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: 'Settings',
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          CustomText(
            text: 'Appearance',
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
          SizedBox(height: 8.h),
          Card(
            child: SwitchListTile(
              secondary: Icon(
                themeProvider.isDark ? Icons.dark_mode : Icons.light_mode,
              ),
              title: CustomText(text: 'Dark mode', fontSize: 15.sp),
              subtitle: CustomText(
                text: themeProvider.isDark ? 'On' : 'Off',
                fontSize: 12.sp,
              ),
              value: themeProvider.isDark,
              onChanged: (_) => themeProvider.toggleTheme(),
            ),
          ),
        ],
      ),
    );
  }
}
