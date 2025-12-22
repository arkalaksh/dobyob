import 'package:dobyob_1/screens/dobyob_session_manager.dart';
import 'package:dobyob_1/widgets/social_buttons.dart';
import 'package:flutter/material.dart';
import 'package:dobyob_1/services/api_service.dart';
import 'dart:io' show Platform;

class LoginScreen extends StatefulWidget {
  final String fcmToken;
  const LoginScreen({super.key, required this.fcmToken});
  
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final otpControllers = List.generate(6, (index) => TextEditingController());
  final otpFocusNodes = List.generate(6, (index) => FocusNode());
  final ApiService apiService = ApiService();

  bool otpFieldVisible = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // PRINT FCM TOKEN IN DEBUG CONSOLE
    print('LoginScreen FCM Token: ${widget.fcmToken}');
  }

  // Email MUST be valid and MUST end with .com
  bool _isValidEmail(String email) {
    final trimmed = email.trim();
    final reg = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.com$');
    return reg.hasMatch(trimmed);
  }

  void _onOtpChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      otpFocusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      otpFocusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  Future<void> _sendOtp() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email')),
      );
      return;
    }

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid .com email address')),
      );
      return;
    }

    setState(() => isLoading = true);
    final res = await apiService.sendEmailOtp(
      email: email,
      deviceToken: widget.fcmToken,
      deviceType: Platform.isAndroid ? 'android' : 'ios',
    );
    setState(() => isLoading = false);

    if (res['success'] == true) {
      setState(() {
        otpFieldVisible = true;
      });
      otpFocusNodes.first.requestFocus();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'OTP sent to your email')),
      );
    } else {
      final errorMsg = res['error']?.toString() ?? 'Failed to send OTP';
      
      if (errorMsg.contains('not registered') || 
          errorMsg.contains('Create your account') || 
          res['user_exists'] == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Create your account first!'),
            backgroundColor: const Color.fromARGB(255, 11, 65, 88),
            duration: const Duration(seconds: 2),
          ),
        );
        
        Future.delayed(const Duration(seconds: 2), () {
          ScaffoldMessenger.of(context).clearSnackBars();
          Navigator.pushReplacementNamed(context, '/intro');
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
    }
  }

  Future<void> _verifyOtp() async {
    final email = emailController.text.trim();

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid .com email address')),
      );
      return;
    }

    final otp = otpControllers.map((c) => c.text).join();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the 6 digit OTP')),
      );
      return;
    }

    setState(() => isLoading = true);
    final res = await apiService.verifyLoginOtp(
      email: email,
      otp: otp,
      deviceToken: widget.fcmToken,
      deviceType: Platform.isAndroid ? 'android' : 'ios',
    );
    setState(() => isLoading = false);

    if (res['success'] == true) {
      final data = res['user'] ?? res;
      final int userId = int.parse(data['user_id'].toString());
      final String name = (data['full_name'] ?? data['name'] ?? '').toString();
      final String userEmail = data['email'] ?? email;
      final String phone = data['phone'] ?? '';
      
      final String deviceToken = widget.fcmToken;
      final String deviceType = Platform.isAndroid ? 'android' : 'ios';

      final session = await DobYobSessionManager.getInstance();
      await session.saveUserSession(
        userId: userId,
        name: name,
        email: userEmail,
        phone: phone,
        deviceToken: deviceToken,
        deviceType: deviceType,
        profilePicture: data['profile_pic'],
      );

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'OTP verification failed')),
      );
    }
  }

  Widget _buildOtpRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        6,
        (index) => SizedBox(
          width: 42,
          height: 50,
          child: TextField(
            controller: otpControllers[index],
            focusNode: otpFocusNodes[index],
            maxLength: 1,
            keyboardType: TextInputType.number,
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
                borderSide: BorderSide(
                  color: otpFocusNodes[index].hasFocus
                      ? const Color(0xFF38BDF8)
                      : const Color(0xFF1F2937),
                  width: 1.4,
                ),
              ),
              filled: true,
              fillColor: const Color(0xFF111827),
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
            ),
            onChanged: (value) => _onOtpChanged(index, value),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF020617);
    const fieldColor = Color(0xFF020617);
    const circleColor = Color(0xFF0EA5E9);
    final stepText = otpFieldVisible ? 'Step 2 of 2' : 'Step 1 of 2';

    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      stepText,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 13,
                      ),
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
                        // ... rest of your build method stays exactly same
                        Center(
                          child: Column(
                            children: const [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: circleColor,
                                child: Icon(Icons.person, color: Colors.white, size: 26),
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
                                'Welcome back to DobYob',
                                style: TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 12,
                                ),
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
                          readOnly: otpFieldVisible,
                          enableInteractiveSelection: !otpFieldVisible,
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
                              borderSide: const BorderSide(
                                color: Color(0xFF38BDF8),
                                width: 1.5,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        if (otpFieldVisible) ...[
                          const Text(
                            'OTP',
                            style: TextStyle(
                              color: Color(0xFFD1D5DB),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _buildOtpRow(),
                          const SizedBox(height: 4),
                          const Text(
                            'Enter the 6‑digit code sent to your email.',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 14),
                        ] else ...[
                          const SizedBox(height: 4),
                        ],
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
                            onPressed: isLoading
                                ? null
                                : (otpFieldVisible ? _verifyOtp : _sendOtp),
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    otpFieldVisible ? "Verify OTP" : "Send OTP",
                                    style: const TextStyle(
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
                              onPressed: () {
                                Navigator.pushReplacementNamed(context, '/signup');
                              },
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
                        if (!otpFieldVisible) ...[
                          const Center(
                            child: Text(
                              'Or Sign in with',
                              style: TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const SocialButtons(),
                          const SizedBox(height: 12),
                        ],
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
