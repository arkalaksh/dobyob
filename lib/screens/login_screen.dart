import 'dart:io' show Platform;

import 'package:dobyob_1/screens/dobyob_session_manager.dart';
import 'package:dobyob_1/services/api_service.dart';
import 'package:dobyob_1/widgets/social_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  final String fcmToken;
  const LoginScreen({super.key, required this.fcmToken});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final mpinController = TextEditingController();
  final ApiService apiService = ApiService();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    debugPrint('LoginScreen FCM Token: ${widget.fcmToken}');
  }

  @override
  void dispose() {
    emailController.dispose();
    mpinController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final trimmed = email.trim();
    final reg = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.com$');
    return reg.hasMatch(trimmed);
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _loginWithMpin() async {
    final email = emailController.text.trim();
    final mpin = mpinController.text.trim();

    debugPrint("LOGIN => email=$email mpin=$mpin token=${widget.fcmToken}");

    if (email.isEmpty) {
      _showSnack('Please enter your email');
      return;
    }

    if (!_isValidEmail(email)) {
      _showSnack('Please enter a valid .com email address');
      return;
    }

    if (mpin.length != 6) {
      _showSnack('Enter 6-digit MPIN');
      return;
    }
setState(() => isLoading = true);

// 🔥 ADD THIS
final session = await DobYobSessionManager.getInstance();
await session.clearSession();

Map<String, dynamic> res = {};
try {
  res = await apiService.verifyLoginOtp(
    email: email,
    mpin: mpin,
    deviceToken: widget.fcmToken,
    deviceType: Platform.isAndroid ? 'android' : 'ios',
  );

    } catch (e) {
      if (mounted) setState(() => isLoading = false);
      _showSnack('Network/Parsing error: $e');
      return;
    }

    if (!mounted) return;
    setState(() => isLoading = false);

    final String serverMsg =
        (res['message'] ?? res['error'] ?? res['raw'] ?? 'Login failed').toString();

    if (res['success'] == true) {
      final data = (res['user'] is Map) ? (res['user'] as Map) : res;

      final userIdStr = (data['user_id'] ?? data['id'] ?? '').toString();
      final userId = int.tryParse(userIdStr);

      if (userId == null) {
        _showSnack('Invalid user_id from server: $userIdStr');
        return;
      }

      final String name = (data['full_name'] ?? data['name'] ?? '').toString();
      final String userEmail = (data['email'] ?? email).toString();
      final String phone = (data['phone'] ?? '').toString();

      try {
        final session = await DobYobSessionManager.getInstance();
        await session.saveUserSession(
  userId: userId,
  name: name,
  email: userEmail,
  phone: phone,
  deviceToken: widget.fcmToken,
  deviceType: Platform.isAndroid ? 'android' : 'ios',
  profilePicture: (data['profile_pic'] != null &&
          data['profile_pic'].toString().toLowerCase() != 'null')
      ? data['profile_pic'].toString()
      : '',
);
      } catch (e) {
        debugPrint("SESSION ERROR: $e");
      }

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } else {
      _showSnack(serverMsg);
    }
  }

  Widget _buildMpinField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MPIN',
          style: TextStyle(
            color: Color(0xFFD1D5DB),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 50,
          child: TextField(
            controller: mpinController,
            maxLength: 6,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly, // digits only [web:197]
              LengthLimitingTextInputFormatter(6),
            ],
            obscureText: true,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
            decoration: InputDecoration(
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF1F2937), width: 1.4),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1.4),
              ),
              filled: true,
              fillColor: const Color(0xFF111827),
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Enter your 6-digit MPIN',
          style: TextStyle(color: Color(0xFF6B7280), fontSize: 11),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF020617);
    const fieldColor = Color(0xFF020617);
    const circleColor = Color(0xFF0EA5E9);

    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 20, right: 20, top: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Login with MPIN',
                      style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 62),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Center(
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: circleColor,
                                child: Icon(Icons.lock_outline, color: Colors.white, size: 26),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Login Account',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Enter email & MPIN',
                                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 56),

                        const Text(
                          'Email address',
                          style: TextStyle(
                            color: Color(0xFFD1D5DB),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        TextField(
                          controller: emailController,
                          style: const TextStyle(color: Colors.white),
                          cursorColor: const Color(0xFF38BDF8),
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Enter your email',
                            hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                            filled: true,
                            fillColor: fieldColor,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFF1F2937)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          ),
                        ),
                        const SizedBox(height: 24),

                        _buildMpinField(),
                        const SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: circleColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: isLoading ? null : _loginWithMpin,
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    "Login",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account? ",
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pushReplacementNamed(context, '/signup'),
                              child: const Text(
                                "Sign Up",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.purpleAccent,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),

                        const Center(
                          child: Text(
                            'Or Sign up with',
                            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const SocialButtons(),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
