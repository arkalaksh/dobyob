import 'package:dobyob_1/screens/dobyob_session_manager.dart';
import 'package:flutter/material.dart';
import 'package:dobyob_1/services/api_service.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final String fullName;
  final String dateOfBirth;
  final String phone;
  final String deviceToken;
  final String deviceType;

  const OtpScreen({
    super.key,
    required this.email,
    required this.fullName,
    required this.dateOfBirth,
    required this.phone,
    required this.deviceToken,
    required this.deviceType,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (index) => FocusNode());

  final ApiService apiService = ApiService();

  void _onOtpChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  Future<void> _confirmOtp() async {
    String otp = _controllers.map((c) => c.text).join();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter 6 digit OTP")),
      );
      return;
    }

    final response = await apiService.verifyRegistrationOtp(
      email: widget.email,
      otp: otp,
      fullName: widget.fullName,
      dateOfBirth: widget.dateOfBirth,
      phone: widget.phone,
      deviceToken: widget.deviceToken,
      deviceType: widget.deviceType,
    );

    if (response['success'] == true) {
      // Backend कडून user data
      final data = response['user'] ?? response;
      final int userId = int.parse(data['user_id'].toString());
      final String name = data['full_name'] ?? widget.fullName;
      final String email = data['email'] ?? widget.email;
      final String phone = data['phone'] ?? widget.phone;
      const String deviceToken = '';
      const String deviceType = 'android';

      final session = await DobYobSessionManager.getInstance();
      await session.saveUserSession(
        userId: userId,
        name: name,
        email: email,
        phone: phone,
        deviceToken: deviceToken,
        deviceType: deviceType,
        profilePicture: data['profile_pic'],
      );

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Invalid OTP')),
      );
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Widget _buildOtpBox(int index) {
    bool isFocused = _focusNodes[index].hasFocus;
    return SizedBox(
      width: 44,
      height: 54,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF020617),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: isFocused
                ? const Color(0xFF0EA5E9)
                : const Color(0xFF1F2937),
            width: isFocused ? 2.0 : 1.3,
          ),
        ),
        child: Center(
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            maxLength: 1,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
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
    const circleColor = Color(0xFF0EA5E9);

    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Center(
                    child: Column(
                      children: const [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: circleColor,
                          child: Icon(Icons.verified_user,
                              color: Colors.white, size: 26),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Verify Account',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Enter the 6‑digit code sent to your email',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, _buildOtpBox),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Didn't get the code? ",
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFFD1D5DB),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: resend OTP
                        },
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: const Text(
                          'Resend now',
                          style: TextStyle(
                            color: Color(0xFF0EA5E9),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: circleColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _confirmOtp,
                      child: const Text(
                        'Confirm OTP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
