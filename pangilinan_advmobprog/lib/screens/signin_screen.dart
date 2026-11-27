import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';

// ENHANCEMENT 2: Custom sign-in screen using UserService.
// Validates the form, calls POST /auth/login, saves the user to
// SharedPreferences and replaces the route with /home.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    UserService userService = UserService();
    // Validate first so the spinner never gets stuck on invalid input.
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await userService.loginUser(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      // Save user data to SharedPreferences
      await userService.saveUserData(response);

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      Navigator.pushReplacementNamed(context, '/home', arguments: response);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: ${e.toString()}')));
    }
  }

  InputDecoration _decoration(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset('assets/images/app_logo.png', height: 84.h),
                  SizedBox(height: 16.h),
                  CustomText(
                    text: 'Welcome back',
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w700,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4.h),
                  CustomText(
                    text: 'Sign in to continue shopping',
                    fontSize: 13.sp,
                    color: Colors.grey,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32.h),
                  TextFormField(
                    controller: _usernameController,
                    textInputAction: TextInputAction.next,
                    decoration: _decoration('Username', Icons.person_outline),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Please enter your username'
                        : null,
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscure,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) {
                      if (!_isLoading) _login();
                    },
                    decoration: _decoration(
                      'Password',
                      Icons.lock_outline,
                      suffix: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Please enter your password'
                        : null,
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    height: 52.h,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: kPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : CustomText(
                              text: 'Log In',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  // Demo account hint (from https://dummyjson.com/users)
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: kAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: CustomText(
                      text: 'Demo account: emilys / emilyspass',
                      fontSize: 12.sp,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
